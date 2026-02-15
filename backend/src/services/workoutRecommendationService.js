const db = require('../database');
const workoutTemplateService = require('./workoutTemplateService');
const logger = require('../utils/logger');

/**
 * Workout Recommendation Service
 * Automatically selects the right template based on user's intake answers
 */

class WorkoutRecommendationService {
  /**
   * Get recommended template based on intake completion stage
   * - Freemium users (3 questions) → Starter templates (3 days only)
   * - Premium users (full intake) → Premium templates (2-6 days based on preference)
   */
  async getRecommendedTemplateForUser(userId) {
    try {
      // Get user data with intake information
      const userResult = await db.query(
        `SELECT 
          u.id,
          u.subscription_tier,
          ui.primary_goal,
          ui.workout_location,
          ui.training_days_per_week,
          ui.fitness_level,
          ui.experience_level,
          ui.injury_history,
          ui.intake_completed_stage
         FROM users u
         LEFT JOIN user_intake ui ON u.id = ui.user_id
         WHERE u.id = $1`,
        [userId]
      );

      if (userResult.rows.length === 0) {
        throw new Error('User not found');
      }

      const user = userResult.rows[0];

      // Determine if user has completed intake
      const hasBasicIntake = user.primary_goal && user.workout_location;
      const hasFullIntake = user.intake_completed_stage === 'full' || user.experience_level;

      if (!hasBasicIntake) {
        logger.warn(`User ${userId} has not completed basic intake`);
        return null;
      }

      // Determine template type based on subscription and intake level
      const isFreemium = user.subscription_tier === 'freemium';
      const isPremiumOrAbove = ['premium', 'smart_premium'].includes(user.subscription_tier);

      let templateType, criteria;

      if (isFreemium || !hasFullIntake) {
        // FREEMIUM or users who haven't completed full intake → Starter templates (3 days only)
        templateType = 'starter';
        criteria = {
          goal: this.mapGoal(user.primary_goal),
          location: this.mapLocation(user.workout_location),
          training_days: 3 // Starter templates are ALWAYS 3 days
        };
      } else if (isPremiumOrAbove && hasFullIntake) {
        // PREMIUM with full intake → Advanced templates (2-6 days)
        templateType = 'advanced';
        criteria = {
          goal: this.mapGoal(user.primary_goal),
          location: this.mapLocation(user.workout_location),
          training_days: parseInt(user.training_days_per_week) || 3,
          experience_level: this.mapExperience(user.experience_level || user.fitness_level)
        };
      } else {
        // Default to starter
        templateType = 'starter';
        criteria = {
          goal: this.mapGoal(user.primary_goal),
          location: this.mapLocation(user.workout_location),
          training_days: 3
        };
      }

      // Find matching template
      const template = this.findBestTemplate(templateType, criteria);

      if (!template) {
        logger.warn(`No template found for user ${userId} with criteria:`, criteria);
        return null;
      }

      logger.info(`Recommended template ${template.plan_id} for user ${userId}`, {
        type: templateType,
        criteria
      });

      return {
        template,
        criteria,
        templateType
      };

    } catch (error) {
      logger.error('Error getting recommended template:', error);
      throw error;
    }
  }

  /**
   * Find best matching template based on type and criteria
   */
  findBestTemplate(type, criteria) {
    const filters = {
      type: type,
      ...criteria
    };

    // Search templates
    const templates = workoutTemplateService.searchTemplates(filters);

    if (templates.length === 0) {
      // Try without training_days filter
      delete filters.training_days;
      const fallbackTemplates = workoutTemplateService.searchTemplates(filters);
      
      if (fallbackTemplates.length === 0) {
        return null;
      }

      // For advanced templates, find closest match by training_days
      if (type === 'advanced' && criteria.training_days) {
        fallbackTemplates.sort((a, b) => {
          const aDiff = Math.abs(a.training_days - criteria.training_days);
          const bDiff = Math.abs(b.training_days - criteria.training_days);
          return aDiff - bDiff;
        });
      }

      return fallbackTemplates[0];
    }

    return templates[0];
  }

