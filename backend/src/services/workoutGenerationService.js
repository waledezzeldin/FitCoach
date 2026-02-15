const { v4: uuidv4 } = require('uuid');
const db = require('../database');
const workoutTemplateService = require('./workoutTemplateService');
const injuryMappingService = require('./injuryMappingService');
const logger = require('../utils/logger');
const exerciseCatalogService = require('./exerciseCatalogService');

/**
 * Workout Generation Service
 * Generates workout plans from templates (both starter and advanced)
 */

class WorkoutGenerationService {
  /**
   * Generate workout plan from template for a user
   */
  async generateFromTemplate(userId, templateId, coachId = null, customizations = {}) {
    const client = await db.getClient();

    try {
      await client.query('BEGIN');

      // Get template
      const template = workoutTemplateService.getTemplateById(templateId);
      if (!template) {
        throw new Error('Template not found');
      }

      // Get user info and intake data
      const userResult = await client.query(
        `SELECT u.*, ui.* FROM users u
         LEFT JOIN user_intake ui ON u.id = ui.user_id
         WHERE u.id = $1`,
        [userId]
      );

      if (userResult.rows.length === 0) {
        throw new Error('User not found');
      }

      const user = userResult.rows[0];

      // Determine user criteria for advanced templates
      const userCriteria = {
        location: customizations.location || user.workout_location || user.preferred_location || 'gym',
        goal: customizations.goal || user.primary_goal || 'general_fitness',
        experience_level: customizations.experience_level || user.experience_level || user.fitness_level || 'beginner',
        injuries: customizations.injuries || (user.injury_history ? JSON.parse(user.injury_history) : [])
      };

      // Get sessions from template (handles both starter and advanced)
      const sessions = await workoutTemplateService.getSessionsFromTemplate(template, userCriteria);

      // Get fitness score projection
      const fitnessScoreProjection = workoutTemplateService.getFitnessScoreProjection(
        template,
        userCriteria.experience_level
      );

      // Apply customizations
      const planData = this.applyCustomizations(template, user, customizations);

      // Create workout plan
      const planResult = await client.query(
        `INSERT INTO workout_plans (
          id, user_id, coach_id, name, name_ar, description, description_ar,
          goal, duration_weeks, days_per_week, start_date, end_date,
          is_active, template_id, template_type, created_at, updated_at
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, true, $13, $14, NOW(), NOW())
        RETURNING *`,
        [
          uuidv4(),
          userId,
          coachId,
          planData.name_en,
          planData.name_ar,
          planData.description_en,
          planData.description_ar,
          userCriteria.goal,
          template.weeks,
          template.training_days,
          customizations.startDate || new Date(),
          this.calculateEndDate(customizations.startDate || new Date(), template.weeks),
          template.plan_id,
          template.type
        ]
      );

      const workoutPlan = planResult.rows[0];

      // Store template metadata
      await client.query(
        `INSERT INTO workout_plan_metadata (
          id, workout_plan_id, location, blocks, fitness_score_projection,
          routing_config, created_at, updated_at
        ) VALUES ($1, $2, $3, $4, $5, $6, NOW(), NOW())`,
        [
          uuidv4(),
          workoutPlan.id,
          userCriteria.location,
          JSON.stringify(template.blocks || []),
          JSON.stringify(fitnessScoreProjection || {}),
          JSON.stringify(template.routing || {})
        ]
      );

      // Create workout sessions based on extracted sessions
      for (let weekNum = 1; weekNum <= template.weeks; weekNum++) {
        const weeklySessions = await workoutTemplateService.getSessionsForWeek(
          template,
          userCriteria,
          weekNum,
          sessions
        );

        for (const session of weeklySessions) {
          // Get or create week
          let weekResult = await client.query(
            'SELECT * FROM workout_weeks WHERE workout_plan_id = $1 AND week_number = $2',
            [workoutPlan.id, weekNum]
          );

          let workoutWeek;
          if (weekResult.rows.length === 0) {
            weekResult = await client.query(
              `INSERT INTO workout_weeks (
                id, workout_plan_id, week_number, created_at, updated_at
              ) VALUES ($1, $2, $3, NOW(), NOW())
              RETURNING *`,
              [uuidv4(), workoutPlan.id, weekNum]
            );
            workoutWeek = weekResult.rows[0];
          } else {
            workoutWeek = weekResult.rows[0];
          }

          // Create day
          const dayResult = await client.query(
            `INSERT INTO workout_days (
              id, workout_week_id, day_number, day_name, day_name_ar,
              focus, focus_ar, created_at, updated_at
            ) VALUES ($1, $2, $3, $4, $5, $6, $7, NOW(), NOW())
            RETURNING *`,
            [
              uuidv4(),
              workoutWeek.id,
              session.day,
              session.name_en || session.name,
              session.name_ar || session.name_en || session.name,
              session.name_en || session.name,
              session.name_ar || session.name_en || session.name
            ]
          );

          const workoutDay = dayResult.rows[0];

          // Create exercises for this day
          let order = 1;
          for (const exercise of session.work) {
            // Get exercise definition if available
            const exDef = workoutTemplateService.getExerciseDefinition(template, exercise.ex_id);
            const catalog = await exerciseCatalogService.getById(exercise.ex_id);

            const resolvedNameEn = exercise.name_en || exDef?.name_en || catalog?.name_en || exercise.ex_id;
            const resolvedNameAr = exercise.name_ar || exDef?.name_ar || catalog?.name_ar || resolvedNameEn;
            const resolvedEquip = exercise.equip || exDef?.equip || catalog?.equip || [];
            const resolvedMuscles = exercise.muscles || exDef?.muscles || catalog?.muscles || [];
            const resolvedVideoId = exercise.video_id || exDef?.video_id || catalog?.video_id || null;

            await client.query(
              `INSERT INTO workout_day_exercises (
                id, workout_day_id, exercise_id, exercise_name, exercise_name_ar,
                sets, reps, rest_seconds, notes, notes_ar, exercise_order,
                rpe, equipment, muscles, video_id,
                was_substituted, original_exercise_id, substitution_reason,
                created_at, updated_at
              ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, NOW(), NOW())`,
              [
                uuidv4(),
                workoutDay.id,
                exercise.ex_id,
                resolvedNameEn,
                resolvedNameAr,
                exercise.sets,
                exercise.reps,
                exercise.rest_s || exercise.rest_seconds || 90,
                exercise.notes_en || '',
                exercise.notes_ar || exercise.notes_en || '',
                order++,
                exercise.rpe || null,
                JSON.stringify(resolvedEquip),
                JSON.stringify(resolvedMuscles),
                resolvedVideoId,
                exercise.was_substituted || false,
                exercise.original_ex_id || null,
                exercise.substitution_reason || null
              ]
            );
          }

          // Store conditioning if present
          if (session.conditioning) {
            await client.query(
              `INSERT INTO workout_day_conditioning (
                id, workout_day_id, type, type_ar, protocol, protocol_ar,
                intensity, target_heart_rate, duration_min, machine_options,
                created_at, updated_at
              ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, NOW(), NOW())`,
              [
                uuidv4(),
                workoutDay.id,
                session.conditioning.type,
                session.conditioning.type_ar || session.conditioning.type,
                session.conditioning.protocol,
                session.conditioning.protocol_ar || session.conditioning.protocol,
                session.conditioning.intensity || session.conditioning.target_zone || null,
                session.conditioning.target_heart_rate || session.conditioning.target_zone || null,
                session.conditioning.duration_min || null,
                JSON.stringify(session.conditioning.machine_options || [])
              ]
            );
          }
        }
      }

      await client.query('COMMIT');

      logger.info(`Generated workout plan ${workoutPlan.id} from template ${templateId} for user ${userId}`);

      return {
        success: true,
        plan: workoutPlan,
        template: template.plan_id,
        type: template.type,
        criteria: userCriteria
      };
    } catch (error) {
      await client.query('ROLLBACK');
      logger.error('Error generating workout from template:', error);
      throw error;
    } finally {
      client.release();
    }
  }

