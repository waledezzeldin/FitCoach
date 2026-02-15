const db = require('../database');
const logger = require('../utils/logger');
const { v4: uuidv4 } = require('uuid');
const pushNotificationService = require('../services/pushNotificationService');

const resolveCoachRecord = async (coachRef) => {
  if (!coachRef) return null;
  const result = await db.query(
    'SELECT * FROM coaches WHERE id = $1 OR user_id = $1',
    [coachRef]
  );
  return result.rows[0] || null;
};

const resolveAssignedCoach = async (userId) => {
  const result = await db.query(
    'SELECT assigned_coach_id FROM users WHERE id = $1',
    [userId]
  );
  if (result.rows.length === 0) return null;
  const assignedCoachUserId = result.rows[0].assigned_coach_id;
  if (!assignedCoachUserId) return null;
  return resolveCoachRecord(assignedCoachUserId);
};

const buildScheduledAt = (scheduledDate, scheduledTime) => {
  if (!scheduledDate || !scheduledTime) return null;
  return new Date(`${scheduledDate}T${scheduledTime}:00`);
};

exports.getUserBookings = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { status } = req.query;

    let coachRecord = null;
    if (req.user.role === 'coach') {
      coachRecord = await resolveCoachRecord(userId);
    }

    const params = [userId];
    let query = `
      SELECT 
        b.*, 
        u.full_name as user_name,
        cu.full_name as coach_name
      FROM video_call_bookings b
      JOIN users u ON b.user_id = u.id
      JOIN coaches c ON b.coach_id = c.id
      JOIN users cu ON c.user_id = cu.id
      WHERE 1=1
    `;

    if (req.user.role === 'coach' && coachRecord) {
      query += ' AND b.coach_id = $2';
      params.push(coachRecord.id);
    } else {
      query += ' AND b.user_id = $1';
    }

    if (status) {
      query += ` AND b.status = $${params.length + 1}`;
      params.push(status);
    }

    query += ' ORDER BY b.scheduled_date DESC, b.scheduled_time DESC';

    const result = await db.query(query, params);

    res.json({
      success: true,
      bookings: result.rows
    });
  } catch (error) {
    logger.error('Get user bookings error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get bookings'
    });
  }
};

exports.getAvailableSlots = async (req, res) => {
  try {
    const { startDate, endDate, coachId } = req.query;
    const rangeStart = startDate ? new Date(startDate) : new Date();
    const rangeEnd = endDate ? new Date(endDate) : new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);

    const coachRecord = coachId
      ? await resolveCoachRecord(coachId)
      : await resolveAssignedCoach(req.user.userId);

    if (!coachRecord) {
      return res.status(404).json({
        success: false,
        message: 'Coach not found'
      });
    }

    const appointmentsResult = await db.query(
      `SELECT scheduled_at, duration_minutes
       FROM appointments
       WHERE coach_id = $1
         AND scheduled_at BETWEEN $2 AND $3
         AND status IN ('scheduled', 'confirmed', 'in_progress')`,
      [coachRecord.id, rangeStart.toISOString(), rangeEnd.toISOString()]
    );

    const busy = appointmentsResult.rows.map((row) => ({
      start: new Date(row.scheduled_at),
      end: new Date(new Date(row.scheduled_at).getTime() + (row.duration_minutes || 30) * 60000)
    }));

    const slots = [];
    for (let d = new Date(rangeStart); d <= rangeEnd; d.setDate(d.getDate() + 1)) {
      const dateStr = d.toISOString().split('T')[0];
      const times = [];
      for (let hour = 9; hour <= 18; hour++) {
        const slotStart = new Date(`${dateStr}T${String(hour).padStart(2, '0')}:00:00`);
        const slotEnd = new Date(slotStart.getTime() + 60 * 60000);
        const overlaps = busy.some((b) => slotStart < b.end && slotEnd > b.start);
        if (!overlaps) {
          times.push(`${String(hour).padStart(2, '0')}:00`);
        }
      }
      slots.push({ date: dateStr, times });
    }

    res.json({
      success: true,
      slots
    });
  } catch (error) {
    logger.error('Get available slots error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to load available slots'
    });
  }
};

