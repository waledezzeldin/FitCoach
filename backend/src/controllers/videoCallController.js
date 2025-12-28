const videoCallService = require('../services/videoCallService');
const logger = require('../utils/logger');
const db = require('../database');

/**
 * Video Call Controller
 * Handles video call endpoints
 */

/**
 * Start video call (create session and get token)
 */
exports.startCall = async (req, res) => {
  try {
    const { appointmentId } = req.params;
    const userId = req.user.userId;

    // Check if user can join
    const canJoin = await videoCallService.canJoinCall(appointmentId, userId);
    
    if (!canJoin.canJoin) {
      return res.status(403).json({
        success: false,
        message: canJoin.reason,
        scheduledAt: canJoin.scheduledAt,
        canJoinAt: canJoin.canJoinAt
      });
    }

    // Create call session
    const callData = await videoCallService.createCallSession(appointmentId, userId);

    // Determine which token to send based on user
    const isCoach = callData.appointment.coach_user_id === userId;
    const userToken = isCoach ? callData.tokens.coach : callData.tokens.user;
    const otherParty = isCoach ? callData.tokens.user : callData.tokens.coach;

    res.json({
      success: true,
      call: {
        sessionId: callData.session.id,
        appointmentId,
        token: userToken.token,
        appId: callData.appId,
        channelName: callData.channelName,
        uid: userToken.uid,
        role: isCoach ? 'coach' : 'user',
        userName: userToken.name,
        otherPartyName: otherParty.name
      }
    });

    logger.info(`Video call started for appointment ${appointmentId} by user ${userId}`);

  } catch (error) {
    logger.error('Start call error:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to start video call'
    });
  }
};

/**
 * Get call token (join existing call)
 */
exports.getToken = async (req, res) => {
  try {
    const { appointmentId } = req.params;
    const userId = req.user.userId;

    const tokenData = await videoCallService.getCallToken(appointmentId, userId);

    res.json({
      success: true,
      call: tokenData
    });

  } catch (error) {
    logger.error('Get call token error:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to get call token'
    });
  }
};

/**
 * End video call
 */
exports.endCall = async (req, res) => {
  try {
    const { appointmentId } = req.params;
    const userId = req.user.userId;
    const { duration } = req.body;

    const result = await videoCallService.endCallSession(appointmentId, userId, duration);

    res.json({
      success: true,
      message: 'Call ended successfully',
      ...result
    });

    logger.info(`Video call ended for appointment ${appointmentId}`);

  } catch (error) {
    logger.error('End call error:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to end call'
    });
  }
};

/**
 * Check if can join call
 */
exports.canJoin = async (req, res) => {
  try {
    const { appointmentId } = req.params;
    const userId = req.user.userId;

    const result = await videoCallService.canJoinCall(appointmentId, userId);

    res.json({
      success: true,
      ...result
    });

  } catch (error) {
    logger.error('Can join call error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to check join status'
    });
  }
};

/**
 * Get call status
 */
exports.getCallStatus = async (req, res) => {
  try {
    const { appointmentId } = req.params;
    const userId = req.user.userId;

    const result = await db.query(
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

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Call session not found'
      });
    }

    const session = result.rows[0];

    // Verify authorization
    if (session.user_id !== userId && session.coach_user_id !== userId) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized'
      });
    }

    res.json({
      success: true,
      session: {
        id: session.id,
        status: session.status,
        channelName: session.channel_name,
        startedAt: session.started_at,
        endedAt: session.ended_at,
        duration: session.duration_minutes
      }
    });

  } catch (error) {
    logger.error('Get call status error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get call status'
    });
  }
};

module.exports = exports;
