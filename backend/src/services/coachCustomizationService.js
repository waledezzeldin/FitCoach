const { v4: uuidv4 } = require('uuid');
const db = require('../database');
const logger = require('../utils/logger');

/**
 * Coach Customization Service
 * Allows coaches to customize workout plans for specific users
 * without affecting the base templates or other users
 */

class CoachCustomizationService {
  /**
   * Clone a workout plan for customization
   * Creates a coach-specific copy that can be modified per user
   */
  async cloneWorkoutPlanForCustomization(workoutPlanId, coachId, customizationNotes = null) {
    const client = await db.getClient();

    try {
      await client.query('BEGIN');

      // Get original workout plan
      const planResult = await client.query(
        'SELECT * FROM workout_plans WHERE id = $1',
        [workoutPlanId]
      );

      if (planResult.rows.length === 0) {
        throw new Error('Workout plan not found');
      }

      const originalPlan = planResult.rows[0];

      // Create cloned plan with coach ownership
      const newPlanId = uuidv4();
      const clonedPlanResult = await client.query(
        `INSERT INTO workout_plans (
          id, user_id, coach_id, name, name_ar, description, description_ar,
          goal, duration_weeks, days_per_week, start_date, end_date,
          is_active, template_id, template_type, is_custom, custom_notes,
          created_at, updated_at
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, true, $16, NOW(), NOW())
        RETURNING *`,
        [
          newPlanId,
          originalPlan.user_id,
          coachId,
          originalPlan.name + ' (Custom)',
          originalPlan.name_ar + ' (مخصص)',
          originalPlan.description,
          originalPlan.description_ar,
          originalPlan.goal,
          originalPlan.duration_weeks,
          originalPlan.days_per_week,
          originalPlan.start_date,
          originalPlan.end_date,
          originalPlan.is_active,
          originalPlan.template_id,
          originalPlan.template_type,
          customizationNotes
        ]
      );

      const clonedPlan = clonedPlanResult.rows[0];

      // Clone metadata
      const metadataResult = await client.query(
        'SELECT * FROM workout_plan_metadata WHERE workout_plan_id = $1',
        [workoutPlanId]
      );

      if (metadataResult.rows.length > 0) {
        const metadata = metadataResult.rows[0];
        await client.query(
          `INSERT INTO workout_plan_metadata (
            id, workout_plan_id, location, blocks, fitness_score_projection,
            routing_config, created_at, updated_at
          ) VALUES ($1, $2, $3, $4, $5, $6, NOW(), NOW())`,
          [
            uuidv4(),
            newPlanId,
            metadata.location,
            metadata.blocks,
            metadata.fitness_score_projection,
            metadata.routing_config
          ]
        );
      }

      // Clone weeks and days
      const weeksResult = await client.query(
        'SELECT * FROM workout_weeks WHERE workout_plan_id = $1 ORDER BY week_number',
        [workoutPlanId]
      );

      for (const week of weeksResult.rows) {
        const newWeekId = uuidv4();
        await client.query(
          `INSERT INTO workout_weeks (
            id, workout_plan_id, week_number, created_at, updated_at
          ) VALUES ($1, $2, $3, NOW(), NOW())`,
          [newWeekId, newPlanId, week.week_number]
        );

        // Clone days for this week
        const daysResult = await client.query(
          'SELECT * FROM workout_days WHERE workout_week_id = $1 ORDER BY day_number',
          [week.id]
        );

        for (const day of daysResult.rows) {
          const newDayId = uuidv4();
          await client.query(
            `INSERT INTO workout_days (
              id, workout_week_id, day_number, day_name, day_name_ar,
              focus, focus_ar, notes, created_at, updated_at
            ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, NOW(), NOW())`,
            [
              newDayId,
              newWeekId,
              day.day_number,
              day.day_name,
              day.day_name_ar,
              day.focus,
              day.focus_ar,
              day.notes
            ]
          );

          // Clone exercises for this day
          const exercisesResult = await client.query(
            'SELECT * FROM workout_day_exercises WHERE workout_day_id = $1 ORDER BY exercise_order',
            [day.id]
          );

          for (const exercise of exercisesResult.rows) {
            await client.query(
              `INSERT INTO workout_day_exercises (
                id, workout_day_id, exercise_id, exercise_name, exercise_name_ar,
                sets, reps, rest_seconds, rpe, tempo, notes, notes_ar, exercise_order,
                equipment, muscles, video_id, was_substituted, original_exercise_id,
                substitution_reason, is_completed, completed_at, created_at, updated_at
              ) VALUES (
                $1, $2, $3, $4, $5,
                $6, $7, $8, $9, $10, $11, $12, $13,
                $14, $15, $16, $17, $18,
                $19, $20, $21, NOW(), NOW()
              )`,
              [
                uuidv4(),
                newDayId,
                exercise.exercise_id,
                exercise.exercise_name || exercise.exercise_id,
                exercise.exercise_name_ar || null,
                exercise.sets,
                exercise.reps,
                exercise.rest_seconds,
                exercise.rpe,
                exercise.tempo,
                exercise.notes,
                exercise.notes_ar,
                exercise.exercise_order,
                exercise.equipment,
                exercise.muscles,
                exercise.video_id,
                exercise.was_substituted || false,
                exercise.original_exercise_id || null,
                exercise.substitution_reason || null,
                exercise.is_completed || false,
                exercise.completed_at || null
              ]
            );
          }
        }
      }

      // Log customization
      await client.query(
        `INSERT INTO coach_customization_log (
          id, coach_id, user_id, workout_plan_id, original_plan_id,
          customization_type, notes, created_at
        ) VALUES ($1, $2, $3, $4, $5, 'clone', $6, NOW())`,
        [
          uuidv4(),
          coachId,
          originalPlan.user_id,
          newPlanId,
          workoutPlanId,
          customizationNotes
        ]
      );

      await client.query('COMMIT');

      logger.info(`Workout plan ${workoutPlanId} cloned to ${newPlanId} by coach ${coachId}`);

      return clonedPlan;

    } catch (error) {
      await client.query('ROLLBACK');
      logger.error('Error cloning workout plan:', error);
      throw error;
    } finally {
      client.release();
    }
  }