exports.createBooking = async (req, res) => {
  const client = await db.getClient();

  try {
    const userId = req.user.userId;
    const {
      scheduledDate,
      scheduledTime,
      scheduledAt,
      durationMinutes,
      notes,
      coachId
    } = req.body;

    const scheduledDateValue = scheduledAt ? new Date(scheduledAt).toISOString().split('T')[0] : scheduledDate;
    const scheduledTimeValue = scheduledAt ? new Date(scheduledAt).toISOString().split('T')[1]?.slice(0, 5) : scheduledTime;
    const scheduledAtValue = scheduledAt ? new Date(scheduledAt) : buildScheduledAt(scheduledDateValue, scheduledTimeValue);

    if (!scheduledAtValue || !scheduledDateValue || !scheduledTimeValue) {
      return res.status(400).json({
        success: false,
        message: 'scheduledDate and scheduledTime are required'
      });
    }

    const coachRecord = coachId
      ? await resolveCoachRecord(coachId)
      : await resolveAssignedCoach(userId);

    if (!coachRecord) {
      return res.status(404).json({
        success: false,
        message: 'Coach not found'
      });
    }

    await client.query('BEGIN');

    const conflictResult = await client.query(
      `SELECT 1 FROM appointments
       WHERE coach_id = $1
         AND status IN ('scheduled', 'confirmed', 'in_progress')
         AND scheduled_at < $2::timestamp + ($3::int || 60) * INTERVAL '1 minute'
         AND scheduled_at + (duration_minutes || 30) * INTERVAL '1 minute' > $2::timestamp
       LIMIT 1`,
      [coachRecord.id, scheduledAtValue.toISOString(), durationMinutes || 60]
    );

    if (conflictResult.rows.length > 0) {
      await client.query('ROLLBACK');
      return res.status(409).json({
        success: false,
        message: 'Selected time slot is no longer available'
      });
    }

    const appointmentResult = await client.query(
      `INSERT INTO appointments (
        id, coach_id, user_id, scheduled_at, duration_minutes, type, notes, status, created_at, updated_at
      ) VALUES ($1, $2, $3, $4, $5, 'video', $6, 'confirmed', NOW(), NOW())
      RETURNING *`,
      [uuidv4(), coachRecord.id, userId, scheduledAtValue, durationMinutes || 60, notes || null]
    );

    const appointment = appointmentResult.rows[0];

    const bookingResult = await client.query(
      `INSERT INTO video_call_bookings (
        id, user_id, coach_id, scheduled_date, scheduled_time, duration_minutes, status,
        notes, meeting_id, created_at, updated_at
      ) VALUES ($1, $2, $3, $4, $5, $6, 'confirmed', $7, $8, NOW(), NOW())
      RETURNING *`,
      [
        uuidv4(),
        userId,
        coachRecord.id,
        scheduledDateValue,
        scheduledTimeValue,
        durationMinutes || 60,
        notes || null,
        appointment.id
      ]
    );

    await client.query('COMMIT');

    const scheduledLabel = `${scheduledDateValue} ${scheduledTimeValue}`;
    pushNotificationService.sendBookingConfirmedNotification(userId, scheduledLabel).catch(() => {});
    pushNotificationService.sendBookingConfirmedNotification(coachRecord.user_id, scheduledLabel).catch(() => {});

    res.status(201).json({
      success: true,
      booking: bookingResult.rows[0],
      appointment
    });
  } catch (error) {
    await client.query('ROLLBACK');
    logger.error('Create booking error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create booking'
    });
  } finally {
    client.release();
  }
};

