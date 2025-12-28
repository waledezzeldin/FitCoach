const db = require('../database');
const logger = require('../utils/logger');
const { hasInjuryConflict } = require('../utils/helpers');
const workoutTemplateService = require('../services/workoutTemplateService');
const workoutGenerationService = require('../services/workoutGenerationService');
const workoutRecommendationService = require('../services/workoutRecommendationService');
const coachCustomizationService = require('../services/coachCustomizationService');

/**
 * Get all workout templates
 */
exports.getTemplates = async (req, res) => {
  try {
    const { goal, level, durationWeeks, daysPerWeek, equipment } = req.query;
    
    const filters = {};
    if (goal) filters.goal = goal;
    if (level) filters.level = level;
    if (durationWeeks) filters.durationWeeks = durationWeeks;
    if (daysPerWeek) filters.daysPerWeek = daysPerWeek;
    if (equipment) filters.equipment = equipment;

    const templates = Object.keys(filters).length > 0
      ? workoutTemplateService.searchTemplates(filters)
      : workoutTemplateService.getAllTemplateSummaries();

    res.json({
      success: true,
      templates,
      count: templates.length
    });
  } catch (error) {
    logger.error('Get templates error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get templates'
    });
  }
};

/**
 * Get template by ID
 */
exports.getTemplateById = async (req, res) => {
  try {
    const { id } = req.params;
    
    const template = workoutTemplateService.getTemplateById(id);
    
    if (!template) {
      return res.status(404).json({
        success: false,
        message: 'Template not found'
      });
    }

    res.json({
      success: true,
      template
    });
  } catch (error) {
    logger.error('Get template by ID error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get template'
    });
  }
};

/**
 * Generate workout from template
 */
exports.generateFromTemplate = async (req, res) => {
  try {
    const { templateId, customizations } = req.body;
    const userId = req.body.userId || req.user.userId;
    const coachId = req.user.role === 'coach' ? req.user.userId : null;

    if (!templateId) {
      return res.status(400).json({
        success: false,
        message: 'Template ID is required'
      });
    }

    const result = await workoutGenerationService.generateFromTemplate(
      userId,
      templateId,
      coachId,
      customizations || {}
    );

    res.status(201).json({
      success: true,
      message: 'Workout plan generated successfully',
      plan: result.plan,
      templateUsed: result.template
    });
  } catch (error) {
    logger.error('Generate from template error:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to generate workout plan'
    });
  }
};

/**
 * Get recommended template for user
 */
exports.getRecommendedTemplate = async (req, res) => {
  try {
    const userId = req.params.userId || req.user.userId;

    const template = await workoutGenerationService.recommendTemplate(userId);

    if (!template) {
      return res.status(404).json({
        success: false,
        message: 'No suitable template found'
      });
    }

    res.json({
      success: true,
      template: workoutTemplateService.getTemplateSummary(template)
    });
  } catch (error) {
    logger.error('Get recommended template error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get recommended template'
    });
  }
};

/**
 * Get user's workout plans
 */
exports.getUserWorkouts = async (req, res) => {
  try {
    const result = await db.query(
      `SELECT * FROM active_workout_plans_with_progress
       WHERE user_id = $1
       ORDER BY start_date DESC`,
      [req.user.userId]
    );
    
    res.json({
      success: true,
      workouts: result.rows
    });
    
  } catch (error) {
    logger.error('Get user workouts error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get workouts'
    });
  }
};

/**
 * Get workout plan by ID
 */
exports.getWorkoutById = async (req, res) => {
  try {
    const { id } = req.params;
    
    // Get workout plan
    const planResult = await db.query(
      'SELECT * FROM workout_plans WHERE id = $1',
      [id]
    );
    
    if (planResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Workout plan not found'
      });
    }
    
    const plan = planResult.rows[0];
    
    // Check authorization
    if (plan.user_id !== req.user.userId && req.user.role !== 'coach' && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Unauthorized'
      });
    }
    
    // Get days with exercises
    const daysResult = await db.query(
      `SELECT 
        wd.*,
        json_agg(
          json_build_object(
            'id', we.id,
            'exerciseId', we.exercise_id,
            'name', e.name,
            'nameAr', e.name_ar,
            'nameEn', e.name_en,
            'category', e.category,
            'sets', we.sets,
            'reps', we.reps,
            'restTime', we.rest_time,
            'isCompleted', we.is_completed,
            'wasSubstituted', we.was_substituted,
            'substitutionReason', we.substitution_reason,
            'videoUrl', e.video_url,
            'thumbnailUrl', e.thumbnail_url
          ) ORDER BY we.order_index
        ) as exercises
       FROM workout_days wd
       LEFT JOIN workout_exercises we ON wd.id = we.workout_day_id
       LEFT JOIN exercises e ON we.exercise_id = e.id
       WHERE wd.workout_plan_id = $1
       GROUP BY wd.id
       ORDER BY wd.day_number`,
      [id]
    );
    
    plan.days = daysResult.rows;
    
    res.json({
      success: true,
      workout: plan
    });
    
  } catch (error) {
    logger.error('Get workout by ID error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get workout'
    });
  }
};

