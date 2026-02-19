const { RtcTokenBuilder, RtcRole } = require('agora-access-token');
const db = require('../database');
const logger = require('../utils/logger');
const { v4: uuidv4 } = require('uuid');
const { isBypassEnabled } = require('../utils/featureFlags');

/**
 * Video Call Service using Agora
 * Handles video call token generation and management
 */

class VideoCallService {
  
  constructor() {
    // Agora credentials from environment
    this.appId = process.env.AGORA_APP_ID;
    this.appCertificate = process.env.AGORA_APP_CERTIFICATE;
    this.bypassAgora = isBypassEnabled('BYPASS_AGORA');
    
    if (this.bypassAgora) {
      logger.warn('Agora bypass enabled. Video call tokens are mocked.');
    } else if (!this.appId || !this.appCertificate) {
      logger.warn('Agora credentials not configured. Video calls will not work.');
    }
  }

  /**
   * Generate Agora RTC token for video call
   */
  generateToken(channelName, uid, role = 'publisher', expirationTime = 3600) {
    try {
      if (this.bypassAgora) {
        const currentTimestamp = Math.floor(Date.now() / 1000);
        const privilegeExpiredTs = currentTimestamp + expirationTime;
        const tokenPayload = `${channelName}:${uid}:${role}:${privilegeExpiredTs}`;
        const token = Buffer.from(tokenPayload).toString('base64');

        return {
          token,
          appId: this.appId || 'bypass-agora-app-id',
          channelName,
          uid,
          expiresAt: new Date(privilegeExpiredTs * 1000),
          bypassed: true
        };
      }

      if (!this.appId || !this.appCertificate) {
        throw new Error('Agora credentials not configured');
      }

      // Convert role to Agora role
      const agoraRole = role === 'publisher' ? RtcRole.PUBLISHER : RtcRole.SUBSCRIBER;

      // Token expiration time (in seconds from now)
      const currentTimestamp = Math.floor(Date.now() / 1000);
      const privilegeExpiredTs = currentTimestamp + expirationTime;

      // Build token
      const token = RtcTokenBuilder.buildTokenWithUid(
        this.appId,
        this.appCertificate,
        channelName,
        uid,
        agoraRole,
        privilegeExpiredTs
      );

      return {
        token,
        appId: this.appId,
        channelName,
        uid,
        expiresAt: new Date(privilegeExpiredTs * 1000)
      };

    } catch (error) {
      logger.error('Generate Agora token error:', error);
      throw error;
    }
  }

  /**
   * Create video call session for appointment
   */
  async createCallSession(appointmentId, userId) {
    try {
      // Get appointment details
      const appointmentResult = await db.query(
        `SELECT 
          a.*,
          u.id as user_id,
          u.full_name as user_name,
          c.user_id as coach_user_id,
          cu.full_name as coach_name
         FROM appointments a
         JOIN users u ON a.user_id = u.id
         JOIN coaches c ON a.coach_id = c.id
         JOIN users cu ON c.user_id = cu.id
         WHERE a.id = $1`,
        [appointmentId]
      );

      if (appointmentResult.rows.length === 0) {
        throw new Error('Appointment not found');
      }

      const appointment = appointmentResult.rows[0];

      // Verify user is part of this appointment
      if (appointment.user_id !== userId && appointment.coach_user_id !== userId) {
        throw new Error('User not authorized for this call');
      }

      // Verify appointment is confirmed
      if (appointment.status !== 'confirmed' && appointment.status !== 'in_progress') {
        throw new Error('Appointment must be confirmed to start call');
      }

      // Check if call session already exists
      let sessionResult = await db.query(
        'SELECT * FROM video_call_sessions WHERE appointment_id = $1',
        [appointmentId]
      );

      let session;

      if (sessionResult.rows.length > 0) {
        // Use existing session
        session = sessionResult.rows[0];
      } else {
        // Create new session
        const channelName = `appointment_${appointmentId}_${Date.now()}`;
        
        const sessionInsert = await db.query(
          `INSERT INTO video_call_sessions (
            id, appointment_id, channel_name, status,
            started_at, created_at, updated_at
          ) VALUES ($1, $2, $3, 'active', NOW(), NOW(), NOW())
          RETURNING *`,
          [uuidv4(), appointmentId, channelName]
        );

        session = sessionInsert.rows[0];

        // Update appointment status to in_progress
        await db.query(
          `UPDATE appointments 
           SET status = 'in_progress', updated_at = NOW()
           WHERE id = $1`,
          [appointmentId]
        );
      }

      // Generate tokens for both user and coach
      const userUid = parseInt(appointment.user_id.replace(/-/g, '').substring(0, 8), 16);
      const coachUid = parseInt(appointment.coach_user_id.replace(/-/g, '').substring(0, 8), 16);

      const userToken = this.generateToken(session.channel_name, userUid, 'publisher');
      const coachToken = this.generateToken(session.channel_name, coachUid, 'publisher');

      return {
        session,
        appointment,
        tokens: {
          user: {
            token: userToken.token,
            uid: userUid,
            name: appointment.user_name
          },
          coach: {
            token: coachToken.token,
            uid: coachUid,
            name: appointment.coach_name
          }
        },
        appId: userToken.appId,
        channelName: session.channel_name
      };

    } catch (error) {
      logger.error('Create call session error:', error);
      throw error;
    }
  }

