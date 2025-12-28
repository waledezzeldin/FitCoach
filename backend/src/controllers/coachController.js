const db = require('../database');
const logger = require('../utils/logger');
const PDFDocument = require('pdfkit');

/**
 * Generate client report
 */
exports.generateClientReport = async (req, res) => {
  try {
    const { id: coachId } = req.params;
    const { clientId } = req.params;
    const { reportType = 'comprehensive', startDate, endDate } = req.query;

    // Verify coach owns this client
    const clientCheck = await db.query(
      'SELECT * FROM user_coaches WHERE coach_id = $1 AND user_id = $2',
      [coachId, clientId]
    );

    if (clientCheck.rows.length === 0) {
      return res.status(403).json({ error: 'Client not assigned to this coach' });
    }

    // Get client info
    const clientResult = await db.query(
      `SELECT u.*, up.* 
       FROM users u
       LEFT JOIN user_profiles up ON u.id = up.user_id
       WHERE u.id = $1`,
      [clientId]
    );

    if (clientResult.rows.length === 0) {
      return res.status(404).json({ error: 'Client not found' });
    }

    const client = clientResult.rows[0];

    // Get report data based on type
    let reportData = {
      client,
      generatedAt: new Date(),
      reportType,
      period: { startDate, endDate }
    };

    // Get progress data
    if (['progress', 'comprehensive'].includes(reportType)) {
      const progressQuery = `
        SELECT * FROM progress_tracking
        WHERE user_id = $1
        ${startDate ? 'AND created_at >= $2' : ''}
        ${endDate ? 'AND created_at <= $3' : ''}
        ORDER BY created_at DESC
      `;
      const progressParams = [clientId];
      if (startDate) progressParams.push(startDate);
      if (endDate) progressParams.push(endDate);
      
      const progress = await db.query(progressQuery, progressParams);
      reportData.progress = progress.rows;
    }

    // Get workout data
    if (['workout', 'comprehensive'].includes(reportType)) {
      const workoutQuery = `
        SELECT w.*, wl.completed_at, wl.duration_minutes
        FROM workouts w
        LEFT JOIN workout_logs wl ON w.id = wl.workout_id
        WHERE w.user_id = $1
        ${startDate ? 'AND w.created_at >= $2' : ''}
        ${endDate ? 'AND w.created_at <= $3' : ''}
        ORDER BY w.created_at DESC
      `;
      const workoutParams = [clientId];
      if (startDate) workoutParams.push(startDate);
      if (endDate) workoutParams.push(endDate);
      
      const workouts = await db.query(workoutQuery, workoutParams);
      reportData.workouts = workouts.rows;
      
      // Calculate workout stats
      const completedWorkouts = workouts.rows.filter(w => w.completed_at);
      reportData.workoutStats = {
        total: workouts.rows.length,
        completed: completedWorkouts.length,
        completionRate: workouts.rows.length > 0 
          ? (completedWorkouts.length / workouts.rows.length * 100).toFixed(1)
          : 0,
        totalMinutes: completedWorkouts.reduce((sum, w) => sum + (w.duration_minutes || 0), 0)
      };
    }

    // Get nutrition data
    if (['nutrition', 'comprehensive'].includes(reportType)) {
      const nutritionQuery = `
        SELECT * FROM nutrition_logs
        WHERE user_id = $1
        ${startDate ? 'AND log_date >= $2' : ''}
        ${endDate ? 'AND log_date <= $3' : ''}
        ORDER BY log_date DESC
      `;
      const nutritionParams = [clientId];
      if (startDate) nutritionParams.push(startDate);
      if (endDate) nutritionParams.push(endDate);
      
      const nutrition = await db.query(nutritionQuery, nutritionParams);
      reportData.nutrition = nutrition.rows;
      
      // Calculate nutrition stats
      const totalCalories = nutrition.rows.reduce((sum, n) => sum + (n.calories || 0), 0);
      const avgCalories = nutrition.rows.length > 0 ? totalCalories / nutrition.rows.length : 0;
      reportData.nutritionStats = {
        totalLogs: nutrition.rows.length,
        avgCalories: avgCalories.toFixed(0),
        totalProtein: nutrition.rows.reduce((sum, n) => sum + (n.protein || 0), 0),
        totalCarbs: nutrition.rows.reduce((sum, n) => sum + (n.carbs || 0), 0),
        totalFat: nutrition.rows.reduce((sum, n) => sum + (n.fat || 0), 0)
      };
    }

    res.json(reportData);
  } catch (error) {
    logger.error('Error generating client report:', error);
    res.status(500).json({ error: 'Failed to generate report' });
  }
};

