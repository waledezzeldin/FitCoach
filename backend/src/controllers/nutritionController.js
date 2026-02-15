const db = require('../database');
const logger = require('../utils/logger');
const { getTrialDaysRemaining } = require('../utils/helpers');
const nutritionAccessService = require('../services/nutritionAccessService');
const nutritionGenerationService = require('../services/nutritionGenerationService');

const buildPlanWithDays = async (planId) => {
  const planResult = await db.query(
    'SELECT * FROM nutrition_plans WHERE id = $1',
    [planId]
  );

  if (planResult.rows.length === 0) {
    return null;
  }

  const plan = planResult.rows[0];

  const daysResult = await db.query(
    `SELECT 
      dmp.*,
      json_agg(
        json_build_object(
          'id', m.id,
          'name', m.name,
          'nameAr', m.name_ar,
          'nameEn', m.name_en,
          'type', m.type,
          'time', m.time,
          'calories', m.calories,
          'protein', m.protein,
          'carbs', m.carbs,
          'fats', m.fats,
          'isCompleted', m.is_completed,
          'imageUrl', m.image_url
        ) ORDER BY m.order_index
      ) as meals
     FROM day_meal_plans dmp
     LEFT JOIN meals m ON dmp.id = m.day_meal_plan_id
     WHERE dmp.nutrition_plan_id = $1
     GROUP BY dmp.id
     ORDER BY dmp.day_number`,
    [planId]
  );

  plan.days = daysResult.rows;

  return plan;
};

/**
 * Get nutrition access status
 */
exports.getAccessStatus = async (req, res) => {
  try {
    const userId = req.user.userId;
    const accessStatus = await nutritionAccessService.checkAccess(userId);

    res.json({
      success: true,
      access: accessStatus
    });

  } catch (error) {
    logger.error('Get nutrition access status error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get nutrition access status'
    });
  }
};

/**
 * Unlock nutrition trial (first workout completion)
 */
exports.unlockTrial = async (req, res) => {
  try {
    const userId = req.user.userId;
    const result = await nutritionAccessService.checkAndUnlockIfFirstWorkout(userId);

    if (!result.shouldUnlock) {
      return res.json({
        success: false,
        message: result.reason,
        currentStatus: result.currentStatus
      });
    }

    res.json({
      success: true,
      message: 'Nutrition trial unlocked!',
      trial: result.unlockResult
    });

  } catch (error) {
    logger.error('Unlock nutrition trial error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to unlock nutrition trial'
    });
  }
};

/**
 * Get user's nutrition plans
 */
exports.getUserPlans = async (req, res) => {
  try {
    // Access status is added by middleware
    const accessInfo = req.nutritionAccess || {};

    const result = await db.query(
      `SELECT 
        np.*,
        COUNT(DISTINCT dmp.id) as total_days,
        COUNT(DISTINCT m.id) as total_meals,
        COUNT(DISTINCT CASE WHEN m.is_completed = TRUE THEN m.id END) as completed_meals,
        ROUND(
          (COUNT(DISTINCT CASE WHEN m.is_completed = TRUE THEN m.id END)::DECIMAL / 
          NULLIF(COUNT(DISTINCT m.id), 0)) * 100, 
          2
        ) as completion_percentage
       FROM nutrition_plans np
       LEFT JOIN day_meal_plans dmp ON np.id = dmp.nutrition_plan_id
       LEFT JOIN meals m ON dmp.id = m.day_meal_plan_id
       WHERE np.user_id = $1 AND np.is_active = TRUE
       GROUP BY np.id
       ORDER BY np.start_date DESC`,
      [req.user.userId]
    );
    
    res.json({
      success: true,
      plans: result.rows,
      accessInfo: {
        hasAccess: accessInfo.hasAccess,
        tier: accessInfo.tier,
        isTrialActive: accessInfo.isTrialActive,
        daysRemaining: accessInfo.daysRemaining,
        expiresAt: accessInfo.trialExpiresAt
      }
    });
    
  } catch (error) {
    logger.error('Get nutrition plans error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get nutrition plans'
    });
  }
};

/**
 * Get nutrition plan by ID
 */
exports.getPlanById = async (req, res) => {
  try {
    const { id } = req.params;
    
    // Get plan
    const plan = await buildPlanWithDays(id);

    if (!plan) {
      return res.status(404).json({
        success: false,
        message: 'Nutrition plan not found'
      });
    }
    
    // Check authorization
    if (plan.user_id !== req.user.userId && req.user.role !== 'coach' && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Unauthorized'
      });
    }
    
    res.json({
      success: true,
      plan,
      trialDaysRemaining: req.trialDaysRemaining || null
    });
    
  } catch (error) {
    logger.error('Get nutrition plan error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get nutrition plan'
    });
  }
};