  /**
   * Update specific exercise in a workout plan
   * Only affects this specific user's plan
   */
  async updateExerciseInPlan(workoutPlanId, exerciseId, updates, coachId) {
    const client = await db.getClient();

    try {
      await client.query('BEGIN');

      // Verify coach has permission to edit this plan
      const planCheck = await client.query(
        'SELECT user_id FROM workout_plans WHERE id = $1 AND (coach_id = $2 OR is_custom = true)',
        [workoutPlanId, coachId]
      );

      if (planCheck.rows.length === 0) {
        throw new Error('Unauthorized: Coach does not have permission to edit this plan');
      }

      const userId = planCheck.rows[0].user_id;

      // Update exercise
      const updateFields = [];
      const updateValues = [];
      let paramCount = 1;

      if (updates.sets !== undefined) {
        updateFields.push(`sets = $${paramCount++}`);
        updateValues.push(updates.sets);
      }
      if (updates.reps !== undefined) {
        updateFields.push(`reps = $${paramCount++}`);
        updateValues.push(updates.reps);
      }
      if (updates.rest_seconds !== undefined) {
        updateFields.push(`rest_seconds = $${paramCount++}`);
        updateValues.push(updates.rest_seconds);
      }
      if (updates.rpe !== undefined) {
        updateFields.push(`rpe = $${paramCount++}`);
        updateValues.push(updates.rpe);
      }
      if (updates.tempo !== undefined) {
        updateFields.push(`tempo = $${paramCount++}`);
        updateValues.push(updates.tempo);
      }
      if (updates.notes !== undefined) {
        updateFields.push(`notes = $${paramCount++}`);
        updateValues.push(updates.notes);
      }

      if (updateFields.length === 0) {
        throw new Error('No updates provided');
      }

      updateFields.push(`updated_at = NOW()`);
      updateValues.push(exerciseId);

      const result = await client.query(
        `UPDATE workout_day_exercises 
         SET ${updateFields.join(', ')}
         WHERE id = $${paramCount}
         RETURNING *`,
        updateValues
      );

      // Log customization
      await client.query(
        `INSERT INTO coach_customization_log (
          id, coach_id, user_id, workout_plan_id, exercise_id,
          customization_type, changes, created_at
        ) VALUES ($1, $2, $3, $4, $5, 'exercise_update', $6, NOW())`,
        [
          uuidv4(),
          coachId,
          userId,
          workoutPlanId,
          exerciseId,
          JSON.stringify(updates)
        ]
      );

      await client.query('COMMIT');

      logger.info(`Exercise ${exerciseId} updated by coach ${coachId} in plan ${workoutPlanId}`);

      return result.rows[0];

    } catch (error) {
      await client.query('ROLLBACK');
      logger.error('Error updating exercise:', error);
      throw error;
    } finally {
      client.release();
    }
  }

  /**
   * Add custom note to workout day for specific user
   */
  async addCustomNoteToDay(workoutDayId, note, coachId) {
    try {
      // Get plan info
      const planResult = await db.query(
        `SELECT wp.id as plan_id, wp.user_id, wp.coach_id
         FROM workout_days wd
         JOIN workout_weeks ww ON wd.workout_week_id = ww.id
         JOIN workout_plans wp ON ww.workout_plan_id = wp.id
         WHERE wd.id = $1`,
        [workoutDayId]
      );

      if (planResult.rows.length === 0) {
        throw new Error('Workout day not found');
      }

      const plan = planResult.rows[0];

      // Verify permission
      if (plan.coach_id !== coachId) {
        throw new Error('Unauthorized: Coach does not have permission');
      }

      // Update day with note
      const result = await db.query(
        `UPDATE workout_days 
         SET notes = $1, updated_at = NOW()
         WHERE id = $2
         RETURNING *`,
        [note, workoutDayId]
      );

      // Log customization
      await db.query(
        `INSERT INTO coach_customization_log (
          id, coach_id, user_id, workout_plan_id, workout_day_id,
          customization_type, notes, created_at
        ) VALUES ($1, $2, $3, $4, $5, 'day_note', $6, NOW())`,
        [
          uuidv4(),
          coachId,
          plan.user_id,
          plan.plan_id,
          workoutDayId,
          note
        ]
      );

      logger.info(`Custom note added to day ${workoutDayId} by coach ${coachId}`);

      return result.rows[0];

    } catch (error) {
      logger.error('Error adding custom note:', error);
      throw error;
    }
  }

  /**
   * Get coach's customization history for a user
   */
  async getCustomizationHistory(coachId, userId, limit = 50) {
    try {
      const result = await db.query(
        `SELECT 
          ccl.*,
          wp.name as workout_plan_name,
          e.name as exercise_name
         FROM coach_customization_log ccl
         LEFT JOIN workout_plans wp ON ccl.workout_plan_id = wp.id
         LEFT JOIN exercises e ON ccl.exercise_id = e.id
         WHERE ccl.coach_id = $1 AND ccl.user_id = $2
         ORDER BY ccl.created_at DESC
         LIMIT $3`,
        [coachId, userId, limit]
      );

      return result.rows;

    } catch (error) {
      logger.error('Error getting customization history:', error);
      throw error;
    }
  }
}

module.exports = new CoachCustomizationService();