/**
 * Get all coaches (public)
 */
exports.getAllCoaches = async (req, res) => {
  try {
    const { limit = 20, offset = 0, specialization, available } = req.query;
    
    let query = `
      SELECT 
        c.*,
        u.full_name,
        u.full_name_ar,
        u.profile_photo_url,
        u.email,
        COUNT(DISTINCT uc.user_id) as client_count
      FROM coaches c
      JOIN users u ON c.user_id = u.id
      LEFT JOIN user_coaches uc ON c.user_id = uc.coach_id
      WHERE c.is_approved = TRUE
        AND c.is_active = TRUE
    `;
    
    const params = [];
    let paramCount = 1;
    
    if (specialization) {
      query += ` AND $${paramCount} = ANY(c.specializations)`;
      params.push(specialization);
      paramCount++;
    }
    
    if (available !== undefined) {
      query += ` AND c.is_available = $${paramCount}`;
      params.push(available === 'true');
      paramCount++;
    }
    
    query += `
      GROUP BY c.id, u.id
      ORDER BY c.average_rating DESC NULLS LAST
      LIMIT $${paramCount} OFFSET $${paramCount + 1}
    `;
    
    params.push(parseInt(limit), parseInt(offset));
    
    const result = await db.query(query, params);
    
    res.json({
      success: true,
      coaches: result.rows,
      total: result.rowCount
    });
    
  } catch (error) {
    logger.error('Get all coaches error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get coaches'
    });
  }
};

/**
 * Get coach by ID (public)
 */
exports.getCoachById = async (req, res) => {
  try {
    const { id } = req.params;
    
    const result = await db.query(
      `SELECT 
        c.*,
        u.full_name,
        u.full_name_ar,
        u.profile_photo_url,
        u.email,
        COUNT(DISTINCT uc.user_id) as client_count
       FROM coaches c
       JOIN users u ON c.user_id = u.id
       LEFT JOIN user_coaches uc ON c.user_id = uc.coach_id
       WHERE c.user_id = $1
       GROUP BY c.id, u.id`,
      [id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Coach not found'
      });
    }
    
    res.json({
      success: true,
      coach: result.rows[0]
    });
    
  } catch (error) {
    logger.error('Get coach by ID error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get coach'
    });
  }
};

/**
 * Get coach's clients (coach/admin only)
 */
exports.getCoachClients = async (req, res) => {
  try {
    const coachId = req.params.id;
    const { status, search, limit = 50, offset = 0 } = req.query;
    
    // Check authorization
    if (req.user.userId !== coachId && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Unauthorized'
      });
    }
    
    let query = `
      SELECT 
        u.*,
        uc.assigned_date,
        uc.is_active as coach_assignment_active,
        wp.id as workout_plan_id,
        wp.name as workout_plan_name,
        np.id as nutrition_plan_id,
        np.name as nutrition_plan_name,
        (
          SELECT COUNT(*) 
          FROM messages m 
          WHERE (m.sender_id = u.id AND m.receiver_id = $1)
             OR (m.sender_id = $1 AND m.receiver_id = u.id)
        ) as message_count
      FROM users u
      JOIN user_coaches uc ON u.id = uc.user_id
      LEFT JOIN workout_plans wp ON u.id = wp.user_id AND wp.is_active = TRUE
      LEFT JOIN nutrition_plans np ON u.id = np.user_id AND np.is_active = TRUE
      WHERE uc.coach_id = $1
    `;
    
    const params = [coachId];
    let paramCount = 2;
    
    if (status) {
      query += ` AND u.is_active = $${paramCount}`;
      params.push(status === 'active');
      paramCount++;
    }
    
    if (search) {
      query += ` AND (u.full_name ILIKE $${paramCount} OR u.email ILIKE $${paramCount})`;
      params.push(`%${search}%`);
      paramCount++;
    }
    
    query += `
      ORDER BY uc.assigned_date DESC
      LIMIT $${paramCount} OFFSET $${paramCount + 1}
    `;
    
    params.push(parseInt(limit), parseInt(offset));
    
    const result = await db.query(query, params);
    
    // Remove sensitive data
    const clients = result.rows.map(client => {
      delete client.password_hash;
      return client;
    });
    
    res.json({
      success: true,
      clients,
      total: clients.length
    });
    
  } catch (error) {
    logger.error('Get coach clients error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get clients'
    });
  }
};

