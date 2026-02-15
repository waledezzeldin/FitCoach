const pushNotificationService = require('../services/pushNotificationService');
const db = require('../database');
const logger = require('../utils/logger');

/**
 * Notification Controller
 * Handles push notification registration and preferences
 */

/**
 * Register device for push notifications
 */
exports.registerDevice = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { deviceToken, deviceType, deviceInfo } = req.body;

    if (!deviceToken) {
      return res.status(400).json({
        success: false,
        message: 'Device token is required'
      });
    }

    if (!['ios', 'android', 'web'].includes(deviceType)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid device type'
      });
    }

    const result = await pushNotificationService.registerDevice(
      userId,
      deviceToken,
      deviceType,
      deviceInfo
    );

    res.json(result);

  } catch (error) {
    logger.error('Register device error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to register device'
    });
  }
};

/**
 * Unregister device
 */
exports.unregisterDevice = async (req, res) => {
  try {
    const { deviceToken } = req.body;

    if (!deviceToken) {
      return res.status(400).json({
        success: false,
        message: 'Device token is required'
      });
    }

    const result = await pushNotificationService.unregisterDevice(deviceToken);

    res.json(result);

  } catch (error) {
    logger.error('Unregister device error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to unregister device'
    });
  }
};

/**
 * Get notification preferences
 */
exports.getPreferences = async (req, res) => {
  try {
    const userId = req.user.userId;

    const result = await db.query(
      `SELECT * FROM notification_preferences WHERE user_id = $1`,
      [userId]
    );

    if (result.rows.length === 0) {
      // Create default preferences
      await db.query(
        `INSERT INTO notification_preferences (user_id) VALUES ($1)`,
        [userId]
      );

      const newPrefs = await db.query(
        `SELECT * FROM notification_preferences WHERE user_id = $1`,
        [userId]
      );

      return res.json({
        success: true,
        preferences: newPrefs.rows[0]
      });
    }

    res.json({
      success: true,
      preferences: result.rows[0]
    });

  } catch (error) {
    logger.error('Get notification preferences error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get preferences'
    });
  }
};

/**
 * Update notification preferences
 */
exports.updatePreferences = async (req, res) => {
  try {
    const userId = req.user.userId;
    const {
      messages_enabled,
      workout_reminders_enabled,
      booking_reminders_enabled,
      progress_updates_enabled,
      nutrition_reminders_enabled,
      subscription_updates_enabled,
      marketing_enabled,
      quiet_hours_enabled,
      quiet_hours_start,
      quiet_hours_end
    } = req.body;

    const updates = [];
    const values = [userId];
    let paramCount = 2;

    if (typeof messages_enabled !== 'undefined') {
      updates.push(`messages_enabled = $${paramCount}`);
      values.push(messages_enabled);
      paramCount++;
    }
    if (typeof workout_reminders_enabled !== 'undefined') {
      updates.push(`workout_reminders_enabled = $${paramCount}`);
      values.push(workout_reminders_enabled);
      paramCount++;
    }
    if (typeof booking_reminders_enabled !== 'undefined') {
      updates.push(`booking_reminders_enabled = $${paramCount}`);
      values.push(booking_reminders_enabled);
      paramCount++;
    }
    if (typeof progress_updates_enabled !== 'undefined') {
      updates.push(`progress_updates_enabled = $${paramCount}`);
      values.push(progress_updates_enabled);
      paramCount++;
    }
    if (typeof nutrition_reminders_enabled !== 'undefined') {
      updates.push(`nutrition_reminders_enabled = $${paramCount}`);
      values.push(nutrition_reminders_enabled);
      paramCount++;
    }
    if (typeof subscription_updates_enabled !== 'undefined') {
      updates.push(`subscription_updates_enabled = $${paramCount}`);
      values.push(subscription_updates_enabled);
      paramCount++;
    }
    if (typeof marketing_enabled !== 'undefined') {
      updates.push(`marketing_enabled = $${paramCount}`);
      values.push(marketing_enabled);
      paramCount++;
    }
    if (typeof quiet_hours_enabled !== 'undefined') {
      updates.push(`quiet_hours_enabled = $${paramCount}`);
      values.push(quiet_hours_enabled);
      paramCount++;
    }
    if (quiet_hours_start) {
      updates.push(`quiet_hours_start = $${paramCount}`);
      values.push(quiet_hours_start);
      paramCount++;
    }
    if (quiet_hours_end) {
      updates.push(`quiet_hours_end = $${paramCount}`);
      values.push(quiet_hours_end);
      paramCount++;
    }

    if (updates.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'No preferences to update'
      });
    }

    updates.push(`updated_at = NOW()`);

    const query = `
      UPDATE notification_preferences
      SET ${updates.join(', ')}
      WHERE user_id = $1
      RETURNING *
    `;

    const result = await db.query(query, values);

    res.json({
      success: true,
      preferences: result.rows[0]
    });

  } catch (error) {
    logger.error('Update notification preferences error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update preferences'
    });
  }
};

/**
 * Get notification history
 */
exports.getHistory = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { limit = 50, offset = 0 } = req.query;

    const result = await db.query(
      `SELECT 
        id,
        notification_type,
        title,
        body,
        data,
        status,
        sent_at,
        delivered_at,
        clicked_at
       FROM notification_history
       WHERE user_id = $1
       ORDER BY sent_at DESC
       LIMIT $2 OFFSET $3`,
      [userId, limit, offset]
    );

    res.json({
      success: true,
      notifications: result.rows,
      total: result.rows.length
    });

  } catch (error) {
    logger.error('Get notification history error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get notification history'
    });
  }
};

/**
 * Send test notification
 */
exports.sendTestNotification = async (req, res) => {
  try {
    const userId = req.user.userId;

    const result = await pushNotificationService.sendToUser(
      userId,
      {
        title: 'اختبار الإشعارات',
        body: 'هذا إشعار تجريبي للتأكد من أن الإشعارات تعمل بشكل صحيح!'
      },
      {
        type: 'test',
        screen: 'home'
      }
    );

    res.json({
      success: result.success,
      message: result.success 
        ? 'Test notification sent successfully'
        : 'Failed to send test notification'
    });

  } catch (error) {
    logger.error('Send test notification error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to send test notification'
    });
  }
};

/**
 * Mark notification as clicked
 */
exports.markAsClicked = async (req, res) => {
  try {
    const { notificationId } = req.params;

    await db.query(
      `UPDATE notification_history
       SET status = 'clicked', clicked_at = NOW()
       WHERE id = $1`,
      [notificationId]
    );

    res.json({
      success: true,
      message: 'Notification marked as clicked'
    });

  } catch (error) {
    logger.error('Mark notification as clicked error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update notification'
    });
  }
};

module.exports = exports;
