const db = require('../database');
const logger = require('../utils/logger');
const { hasInjuryConflict } = require('../utils/helpers');
const workoutTemplateService = require('../services/workoutTemplateService');
const workoutGenerationService = require('../services/workoutGenerationService');
const workoutRecommendationService = require('../services/workoutRecommendationService');
const coachCustomizationService = require('../services/coachCustomizationService');
const exerciseCatalogService = require('../services/exerciseCatalogService');

const applyCatalogToPlanExercise = async (exercise) => {
  if (!exercise) return exercise;
  const exId = exercise.exerciseId || exercise.ex_id || null;
  if (!exId) return exercise;
  const catalog = await exerciseCatalogService.getById(exId);
  if (!catalog) return exercise;

  return {
    ...exercise,
    name: exercise.name || catalog.name_en || exId,
    nameAr: exercise.nameAr || catalog.name_ar || exercise.name || exId,
    nameEn: exercise.nameEn || catalog.name_en || exercise.name || exId,
    instructions: exercise.instructions || catalog.instructions_en,
    instructionsAr: exercise.instructionsAr || catalog.instructions_ar,
    instructionsEn: exercise.instructionsEn || catalog.instructions_en,
    equipment: exercise.equipment && exercise.equipment.length ? exercise.equipment : catalog.equip,
    muscleGroup: exercise.muscleGroup || (catalog.muscles || []).join(', '),
    videoUrl: exercise.videoUrl || catalog.video_url,
    thumbnailUrl: exercise.thumbnailUrl || catalog.thumbnail_url,
  };
};

const buildPlanWithDays = async (planId) => {
  const planResult = await db.query(
    'SELECT * FROM workout_plans WHERE id = $1',
    [planId]
  );

  if (planResult.rows.length === 0) {
    return null;
  }

  const plan = planResult.rows[0];

  const daysResult = await db.query(
    `SELECT 
      wd.id,
      wd.day_name,
      wd.day_name_ar,
      wd.day_number,
      wd.notes,
      json_agg(
        json_build_object(
          'id', wde.id,
          'exerciseId', wde.exercise_id,
          'name', COALESCE(wde.exercise_name, e.name, e.name_en, wde.exercise_id),
          'nameAr', COALESCE(wde.exercise_name_ar, e.name_ar),
          'nameEn', COALESCE(e.name_en, wde.exercise_name),
          'category', e.category,
          'muscleGroup', e.muscle_group,
          'equipment', e.equipment,
          'difficulty', e.difficulty,
          'videoUrl', e.video_url,
          'thumbnailUrl', e.thumbnail_url,
          'instructions', e.instructions,
          'instructionsAr', e.instructions_ar,
          'instructionsEn', e.instructions_en,
          'sets', wde.sets,
          'reps', wde.reps,
          'restTime', wde.rest_seconds,
          'tempo', wde.tempo,
          'notes', wde.notes,
          'contraindications', e.contraindications,
          'alternatives', e.alternatives,
          'isCompleted', wde.is_completed,
          'order', wde.exercise_order
        ) ORDER BY wde.exercise_order
      ) as exercises
     FROM workout_days wd
     LEFT JOIN workout_day_exercises wde ON wd.id = wde.workout_day_id
     LEFT JOIN exercises e ON e.id::text = wde.exercise_id OR e.ex_id = wde.exercise_id
     LEFT JOIN workout_weeks ww ON ww.id = wd.workout_week_id
     WHERE wd.workout_plan_id = $1 OR ww.workout_plan_id = $1
     GROUP BY wd.id
     ORDER BY wd.day_number`,
    [planId]
  );

  plan.days = await Promise.all(daysResult.rows.map(async (day) => {
    const exercises = await Promise.all((day.exercises || []).filter(Boolean).map(applyCatalogToPlanExercise));
    return {
      id: day.id,
      dayName: day.day_name,
      dayNameAr: day.day_name_ar,
      dayNumber: day.day_number,
      notes: day.notes,
      exercises
    };
  }));

  return plan;
};

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
 * Get active workout plan for current user (Flutter-compatible)
 */
exports.getActivePlan = async (req, res) => {
  try {
    const result = await db.query(
      `SELECT id FROM workout_plans
       WHERE user_id = $1 AND is_active = TRUE
       ORDER BY start_date DESC
       LIMIT 1`,
      [req.user.userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'No active plan found'
      });
    }

    const plan = await buildPlanWithDays(result.rows[0].id);

    if (!plan) {
      return res.status(404).json({
        success: false,
        message: 'Workout plan not found'
      });
    }

    res.json(plan);
  } catch (error) {
    logger.error('Get active plan error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to load active plan'
    });
  }
};

/**
 * Mark exercise complete (Flutter-compatible)
 */
