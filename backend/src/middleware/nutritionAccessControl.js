const nutritionAccessService = require('../services/nutritionAccessService');
const logger = require('../utils/logger');

/**
 * Middleware to check nutrition access
 * Blocks access if user doesn't have permission
 */
async function checkNutritionAccess(req, res, next) {
  try {
    const userId = req.user.userId;

    const accessStatus = await nutritionAccessService.checkAccess(userId);

    if (!accessStatus.hasAccess) {
      return res.status(403).json({
        success: false,
        message: 'Nutrition access locked',
        error: 'NUTRITION_ACCESS_DENIED',
        accessStatus: {
          hasAccess: false,
          tier: accessStatus.tier,
          requiresUpgrade: true,
          daysRemaining: null,
          upgradeMessage: accessStatus.tier === 'freemium' 
            ? 'Complete your first workout to unlock 7-day nutrition trial, or upgrade to Premium for unlimited access'
            : 'Upgrade to Premium for nutrition access'
        }
      });
    }

    // Add access info to request for controller use
    req.nutritionAccess = accessStatus;

    next();

  } catch (error) {
    logger.error('Nutrition access middleware error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to check nutrition access'
    });
  }
}

/**
 * Middleware to add nutrition access info (doesn't block, just adds info)
 */
async function addNutritionAccessInfo(req, res, next) {
  try {
    const userId = req.user.userId;
    const accessStatus = await nutritionAccessService.checkAccess(userId);
    req.nutritionAccess = accessStatus;
    next();
  } catch (error) {
    logger.error('Add nutrition access info error:', error);
    // Don't block request, just continue without access info
    req.nutritionAccess = null;
    next();
  }
}

module.exports = {
  checkNutritionAccess,
  addNutritionAccessInfo
};
