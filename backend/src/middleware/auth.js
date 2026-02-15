const jwt = require('jsonwebtoken');
const db = require('../database');
const logger = require('../utils/logger');

/**
 * Verify JWT token and attach user to request
 */
exports.authMiddleware = async (req, res, next) => {
  try {
    // Get token from header
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: 'No token provided'
      });
    }
    
    const token = authHeader.substring(7); // Remove 'Bearer ' prefix
    
    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // Check if user exists and is active
    const result = await db.query(
      'SELECT id, role, subscription_tier, is_active FROM users WHERE id = $1',
      [decoded.userId]
    );
    
    if (result.rows.length === 0 || !result.rows[0].is_active) {
      return res.status(401).json({
        success: false,
        message: 'Invalid token or inactive user'
      });
    }
    
    // Attach user info to request
    req.user = {
      userId: decoded.userId,
      role: decoded.role,
      tier: decoded.tier
    };
    
    next();
    
  } catch (error) {
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        success: false,
        message: 'Invalid token'
      });
    }
    
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        success: false,
        message: 'Token expired'
      });
    }
    
    logger.error('Auth middleware error:', error);
    res.status(500).json({
      success: false,
      message: 'Authentication failed'
    });
  }
};

/**
 * Check if user has required role
 */
exports.roleCheck = (...allowedRoles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        message: 'Authentication required'
      });
    }
    
    if (!allowedRoles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        message: 'Insufficient permissions'
      });
    }
    
    next();
  };
};

/**
 * Check if user has required subscription tier
 */
exports.tierCheck = (...allowedTiers) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        message: 'Authentication required'
      });
    }
    
    if (!allowedTiers.includes(req.user.tier)) {
      return res.status(403).json({
        success: false,
        message: 'Upgrade required to access this feature',
        requiredTier: allowedTiers
      });
    }
    
    next();
  };
};

/**
 * Check message quota
 */
exports.checkMessageQuota = async (req, res, next) => {
  try {
    const result = await db.query(
      'SELECT subscription_tier, messages_sent_this_month FROM users WHERE id = $1',
      [req.user.userId]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }
    
    const user = result.rows[0];
    
    // Define quotas
    const quotas = {
      freemium: 20,
      premium: 200,
      smart_premium: -1 // unlimited
    };
    
    const quota = quotas[user.subscription_tier];
    
    // Check if quota exceeded
    if (quota !== -1 && user.messages_sent_this_month >= quota) {
      return res.status(403).json({
        success: false,
        message: 'Message quota exceeded',
        quota,
        used: user.messages_sent_this_month,
        upgradeRequired: true
      });
    }
    
    next();
    
  } catch (error) {
    logger.error('Message quota check error:', error);
    res.status(500).json({
      success: false,
      message: 'Quota check failed'
    });
  }
};

/**
 * Check video call quota
 */
exports.checkCallQuota = async (req, res, next) => {
  try {
    const result = await db.query(
      'SELECT subscription_tier, video_calls_this_month FROM users WHERE id = $1',
      [req.user.userId]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }
    
    const user = result.rows[0];
    
    // Define quotas
    const quotas = {
      freemium: 1,
      premium: 2,
      smart_premium: 4
    };
    
    const quota = quotas[user.subscription_tier];
    
    // Check if quota exceeded
    if (user.video_calls_this_month >= quota) {
      return res.status(403).json({
        success: false,
        message: 'Video call quota exceeded',
        quota,
        used: user.video_calls_this_month,
        upgradeRequired: true
      });
    }
    
    next();
    
  } catch (error) {
    logger.error('Call quota check error:', error);
    res.status(500).json({
      success: false,
      message: 'Quota check failed'
    });
  }
};

/**
 * Check nutrition access (trial or paid)
 */
exports.checkNutritionAccess = async (req, res, next) => {
  try {
    const result = await db.query(
      `SELECT 
        subscription_tier,
        nutrition_trial_active,
        nutrition_trial_start_date
       FROM users 
       WHERE id = $1`,
      [req.user.userId]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }
    
    const user = result.rows[0];
    
    // Premium and Smart Premium have full access
    if (user.subscription_tier === 'premium' || user.subscription_tier === 'smart_premium') {
      return next();
    }
    
    // Freemium users need active trial
    if (user.subscription_tier === 'freemium') {
      if (!user.nutrition_trial_active) {
        return res.status(403).json({
          success: false,
          message: 'Nutrition trial has expired',
          upgradeRequired: true,
          trialExpired: true
        });
      }
      
      // Check if trial is still valid (14 days)
      const trialStart = new Date(user.nutrition_trial_start_date);
      const now = new Date();
      const daysPassed = Math.floor((now - trialStart) / (1000 * 60 * 60 * 24));
      
      if (daysPassed >= 14) {
        // Expire the trial
        await db.query(
          'UPDATE users SET nutrition_trial_active = FALSE WHERE id = $1',
          [req.user.userId]
        );
        
        return res.status(403).json({
          success: false,
          message: 'Nutrition trial has expired',
          upgradeRequired: true,
          trialExpired: true
        });
      }
      
      // Trial is still active
      req.trialDaysRemaining = 14 - daysPassed;
      return next();
    }
    
    // Shouldn't reach here
    res.status(403).json({
      success: false,
      message: 'No nutrition access'
    });
    
  } catch (error) {
    logger.error('Nutrition access check error:', error);
    res.status(500).json({
      success: false,
      message: 'Access check failed'
    });
  }
};
