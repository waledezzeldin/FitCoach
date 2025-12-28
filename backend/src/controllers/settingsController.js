const db = require('../database');
const logger = require('../utils/logger');
const { validationResult } = require('express-validator');

/**
 * Get user notification settings
 */
exports.getNotificationSettings = async (req, res) => {
  try {
    const userId = req.user.userId;

    const result = await db.query(
      `SELECT 
        workout_reminders,
        coach_messages_notifications,
        nutrition_tracking_notifications,
        promotions_notifications,
        new_client_assignments,
        client_messages_notifications,
        session_reminders,
        payment_alerts,
        system_alerts,
        user_reports_notifications,
        coach_applications_notifications,
        payment_issues_notifications,
        security_alerts,
        push_enabled,
        email_enabled,
        sms_enabled
       FROM users
       WHERE id = $1`,
      [userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    res.json({
      success: true,
      settings: result.rows[0]
    });

  } catch (error) {
    logger.error('Get notification settings error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get notification settings'
    });
  }
};

/**
 * Update notification settings
 */
exports.updateNotificationSettings = async (req, res) => {
  try {
    const userId = req.user.userId;
    const {
      workoutReminders,
      coachMessagesNotifications,
      nutritionTrackingNotifications,
      promotionsNotifications,
      newClientAssignments,
      clientMessagesNotifications,
      sessionReminders,
      paymentAlerts,
      systemAlerts,
      userReportsNotifications,
      coachApplicationsNotifications,
      paymentIssuesNotifications,
      securityAlerts,
      pushEnabled,
      emailEnabled,
      smsEnabled
    } = req.body;

    const result = await db.query(
      `UPDATE users
       SET workout_reminders = COALESCE($1, workout_reminders),
           coach_messages_notifications = COALESCE($2, coach_messages_notifications),
           nutrition_tracking_notifications = COALESCE($3, nutrition_tracking_notifications),
           promotions_notifications = COALESCE($4, promotions_notifications),
           new_client_assignments = COALESCE($5, new_client_assignments),
           client_messages_notifications = COALESCE($6, client_messages_notifications),
           session_reminders = COALESCE($7, session_reminders),
           payment_alerts = COALESCE($8, payment_alerts),
           system_alerts = COALESCE($9, system_alerts),
           user_reports_notifications = COALESCE($10, user_reports_notifications),
           coach_applications_notifications = COALESCE($11, coach_applications_notifications),
           payment_issues_notifications = COALESCE($12, payment_issues_notifications),
           security_alerts = COALESCE($13, security_alerts),
           push_enabled = COALESCE($14, push_enabled),
           email_enabled = COALESCE($15, email_enabled),
           sms_enabled = COALESCE($16, sms_enabled),
           updated_at = NOW()
       WHERE id = $17
       RETURNING 
         workout_reminders,
         coach_messages_notifications,
         nutrition_tracking_notifications,
         promotions_notifications,
         new_client_assignments,
         client_messages_notifications,
         session_reminders,
         payment_alerts,
         system_alerts,
         user_reports_notifications,
         coach_applications_notifications,
         payment_issues_notifications,
         security_alerts,
         push_enabled,
         email_enabled,
         sms_enabled`,
      [
        workoutReminders,
        coachMessagesNotifications,
        nutritionTrackingNotifications,
        promotionsNotifications,
        newClientAssignments,
        clientMessagesNotifications,
        sessionReminders,
        paymentAlerts,
        systemAlerts,
        userReportsNotifications,
        coachApplicationsNotifications,
        paymentIssuesNotifications,
        securityAlerts,
        pushEnabled,
        emailEnabled,
        smsEnabled,
        userId
      ]
    );

    res.json({
      success: true,
      message: 'Notification settings updated successfully',
      settings: result.rows[0]
    });

  } catch (error) {
    logger.error('Update notification settings error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update notification settings'
    });
  }
};

/**
 * Get coach profile (for coaches only)
 */
exports.getCoachProfile = async (req, res) => {
  try {
    const userId = req.user.userId;

    // Check if user is a coach
    const userCheck = await db.query(
      'SELECT role FROM users WHERE id = $1',
      [userId]
    );

    if (userCheck.rows.length === 0 || userCheck.rows[0].role !== 'coach') {
      return res.status(403).json({
        success: false,
        message: 'Only coaches can access coach profile'
      });
    }

    const result = await db.query(
      `SELECT 
        c.*,
        u.full_name,
        u.profile_photo_url
       FROM coaches c
       JOIN users u ON c.user_id = u.id
       WHERE c.user_id = $1`,
      [userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Coach profile not found'
      });
    }

    res.json({
      success: true,
      coach: result.rows[0]
    });

  } catch (error) {
    logger.error('Get coach profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get coach profile'
    });
  }
};