exports.completeExerciseCompat = async (req, res) => {
  try {
    const { exerciseId } = req.params;

    await db.query(
      `UPDATE workout_day_exercises wde
       SET is_completed = TRUE,
           completed_at = NOW()
       FROM workout_days wd
       LEFT JOIN workout_weeks ww ON ww.id = wd.workout_week_id
       WHERE wde.id = $1
       AND wde.workout_day_id = wd.id
       AND (wd.workout_plan_id IN (SELECT id FROM workout_plans WHERE user_id = $2)
            OR ww.workout_plan_id IN (SELECT id FROM workout_plans WHERE user_id = $2))`,
      [exerciseId, req.user.userId]
    );

    res.json({
      success: true,
      message: 'Exercise marked as complete'
    });
  } catch (error) {
    logger.error('Complete exercise (compat) error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to complete exercise'
    });
  }
};

/**
 * Substitute exercise (Flutter-compatible)
 */
exports.substituteExerciseCompat = async (req, res) => {
  const client = await db.getClient();

  try {
    const { originalExerciseId, newExerciseId } = req.body;

    if (!originalExerciseId || !newExerciseId) {
      return res.status(400).json({
        success: false,
        message: 'originalExerciseId and newExerciseId are required'
      });
    }

    await client.query('BEGIN');

    const exerciseResult = await client.query(
      'SELECT * FROM exercises WHERE id = $1 OR ex_id = $1',
      [newExerciseId]
    );

    if (exerciseResult.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({
        success: false,
        message: 'Exercise not found'
      });
    }

    const newExercise = exerciseResult.rows[0];

    await client.query(
      `UPDATE workout_day_exercises wde
       SET exercise_id = $1,
           exercise_name = $2,
           exercise_name_ar = $3,
           was_substituted = TRUE,
           original_exercise_id = $4,
           substitution_reason = $5,
           updated_at = NOW()
       FROM workout_days wd
       LEFT JOIN workout_weeks ww ON ww.id = wd.workout_week_id
       WHERE wde.id = $6
       AND wde.workout_day_id = wd.id
       AND (wd.workout_plan_id IN (SELECT id FROM workout_plans WHERE user_id = $7)
            OR ww.workout_plan_id IN (SELECT id FROM workout_plans WHERE user_id = $7))`,
      [
        newExercise.id,
        newExercise.name_en || newExercise.name || newExercise.ex_id || newExercise.id,
        newExercise.name_ar || null,
        originalExerciseId,
        'user_substitution',
        originalExerciseId,
        req.user.userId
      ]
    );

    await client.query('COMMIT');

    res.json({
      success: true,
      message: 'Exercise substituted successfully'
    });
  } catch (error) {
    await client.query('ROLLBACK');
    logger.error('Substitute exercise (compat) error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to substitute exercise'
    });
  } finally {
    client.release();
  }
};

/**
 * Log workout session (Flutter-compatible)
 */
exports.logWorkoutCompat = async (req, res) => {
  const client = await db.getClient();
  try {
    const payload = req.body || {};
    const rawIds = [
      ...(Array.isArray(payload.exerciseIds) ? payload.exerciseIds : []),
      ...(Array.isArray(payload.completedExerciseIds) ? payload.completedExerciseIds : []),
      ...(typeof payload.exerciseId === 'string' ? [payload.exerciseId] : []),
    ];

    const exerciseIds = [...new Set(rawIds.map((id) => String(id).trim()).filter(Boolean))];
    const workoutDayId = payload.workoutDayId ? String(payload.workoutDayId).trim() : null;
    const completedAt = payload.completedAt ? new Date(payload.completedAt) : new Date();
    const durationMinutes = Number.isFinite(Number(payload.durationMinutes))
      ? Math.max(0, Math.floor(Number(payload.durationMinutes)))
      : null;
    const notes = typeof payload.notes === 'string' ? payload.notes.trim() : null;

    if (!exerciseIds.length && !workoutDayId) {
      return res.status(400).json({
        success: false,
        message: 'Provide exerciseIds/completedExerciseIds or workoutDayId to log a workout'
      });
    }

    await client.query('BEGIN');

    let targetExerciseIds = exerciseIds;
    if (!targetExerciseIds.length && workoutDayId) {
      const dayExercises = await client.query(
        `SELECT wde.id::text AS id
         FROM workout_day_exercises wde
         JOIN workout_days wd ON wd.id = wde.workout_day_id
         LEFT JOIN workout_weeks ww ON ww.id = wd.workout_week_id
         JOIN workout_plans wp
           ON wp.id = COALESCE(wd.workout_plan_id, ww.workout_plan_id)
         WHERE wd.id = $1 AND wp.user_id = $2`,
        [workoutDayId, req.user.userId]
      );

      targetExerciseIds = dayExercises.rows.map((row) => row.id);
    }

    if (!targetExerciseIds.length) {
      await client.query('ROLLBACK');
      return res.status(404).json({
        success: false,
        message: 'No workout exercises found to log'
      });
    }

    const updateResult = await client.query(
      `UPDATE workout_day_exercises wde
       SET is_completed = TRUE,
           completed_at = COALESCE(wde.completed_at, $3),
           updated_at = NOW()
       FROM workout_days wd
       LEFT JOIN workout_weeks ww ON ww.id = wd.workout_week_id
       JOIN workout_plans wp
         ON wp.id = COALESCE(wd.workout_plan_id, ww.workout_plan_id)
       WHERE wde.id::text = ANY($1::text[])
         AND wde.workout_day_id = wd.id
         AND wp.user_id = $2
         AND ($4::text IS NULL OR wd.id::text = $4::text)
       RETURNING wde.id, wde.workout_day_id, wde.completed_at`,
      [targetExerciseIds, req.user.userId, completedAt, workoutDayId]
    );

    if (!updateResult.rows.length) {
      await client.query('ROLLBACK');
      return res.status(404).json({
        success: false,
        message: 'No matching workout exercises found for this user'
      });
    }

    await client.query(
      `INSERT INTO audit_logs (
        user_id, action, entity_type, entity_id, new_values, created_at
      ) VALUES ($1, $2, $3, NULL, $4::jsonb, NOW())`,
      [
        req.user.userId,
        'workout_logged',
        'workout_session',
        JSON.stringify({
          completedExerciseIds: updateResult.rows.map((row) => row.id),
          workoutDayId,
          durationMinutes,
          notes
        })
      ]
    );

    await client.query('COMMIT');

    res.json({
      success: true,
      message: 'Workout logged successfully',
      logged: {
        completedExercises: updateResult.rows.length,
        exerciseIds: updateResult.rows.map((row) => row.id),
        workoutDayId: workoutDayId ?? updateResult.rows[0].workout_day_id,
        durationMinutes
      }
    });
  } catch (error) {
    await client.query('ROLLBACK');
    logger.error('Log workout (compat) error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to log workout'
    });
  } finally {
    client.release();
  }
};

