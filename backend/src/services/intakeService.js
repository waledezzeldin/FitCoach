const { v4: uuidv4 } = require('uuid');
const db = require('../database');
const logger = require('../utils/logger');
const workoutGenerationService = require('./workoutGenerationService');

/**
 * Intake Service
 * Handles two-stage intake system:
 * - Stage 1 (Basic): 3 questions - goal, location, training_days (all users)
 * - Stage 2 (Full): Complete questionnaire (Premium+ only)
 */

class IntakeService {
  /**
   * Submit Stage 1 intake (basic - 3 questions)
   * Available to ALL users (Freemium + Premium)
   */
  async submitStage1(userId, intakeData) {
    const client = await db.getClient();

    try {
      await client.query('BEGIN');

      const {
        primary_goal,      // 'fat_loss', 'muscle_gain', 'general_fitness'
        workout_location,  // 'gym', 'home'
        training_days_per_week  // For freemium: always 3
      } = intakeData;

      // Validate required fields
      if (!primary_goal || !workout_location) {
        throw new Error('Primary goal and workout location are required');
      }

      // Get user subscription tier
      const userResult = await client.query(
        'SELECT subscription_tier FROM users WHERE id = $1',
        [userId]
      );

      if (userResult.rows.length === 0) {
        throw new Error('User not found');
      }

      const user = userResult.rows[0];
      const isFreemium = user.subscription_tier === 'freemium';

      // Freemium users: force 3 days
      const finalTrainingDays = isFreemium ? 3 : (training_days_per_week || 3);

      // Check if intake exists
      const existingIntake = await client.query(
        'SELECT id FROM user_intake WHERE user_id = $1',
        [userId]
      );

      let intakeId;

      if (existingIntake.rows.length > 0) {
        // Update existing
        await client.query(
          `UPDATE user_intake 
           SET primary_goal = $1,
               workout_location = $2,
               training_days_per_week = $3,
               intake_completed_stage = 'basic',
               updated_at = NOW()
           WHERE user_id = $4`,
          [primary_goal, workout_location, finalTrainingDays, userId]
        );
        intakeId = existingIntake.rows[0].id;
      } else {
        // Create new
        const result = await client.query(
          `INSERT INTO user_intake (
            id, user_id, primary_goal, workout_location, training_days_per_week,
            intake_completed_stage, created_at, updated_at
          ) VALUES ($1, $2, $3, $4, $5, 'basic', NOW(), NOW())
          RETURNING id`,
          [uuidv4(), userId, primary_goal, workout_location, finalTrainingDays]
        );
        intakeId = result.rows[0].id;
      }

      // Update user table
      await client.query(
        `UPDATE users 
         SET primary_goal = $1,
             workout_location = $2,
             training_days_per_week = $3,
             first_intake_completed = true,
             updated_at = NOW()
         WHERE id = $4`,
        [primary_goal, workout_location, finalTrainingDays, userId]
      );

      // Auto-generate starter workout plan
      const template = await workoutGenerationService.getStarterTemplate(
        primary_goal,
        workout_location,
        finalTrainingDays
      );

      let workoutPlan = null;
      if (template) {
        const planResult = await workoutGenerationService.generateFromTemplate(
          userId,
          template.plan_id,
          null,
          { startDate: new Date() }
        );
        workoutPlan = planResult.plan;
      }

      await client.query('COMMIT');

      logger.info(`Stage 1 intake completed for user ${userId}`);

      return {
        intakeId,
        stage: 'basic',
        canAccessStage2: !isFreemium, // Only premium can access stage 2
        workoutPlanGenerated: !!workoutPlan,
        workoutPlan: workoutPlan ? {
          id: workoutPlan.id,
          name: workoutPlan.name,
          trainingDays: finalTrainingDays
        } : null
      };

    } catch (error) {
      await client.query('ROLLBACK');
      logger.error('Stage 1 intake submission error:', error);
      throw error;
    } finally {
      client.release();
    }
  }