  /**
   * Map user's goal to template goal
   */
  mapGoal(userGoal) {
    const goalMap = {
      'lose_weight': 'fat_loss',
      'build_muscle': 'muscle_gain',
      'improve_endurance': 'endurance',
      'general_fitness': 'general_fitness',
      'get_stronger': 'strength',
      'fat_loss': 'fat_loss',
      'muscle_gain': 'muscle_gain',
      'hypertrophy': 'muscle_gain'
    };
    
    return goalMap[userGoal] || 'general_fitness';
  }

  /**
   * Map user's location to template location
   */
  mapLocation(userLocation) {
    const locationMap = {
      'at_gym': 'gym',
      'at_home': 'home',
      'gym': 'gym',
      'home': 'home',
      'outdoors': 'home', // Map outdoors to home (bodyweight)
      'both': 'gym' // Default to gym if both
    };
    
    return locationMap[userLocation] || 'gym';
  }

  /**
   * Map user's experience/fitness level
   */
  mapExperience(userLevel) {
    const experienceMap = {
      'never_trained': 'beginner',
      'less_than_6_months': 'beginner',
      '6_months_to_2_years': 'intermediate',
      'more_than_2_years': 'advanced',
      'beginner': 'beginner',
      'intermediate': 'intermediate',
      'advanced': 'advanced',
      'expert': 'advanced'
    };
    
    return experienceMap[userLevel] || 'beginner';
  }

  /**
   * Check if user is eligible for template type
   */
  async isUserEligibleForTemplate(userId, templateId) {
    try {
      const template = workoutTemplateService.getTemplateById(templateId);
      if (!template) {
        return { eligible: false, reason: 'Template not found' };
      }

      const userResult = await db.query(
        'SELECT subscription_tier, intake_completed_stage FROM users u LEFT JOIN user_intake ui ON u.id = ui.user_id WHERE u.id = $1',
        [userId]
      );

      if (userResult.rows.length === 0) {
        return { eligible: false, reason: 'User not found' };
      }

      const user = userResult.rows[0];

      // Freemium users can only access starter templates
      if (user.subscription_tier === 'freemium' && template.type !== 'starter') {
        return { 
          eligible: false, 
          reason: 'Premium subscription required for advanced templates',
          upgradeRequired: true 
        };
      }

      // Users without full intake can only access starter templates
      if (template.type === 'advanced' && user.intake_completed_stage !== 'full') {
        return { 
          eligible: false, 
          reason: 'Complete full intake questionnaire to access advanced templates',
          intakeRequired: true 
        };
      }

      return { eligible: true };

    } catch (error) {
      logger.error('Error checking user eligibility:', error);
      return { eligible: false, reason: 'Error checking eligibility' };
    }
  }

  /**
   * Get available training day options for user
   */
  async getAvailableTrainingDaysForUser(userId) {
    try {
      const userResult = await db.query(
        'SELECT subscription_tier, intake_completed_stage FROM users u LEFT JOIN user_intake ui ON u.id = ui.user_id WHERE u.id = $1',
        [userId]
      );

      if (userResult.rows.length === 0) {
        throw new Error('User not found');
      }

      const user = userResult.rows[0];
      const isFreemium = user.subscription_tier === 'freemium';
      const hasFullIntake = user.intake_completed_stage === 'full';

      // Freemium or users without full intake: only 3 days
      if (isFreemium || !hasFullIntake) {
        return {
          availableDays: [3],
          reason: isFreemium 
            ? 'Freemium tier limited to 3-day programs' 
            : 'Complete full intake to access more training days'
        };
      }

      // Premium users with full intake: 2-6 days
      return {
        availableDays: [2, 3, 4, 5, 6],
        reason: 'Full range available with premium subscription'
      };

    } catch (error) {
      logger.error('Error getting available training days:', error);
      throw error;
    }
  }
}

module.exports = new WorkoutRecommendationService();