/**
 * Get workout history (Flutter-compatible)
 */
exports.getWorkoutHistoryCompat = async (req, res) => {
  try {
    const result = await db.query(
      `SELECT * FROM workout_plans
       WHERE user_id = $1
       ORDER BY start_date DESC`,
      [req.user.userId]
    );

    res.json(result.rows);
  } catch (error) {
    logger.error('Get workout history (compat) error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to load workout history'
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
            'id', wde.id,
            'exerciseId', wde.exercise_id,
            'name', COALESCE(wde.exercise_name, e.name, e.name_en, wde.exercise_id),
            'nameAr', COALESCE(wde.exercise_name_ar, e.name_ar),
            'nameEn', COALESCE(e.name_en, wde.exercise_name),
            'category', e.category,
            'sets', wde.sets,
            'reps', wde.reps,
            'restTime', wde.rest_seconds,
            'isCompleted', wde.is_completed,
            'wasSubstituted', wde.was_substituted,
            'substitutionReason', wde.substitution_reason,
            'videoUrl', e.video_url,
            'thumbnailUrl', e.thumbnail_url
          ) ORDER BY wde.exercise_order
        ) as exercises
       FROM workout_days wd
       LEFT JOIN workout_day_exercises wde ON wd.id = wde.workout_day_id
       LEFT JOIN exercises e ON e.id::text = wde.exercise_id
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
      `UPDATE workout_day_exercises
       SET is_completed = TRUE,
           completed_at = NOW()
       WHERE id = $1
       AND workout_day_id IN (
         SELECT wd.id
         FROM workout_days wd
         LEFT JOIN workout_weeks ww ON ww.id = wd.workout_week_id
         WHERE wd.workout_plan_id = $2 OR ww.workout_plan_id = $2
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
      `UPDATE workout_day_exercises
       SET exercise_id = $1,
           exercise_name = $2,
           exercise_name_ar = $3,
           was_substituted = TRUE,
           original_exercise_id = $4,
           substitution_reason = $5
       WHERE id = $6`,
      [
        alternative.id,
        alternative.name || alternative.name_en || alternative.id,
        alternative.name_ar || null,
        exerciseId,
        reason,
        req.body.workoutExerciseId
      ]
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
    let weekId = null;
    try {
      const weekResult = await client.query(
        `INSERT INTO workout_weeks (workout_plan_id, week_number, created_at, updated_at)
         VALUES ($1, 1, NOW(), NOW())
         RETURNING *`,
        [plan.id]
      );
      weekId = weekResult.rows[0]?.id || null;
    } catch (_) {
      weekId = null;
    }

    for (const day of days) {
      const dayResult = await client.query(
        `INSERT INTO workout_days (workout_plan_id, workout_week_id, day_name, day_number, notes)
         VALUES ($1, $2, $3, $4, $5)
         RETURNING *`,
        [plan.id, weekId, day.dayName, day.dayNumber, day.notes]
      );
      
      const workoutDay = dayResult.rows[0];
      
      for (let i = 0; i < day.exercises.length; i++) {
        const exercise = day.exercises[i];
        
        await client.query(
          `INSERT INTO workout_day_exercises (
            workout_day_id, exercise_id, exercise_name, sets, reps, rest_seconds, tempo, notes, exercise_order
          ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
          [
            workoutDay.id,
            exercise.exerciseId,
            exercise.name || exercise.exerciseId,
            exercise.sets,
            exercise.reps,
            exercise.restTime ? parseInt(exercise.restTime, 10) || null : null,
            exercise.tempo,
            exercise.notes,
            i + 1
          ]
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