/**
 * Complete exercise
 */
exports.completeExercise = async (req, res) => {
  try {
    const { id, exerciseId } = req.params;
    
    await db.query(
      `UPDATE workout_exercises
       SET is_completed = TRUE,
           completed_at = NOW()
       WHERE id = $1 
       AND workout_day_id IN (
         SELECT id FROM workout_days WHERE workout_plan_id = $2
       )`,
      [exerciseId, id]
    );
    
    res.json({
      success: true,
      message: 'Exercise marked as complete'
    });
    
  } catch (error) {
    logger.error('Complete exercise error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to complete exercise'
    });
  }
};

/**
 * Get workout progress
 */
exports.getProgress = async (req, res) => {
  try {
    const { id } = req.params;
    
    const result = await db.query(
      'SELECT * FROM active_workout_plans_with_progress WHERE id = $1',
      [id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Workout not found'
      });
    }
    
    res.json({
      success: true,
      progress: result.rows[0]
    });
    
  } catch (error) {
    logger.error('Get progress error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get progress'
    });
  }
};

/**
 * Substitute exercise due to injury
 */
exports.substituteExercise = async (req, res) => {
  const client = await db.getClient();
  
  try {
    const { id } = req.params;
    const { exerciseId, reason } = req.body;
    
    await client.query('BEGIN');
    
    // Get user injuries
    const userResult = await client.query(
      'SELECT injuries FROM users WHERE id = $1',
      [req.user.userId]
    );
    
    const userInjuries = userResult.rows[0].injuries || [];
    
    // Get current exercise
    const exerciseResult = await client.query(
      'SELECT * FROM exercises WHERE id = $1',
      [exerciseId]
    );
    
    if (exerciseResult.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({
        success: false,
        message: 'Exercise not found'
      });
    }
    
    const currentExercise = exerciseResult.rows[0];
    
    // Get alternatives that don't conflict with injuries
    const alternativesResult = await client.query(
      `SELECT * FROM exercises
       WHERE id = ANY($1)
       AND NOT EXISTS (
         SELECT 1 FROM unnest(contraindications) AS contra
         WHERE contra = ANY($2)
       )
       LIMIT 5`,
      [currentExercise.alternatives || [], userInjuries]
    );
    
    const safeAlternatives = alternativesResult.rows;
    
    if (safeAlternatives.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({
        success: false,
        message: 'No safe alternatives available'
      });
    }
    
    // Use first alternative
    const alternative = safeAlternatives[0];
    
    // Update workout exercise
    await client.query(
      `UPDATE workout_exercises
       SET exercise_id = $1,
           was_substituted = TRUE,
           original_exercise_id = $2,
           substitution_reason = $3
       WHERE id = $4`,
      [alternative.id, exerciseId, reason, req.body.workoutExerciseId]
    );
    
    await client.query('COMMIT');
    
    logger.info(`Exercise substituted: ${exerciseId} -> ${alternative.id}`);
    
    res.json({
      success: true,
      message: 'Exercise substituted successfully',
      alternative: {
        id: alternative.id,
        name: alternative.name,
        nameAr: alternative.name_ar,
        nameEn: alternative.name_en,
        reason
      },
      otherAlternatives: safeAlternatives.slice(1)
    });
    
  } catch (error) {
    await client.query('ROLLBACK');
    logger.error('Substitute exercise error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to substitute exercise'
    });
  } finally {
    client.release();
  }
};

/**
 * Create workout plan (Coach/Admin)
 */
