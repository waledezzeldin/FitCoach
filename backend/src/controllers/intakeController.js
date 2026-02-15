const intakeService = require('../services/intakeService');
const logger = require('../utils/logger');

/**
 * Submit Stage 1 intake (3 questions - all users)
 */
exports.submitStage1 = async (req, res) => {
  try {
    const userId = req.user.userId;
    const intakeData = req.body;

    // Validate required fields
    if (!intakeData.primary_goal || !intakeData.workout_location) {
      return res.status(400).json({
        success: false,
        message: 'Primary goal and workout location are required'
      });
    }

    const result = await intakeService.submitStage1(userId, intakeData);

    res.status(200).json({
      success: true,
      message: 'Basic intake completed successfully',
      data: result
    });

  } catch (error) {
    logger.error('Submit stage 1 intake error:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to submit intake'
    });
  }
};

/**
 * Submit Stage 2 intake (full questionnaire - Premium+ only)
 */
exports.submitStage2 = async (req, res) => {
  try {
    const userId = req.user.userId;
    const intakeData = req.body;

    const result = await intakeService.submitStage2(userId, intakeData);

    res.status(200).json({
      success: true,
      message: 'Full intake completed successfully',
      data: result
    });

  } catch (error) {
    logger.error('Submit stage 2 intake error:', error);
    
    if (error.message.includes('Premium subscription required')) {
      return res.status(403).json({
        success: false,
        message: error.message,
        upgradeRequired: true
      });
    }

    res.status(500).json({
      success: false,
      message: error.message || 'Failed to submit intake'
    });
  }
};

/**
 * Get user's intake status
 */
exports.getStatus = async (req, res) => {
  try {
    const userId = req.user.userId;

    const status = await intakeService.getIntakeStatus(userId);

    res.status(200).json({
      success: true,
      status
    });

  } catch (error) {
    logger.error('Get intake status error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get intake status'
    });
  }
};

/**
 * Check if user should be prompted for Stage 2
 */
exports.checkPrompt = async (req, res) => {
  try {
    const userId = req.user.userId;

    const promptInfo = await intakeService.shouldPromptStage2(userId);

    res.status(200).json({
      success: true,
      prompt: promptInfo
    });

  } catch (error) {
    logger.error('Check prompt error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to check prompt status'
    });
  }
};
