const db = require('../database');
const logger = require('../utils/logger');
const { startNutritionTrial } = require('../services/quotaService');
const { validationResult } = require('express-validator');

/**
 * Get user profile
 */
exports.getUserProfile = async (req, res) => {
  try {
    const { id } = req.params;
    
    // Check authorization (users can only view their own profile unless admin/coach)
    if (req.user.userId !== id && req.user.role !== 'admin' && req.user.role !== 'coach') {
      return res.status(403).json({
        success: false,
        message: 'Unauthorized to view this profile'
      });
    }
    
    const result = await db.query(
      `SELECT 
        u.*,
        c.id as assigned_coach_id,
        c.bio as coach_bio,
        c.average_rating as coach_rating,
        coach_user.full_name as coach_name,
        coach_user.profile_photo_url as coach_photo
       FROM users u
       LEFT JOIN coaches c ON u.assigned_coach_id = c.user_id
       LEFT JOIN users coach_user ON c.user_id = coach_user.id
       WHERE u.id = $1`,
      [id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }
    
    const user = result.rows[0];
    delete user.password_hash;
    
    res.json({
      success: true,
      user
    });
    
  } catch (error) {
    logger.error('Get user profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get user profile'
    });
  }
};

/**
 * Update user profile
 */
exports.updateProfile = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ success: false, errors: errors.array() });
    }
    
    const { id } = req.params;
    
    // Check authorization
    if (req.user.userId !== id && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Unauthorized to update this profile'
      });
    }
    
    const { 
      fullName, 
      fullNameAr, 
      email, 
      dateOfBirth, 
      gender,
      preferredLanguage,
      theme
    } = req.body;
    
    const result = await db.query(
      `UPDATE users
       SET full_name = COALESCE($1, full_name),
           full_name_ar = COALESCE($2, full_name_ar),
           email = COALESCE($3, email),
           date_of_birth = COALESCE($4, date_of_birth),
           gender = COALESCE($5, gender),
           preferred_language = COALESCE($6, preferred_language),
           theme = COALESCE($7, theme),
           updated_at = NOW()
       WHERE id = $8
       RETURNING *`,
      [fullName, fullNameAr, email, dateOfBirth, gender, preferredLanguage, theme, id]
    );
    
    const user = result.rows[0];
    delete user.password_hash;
    
    res.json({
      success: true,
      message: 'Profile updated successfully',
      user
    });
    
  } catch (error) {
    logger.error('Update profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update profile'
    });
  }
};

/**
 * Complete first intake (5 questions)
 */
exports.completeFirstIntake = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ success: false, errors: errors.array() });
    }
    
    const {
      goal,
      fitnessLevel,
      age,
      weight,
      height,
      activityLevel,
      dietaryPreferences
    } = req.body;
    
    const result = await db.query(
      `UPDATE users
       SET goal = $1,
           fitness_level = $2,
           age = $3,
           weight = $4,
           height = $5,
           activity_level = $6,
           dietary_preferences = $7,
           first_intake_completed = TRUE,
           updated_at = NOW()
       WHERE id = $8
       RETURNING *`,
      [goal, fitnessLevel, age, weight, height, activityLevel, dietaryPreferences || [], req.user.userId]
    );
    
    const user = result.rows[0];
    delete user.password_hash;
    
    logger.info(`First intake completed for user: ${req.user.userId}`);
    
    res.json({
      success: true,
      message: 'First intake completed successfully',
      user
    });
    
  } catch (error) {
    logger.error('Complete first intake error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to complete first intake'
    });
  }
};

/**
 * Complete second intake (6 questions - Premium+ only)
 */
exports.completeSecondIntake = async (req, res) => {
  try {
    const {
      healthHistory,
      injuries,
      medications,
      medicalConditions,
      specificGoals,
      trainingHistory
    } = req.body;
    
    const result = await db.query(
      `UPDATE users
       SET health_history = $1,
           injuries = $2,
           medications = $3,
           medical_conditions = $4,
           specific_goals = $5,
           training_history = $6,
           second_intake_completed = TRUE,
           updated_at = NOW()
       WHERE id = $7
       RETURNING *`,
      [healthHistory, injuries || [], medications || [], medicalConditions || [], specificGoals, trainingHistory, req.user.userId]
    );
    
    const user = result.rows[0];
    delete user.password_hash;
    
    logger.info(`Second intake completed for user: ${req.user.userId}`);
    
    res.json({
      success: true,
      message: 'Second intake completed successfully',
      user
    });
    
  } catch (error) {
    logger.error('Complete second intake error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to complete second intake'
    });
  }
};

/**
 * Get user quota status
 */
exports.getQuotaStatus = async (req, res) => {
  try {
    const { id } = req.params;
    
    // Check authorization
    if (req.user.userId !== id && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Unauthorized'
      });
    }
    
    const result = await db.query(
      'SELECT * FROM user_quota_status WHERE user_id = $1',
      [id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Quota status not found'
      });
    }
    
    const quota = result.rows[0];
    
    // Calculate percentages
    const messagePercentage = quota.message_quota === -1 
      ? 0 
      : (quota.messages_sent_this_month / quota.message_quota) * 100;
    
    const callPercentage = quota.call_quota === -1
      ? 0
      : (quota.video_calls_this_month / quota.call_quota) * 100;
    
    res.json({
      success: true,
      quota: {
        ...quota,
        messagePercentage: Math.round(messagePercentage),
        callPercentage: Math.round(callPercentage),
        messageWarning: messagePercentage >= 80,
        callWarning: callPercentage >= 80
      }
    });
    
  } catch (error) {
    logger.error('Get quota status error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get quota status'
    });
  }
};

/**
 * Start nutrition trial (Freemium only)
 */
exports.startNutritionTrial = async (req, res) => {
  try {
    // Check if already started
    const checkResult = await db.query(
      'SELECT nutrition_trial_start_date FROM users WHERE id = $1',
      [req.user.userId]
    );
    
    if (checkResult.rows[0].nutrition_trial_start_date) {
      return res.status(400).json({
        success: false,
        message: 'Trial already started or expired'
      });
    }
    
    await startNutritionTrial(req.user.userId);
    
    res.json({
      success: true,
      message: 'Nutrition trial started successfully',
      trialDays: 14
    });
    
  } catch (error) {
    logger.error('Start nutrition trial error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to start nutrition trial'
    });
  }
};

/**
 * Upload profile photo
 */
exports.uploadPhoto = async (req, res) => {
  try {
    const { id } = req.params;
    
    // Check authorization
    if (req.user.userId !== id) {
      return res.status(403).json({
        success: false,
        message: 'Unauthorized'
      });
    }
    
    // TODO: Implement file upload to S3
    // For now, accept URL
    const { photoUrl } = req.body;
    
    await db.query(
      'UPDATE users SET profile_photo_url = $1 WHERE id = $2',
      [photoUrl, id]
    );
    
    res.json({
      success: true,
      message: 'Profile photo updated successfully',
      photoUrl
    });
    
  } catch (error) {
    logger.error('Upload photo error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to upload photo'
    });
  }
};
