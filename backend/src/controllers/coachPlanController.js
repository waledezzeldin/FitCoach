const db = require('../database');
const logger = require('../utils/logger');
const { v4: uuidv4 } = require('uuid');
const exerciseCatalogService = require('../services/exerciseCatalogService');

const resolveCoachRecord = async (coachRef) => {
  const result = await db.query(
    'SELECT * FROM coaches WHERE id = $1 OR user_id = $1',
    [coachRef]
  );
  return result.rows[0] || null;
};

const parseRestSeconds = (restTime) => {
  if (restTime === null || restTime === undefined) return null;
  if (typeof restTime === 'number') return restTime;
  if (typeof restTime === 'string') {
    const match = restTime.match(/\d+/);
    return match ? parseInt(match[0], 10) : null;
  }
  return null;
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
      wd.focus,
      wd.focus_ar,
      ww.week_number,
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
     GROUP BY wd.id, ww.week_number
     ORDER BY COALESCE(ww.week_number, 1), wd.day_number`,
    [planId]
  );

  const applyCatalogToExercise = async (exercise) => {
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

  plan.days = await Promise.all(daysResult.rows.map(async (day) => ({
    id: day.id,
    dayName: day.day_name,
    dayNameAr: day.day_name_ar,
    dayNumber: day.day_number,
    notes: day.notes,
    focus: day.focus,
    focusAr: day.focus_ar,
    weekNumber: day.week_number || 1,
    exercises: await Promise.all(
      (day.exercises || []).filter(Boolean).map(async (exercise) => ({
        ...(await applyCatalogToExercise(exercise)),
        restTime: exercise.restTime ? `${exercise.restTime}` : null
      }))
    )
  })));

  return plan;
};

const buildPlanDataFromPlan = (plan) => {
  if (!plan) return null;

  const days = (plan.days || []).map((day) => ({
    dayNumber: day.dayNumber,
    day: day.dayNumber,
    name: day.dayName,
    nameAr: day.dayNameAr,
    notes: day.notes,
    exercises: (day.exercises || []).map((exercise) => ({
      exerciseId: exercise.exerciseId,
      id: exercise.exerciseId,
      name: exercise.name,
      nameAr: exercise.nameAr,
      nameEn: exercise.nameEn,
      sets: exercise.sets,
      reps: exercise.reps,
      restTime: exercise.restTime,
      tempo: exercise.tempo,
      notes: exercise.notes
    }))
  }));

  const weeksMap = new Map();
  for (const day of plan.days || []) {
    const weekNumber = day.weekNumber || 1;
    if (!weeksMap.has(weekNumber)) {
      weeksMap.set(weekNumber, []);
    }
    weeksMap.get(weekNumber).push({
      dayNumber: day.dayNumber,
      day: day.dayNumber,
      name: day.dayName,
      nameAr: day.dayNameAr,
      notes: day.notes,
      exercises: (day.exercises || []).map((exercise) => ({
        exerciseId: exercise.exerciseId,
        id: exercise.exerciseId,
        name: exercise.name,
        nameAr: exercise.nameAr,
        nameEn: exercise.nameEn,
        sets: exercise.sets,
        reps: exercise.reps,
        restTime: exercise.restTime,
        tempo: exercise.tempo,
        notes: exercise.notes
      }))
    });
  }

  const weeks = Array.from(weeksMap.entries())
    .sort(([a], [b]) => a - b)
    .map(([weekNumber, weekDays]) => ({
      weekNumber,
      days: weekDays
    }));

  return {
    name: plan.name,
    description: plan.description,
    goal: plan.goal,
    daysPerWeek: plan.days_per_week || (plan.days || []).length,
    days,
    weeks
  };
};

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

    const coachRecord = await resolveCoachRecord(coachId);

    if (!coachRecord) {
      return res.status(404).json({
        success: false,
        message: 'Coach not found'
      });
    }
    
    // Verify coach owns this client
    const clientCheck = await db.query(
      'SELECT id FROM user_coaches WHERE user_id = $1 AND coach_id = $2 AND is_active = TRUE',
      [clientId, coachRecord.id]
    );
    
    if (clientCheck.rows.length === 0) {
      return res.status(403).json({
        success: false,
        message: 'Client not assigned to this coach'
      });
    }
    
    // Get current workout plan
    const result = await db.query(
      `SELECT id FROM workout_plans
       WHERE user_id = $1 AND is_active = TRUE
       ORDER BY start_date DESC
       LIMIT 1`,
      [clientId]
    );

    if (result.rows.length === 0) {
      return res.json({
        success: true,
        workoutPlan: null
      });
    }

    const plan = await buildPlanWithDays(result.rows[0].id);
    const planData = buildPlanDataFromPlan(plan);

    res.json({
      success: true,
      workoutPlan: {
        ...plan,
        plan_data: planData,
        planData
      }
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

    const coachRecord = await resolveCoachRecord(coachId);

    if (!coachRecord) {
      client.release();
      return res.status(404).json({
        success: false,
        message: 'Coach not found'
      });
    }
    
    await client.query('BEGIN');
    
    // Verify coach owns this client
    const clientCheck = await client.query(
      'SELECT id FROM user_coaches WHERE user_id = $1 AND coach_id = $2 AND is_active = TRUE',
      [clientId, coachRecord.id]
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
      `UPDATE workout_plans
       SET is_active = FALSE
       WHERE user_id = $1 AND is_active = TRUE`,
      [clientId]
    );

    const normalizedPlanData = planData || {};
    const planName = normalizedPlanData.name || 'Coach Plan';
    const planDescription = normalizedPlanData.description || notes || null;
    const planGoal = normalizedPlanData.goal || null;

    const rawDays = Array.isArray(normalizedPlanData.days)
      ? normalizedPlanData.days
      : null;
    const rawWeeks = Array.isArray(normalizedPlanData.weeks)
      ? normalizedPlanData.weeks
      : null;

    const totalDays = rawWeeks
      ? rawWeeks.reduce((sum, week) => sum + (Array.isArray(week.days) ? week.days.length : 0), 0)
      : (rawDays ? rawDays.length : 0);

    const planResult = await client.query(
      `INSERT INTO workout_plans (
        id, user_id, coach_id, name, description, goal,
        days_per_week, start_date, is_active, created_at, updated_at
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, CURRENT_DATE, TRUE, NOW(), NOW())
      RETURNING *`,
      [
        uuidv4(),
        clientId,
        coachRecord.id,
        planName,
        planDescription,
        planGoal,
        normalizedPlanData.daysPerWeek || totalDays || null
      ]
    );

    const plan = planResult.rows[0];

    const weeksToInsert = rawWeeks && rawWeeks.length
      ? rawWeeks
      : [{ weekNumber: 1, days: rawDays || [] }];

    for (let weekIndex = 0; weekIndex < weeksToInsert.length; weekIndex++) {
      const week = weeksToInsert[weekIndex] || {};
      const weekNumber = week.weekNumber || weekIndex + 1;

      const weekInsert = await client.query(
        `INSERT INTO workout_weeks (
          id, workout_plan_id, week_number, notes, created_at, updated_at
        ) VALUES ($1, $2, $3, $4, NOW(), NOW())
        RETURNING id`,
        [uuidv4(), plan.id, weekNumber, week.notes || null]
      );

      const weekId = weekInsert.rows[0].id;
      const weekDays = Array.isArray(week.days) ? week.days : [];

      for (let dayIndex = 0; dayIndex < weekDays.length; dayIndex++) {
        const day = weekDays[dayIndex] || {};
        const dayNumber = day.dayNumber || day.day || dayIndex + 1;
        const dayName = day.name || day.dayName || `Day ${dayNumber}`;

        const dayInsert = await client.query(
          `INSERT INTO workout_days (
            id, workout_plan_id, workout_week_id, day_name, day_name_ar, day_number, notes, focus, focus_ar, created_at, updated_at
          ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, NOW(), NOW())
          RETURNING id`,
          [
            uuidv4(),
            plan.id,
            weekId,
            dayName,
            day.nameAr || day.dayNameAr || null,
            dayNumber,
            day.notes || null,
            day.focus || null,
            day.focusAr || null
          ]
        );

        const dayId = dayInsert.rows[0].id;
        const exercises = Array.isArray(day.exercises) ? day.exercises : [];

        for (let exerciseIndex = 0; exerciseIndex < exercises.length; exerciseIndex++) {
          const exercise = exercises[exerciseIndex] || {};
          const exerciseName = exercise.name || exercise.exerciseName || exercise.title || `Exercise ${exerciseIndex + 1}`;
          const exerciseId = exercise.exerciseId || exercise.id || exercise.exercise_id || null;
          const catalog = exerciseId ? await exerciseCatalogService.getById(exerciseId) : null;
          const resolvedNameEn = exercise.nameEn || exerciseName || catalog?.name_en || exerciseId || `Exercise ${exerciseIndex + 1}`;
          const resolvedNameAr = exercise.nameAr || catalog?.name_ar || resolvedNameEn;
          const resolvedEquip = exercise.equipment || catalog?.equip || null;
          const resolvedMuscles = exercise.muscles || catalog?.muscles || null;
          const resolvedVideoId = exercise.videoId || catalog?.video_id || null;

          await client.query(
            `INSERT INTO workout_day_exercises (
              id, workout_day_id, exercise_id, exercise_name, exercise_name_ar,
              sets, reps, rest_seconds, tempo, notes, notes_ar,
              equipment, muscles, video_id, exercise_order, created_at, updated_at
            ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, NOW(), NOW())`,
            [
              uuidv4(),
              dayId,
              exerciseId,
              resolvedNameEn,
              resolvedNameAr,
              parseInt(exercise.sets, 10) || 3,
              exercise.reps ? `${exercise.reps}` : '10',
              parseRestSeconds(exercise.restTime || exercise.rest || exercise.rest_seconds),
              exercise.tempo || null,
              exercise.notes || null,
              exercise.notesAr || null,
              resolvedEquip ? JSON.stringify(resolvedEquip) : null,
              resolvedMuscles ? JSON.stringify(resolvedMuscles) : null,
              resolvedVideoId,
              exerciseIndex + 1
            ]
          );
        }
      }
    }
    
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
        JSON.stringify({ planId: plan.id })
      ]
    );
    
    res.json({
      success: true,
      message: 'Workout plan updated successfully',
      workoutPlan: {
        ...plan,
        plan_data: normalizedPlanData,
        planData: normalizedPlanData
      }
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