exports.createWorkoutPlan = async (req, res) => {
  const client = await db.getClient();
  
  try {
    const { userId, name, description, startDate, endDate, days } = req.body;
    
    await client.query('BEGIN');
    
    // Create workout plan
    const planResult = await client.query(
      `INSERT INTO workout_plans (user_id, coach_id, name, description, start_date, end_date)
       VALUES ($1, (SELECT id FROM coaches WHERE user_id = $2), $3, $4, $5, $6)
       RETURNING *`,
      [userId, req.user.userId, name, description, startDate, endDate]
    );
    
    const plan = planResult.rows[0];
    
    // Create days and exercises
    for (const day of days) {
      const dayResult = await client.query(
        `INSERT INTO workout_days (workout_plan_id, day_name, day_number, notes)
         VALUES ($1, $2, $3, $4)
         RETURNING *`,
        [plan.id, day.dayName, day.dayNumber, day.notes]
      );
      
      const workoutDay = dayResult.rows[0];
      
      for (let i = 0; i < day.exercises.length; i++) {
        const exercise = day.exercises[i];
        
        await client.query(
          `INSERT INTO workout_exercises (
            workout_day_id, exercise_id, sets, reps, rest_time, tempo, notes, order_index
          ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
          [workoutDay.id, exercise.exerciseId, exercise.sets, exercise.reps, 
           exercise.restTime, exercise.tempo, exercise.notes, i]
        );
      }
    }
    
    await client.query('COMMIT');
    
    logger.info(`Workout plan created: ${plan.id} for user ${userId}`);
    
    res.status(201).json({
      success: true,
      message: 'Workout plan created successfully',
      plan
    });
    
  } catch (error) {
    await client.query('ROLLBACK');
    logger.error('Create workout plan error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create workout plan'
    });
  } finally {
    client.release();
  }
};

/**
 * Update workout plan
 */
exports.updateWorkoutPlan = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, description, endDate, isActive } = req.body;
    
    const result = await db.query(
      `UPDATE workout_plans
       SET name = COALESCE($1, name),
           description = COALESCE($2, description),
           end_date = COALESCE($3, end_date),
           is_active = COALESCE($4, is_active),
           updated_at = NOW()
       WHERE id = $5
       RETURNING *`,
      [name, description, endDate, isActive, id]
    );
    
    res.json({
      success: true,
      message: 'Workout plan updated successfully',
      plan: result.rows[0]
    });
    
  } catch (error) {
    logger.error('Update workout plan error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update workout plan'
    });
  }
};

/**
 * Delete workout plan
 */
exports.deleteWorkoutPlan = async (req, res) => {
  try {
    const { id } = req.params;
    
    await db.query('DELETE FROM workout_plans WHERE id = $1', [id]);
    
    res.json({
      success: true,
      message: 'Workout plan deleted successfully'
    });
    
  } catch (error) {
    logger.error('Delete workout plan error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete workout plan'
    });
  }
};

/**
 * Clone workout plan for customization (Coach only)
 */
exports.cloneWorkoutPlan = async (req, res) => {
  try {
    const { id } = req.params;
    const { customizationNotes } = req.body;
    const coachId = req.user.userId;

    const clonedPlan = await coachCustomizationService.cloneWorkoutPlanForCustomization(
      id,
      coachId,
      customizationNotes
    );

    res.status(201).json({
      success: true,
      message: 'Workout plan cloned successfully',
      plan: clonedPlan
    });

  } catch (error) {
    logger.error('Clone workout plan error:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to clone workout plan'
    });
  }
};

/**
 * Update exercise for specific user (Coach only)
 */
exports.updateExerciseForUser = async (req, res) => {
  try {
    const { id, exerciseId } = req.params;
    const updates = req.body;
    const coachId = req.user.userId;

    const updatedExercise = await coachCustomizationService.updateExerciseInPlan(
      id,
      exerciseId,
      updates,
      coachId
    );

    res.json({
      success: true,
      message: 'Exercise updated successfully',
      exercise: updatedExercise
    });

  } catch (error) {
    logger.error('Update exercise for user error:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to update exercise'
    });
  }
};

/**
 * Add custom note to workout day (Coach only)
 */
exports.addCustomNoteToDay = async (req, res) => {
  try {
    const { dayId } = req.params;
    const { note } = req.body;
    const coachId = req.user.userId;

    const updatedDay = await coachCustomizationService.addCustomNoteToDay(
      dayId,
      note,
      coachId
    );

    res.json({
      success: true,
      message: 'Custom note added successfully',
      day: updatedDay
    });

  } catch (error) {
    logger.error('Add custom note error:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to add custom note'
    });
  }
};

/**
 * Get coach's customization history for a user
 */
exports.getCustomizationHistory = async (req, res) => {
  try {
    const { userId } = req.params;
    const coachId = req.user.userId;
    const limit = parseInt(req.query.limit) || 50;

    const history = await coachCustomizationService.getCustomizationHistory(
      coachId,
      userId,
      limit
    );

    res.json({
      success: true,
      history,
      count: history.length
    });

  } catch (error) {
    logger.error('Get customization history error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get customization history'
    });
  }
};