const db = require('../database');
const logger = require('../utils/logger');
const { v4: uuidv4 } = require('uuid');

/**
 * Coach Plan Controller
 * Allows coaches to edit/customize user workout and nutrition plans
 */

/**
 * Get client's workout plan
 */
exports.getClientWorkoutPlan = async (req, res) => {
  try {
    const { coachId, clientId } = req.params;
    
    // Verify coach owns this client
    const clientCheck = await db.query(
      'SELECT id FROM user_coaches WHERE user_id = $1 AND coach_id = $2 AND is_active = TRUE',
      [clientId, coachId]
    );
    
    if (clientCheck.rows.length === 0) {
      return res.status(403).json({
        success: false,
        message: 'Client not assigned to this coach'
      });
    }
    
    // Get current workout plan
    const result = await db.query(
      `SELECT * FROM user_workout_plans
       WHERE user_id = $1
       ORDER BY created_at DESC
       LIMIT 1`,
      [clientId]
    );
    
    res.json({
      success: true,
      workoutPlan: result.rows[0] || null
    });
    
  } catch (error) {
    logger.error('Get client workout plan error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get workout plan'
    });
  }
};

/**
 * Update client's workout plan
 */
exports.updateClientWorkoutPlan = async (req, res) => {
  const client = await db.getClient();
  
  try {
    const { coachId, clientId } = req.params;
    const { planData, notes } = req.body;
    
    await client.query('BEGIN');
    
    // Verify coach owns this client
    const clientCheck = await client.query(
      'SELECT id FROM user_coaches WHERE user_id = $1 AND coach_id = $2 AND is_active = TRUE',
      [clientId, coachId]
    );
    
    if (clientCheck.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(403).json({
        success: false,
        message: 'Client not assigned to this coach'
      });
    }
    
    // Archive old plan
    await client.query(
      `UPDATE user_workout_plans
       SET is_active = FALSE
       WHERE user_id = $1 AND is_active = TRUE`,
      [clientId]
    );
    
    // Create new plan
    const result = await client.query(
      `INSERT INTO user_workout_plans (
        id, user_id, plan_data, notes, is_active, customized_by_coach, created_at
      ) VALUES ($1, $2, $3, $4, TRUE, TRUE, NOW())
      RETURNING *`,
      [uuidv4(), clientId, JSON.stringify(planData), notes]
    );
    
    await client.query('COMMIT');
    client.release();
    
    // Create notification
    await db.query(
      `INSERT INTO notifications (
        id, user_id, type, title, title_ar, message, message_ar, data, created_at
      ) VALUES ($1, $2, 'workout_plan_updated', $3, $4, $5, $6, $7, NOW())`,
      [
        uuidv4(),
        clientId,
        'Workout Plan Updated',
        'تم تحديث خطة التمرين',
        'Your coach has customized your workout plan',
        'قام مدربك بتخصيص خطة التمرين الخاصة بك',
        JSON.stringify({ planId: result.rows[0].id })
      ]
    );
    
    res.json({
      success: true,
      message: 'Workout plan updated successfully',
      workoutPlan: result.rows[0]
    });
    
    logger.info(`Coach ${coachId} updated workout plan for client ${clientId}`);
    
  } catch (error) {
    await client.query('ROLLBACK');
    client.release();
    logger.error('Update client workout plan error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update workout plan'
    });
  }
};

/**
 * Get client's nutrition plan
 */
exports.getClientNutritionPlan = async (req, res) => {
  try {
    const { coachId, clientId } = req.params;
    
    // Verify coach owns this client
    const clientCheck = await db.query(
      'SELECT id FROM user_coaches WHERE user_id = $1 AND coach_id = $2 AND is_active = TRUE',
      [clientId, coachId]
    );
    
    if (clientCheck.rows.length === 0) {
      return res.status(403).json({
        success: false,
        message: 'Client not assigned to this coach'
      });
    }
    
    // Get current nutrition plan
    const result = await db.query(
      `SELECT * FROM user_nutrition_plans
       WHERE user_id = $1
       ORDER BY created_at DESC
       LIMIT 1`,
      [clientId]
    );
    
    res.json({
      success: true,
      nutritionPlan: result.rows[0] || null
    });
    
  } catch (error) {
    logger.error('Get client nutrition plan error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get nutrition plan'
    });
  }
};

/**
 * Update client's nutrition plan
 */
exports.updateClientNutritionPlan = async (req, res) => {
  const client = await db.getClient();
  
  try {
    const { coachId, clientId } = req.params;
    const { 
      dailyCalories,
      macros,
      mealPlan,
      notes 
    } = req.body;
    
    await client.query('BEGIN');
    
    // Verify coach owns this client
    const clientCheck = await client.query(
      'SELECT id FROM user_coaches WHERE user_id = $1 AND coach_id = $2 AND is_active = TRUE',
      [clientId, coachId]
    );
    
    if (clientCheck.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(403).json({
        success: false,
        message: 'Client not assigned to this coach'
      });
    }
    
    // Archive old plan
    await client.query(
      `UPDATE user_nutrition_plans
       SET is_active = FALSE
       WHERE user_id = $1 AND is_active = TRUE`,
      [clientId]
    );
    
    // Create new plan
    const result = await client.query(
      `INSERT INTO user_nutrition_plans (
        id, user_id, daily_calories, macros, meal_plan, notes,
        is_active, customized_by_coach, created_at
      ) VALUES ($1, $2, $3, $4, $5, $6, TRUE, TRUE, NOW())
      RETURNING *`,
      [
        uuidv4(),
        clientId,
        dailyCalories,
        JSON.stringify(macros),
        JSON.stringify(mealPlan),
        notes
      ]
    );
    
    await client.query('COMMIT');
    client.release();
    
    // Create notification
    await db.query(
      `INSERT INTO notifications (
        id, user_id, type, title, title_ar, message, message_ar, data, created_at
      ) VALUES ($1, $2, 'nutrition_plan_updated', $3, $4, $5, $6, $7, NOW())`,
      [
        uuidv4(),
        clientId,
        'Nutrition Plan Updated',
        'تم تحديث خطة التغذية',
        'Your coach has customized your nutrition plan',
        'قام مدربك بتخصيص خطة التغذية الخاصة بك',
        JSON.stringify({ planId: result.rows[0].id })
      ]
    );
    
    res.json({
      success: true,
      message: 'Nutrition plan updated successfully',
      nutritionPlan: result.rows[0]
    });
    
    logger.info(`Coach ${coachId} updated nutrition plan for client ${clientId}`);
    
  } catch (error) {
    await client.query('ROLLBACK');
    client.release();
    logger.error('Update client nutrition plan error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update nutrition plan'
    });
  }
};

module.exports = exports;