/**
 * Get coach's appointments
 */
exports.getCoachAppointments = async (req, res) => {
  try {
    const coachId = req.params.id;
    const { status, startDate, endDate, limit = 50, offset = 0 } = req.query;
    
    // Check authorization
    if (req.user.userId !== coachId && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Unauthorized'
      });
    }
    
    let query = `
      SELECT 
        a.*,
        u.full_name as client_name,
        u.profile_photo_url as client_photo
      FROM appointments a
      JOIN users u ON a.user_id = u.id
      WHERE a.coach_id = $1
    `;
    
    const params = [coachId];
    let paramCount = 2;
    
    if (status) {
      query += ` AND a.status = $${paramCount}`;
      params.push(status);
      paramCount++;
    }
    
    if (startDate) {
      query += ` AND a.scheduled_at >= $${paramCount}`;
      params.push(startDate);
      paramCount++;
    }
    
    if (endDate) {
      query += ` AND a.scheduled_at <= $${paramCount}`;
      params.push(endDate);
      paramCount++;
    }
    
    query += `
      ORDER BY a.scheduled_at ASC
      LIMIT $${paramCount} OFFSET $${paramCount + 1}
    `;
    
    params.push(parseInt(limit), parseInt(offset));
    
    const result = await db.query(query, params);
    
    res.json({
      success: true,
      appointments: result.rows,
      total: result.rowCount
    });
    
  } catch (error) {
    logger.error('Get coach appointments error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get appointments'
    });
  }
};

/**
 * Create appointment
 */
exports.createAppointment = async (req, res) => {
  try {
    const coachId = req.params.id;
    const { userId, scheduledAt, duration, type, notes } = req.body;
    
    // Check authorization
    if (req.user.userId !== coachId && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Unauthorized'
      });
    }
    
    // Check if user is client of this coach
    const clientCheck = await db.query(
      'SELECT id FROM user_coaches WHERE user_id = $1 AND coach_id = $2',
      [userId, coachId]
    );
    
    if (clientCheck.rows.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'User is not a client of this coach'
      });
    }
    
    const result = await db.query(
      `INSERT INTO appointments (
        coach_id,
        user_id,
        scheduled_at,
        duration_minutes,
        type,
        notes,
        status
      ) VALUES ($1, $2, $3, $4, $5, $6, 'scheduled')
      RETURNING *`,
      [coachId, userId, scheduledAt, duration, type, notes]
    );
    
    res.status(201).json({
      success: true,
      message: 'Appointment created successfully',
      appointment: result.rows[0]
    });
    
    logger.info(`Appointment created: ${result.rows[0].id}`);
    
  } catch (error) {
    logger.error('Create appointment error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create appointment'
    });
  }
};

/**
 * Update appointment status
 */