/**
 * Update coach profile
 */
exports.updateCoachProfile = async (req, res) => {
  try {
    const userId = req.user.userId;
    const {
      bio,
      bioAr,
      yearsOfExperience,
      specializations,
      certifications,
      experience,
      hourlyRate
    } = req.body;

    // Check if user is a coach
    const userCheck = await db.query(
      'SELECT role FROM users WHERE id = $1',
      [userId]
    );

    if (userCheck.rows.length === 0 || userCheck.rows[0].role !== 'coach') {
      return res.status(403).json({
        success: false,
        message: 'Only coaches can update coach profile'
      });
    }

    const result = await db.query(
      `UPDATE coaches
       SET bio = COALESCE($1, bio),
           bio_ar = COALESCE($2, bio_ar),
           years_of_experience = COALESCE($3, years_of_experience),
           specializations = COALESCE($4, specializations),
           certifications = COALESCE($5, certifications),
           experience = COALESCE($6, experience),
           hourly_rate = COALESCE($7, hourly_rate),
           updated_at = NOW()
       WHERE user_id = $8
       RETURNING *`,
      [bio, bioAr, yearsOfExperience, specializations, certifications, experience, hourlyRate, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Coach profile not found'
      });
    }

    res.json({
      success: true,
      message: 'Coach profile updated successfully',
      coach: result.rows[0]
    });

  } catch (error) {
    logger.error('Update coach profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update coach profile'
    });
  }
};

/**
 * Get admin profile (for admins only)
 */
exports.getAdminProfile = async (req, res) => {
  try {
    const userId = req.user.userId;

    const result = await db.query(
      `SELECT 
        u.id,
        u.full_name,
        u.email,
        u.role,
        u.profile_photo_url,
        u.created_at,
        u.permissions
       FROM users u
       WHERE u.id = $1 AND u.role = 'admin'`,
      [userId]
    );

    if (result.rows.length === 0) {
      return res.status(403).json({
        success: false,
        message: 'Only admins can access admin profile'
      });
    }

    res.json({
      success: true,
      admin: result.rows[0]
    });

  } catch (error) {
    logger.error('Get admin profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get admin profile'
    });
  }
};

/**
 * Change password
 */
exports.changePassword = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { currentPassword, newPassword } = req.body;

    if (!currentPassword || !newPassword) {
      return res.status(400).json({
        success: false,
        message: 'Current password and new password are required'
      });
    }

    // Get current password hash
    const userResult = await db.query(
      'SELECT password_hash FROM users WHERE id = $1',
      [userId]
    );

    if (userResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Verify current password
    const bcrypt = require('bcrypt');
    const isValid = await bcrypt.compare(currentPassword, userResult.rows[0].password_hash);

    if (!isValid) {
      return res.status(401).json({
        success: false,
        message: 'Current password is incorrect'
      });
    }

    // Hash new password
    const newPasswordHash = await bcrypt.hash(newPassword, 10);

    // Update password
    await db.query(
      'UPDATE users SET password_hash = $1, updated_at = NOW() WHERE id = $2',
      [newPasswordHash, userId]
    );

    logger.info(`Password changed for user: ${userId}`);

    res.json({
      success: true,
      message: 'Password changed successfully'
    });

  } catch (error) {
    logger.error('Change password error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to change password'
    });
  }
};

/**
 * Delete account (soft delete)
 */
exports.deleteAccount = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { password } = req.body;

    if (!password) {
      return res.status(400).json({
        success: false,
        message: 'Password is required to delete account'
      });
    }

    // Verify password
    const userResult = await db.query(
      'SELECT password_hash FROM users WHERE id = $1',
      [userId]
    );

    if (userResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    const bcrypt = require('bcrypt');
    const isValid = await bcrypt.compare(password, userResult.rows[0].password_hash);

    if (!isValid) {
      return res.status(401).json({
        success: false,
        message: 'Incorrect password'
      });
    }

    // Soft delete
    await db.query(
      `UPDATE users 
       SET is_deleted = TRUE,
           deleted_at = NOW(),
           updated_at = NOW()
       WHERE id = $1`,
      [userId]
    );

    logger.info(`Account deleted for user: ${userId}`);

    res.json({
      success: true,
      message: 'Account deleted successfully'
    });

  } catch (error) {
    logger.error('Delete account error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete account'
    });
  }
};

module.exports = exports;