  /**
   * Apply customizations to template
   */
  applyCustomizations(template, user, customizations) {
    const planData = {
      name_en: customizations.name_en || template.name_en,
      name_ar: customizations.name_ar || template.name_ar,
      description_en: customizations.description_en || template.description_en,
      description_ar: customizations.description_ar || template.description_ar
    };

    // Add user name to plan if desired
    if (customizations.includeUserName && user.full_name) {
      planData.name_en = `${template.name_en} - ${user.full_name}`;
      planData.name_ar = `${template.name_ar} - ${user.full_name_ar || user.full_name}`;
    }

    return planData;
  }

  /**
   * Calculate end date based on start date and duration
   */
  calculateEndDate(startDate, durationWeeks) {
    const endDate = new Date(startDate);
    endDate.setDate(endDate.getDate() + (durationWeeks * 7));
    return endDate;
  }

  /**
   * Recommend template based on user profile and intake level
   */
  async recommendTemplate(userId) {
    try {
      const userResult = await db.query(
        `SELECT u.*, ui.* FROM users u
         LEFT JOIN user_intake ui ON u.id = ui.user_id
         WHERE u.id = $1`,
        [userId]
      );

      if (userResult.rows.length === 0) {
        throw new Error('User not found');
      }

      const user = userResult.rows[0];

      // Determine intake level
      const intakeLevel = user.intake_completed_stage === 'basic' ? 'starter' : 'advanced';

      // Build intake data object
      const intakeData = {
        intake_level: intakeLevel,
        primary_goal: user.primary_goal,
        workout_location: user.workout_location || user.preferred_location,
        available_days: user.available_days || user.training_days_per_week,
        fitness_level: user.fitness_level,
        experience_level: user.experience_level
      };

      // Find best matching template
      const template = workoutTemplateService.findBestMatch(intakeData);

      if (!template) {
        logger.warn(`No template found for user ${userId} with intake level ${intakeLevel}`);
        return null;
      }

      return template;
    } catch (error) {
      logger.error('Error recommending template:', error);
      throw error;
    }
  }

  /**
   * Get template for starter intake (first 3 questions)
   */
  async getStarterTemplate(goal, location, trainingDays) {
    const templates = workoutTemplateService.searchTemplates({
      type: 'starter',
      goal,
      location,
      training_days: trainingDays
    });

    return templates[0] || null;
  }

  /**
   * Get template for advanced intake (full questionnaire)
   */
  async getAdvancedTemplate(filters) {
    const templates = workoutTemplateService.searchTemplates({
      type: 'advanced',
      ...filters
    });

    return templates[0] || null;
  }

  /**
   * Generate multiple plans for different goals
   */
  async generateMultiplePlans(userId, templateIds, coachId = null) {
    const results = [];

    for (const templateId of templateIds) {
      try {
        const result = await this.generateFromTemplate(userId, templateId, coachId);
        results.push(result);
      } catch (error) {
        logger.error(`Error generating plan from template ${templateId}:`, error);
        results.push({
          success: false,
          templateId,
          error: error.message
        });
      }
    }

    return results;
  }
}

const workoutGenerationService = new WorkoutGenerationService();

module.exports = workoutGenerationService;