/**
 * Get active nutrition plan (Flutter-compatible)
 */
exports.getActivePlanCompat = async (req, res) => {
  try {
    const result = await db.query(
      `SELECT id FROM nutrition_plans
       WHERE user_id = $1 AND is_active = TRUE
       ORDER BY start_date DESC
       LIMIT 1`,
      [req.user.userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'No active nutrition plan'
      });
    }

    const plan = await buildPlanWithDays(result.rows[0].id);

    if (!plan) {
      return res.status(404).json({
        success: false,
        message: 'Nutrition plan not found'
      });
    }

    res.json(plan);
  } catch (error) {
    logger.error('Get active nutrition plan error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get nutrition plan'
    });
  }
};

/**
 * Get nutrition trial status (Flutter-compatible)
 */
exports.getTrialStatusCompat = async (req, res) => {
  try {
    const accessStatus = await nutritionAccessService.checkAccess(req.user.userId);

    res.json({
      startDate: accessStatus.trialStartedAt,
      expiresAt: accessStatus.trialExpiresAt,
      daysRemaining: accessStatus.daysRemaining,
      hasAccess: accessStatus.hasAccess,
      tier: accessStatus.tier
    });
  } catch (error) {
    logger.error('Get nutrition trial status error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get trial status'
    });
  }
};

/**
 * Log a meal consumption (Flutter-compatible)
 */
exports.logMealCompat = async (req, res) => {
  try {
    const { mealId } = req.params;

    await db.query(
      `UPDATE meals
       SET is_completed = TRUE,
           completed_at = NOW()
       WHERE id = $1
       AND day_meal_plan_id IN (
         SELECT dmp.id
         FROM day_meal_plans dmp
         JOIN nutrition_plans np ON dmp.nutrition_plan_id = np.id
         WHERE np.user_id = $2
       )`,
      [mealId, req.user.userId]
    );

    res.json({
      success: true,
      message: 'Meal logged successfully'
    });
  } catch (error) {
    logger.error('Log meal error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to log meal'
    });
  }
};

/**
 * Get nutrition history (Flutter-compatible)
 */
exports.getNutritionHistoryCompat = async (req, res) => {
  try {
    const result = await db.query(
      `SELECT
        DATE(m.completed_at) as date,
        COALESCE(SUM(m.calories), 0) as calories,
        COALESCE(SUM(m.protein), 0) as protein,
        COALESCE(SUM(m.carbs), 0) as carbs,
        COALESCE(SUM(m.fats), 0) as fat
       FROM meals m
       JOIN day_meal_plans dmp ON m.day_meal_plan_id = dmp.id
       JOIN nutrition_plans np ON dmp.nutrition_plan_id = np.id
       WHERE np.user_id = $1
         AND m.is_completed = TRUE
         AND m.completed_at IS NOT NULL
       GROUP BY DATE(m.completed_at)
       ORDER BY DATE(m.completed_at) DESC`,
      [req.user.userId]
    );

    res.json(result.rows.map((row) => ({
      date: row.date,
      calories: Number(row.calories),
      protein: Number(row.protein),
      carbs: Number(row.carbs),
      fat: Number(row.fat)
    })));
  } catch (error) {
    logger.error('Get nutrition history error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to load nutrition history'
    });
  }
};

/**
 * Complete meal
 */
exports.completeMeal = async (req, res) => {
  try {
    const { id, mealId } = req.params;
    
    await db.query(
      `UPDATE meals
       SET is_completed = TRUE,
           completed_at = NOW()
       WHERE id = $1 
       AND day_meal_plan_id IN (
         SELECT id FROM day_meal_plans WHERE nutrition_plan_id = $2
       )`,
      [mealId, id]
    );
    
    res.json({
      success: true,
      message: 'Meal marked as complete'
    });
    
  } catch (error) {
    logger.error('Complete meal error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to complete meal'
    });
  }
};

/**
 * Create nutrition plan (Coach/Admin)
 */