  /**
   * Submit Stage 2 intake (full questionnaire)
   * Available to PREMIUM+ users only
   */
  async submitStage2(userId, intakeData) {
    const client = await db.getClient();

    try {
      await client.query('BEGIN');

      // Check if user is premium
      const userResult = await client.query(
        'SELECT subscription_tier FROM users WHERE id = $1',
        [userId]
      );

      if (userResult.rows.length === 0) {
        throw new Error('User not found');
      }

      const user = userResult.rows[0];
      const isPremiumOrAbove = ['premium', 'smart_premium'].includes(user.subscription_tier);

      if (!isPremiumOrAbove) {
        throw new Error('Premium subscription required to complete full intake');
      }

      const {
        age,
        weight,
        height,
        gender,
        experience_level,
        fitness_level,
        injury_history,
        health_conditions,
        available_equipment,
        training_preference,
        nutrition_preference
      } = intakeData;

      // Update user_intake
      await client.query(
        `UPDATE user_intake 
         SET age = $1,
             weight = $2,
             height = $3,
             gender = $4,
             experience_level = $5,
             fitness_level = $6,
             injury_history = $7,
             health_conditions = $8,
             available_equipment = $9,
             training_preference = $10,
             nutrition_preference = $11,
             intake_completed_stage = 'full',
             updated_at = NOW()
         WHERE user_id = $12`,
        [
          age, weight, height, gender, experience_level, fitness_level,
          JSON.stringify(injury_history || []),
          JSON.stringify(health_conditions || []),
          JSON.stringify(available_equipment || []),
          training_preference,
          nutrition_preference,
          userId
        ]
      );

      // Update user table
      await client.query(
        `UPDATE users 
         SET age = $1,
             weight = $2,
             height = $3,
             gender = $4,
             experience_level = $5,
             fitness_level = $6,
             updated_at = NOW()
         WHERE id = $7`,
        [age, weight, height, gender, experience_level, fitness_level, userId]
      );

      // Get recommended advanced template
      const recommendation = await workoutGenerationService.recommendTemplate(userId);

      await client.query('COMMIT');

      logger.info(`Stage 2 intake completed for user ${userId}`);

      return {
        stage: 'full',
        intakeCompleted: true,
        recommendedTemplate: recommendation ? {
          id: recommendation.plan_id,
          name: recommendation.name_en,
          nameAr: recommendation.name_ar,
          trainingDays: recommendation.training_days
        } : null
      };

    } catch (error) {
      await client.query('ROLLBACK');
      logger.error('Stage 2 intake submission error:', error);
      throw error;
    } finally {
      client.release();
    }
  }

  /**
   * Get user's intake status
   */
  async getIntakeStatus(userId) {
    try {
      const result = await db.query(
        `SELECT 
          ui.*,
          u.subscription_tier,
          u.first_intake_completed
         FROM user_intake ui
         JOIN users u ON ui.user_id = u.id
         WHERE ui.user_id = $1`,
        [userId]
      );

      if (result.rows.length === 0) {
        return {
          stage1Completed: false,
          stage2Completed: false,
          canAccessStage2: false,
          data: null
        };
      }

      const intake = result.rows[0];
      const isFreemium = intake.subscription_tier === 'freemium';
      const stage1Completed = intake.intake_completed_stage === 'basic' || intake.intake_completed_stage === 'full';
      const stage2Completed = intake.intake_completed_stage === 'full';

      return {
        stage1Completed,
        stage2Completed,
        canAccessStage2: !isFreemium,
        subscriptionTier: intake.subscription_tier,
        data: {
          // Stage 1 data
          primary_goal: intake.primary_goal,
          workout_location: intake.workout_location,
          training_days_per_week: intake.training_days_per_week,
          
          // Stage 2 data (if completed)
          ...(stage2Completed && {
            age: intake.age,
            weight: intake.weight,
            height: intake.height,
            gender: intake.gender,
            experience_level: intake.experience_level,
            fitness_level: intake.fitness_level,
            injury_history: intake.injury_history,
            health_conditions: intake.health_conditions,
            available_equipment: intake.available_equipment,
            training_preference: intake.training_preference,
            nutrition_preference: intake.nutrition_preference
          })
        }
      };

    } catch (error) {
      logger.error('Get intake status error:', error);
      throw error;
    }
  }

  /**
   * Prompt user to complete Stage 2 (for Premium users)
   */
  async shouldPromptStage2(userId) {
    try {
      const result = await db.query(
        `SELECT 
          ui.intake_completed_stage,
          u.subscription_tier,
          u.created_at
         FROM users u
         LEFT JOIN user_intake ui ON u.id = ui.user_id
         WHERE u.id = $1`,
        [userId]
      );

      if (result.rows.length === 0) {
        return { shouldPrompt: false };
      }

      const user = result.rows[0];
      const isPremium = ['premium', 'smart_premium'].includes(user.subscription_tier);
      const hasCompletedStage1 = user.intake_completed_stage === 'basic';
      const hasCompletedStage2 = user.intake_completed_stage === 'full';

      // Prompt if: Premium user + completed stage 1 + not completed stage 2
      const shouldPrompt = isPremium && hasCompletedStage1 && !hasCompletedStage2;

      return {
        shouldPrompt,
        reason: shouldPrompt ? 'Complete your profile to unlock personalized workout plans' : null
      };

    } catch (error) {
      logger.error('Should prompt stage 2 error:', error);
      throw error;
    }
  }
}

module.exports = new IntakeService();
