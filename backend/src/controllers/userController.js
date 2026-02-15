const db = require('../database');
const logger = require('../utils/logger');
const { startNutritionTrial } = require('../services/quotaService');
const intakeService = require('../services/intakeService');
const userProfileService = require('../services/userProfileService');
const s3Service = require('../services/s3Service');
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
      age,
      weight,
      height,
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
           age = COALESCE($5, age),
           weight = COALESCE($6, weight),
           height = COALESCE($7, height),
           gender = COALESCE($8, gender),
           preferred_language = COALESCE($9, preferred_language),
           theme = COALESCE($10, theme),
           updated_at = NOW()
       WHERE id = $11
       RETURNING *`,
      [
        fullName,
        fullNameAr,
        email,
        dateOfBirth,
        age,
        weight,
        height,
        gender,
        preferredLanguage,
        theme,
        id
      ]
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
 * Get current user profile (Flutter-compatible shape)
 */
exports.getMe = async (req, res) => {
  try {
    const userId = req.user.userId;
    const profile = await userProfileService.getUserProfileForApp(userId);

    if (!profile) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    res.json(profile);
  } catch (error) {
    logger.error('Get current user profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get user profile'
    });
  }
};

const mapAppTierToDb = (tier) => {
  const normalized = String(tier || '').trim().toLowerCase();
  if (normalized === 'freemium') return 'freemium';
  if (normalized === 'premium') return 'premium';
  if (normalized === 'smart premium' || normalized === 'smart_premium') return 'smart_premium';
  return null;
};

/**
 * Update current user's subscription tier (Flutter contract)
 */
exports.updateSubscription = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { tier } = req.body;
    const mappedTier = mapAppTierToDb(tier);

    if (!mappedTier) {
      return res.status(400).json({
        success: false,
        message: 'Invalid subscription tier'
      });
    }

    await db.query(
      `UPDATE users
       SET subscription_tier = $1,
           subscription_start_date = NOW(),
           updated_at = NOW()
       WHERE id = $2`,
      [mappedTier, userId]
    );

    const profile = await userProfileService.getUserProfileForApp(userId);
    if (!profile) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    res.json(profile);
  } catch (error) {
    logger.error('Update subscription (compat) error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update subscription'
    });
  }
};

const mapGoalForIntake = (goal) => {
  const goalMap = {
    fat_loss: 'fat_loss',
    muscle_gain: 'muscle_gain',
    general_fitness: 'general_fitness',
    lose_weight: 'fat_loss',
    build_muscle: 'muscle_gain'
  };
  return goalMap[goal] || 'general_fitness';
};

const mapLocationForIntake = (location) => {
  const locationMap = {
    gym: 'gym',
    home: 'home',
    at_gym: 'gym',
    at_home: 'home'
  };
  return locationMap[location] || 'gym';
};

/**
 * Submit first intake (Flutter contract) → maps to IntakeService stage 1
 */
exports.submitFirstIntakeCompat = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { gender, mainGoal, workoutLocation } = req.body;

    if (!mainGoal || !workoutLocation) {
      return res.status(400).json({
        success: false,
        message: 'mainGoal and workoutLocation are required'
      });
    }

    const intakeData = {
      primary_goal: mapGoalForIntake(mainGoal),
      workout_location: mapLocationForIntake(workoutLocation),
      training_days_per_week: 3
    };

    await intakeService.submitStage1(userId, intakeData);

    if (gender) {
      await db.query(
        'UPDATE users SET gender = COALESCE($1, gender), updated_at = NOW() WHERE id = $2',
        [gender, userId]
      );
    }

    const profile = await userProfileService.getUserProfileForApp(userId);
    res.json(profile);
  } catch (error) {
    logger.error('Submit first intake (compat) error:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to submit intake'
    });
  }
};

/**
 * Submit second intake (Flutter contract) → maps to IntakeService stage 2
 */
exports.submitSecondIntakeCompat = async (req, res) => {
  try {
    const userId = req.user.userId;
    const {
      age,
      weight,
      height,
      experienceLevel,
      workoutFrequency,
      injuries
    } = req.body;

    const intakeData = {
      age,
      weight,
      height,
      experience_level: experienceLevel,
      injury_history: injuries || []
    };

    await intakeService.submitStage2(userId, intakeData);

    if (workoutFrequency) {
      await db.query(
        `UPDATE user_intake
         SET training_days_per_week = $1, updated_at = NOW()
         WHERE user_id = $2`,
        [workoutFrequency, userId]
      );

      await db.query(
        `UPDATE users
         SET training_days_per_week = $1, updated_at = NOW()
         WHERE id = $2`,
        [workoutFrequency, userId]
      );
    }

    const profile = await userProfileService.getUserProfileForApp(userId);
    res.json(profile);
  } catch (error) {
    logger.error('Submit second intake (compat) error:', error);

    if (error.message && error.message.includes('Premium subscription required')) {
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
 * Get current user's quota status
 */
exports.getMyQuotaStatus = async (req, res) => {
  req.params.id = req.user.userId;
  return exports.getQuotaStatus(req, res);
};

/**
 * Get user appointments (Flutter-compatible)
 */
exports.getUserAppointments = async (req, res) => {
  try {
    const { id } = req.params;
    const { startDate, endDate, status } = req.query;

    if (req.user.userId !== id && req.user.role !== 'admin' && req.user.role !== 'coach') {
      return res.status(403).json({
        success: false,
        message: 'Unauthorized'
      });
    }

    let coachFilterId = null;
    if (req.user.role === 'coach') {
      const coachResult = await db.query('SELECT id FROM coaches WHERE user_id = $1', [req.user.userId]);
      coachFilterId = coachResult.rows[0]?.id || null;
    }

    const params = [id];
    let query = `
      SELECT 
        a.*, 
        cu.full_name as coach_name,
        u.full_name as user_name
      FROM appointments a
      JOIN users u ON a.user_id = u.id
      JOIN coaches c ON a.coach_id = c.id
      JOIN users cu ON c.user_id = cu.id
      WHERE a.user_id = $1
    `;

    if (coachFilterId) {
      query += ' AND a.coach_id = $2';
      params.push(coachFilterId);
    }

    if (startDate) {
      query += ` AND a.scheduled_at >= $${params.length + 1}`;
      params.push(startDate);
    }
    if (endDate) {
      query += ` AND a.scheduled_at <= $${params.length + 1}`;
      params.push(endDate);
    }
    if (status) {
      query += ` AND a.status = $${params.length + 1}`;
      params.push(status);
    }

    query += ' ORDER BY a.scheduled_at DESC';

    const result = await db.query(query, params);

    res.json({
      success: true,
      appointments: result.rows
    });
  } catch (error) {
    logger.error('Get user appointments error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get appointments'
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
    
    const shouldRemove = req.body?.remove === true || req.body?.remove === 'true';

    if (shouldRemove) {
      await db.query(
        'UPDATE users SET profile_photo_url = NULL WHERE id = $1',
        [id]
      );

      return res.json({
        success: true,
        message: 'Profile photo removed successfully',
        photoUrl: null
      });
    }

    let photoUrl = req.body?.photoUrl;

    if (req.file) {
      const uploadResult = await s3Service.uploadFile(req.file, `profile-photos/${id}`);
      photoUrl = uploadResult.url;
    }

    if (!photoUrl) {
      return res.status(400).json({
        success: false,
        message: 'photo file or photoUrl is required'
      });
    }
    
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
