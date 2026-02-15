const db = require('../database');
const logger = require('../utils/logger');

/**
 * Middleware to check if user has Premium or Smart Premium subscription
 * Used for premium-only features like AI InBody extraction, chat attachments, etc.
 */
const requirePremiumTier = async (req, res, next) => {
  try {
    const userId = req.user.userId;

    const result = await db.query(
      `SELECT subscription_tier FROM users WHERE id = $1`,
      [userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    const tier = result.rows[0].subscription_tier;

    // Check if user has Premium or Smart Premium
    if (tier === 'premium' || tier === 'smart_premium') {
      next();
    } else {
      return res.status(403).json({
        success: false,
        message: 'This feature requires a Premium subscription. Please upgrade to access AI-powered features.',
        upgradeRequired: true,
        currentTier: tier,
        requiredTier: 'premium',
        feature: 'AI InBody Extraction'
      });
    }

  } catch (error) {
    logger.error('Premium tier check error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to verify subscription tier'
    });
  }
};

/**
 * Middleware to check if user has Smart Premium subscription
 * Used for Smart Premium exclusive features
 */
const requireSmartPremiumTier = async (req, res, next) => {
  try {
    const userId = req.user.userId;

    const result = await db.query(
      `SELECT subscription_tier FROM users WHERE id = $1`,
      [userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    const tier = result.rows[0].subscription_tier;

    if (tier === 'smart_premium') {
      next();
    } else {
      return res.status(403).json({
        success: false,
        message: 'This feature requires a Smart Premium subscription.',
        upgradeRequired: true,
        currentTier: tier,
        requiredTier: 'smart_premium'
      });
    }

  } catch (error) {
    logger.error('Smart Premium tier check error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to verify subscription tier'
    });
  }
};

module.exports = {
  requirePremiumTier,
  requireSmartPremiumTier
};
