const db = require('../database');
const logger = require('../utils/logger');

/**
 * Reset monthly quotas for all users
 */
exports.resetMonthlyQuotas = async () => {
  try {
    const result = await db.query(`
      UPDATE users
      SET 
        messages_sent_this_month = 0,
        video_calls_this_month = 0,
        quota_reset_date = NOW() + INTERVAL '1 month'
      WHERE quota_reset_date <= NOW()
      RETURNING id, phone_number
    `);
    
    logger.info(`Reset quotas for ${result.rows.length} users`);
    return result.rows;
    
  } catch (error) {
    logger.error('Reset quotas error:', error);
    throw error;
  }
};

/**
 * Increment message count
 */
exports.incrementMessageCount = async (userId) => {
  try {
    await db.query(
      'UPDATE users SET messages_sent_this_month = messages_sent_this_month + 1 WHERE id = $1',
      [userId]
    );
  } catch (error) {
    logger.error('Increment message count error:', error);
    throw error;
  }
};

/**
 * Increment video call count
 */
exports.incrementCallCount = async (userId) => {
  try {
    await db.query(
      'UPDATE users SET video_calls_this_month = video_calls_this_month + 1 WHERE id = $1',
      [userId]
    );
  } catch (error) {
    logger.error('Increment call count error:', error);
    throw error;
  }
};

/**
 * Increment quota by type (compatibility wrapper)
 */
exports.incrementQuota = async (userId, type) => {
  if (type === 'messages') {
    return exports.incrementMessageCount(userId);
  }
  if (type === 'videoCalls') {
    return exports.incrementCallCount(userId);
  }
  throw new Error(`Unsupported quota type: ${type}`);
};

/**
 * Get user quota status
 */
exports.getQuotaStatus = async (userId) => {
  try {
    const result = await db.query(
      'SELECT * FROM user_quota_status WHERE user_id = $1',
      [userId]
    );
    
    return result.rows[0] || null;
    
  } catch (error) {
    logger.error('Get quota status error:', error);
    throw error;
  }
};

/**
 * Check if user can send message
 */
exports.canSendMessage = async (userId) => {
  try {
    const quota = await exports.getQuotaStatus(userId);
    
    if (!quota) return false;
    
    // Unlimited for smart_premium
    if (quota.message_quota === -1) return true;
    
    return quota.messages_sent_this_month < quota.message_quota;
    
  } catch (error) {
    logger.error('Can send message check error:', error);
    return false;
  }
};

/**
 * Check if user can book video call
 */
exports.canBookCall = async (userId) => {
  try {
    const quota = await exports.getQuotaStatus(userId);
    
    if (!quota) return false;
    
    return quota.video_calls_this_month < quota.call_quota;
    
  } catch (error) {
    logger.error('Can book call check error:', error);
    return false;
  }
};

/**
 * Start nutrition trial for freemium user
 */
exports.startNutritionTrial = async (userId) => {
  try {
    await db.query(
      `UPDATE users 
       SET nutrition_trial_active = TRUE,
           nutrition_trial_start_date = NOW()
       WHERE id = $1 AND subscription_tier = 'freemium'`,
      [userId]
    );
    
    logger.info(`Started nutrition trial for user: ${userId}`);
    
  } catch (error) {
    logger.error('Start nutrition trial error:', error);
    throw error;
  }
};