exports.updateAppointment = async (req, res) => {
  const client = await db.getClient();

  try {
    const { id: coachId, appointmentId } = req.params;
    const { status, notes } = req.body;

    // Check authorization
    if (req.user.role !== 'admin') {
      const coachResult = await client.query(
        'SELECT user_id FROM coaches WHERE id = $1',
        [coachId]
      );

      if (coachResult.rows.length === 0 || coachResult.rows[0].user_id !== req.user.userId) {
        return res.status(403).json({
          success: false,
          message: 'Unauthorized'
        });
      }
    }

    await client.query('BEGIN');

    // Get appointment details
    const appointmentResult = await client.query(
      `SELECT a.*, u.id as user_id, u.full_name as user_name, c.user_id as coach_user_id
       FROM appointments a
       JOIN users u ON a.user_id = u.id
       JOIN coaches c ON a.coach_id = c.id
       WHERE a.id = $1 AND a.coach_id = $2`,
      [appointmentId, coachId]
    );

    if (appointmentResult.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({
        success: false,
        message: 'Appointment not found'
      });
    }

    const appointment = appointmentResult.rows[0];

    // Update appointment
    const updateResult = await client.query(
      `UPDATE appointments
       SET status = $1,
           notes = COALESCE($2, notes),
           updated_at = NOW()
       WHERE id = $3
       RETURNING *`,
      [status, notes, appointmentId]
    );

    // Create notifications based on status
    if (status === 'confirmed') {
      // Notify user that appointment is confirmed
      await client.query(
        `INSERT INTO notifications (
          id, user_id, type, title, title_ar, message, message_ar,
          data, created_at
        ) VALUES ($1, $2, 'appointment_confirmed', $3, $4, $5, $6, $7, NOW())`,
        [
          require('uuid').v4(),
          appointment.user_id,
          'Appointment Confirmed',
          'تم تأكيد الموعد',
          `Your video call appointment has been confirmed for ${new Date(appointment.scheduled_at).toLocaleString()}`,
          `تم تأكيد موعد مكالمة الفيديو الخاصة بك في ${new Date(appointment.scheduled_at).toLocaleString()}`,
          JSON.stringify({ appointmentId, coachId, scheduledAt: appointment.scheduled_at })
        ]
      );

      // Notify coach
      await client.query(
        `INSERT INTO notifications (
          id, user_id, type, title, title_ar, message, message_ar,
          data, created_at
        ) VALUES ($1, $2, 'appointment_confirmed', $3, $4, $5, $6, $7, NOW())`,
        [
          require('uuid').v4(),
          appointment.coach_user_id,
          'Appointment Confirmed',
          'تم تأكيد الموعد',
          `Appointment with ${appointment.user_name} confirmed for ${new Date(appointment.scheduled_at).toLocaleString()}`,
          `تم تأكيد الموعد مع ${appointment.user_name} في ${new Date(appointment.scheduled_at).toLocaleString()}`,
          JSON.stringify({ appointmentId, userId: appointment.user_id, scheduledAt: appointment.scheduled_at })
        ]
      );
    }

    if (status === 'cancelled') {
      // Notify user of cancellation
      await client.query(
        `INSERT INTO notifications (
          id, user_id, type, title, title_ar, message, message_ar,
          data, created_at
        ) VALUES ($1, $2, 'appointment_cancelled', $3, $4, $5, $6, $7, NOW())`,
        [
          require('uuid').v4(),
          appointment.user_id,
          'Appointment Cancelled',
          'تم إلغاء الموعد',
          'Your appointment has been cancelled',
          'تم إلغاء موعدك',
          JSON.stringify({ appointmentId, reason: notes })
        ]
      );
    }

    await client.query('COMMIT');
    client.release();

    res.json({
      success: true,
      message: 'Appointment updated successfully',
      appointment: updateResult.rows[0]
    });

    logger.info(`Appointment ${appointmentId} updated to ${status} by coach ${coachId}`);

  } catch (error) {
    await client.query('ROLLBACK');
    client.release();
    logger.error('Update appointment error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update appointment'
    });
  }
};

/**
 * Get coach earnings
 */