  /**
   * Get token for joining existing call
   */
  async getCallToken(appointmentId, userId) {
    try {
      // Get session
      const sessionResult = await db.query(
        `SELECT 
          vcs.*,
          a.user_id,
          a.coach_id,
          c.user_id as coach_user_id,
          u.full_name as user_name,
          cu.full_name as coach_name
         FROM video_call_sessions vcs
         JOIN appointments a ON vcs.appointment_id = a.id
         JOIN coaches c ON a.coach_id = c.id
         JOIN users u ON a.user_id = u.id
         JOIN users cu ON c.user_id = cu.id
         WHERE vcs.appointment_id = $1`,
        [appointmentId]
      );

      if (sessionResult.rows.length === 0) {
        throw new Error('Call session not found');
      }

      const session = sessionResult.rows[0];

      // Verify user is part of this call
      if (session.user_id !== userId && session.coach_user_id !== userId) {
        throw new Error('User not authorized for this call');
      }

      // Generate UID based on user ID
      const uid = parseInt(userId.replace(/-/g, '').substring(0, 8), 16);

      // Generate token
      const tokenData = this.generateToken(session.channel_name, uid, 'publisher');

      const isCoach = session.coach_user_id === userId;

      return {
        token: tokenData.token,
        appId: tokenData.appId,
        channelName: session.channel_name,
        uid,
        role: isCoach ? 'coach' : 'user',
        sessionId: session.id,
        appointment: {
          id: appointmentId,
          userName: session.user_name,
          coachName: session.coach_name
        }
      };

    } catch (error) {
      logger.error('Get call token error:', error);
      throw error;
    }
  }

  /**
   * End video call session
   */
  async endCallSession(appointmentId, userId, duration) {
    const client = await db.getClient();

    try {
      await client.query('BEGIN');

      // Get session and appointment
      const sessionResult = await client.query(
        `SELECT 
          vcs.*,
          a.user_id,
          a.coach_id,
          c.user_id as coach_user_id
         FROM video_call_sessions vcs
         JOIN appointments a ON vcs.appointment_id = a.id
         JOIN coaches c ON a.coach_id = c.id
         WHERE vcs.appointment_id = $1`,
        [appointmentId]
      );

      if (sessionResult.rows.length === 0) {
        await client.query('ROLLBACK');
        throw new Error('Call session not found');
      }

      const session = sessionResult.rows[0];

      // Verify user is part of this call
      if (session.user_id !== userId && session.coach_user_id !== userId) {
        await client.query('ROLLBACK');
        throw new Error('User not authorized to end this call');
      }

      if (session.status !== 'completed') {
        // Update session
        await client.query(
          `UPDATE video_call_sessions
           SET status = 'completed',
               ended_at = NOW(),
               duration_minutes = $1,
               updated_at = NOW()
           WHERE id = $2`,
          [duration || 0, session.id]
        );

        // Update appointment status
        await client.query(
          `UPDATE appointments
           SET status = 'completed',
               updated_at = NOW()
           WHERE id = $1`,
          [appointmentId]
        );

        // Increment video call count for user
        await client.query(
          `UPDATE users
           SET video_calls_this_month = video_calls_this_month + 1
           WHERE id = $1`,
          [session.user_id]
        );
      }

      await client.query('COMMIT');
      client.release();

      logger.info(`Video call ended for appointment ${appointmentId}, duration: ${duration} minutes`);

      return {
        success: true,
        duration: duration || session.duration_minutes || 0,
        appointmentId,
        alreadyCompleted: session.status === 'completed'
      };

    } catch (error) {
      await client.query('ROLLBACK');
      client.release();
      logger.error('End call session error:', error);
      throw error;
    }
  }

  /**
   * Check if user can join call (time-based)
   */
  async canJoinCall(appointmentId, userId) {
    try {
      const result = await db.query(
        `SELECT 
          a.*,
          c.user_id as coach_user_id
         FROM appointments a
         JOIN coaches c ON a.coach_id = c.id
         WHERE a.id = $1`,
        [appointmentId]
      );

      if (result.rows.length === 0) {
        return { canJoin: false, reason: 'Appointment not found' };
      }

      const appointment = result.rows[0];

      // Verify user
      if (appointment.user_id !== userId && appointment.coach_user_id !== userId) {
        return { canJoin: false, reason: 'Not authorized' };
      }

      // Check status
      if (appointment.status !== 'confirmed' && appointment.status !== 'in_progress') {
        return { canJoin: false, reason: `Appointment status is ${appointment.status}` };
      }

      // Check time (can join 10 minutes before scheduled time)
      const scheduledTime = new Date(appointment.scheduled_at);
      const now = new Date();
      const tenMinutesBefore = new Date(scheduledTime.getTime() - 10 * 60 * 1000);
      const durationMinutes = appointment.duration_minutes || 60;
      const fifteenMinutesAfter = new Date(
        scheduledTime.getTime() + (durationMinutes + 15) * 60 * 1000
      );

      if (now < tenMinutesBefore) {
        return { 
          canJoin: false, 
          reason: 'Too early to join',
          scheduledAt: scheduledTime,
          canJoinAt: tenMinutesBefore
        };
      }

      if (now > fifteenMinutesAfter) {
        return { 
          canJoin: false, 
          reason: 'Appointment time has passed' 
        };
      }

      return { 
        canJoin: true,
        appointment 
      };

    } catch (error) {
      logger.error('Can join call check error:', error);
      return { canJoin: false, reason: 'Error checking appointment' };
    }
  }
}

module.exports = new VideoCallService();