exports.updateBooking = async (req, res) => {
  const client = await db.getClient();

  try {
    const { id } = req.params;
    const { scheduledDate, scheduledTime, durationMinutes, notes } = req.body;

    await client.query('BEGIN');

    const bookingResult = await client.query(
      'SELECT * FROM video_call_bookings WHERE id = $1',
      [id]
    );

    if (bookingResult.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({
        success: false,
        message: 'Booking not found'
      });
    }

    const booking = bookingResult.rows[0];
    const scheduledAtValue = buildScheduledAt(scheduledDate || booking.scheduled_date, scheduledTime || booking.scheduled_time);

    const updateResult = await client.query(
      `UPDATE video_call_bookings
       SET scheduled_date = COALESCE($1, scheduled_date),
           scheduled_time = COALESCE($2, scheduled_time),
           duration_minutes = COALESCE($3, duration_minutes),
           notes = COALESCE($4, notes),
           updated_at = NOW()
       WHERE id = $5
       RETURNING *`,
      [scheduledDate || null, scheduledTime || null, durationMinutes || null, notes || null, id]
    );

    if (booking.meeting_id) {
      await client.query(
        `UPDATE appointments
         SET scheduled_at = COALESCE($1, scheduled_at),
             duration_minutes = COALESCE($2, duration_minutes),
             notes = COALESCE($3, notes),
             updated_at = NOW()
         WHERE id = $4`,
        [scheduledAtValue, durationMinutes || null, notes || null, booking.meeting_id]
      );
    }

    await client.query('COMMIT');

    const scheduledLabel = `${updateResult.rows[0].scheduled_date} ${updateResult.rows[0].scheduled_time}`;
    const coachRecord = await resolveCoachRecord(booking.coach_id);
    pushNotificationService.sendBookingUpdatedNotification(booking.user_id, scheduledLabel).catch(() => {});
    if (coachRecord?.user_id) {
      pushNotificationService.sendBookingUpdatedNotification(coachRecord.user_id, scheduledLabel).catch(() => {});
    }

    res.json({
      success: true,
      booking: updateResult.rows[0]
    });
  } catch (error) {
    await client.query('ROLLBACK');
    logger.error('Update booking error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update booking'
    });
  } finally {
    client.release();
  }
};

exports.cancelBooking = async (req, res) => {
  const client = await db.getClient();

  try {
    const { id } = req.params;
    const { reason } = req.body;

    await client.query('BEGIN');

    const bookingResult = await client.query(
      'SELECT * FROM video_call_bookings WHERE id = $1',
      [id]
    );

    if (bookingResult.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({
        success: false,
        message: 'Booking not found'
      });
    }

    const booking = bookingResult.rows[0];

    await client.query(
      `UPDATE video_call_bookings
       SET status = 'cancelled',
           cancelled_by = $1,
           cancellation_reason = $2,
           cancelled_at = NOW(),
           updated_at = NOW()
       WHERE id = $3`,
      [req.user.userId, reason || null, id]
    );

    if (booking.meeting_id) {
      await client.query(
        `UPDATE appointments
         SET status = 'cancelled', updated_at = NOW()
         WHERE id = $1`,
        [booking.meeting_id]
      );
    }

    await client.query('COMMIT');

    const scheduledLabel = `${booking.scheduled_date} ${booking.scheduled_time}`;
    const coachRecord = await resolveCoachRecord(booking.coach_id);
    pushNotificationService.sendBookingCancelledNotification(booking.user_id, scheduledLabel).catch(() => {});
    if (coachRecord?.user_id) {
      pushNotificationService.sendBookingCancelledNotification(coachRecord.user_id, scheduledLabel).catch(() => {});
    }

    res.json({
      success: true,
      message: 'Booking cancelled'
    });
  } catch (error) {
    await client.query('ROLLBACK');
    logger.error('Cancel booking error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to cancel booking'
    });
  } finally {
    client.release();
  }
};