exports.getCoachEarnings = async (req, res) => {
  try {
    const coachId = req.params.id;
    const { startDate, endDate, period = 'month' } = req.query;
    
    // Check authorization
    if (req.user.userId !== coachId && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Unauthorized'
      });
    }
    
    // Get total earnings
    const totalResult = await db.query(
      `SELECT 
        COALESCE(SUM(amount), 0) as total_earnings,
        COALESCE(SUM(coach_commission), 0) as total_commission,
        COUNT(*) as total_transactions
       FROM coach_earnings
       WHERE coach_id = $1
       AND status = 'paid'`,
      [coachId]
    );
    
    // Get earnings by period
    let periodQuery = `
      SELECT 
        DATE_TRUNC($2, created_at) as period,
        SUM(coach_commission) as earnings,
        COUNT(*) as transactions
      FROM coach_earnings
      WHERE coach_id = $1
      AND status = 'paid'
    `;
    
    const params = [coachId, period];
    
    if (startDate) {
      periodQuery += ` AND created_at >= $3`;
      params.push(startDate);
    }
    
    if (endDate) {
      periodQuery += ` AND created_at <= $${params.length + 1}`;
      params.push(endDate);
    }
    
    periodQuery += ` GROUP BY period ORDER BY period DESC LIMIT 12`;
    
    const periodResult = await db.query(periodQuery, params);
    
    // Get recent transactions
    const transactionsResult = await db.query(
      `SELECT 
        ce.*,
        u.full_name as client_name
       FROM coach_earnings ce
       JOIN users u ON ce.user_id = u.id
       WHERE ce.coach_id = $1
       ORDER BY ce.created_at DESC
       LIMIT 20`,
      [coachId]
    );
    
    res.json({
      success: true,
      summary: totalResult.rows[0],
      periodBreakdown: periodResult.rows,
      recentTransactions: transactionsResult.rows
    });
    
  } catch (error) {
    logger.error('Get coach earnings error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get earnings'
    });
  }
};

/**
 * Assign fitness score to client
 */
exports.assignFitnessScore = async (req, res) => {
  try {
    const { clientId } = req.params;
    const { fitnessScore, notes } = req.body;
    const coachId = req.user.userId;
    
    // Validate score
    if (fitnessScore < 0 || fitnessScore > 100) {
      return res.status(400).json({
        success: false,
        message: 'Fitness score must be between 0 and 100'
      });
    }
    
    // Check if coach assigned to client
    const clientCheck = await db.query(
      'SELECT id FROM user_coaches WHERE user_id = $1 AND coach_id = $2',
      [clientId, coachId]
    );
    
    if (clientCheck.rows.length === 0) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to assign score to this client'
      });
    }
    
    // Update user fitness score
    const result = await db.query(
      `UPDATE users
       SET fitness_score = $1,
           fitness_score_updated_by = 'coach',
           fitness_score_last_updated = NOW(),
           updated_at = NOW()
       WHERE id = $2
       RETURNING id, full_name, fitness_score`,
      [fitnessScore, clientId]
    );
    
    // Log the score assignment
    await db.query(
      `INSERT INTO fitness_score_history (
        user_id,
        coach_id,
        score,
        notes,
        assigned_by
      ) VALUES ($1, $2, $3, $4, 'coach')`,
      [clientId, coachId, fitnessScore, notes]
    );
    
    res.json({
      success: true,
      message: 'Fitness score assigned successfully',
      user: result.rows[0]
    });
    
    logger.info(`Fitness score ${fitnessScore} assigned to user ${clientId} by coach ${coachId}`);
    
  } catch (error) {
    logger.error('Assign fitness score error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to assign fitness score'
    });
  }
};

/**
 * Get coach analytics/dashboard stats
 */
exports.getCoachAnalytics = async (req, res) => {
  try {
    const coachId = req.params.id;
    
    // Check authorization
    if (req.user.userId !== coachId && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Unauthorized'
      });
    }
    
    // Active clients
    const clientsResult = await db.query(
      `SELECT COUNT(*) as count
       FROM user_coaches
       WHERE coach_id = $1 AND is_active = TRUE`,
      [coachId]
    );
    
    // Upcoming appointments
    const appointmentsResult = await db.query(
      `SELECT COUNT(*) as count
       FROM appointments
       WHERE coach_id = $1 
       AND scheduled_at > NOW()
       AND status = 'scheduled'`,
      [coachId]
    );
    
    // Today's earnings
    const earningsResult = await db.query(
      `SELECT COALESCE(SUM(coach_commission), 0) as earnings
       FROM coach_earnings
       WHERE coach_id = $1
       AND DATE(created_at) = CURRENT_DATE
       AND status = 'paid'`,
      [coachId]
    );
    
    // Month's earnings
    const monthEarningsResult = await db.query(
      `SELECT COALESCE(SUM(coach_commission), 0) as earnings
       FROM coach_earnings
       WHERE coach_id = $1
       AND DATE_TRUNC('month', created_at) = DATE_TRUNC('month', CURRENT_DATE)
       AND status = 'paid'`,
      [coachId]
    );
    
    // Unread messages
    const messagesResult = await db.query(
      `SELECT COUNT(*) as count
       FROM messages
       WHERE receiver_id = $1
       AND is_read = FALSE`,
      [coachId]
    );
    
    res.json({
      success: true,
      analytics: {
        activeClients: parseInt(clientsResult.rows[0].count),
        upcomingAppointments: parseInt(appointmentsResult.rows[0].count),
        todayEarnings: parseFloat(earningsResult.rows[0].earnings),
        monthEarnings: parseFloat(monthEarningsResult.rows[0].earnings),
        unreadMessages: parseInt(messagesResult.rows[0].count)
      }
    });
    
  } catch (error) {
    logger.error('Get coach analytics error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get analytics'
    });
  }
};


