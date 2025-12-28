const admin = require('firebase-admin');
const db = require('../database');
const logger = require('../utils/logger');

/**
 * Push Notification Service
 * Handles Firebase Cloud Messaging (FCM) for iOS and Android
 */

// Initialize Firebase Admin SDK
let firebaseApp;

try {
  const serviceAccount = process.env.FIREBASE_SERVICE_ACCOUNT 
    ? JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT)
    : require(process.env.FIREBASE_SERVICE_ACCOUNT_PATH || './firebase-service-account.json');

  firebaseApp = admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });

  logger.info('Firebase Admin SDK initialized successfully');
} catch (error) {
  logger.warn('Firebase Admin SDK initialization failed:', error.message);
  logger.warn('Push notifications will be disabled');
}

/**
 * Send push notification to a single device
 */
exports.sendToDevice = async (deviceToken, notification, data = {}) => {
  if (!firebaseApp) {
    logger.warn('Firebase not initialized, skipping notification');
    return { success: false, reason: 'firebase_not_initialized' };
  }

  try {
    const message = {
      notification: {
        title: notification.title,
        body: notification.body,
        imageUrl: notification.imageUrl
      },
      data: {
        ...data,
        notificationType: data.type || 'general',
        timestamp: new Date().toISOString()
      },
      token: deviceToken,
      android: {
        priority: 'high',
        notification: {
          sound: 'default',
          channelId: 'default',
          color: '#3B82F6' // App primary color
        }
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1
          }
        }
      }
    };

    const response = await admin.messaging().send(message);
    
    logger.info(`Push notification sent successfully: ${response}`);
    
    return { success: true, messageId: response };

  } catch (error) {
    logger.error('Send push notification error:', error);
    
    // If token is invalid, remove it from database
    if (error.code === 'messaging/invalid-registration-token' || 
        error.code === 'messaging/registration-token-not-registered') {
      await removeDeviceToken(deviceToken);
    }
    
    return { success: false, error: error.message };
  }
};

/**
 * Send push notification to multiple devices
 */
exports.sendToMultipleDevices = async (deviceTokens, notification, data = {}) => {
  if (!firebaseApp) {
    logger.warn('Firebase not initialized, skipping notifications');
    return { success: false, reason: 'firebase_not_initialized' };
  }

  if (!deviceTokens || deviceTokens.length === 0) {
    return { success: false, reason: 'no_tokens_provided' };
  }

  try {
    const message = {
      notification: {
        title: notification.title,
        body: notification.body,
        imageUrl: notification.imageUrl
      },
      data: {
        ...data,
        notificationType: data.type || 'general',
        timestamp: new Date().toISOString()
      },
      android: {
        priority: 'high',
        notification: {
          sound: 'default',
          channelId: 'default',
          color: '#3B82F6'
        }
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1
          }
        }
      }
    };

    const response = await admin.messaging().sendMulticast({
      ...message,
      tokens: deviceTokens
    });

    logger.info(`Push notifications sent: ${response.successCount} successful, ${response.failureCount} failed`);

    // Remove invalid tokens
    if (response.failureCount > 0) {
      const tokensToRemove = [];
      response.responses.forEach((resp, idx) => {
        if (!resp.success && 
            (resp.error.code === 'messaging/invalid-registration-token' ||
             resp.error.code === 'messaging/registration-token-not-registered')) {
          tokensToRemove.push(deviceTokens[idx]);
        }
      });
      
      if (tokensToRemove.length > 0) {
        await removeMultipleDeviceTokens(tokensToRemove);
      }
    }

    return {
      success: true,
      successCount: response.successCount,
      failureCount: response.failureCount
    };

  } catch (error) {
    logger.error('Send multiple push notifications error:', error);
    return { success: false, error: error.message };
  }
};

/**
 * Send notification to a user (all their devices)
 */
exports.sendToUser = async (userId, notification, data = {}) => {
  try {
    // Get all device tokens for user
    const result = await db.query(
      `SELECT device_token FROM user_devices 
       WHERE user_id = $1 AND device_token IS NOT NULL AND is_active = true`,
      [userId]
    );

    if (result.rows.length === 0) {
      logger.info(`No device tokens found for user ${userId}`);
      return { success: false, reason: 'no_devices' };
    }

    const deviceTokens = result.rows.map(row => row.device_token);
    
    return await exports.sendToMultipleDevices(deviceTokens, notification, data);

  } catch (error) {
    logger.error('Send to user error:', error);
    return { success: false, error: error.message };
  }
};

/**
 * Send notification to multiple users
 */
exports.sendToUsers = async (userIds, notification, data = {}) => {
  try {
    // Get all device tokens for users
    const result = await db.query(
      `SELECT device_token FROM user_devices 
       WHERE user_id = ANY($1) AND device_token IS NOT NULL AND is_active = true`,
      [userIds]
    );

    if (result.rows.length === 0) {
      return { success: false, reason: 'no_devices' };
    }

    const deviceTokens = result.rows.map(row => row.device_token);
    
    return await exports.sendToMultipleDevices(deviceTokens, notification, data);

  } catch (error) {
    logger.error('Send to users error:', error);
    return { success: false, error: error.message };
  }
};

/**
 * Notification templates
 */
exports.sendNewMessageNotification = async (userId, senderName, messagePreview) => {
  const notification = {
    title: `رسالة جديدة من ${senderName}`,
    body: messagePreview.substring(0, 100)
  };

  const data = {
    type: 'new_message',
    screen: 'coach'
  };

  return await exports.sendToUser(userId, notification, data);
};