exports.createPlan = async (req, res) => {
  const client = await db.getClient();
  
  try {
    const { 
      userId, name, description, 
      dailyCalories, proteinTarget, carbsTarget, fatsTarget,
      startDate, endDate, days 
    } = req.body;
    
    await client.query('BEGIN');
    
    // Create nutrition plan
    const planResult = await client.query(
      `INSERT INTO nutrition_plans (
        user_id, coach_id, name, description,
        daily_calories, protein_target, carbs_target, fats_target,
        start_date, end_date
      ) VALUES ($1, (SELECT id FROM coaches WHERE user_id = $2), $3, $4, $5, $6, $7, $8, $9, $10)
      RETURNING *`,
      [userId, req.user.userId, name, description, 
       dailyCalories, proteinTarget, carbsTarget, fatsTarget,
       startDate, endDate]
    );
    
    const plan = planResult.rows[0];
    
    // Create days and meals
    for (const day of days) {
      const dayResult = await client.query(
        `INSERT INTO day_meal_plans (nutrition_plan_id, day_name, day_number, notes)
         VALUES ($1, $2, $3, $4)
         RETURNING *`,
        [plan.id, day.dayName, day.dayNumber, day.notes]
      );
      
      const mealDay = dayResult.rows[0];
      
      for (let i = 0; i < day.meals.length; i++) {
        const meal = day.meals[i];
        
        await client.query(
          `INSERT INTO meals (
            day_meal_plan_id, name, name_ar, name_en, type, time,
            calories, protein, carbs, fats, instructions, instructions_ar, instructions_en,
            order_index
          ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)`,
          [mealDay.id, meal.name, meal.nameAr, meal.nameEn, meal.type, meal.time,
           meal.calories, meal.protein, meal.carbs, meal.fats,
           meal.instructions, meal.instructionsAr, meal.instructionsEn, i]
        );
      }
    }
    
    await client.query('COMMIT');
    
    logger.info(`Nutrition plan created: ${plan.id} for user ${userId}`);
    
    res.status(201).json({
      success: true,
      message: 'Nutrition plan created successfully',
      plan
    });
    
  } catch (error) {
    await client.query('ROLLBACK');
    logger.error('Create nutrition plan error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create nutrition plan'
    });
  } finally {
    client.release();
  }
};

/**
 * Update nutrition plan
 */
exports.updatePlan = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, description, dailyCalories, proteinTarget, carbsTarget, fatsTarget, endDate, isActive } = req.body;
    
    const result = await db.query(
      `UPDATE nutrition_plans
       SET name = COALESCE($1, name),
           description = COALESCE($2, description),
           daily_calories = COALESCE($3, daily_calories),
           protein_target = COALESCE($4, protein_target),
           carbs_target = COALESCE($5, carbs_target),
           fats_target = COALESCE($6, fats_target),
           end_date = COALESCE($7, end_date),
           is_active = COALESCE($8, is_active),
           updated_at = NOW()
       WHERE id = $9
       RETURNING *`,
      [name, description, dailyCalories, proteinTarget, carbsTarget, fatsTarget, endDate, isActive, id]
    );
    
    res.json({
      success: true,
      message: 'Nutrition plan updated successfully',
      plan: result.rows[0]
    });
    
  } catch (error) {
    logger.error('Update nutrition plan error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update nutrition plan'
    });
  }
};

/**
 * Delete nutrition plan
 */
exports.deletePlan = async (req, res) => {
  try {
    const { id } = req.params;
    
    await db.query('DELETE FROM nutrition_plans WHERE id = $1', [id]);
    
    res.json({
      success: true,
      message: 'Nutrition plan deleted successfully'
    });
    
  } catch (error) {
    logger.error('Delete nutrition plan error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete nutrition plan'
    });
  }
};

/**
 * Generate nutrition plan based on user intake
 */
exports.generatePlan = async (req, res) => {
  try {
    const userId = req.user.userId;
    const customizations = req.body;

    // Check access
    const accessStatus = await nutritionAccessService.checkAccess(userId);
    
    if (!accessStatus.hasAccess) {
      return res.status(403).json({
        success: false,
        message: 'Nutrition access required. Please upgrade your plan or complete first workout.',
        access: accessStatus
      });
    }

    // Deactivate previous plans
    await db.query(
      'UPDATE nutrition_plans SET is_active = FALSE WHERE user_id = $1 AND is_active = TRUE',
      [userId]
    );

    // Generate new plan
    const result = await nutritionGenerationService.generatePlan(userId, customizations);

    res.status(201).json({
      success: true,
      message: 'Nutrition plan generated successfully',
      ...result
    });

    logger.info(`Nutrition plan generated for user ${userId}`);

  } catch (error) {
    logger.error('Generate nutrition plan error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to generate nutrition plan'
    });
  }
};