/**
 * Get comprehensive coach profile (public)
 * Includes: bio, yearsOfExperience, specializations, isVerified, stats, certificates, experiences, achievements, contact, avatar
 */
exports.getCoachProfile = async (req, res) => {
  try {
    const { id } = req.params;
    // Get coach core info and user info
    const coachResult = await db.query(
      `SELECT c.*, u.full_name, u.full_name_ar, u.profile_photo_url, u.email, u.phone, u.bio, u.years_of_experience, u.is_verified, c.specializations
       FROM coaches c
       JOIN users u ON c.user_id = u.id
       WHERE c.user_id = $1`,
      [id]
    );
    if (coachResult.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Coach not found' });
    }
    const coach = coachResult.rows[0];

    // Get certificates
    const certificatesResult = await db.query(
      `SELECT * FROM coach_certificates WHERE coach_id = $1 ORDER BY date_obtained DESC`,
      [id]
    );
    // Get experiences
    const experiencesResult = await db.query(
      `SELECT * FROM coach_experiences WHERE coach_id = $1 ORDER BY start_date DESC`,
      [id]
    );
    // Get achievements
    const achievementsResult = await db.query(
      `SELECT * FROM coach_achievements WHERE coach_id = $1 ORDER BY date DESC`,
      [id]
    );
    // Get stats
    const statsResult = await db.query(
      `SELECT 
        (SELECT COUNT(DISTINCT user_id) FROM user_coaches WHERE coach_id = $1) as total_clients,
        (SELECT COUNT(*) FROM user_coaches WHERE coach_id = $1 AND is_active = TRUE) as active_clients,
        (SELECT COUNT(*) FROM appointments WHERE coach_id = $1) as completed_sessions,
        (SELECT AVG(rating) FROM coach_ratings WHERE coach_id = $1) as avg_rating,
        (SELECT COUNT(*) FROM coach_ratings WHERE coach_id = $1) as review_count,
        (SELECT COALESCE(SUM(coach_commission),0) FROM coach_earnings WHERE coach_id = $1) as total_revenue
      `,
      [id]
    );
    const stats = statsResult.rows[0];

    res.json({
      id: coach.user_id,
      name: coach.full_name,
      email: coach.email,
      phone: coach.phone,
      bio: coach.bio,
      yearsOfExperience: coach.years_of_experience,
      specializations: coach.specializations,
      isVerified: coach.is_verified,
      avatar: coach.profile_photo_url,
      stats: {
        totalClients: parseInt(stats.total_clients) || 0,
        activeClients: parseInt(stats.active_clients) || 0,
        completedSessions: parseInt(stats.completed_sessions) || 0,
        avgRating: parseFloat(stats.avg_rating) || 0,
        reviewCount: parseInt(stats.review_count) || 0,
        totalRevenue: parseFloat(stats.total_revenue) || 0
      },
      certificates: certificatesResult.rows,
      experiences: experiencesResult.rows,
      achievements: achievementsResult.rows
    });
  } catch (error) {
    logger.error('Get coach profile error:', error);
    res.status(500).json({ success: false, message: 'Failed to get coach profile' });
  }
};

module.exports = exports;