exports.sendWorkoutReminderNotification = async (userId) => {
  const notification = {
    title: 'وقت التمرين! 💪',
    body: 'حان وقت جلسة التمرين اليومية. هل أنت مستعد؟'
  };

  const data = {
    type: 'workout_reminder',
    screen: 'workout'
  };

  return await exports.sendToUser(userId, notification, data);
};

exports.sendCoachAssignedNotification = async (userId, coachName) => {
  const notification = {
    title: 'تم تعيين مدرب جديد! 🎯',
    body: `تم تعيين ${coachName} كمدربك الشخصي`
  };

  const data = {
    type: 'coach_assigned',
    screen: 'coach'
  };

  return await exports.sendToUser(userId, notification, data);
};

exports.sendWorkoutCompletedNotification = async (userId, workoutName) => {
  const notification = {
    title: 'أحسنت! 🎉',
    body: `لقد أكملت ${workoutName}. استمر في التقدم!`
  };

  const data = {
    type: 'workout_completed',
    screen: 'progress'
  };

  return await exports.sendToUser(userId, notification, data);
};

exports.sendBookingConfirmedNotification = async (userId, scheduledTime) => {
  const notification = {
    title: 'تأكيد الموعد ✅',
    body: `تم تأكيد موعد المكالمة المرئية: ${scheduledTime}`
  };

  const data = {
    type: 'booking_confirmed',
    screen: 'bookings'
  };

  return await exports.sendToUser(userId, notification, data);
};

exports.sendBookingReminderNotification = async (userId, minutesUntil) => {
  const notification = {
    title: 'تذكير بالموعد 📞',
    body: `ستبدأ مكالمتك المرئية خلال ${minutesUntil} دقيقة`
  };

  const data = {
    type: 'booking_reminder',
    screen: 'bookings'
  };

  return await exports.sendToUser(userId, notification, data);
};

exports.sendSubscriptionExpiringSoonNotification = async (userId, daysRemaining) => {
  const notification = {
    title: 'اشتراكك ينتهي قريباً ⏰',
    body: `سينتهي اشتراكك خلال ${daysRemaining} أيام. جدد الآن!`
  };

  const data = {
    type: 'subscription_expiring',
    screen: 'store'
  };

  return await exports.sendToUser(userId, notification, data);
};

exports.sendNutritionUnlockedNotification = async (userId) => {
  const notification = {
    title: 'تم فتح خطة التغذية! 🥗',
    body: 'رائع! لقد أكملت أول تمرين وفتحت الوصول للتغذية'
  };

  const data = {
    type: 'nutrition_unlocked',
    screen: 'nutrition'
  };

  return await exports.sendToUser(userId, notification, data);
};

/**
 * Register device token
 */
exports.registerDevice = async (userId, deviceToken, deviceType, deviceInfo = {}) => {
  try {
    // Check if token already exists
    const existing = await db.query(
      `SELECT id FROM user_devices WHERE device_token = $1`,
      [deviceToken]
    );

    if (existing.rows.length > 0) {
      // Update existing device
      await db.query(
        `UPDATE user_devices 
         SET user_id = $1, 
             device_type = $2,
             device_info = $3,
             is_active = true,
             updated_at = NOW()
         WHERE device_token = $4`,
        [userId, deviceType, JSON.stringify(deviceInfo), deviceToken]
      );
    } else {
      // Insert new device
      await db.query(
        `INSERT INTO user_devices (user_id, device_token, device_type, device_info)
         VALUES ($1, $2, $3, $4)`,
        [userId, deviceToken, deviceType, JSON.stringify(deviceInfo)]
      );
    }

    logger.info(`Device registered for user ${userId}`);
    return { success: true };

  } catch (error) {
    logger.error('Register device error:', error);
    return { success: false, error: error.message };
  }
};

/**
 * Unregister device token
 */
exports.unregisterDevice = async (deviceToken) => {
  try {
    await db.query(
      `UPDATE user_devices 
       SET is_active = false, updated_at = NOW()
       WHERE device_token = $1`,
      [deviceToken]
    );

    logger.info(`Device unregistered: ${deviceToken}`);
    return { success: true };

  } catch (error) {
    logger.error('Unregister device error:', error);
    return { success: false, error: error.message };
  }
};

/**
 * Helper: Remove invalid device token
 */
async function removeDeviceToken(deviceToken) {
  try {
    await db.query(
      `DELETE FROM user_devices WHERE device_token = $1`,
      [deviceToken]
    );
    logger.info(`Removed invalid device token: ${deviceToken}`);
  } catch (error) {
    logger.error('Remove device token error:', error);
  }
}

/**
 * Helper: Remove multiple invalid device tokens
 */
async function removeMultipleDeviceTokens(deviceTokens) {
  try {
    await db.query(
      `DELETE FROM user_devices WHERE device_token = ANY($1)`,
      [deviceTokens]
    );
    logger.info(`Removed ${deviceTokens.length} invalid device tokens`);
  } catch (error) {
    logger.error('Remove multiple device tokens error:', error);
  }
}

/**
 * Send topic notification (e.g., to all users, all coaches, etc.)
 */
exports.sendToTopic = async (topic, notification, data = {}) => {
  if (!firebaseApp) {
    logger.warn('Firebase not initialized, skipping notification');
    return { success: false, reason: 'firebase_not_initialized' };
  }

  try {
    const message = {
      notification: {
        title: notification.title,
        body: notification.body
      },
      data: {
        ...data,
        notificationType: data.type || 'general',
        timestamp: new Date().toISOString()
      },
      topic: topic
    };

    const response = await admin.messaging().send(message);
    
    logger.info(`Topic notification sent to ${topic}: ${response}`);
    
    return { success: true, messageId: response };

  } catch (error) {
    logger.error('Send topic notification error:', error);
    return { success: false, error: error.message };
  }
};

module.exports = exports;
