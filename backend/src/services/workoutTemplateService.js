const fs = require('fs').promises;
const path = require('path');
const logger = require('../utils/logger');
const injuryMappingService = require('./injuryMappingService');

/**
 * Workout Template Service
 * Handles loading, validating, and managing workout plan templates from JSON files
 * Supports two intake levels: starter (3 questions) and advanced (full intake)
 */

const TEMPLATES_DIR = path.join(__dirname, '../data/workout-templates');
const VALID_TYPES = ['starter', 'advanced'];
const VALID_GOALS = ['fat_loss', 'muscle_gain', 'general_fitness', 'endurance', 'strength', 'hypertrophy'];
const VALID_LOCATIONS = ['gym', 'home', 'outdoors', 'hybrid'];
const VALID_EXPERIENCE_LEVELS = ['beginner', 'intermediate', 'advanced'];

class WorkoutTemplateService {
  constructor() {
    this.templates = new Map();
    this.templatesByType = new Map(); // starter vs advanced
    this.templatesByGoalLocation = new Map(); // goal + location combos
  }

  /**
   * Load all templates from disk
   */
  async loadTemplates() {
    try {
      logger.info('Loading workout templates...');
      
      for (const type of VALID_TYPES) {
        const typeDir = path.join(TEMPLATES_DIR, type);
        
        try {
          const files = await fs.readdir(typeDir);
          
          for (const file of files) {
            if (file.endsWith('.json') && !file.startsWith('.')) {
              const filePath = path.join(typeDir, file);
              await this.loadTemplate(filePath, type);
            }
          }
        } catch (error) {
          logger.warn(`Directory not found or empty: ${typeDir}`);
        }
      }

      logger.info(`Loaded ${this.templates.size} workout templates`);
      return this.templates.size;
    } catch (error) {
      logger.error('Error loading templates:', error);
      throw new Error('Failed to load workout templates');
    }
  }

  /**
   * Load a single template file
   */
  async loadTemplate(filePath, type) {
    try {
      const content = await fs.readFile(filePath, 'utf8');
      const template = JSON.parse(content);

      // Validate template
      this.validateTemplate(template);

      // Store template
      this.templates.set(template.plan_id, template);

      // Index by type
      if (!this.templatesByType.has(type)) {
        this.templatesByType.set(type, []);
      }
      this.templatesByType.get(type).push(template);

      // Index by goal and location
      const key = `${template.goal}_${template.location}_${template.training_days}d`;
      if (!this.templatesByGoalLocation.has(key)) {
        this.templatesByGoalLocation.set(key, []);
      }
      this.templatesByGoalLocation.get(key).push(template);

      logger.info(`Loaded template: ${template.plan_id} (${template.name_en})`);
    } catch (error) {
      logger.error(`Error loading template ${filePath}:`, error.message);
      // Don't throw - continue loading other templates
    }
  }

  /**
   * Validate template structure
   */
  validateTemplate(template) {
    // Required fields
    const requiredFields = ['plan_id', 'type'];
    
    for (const field of requiredFields) {
      if (!template[field]) {
        throw new Error(`Template missing required field: ${field}`);
      }
    }

    // Validate type
    if (!VALID_TYPES.includes(template.type)) {
      throw new Error(`Invalid type: ${template.type}. Must be one of: ${VALID_TYPES.join(', ')}`);
    }

    // Validate based on template type
    if (template.type === 'starter') {
      // Starter templates: simple format with sessions array
      this.validateStarterTemplate(template);
    } else if (template.type === 'advanced') {
      // Advanced templates: complex format with programs object
      this.validateAdvancedTemplate(template);
    }

    return true;
  }

  /**
   * Validate starter template structure (simple format)
   */
  validateStarterTemplate(template) {
    const requiredFields = ['goal', 'location', 'training_days', 'weeks', 'sessions'];
    
    for (const field of requiredFields) {
      if (!template[field]) {
        throw new Error(`Starter template missing required field: ${field}`);
      }
    }

    // Validate goal
    if (!VALID_GOALS.includes(template.goal)) {
      throw new Error(`Invalid goal: ${template.goal}`);
    }

    // Validate location
    if (!VALID_LOCATIONS.includes(template.location)) {
      throw new Error(`Invalid location: ${template.location}`);
    }

    // Validate numeric fields
    if (template.weeks < 1 || template.weeks > 52) {
      throw new Error('Weeks must be between 1 and 52');
    }

    if (template.training_days < 1 || template.training_days > 7) {
      throw new Error('Training days must be between 1 and 7');
    }

    // Validate sessions array
    if (!Array.isArray(template.sessions) || template.sessions.length === 0) {
      throw new Error('Starter template must have at least one session');
    }

    // Validate each session
    template.sessions.forEach((session, index) => {
      if (!session.day || !Array.isArray(session.work)) {
        throw new Error(`Invalid session structure at index ${index}`);
      }

      // Validate each exercise
      session.work.forEach((exercise, exIndex) => {
        if (!exercise.ex_id || !exercise.name_en || !exercise.sets || !exercise.reps) {
          throw new Error(`Invalid exercise at session ${index}, exercise ${exIndex}`);
        }
      });
    });
  }

  /**
   * Validate advanced template structure (complex format with programs)
   */
  validateAdvancedTemplate(template) {
    const requiredFields = ['training_days', 'weeks', 'programs'];
    
    for (const field of requiredFields) {
      if (!template[field]) {
        throw new Error(`Advanced template missing required field: ${field}`);
      }
    }

    // Validate numeric fields
    if (template.weeks < 1 || template.weeks > 52) {
      throw new Error('Weeks must be between 1 and 52');
    }

    if (template.training_days < 1 || template.training_days > 7) {
      throw new Error('Training days must be between 1 and 7');
    }

    // Validate programs structure
    if (typeof template.programs !== 'object') {
      throw new Error('Advanced template must have programs object');
    }

    // Validate at least one location exists
    const locations = Object.keys(template.programs);
    if (locations.length === 0) {
      throw new Error('Advanced template must have at least one location');
    }

    // Validate each location
    locations.forEach(location => {
      if (!VALID_LOCATIONS.includes(location)) {
        logger.warn(`Unknown location in template: ${location}`);
      }

      const locationPrograms = template.programs[location];
      if (typeof locationPrograms !== 'object') {
        throw new Error(`Invalid programs structure for location: ${location}`);
      }

      // Validate each goal
      Object.keys(locationPrograms).forEach(goal => {
        if (!VALID_GOALS.includes(goal)) {
          logger.warn(`Unknown goal in template: ${goal}`);
        }

        const experiencePrograms = locationPrograms[goal];
        if (typeof experiencePrograms !== 'object') {
          throw new Error(`Invalid experience programs for ${location}/${goal}`);
        }

        // Validate each experience level
        Object.keys(experiencePrograms).forEach(experience => {
          if (!VALID_EXPERIENCE_LEVELS.includes(experience)) {
            logger.warn(`Unknown experience level: ${experience}`);
          }

          const sessions = experiencePrograms[experience];
          if (!Array.isArray(sessions)) {
            throw new Error(`Sessions must be array for ${location}/${goal}/${experience}`);
          }

          // Validate sessions
          sessions.forEach((session, idx) => {
            if (!session.day || !Array.isArray(session.work)) {
              throw new Error(`Invalid session at ${location}/${goal}/${experience}[${idx}]`);
            }
          });
        });
      });
    });

    // Validate experience_adjustments if present
    if (template.experience_adjustments) {
      VALID_EXPERIENCE_LEVELS.forEach(level => {
        if (template.experience_adjustments[level]) {
          const adj = template.experience_adjustments[level];
          if (typeof adj.set_multiplier !== 'number' || typeof adj.intensity_bias !== 'number') {
            throw new Error(`Invalid experience_adjustments for ${level}`);
          }
        }
      });
    }
  }

  /**
   * Get all templates
   */
  getAllTemplates() {
    return Array.from(this.templates.values());
  }

  /**
   * Get template by ID
   */
  getTemplateById(id) {
    return this.templates.get(id);
  }

  /**
   * Get templates by type (starter or advanced)
   */
  getTemplatesByType(type) {
    return this.templatesByType.get(type) || [];
  }

  /**
   * Get templates by goal, location, and days
   */
  getTemplatesByGoalLocationDays(goal, location, trainingDays) {
    const key = `${goal}_${location}_${trainingDays}d`;
    return this.templatesByGoalLocation.get(key) || [];
  }

  /**
   * Search templates with filters
   */
  searchTemplates(filters = {}) {
    let results = this.getAllTemplates();

    if (filters.type) {
      results = results.filter(t => t.type === filters.type);
    }

    if (filters.goal) {
      results = results.filter(t => t.goal === filters.goal);
    }

    if (filters.location) {
      results = results.filter(t => t.location === filters.location);
    }

    if (filters.training_days) {
      results = results.filter(t => t.training_days === parseInt(filters.training_days));
    }

    if (filters.weeks) {
      results = results.filter(t => t.weeks === parseInt(filters.weeks));
    }

    if (filters.max_weeks) {
      results = results.filter(t => t.weeks <= parseInt(filters.max_weeks));
    }

    if (filters.min_weeks) {
      results = results.filter(t => t.weeks >= parseInt(filters.min_weeks));
    }

    return results;
  }

  /**
   * Get template summary (without full session data)
   */
  getTemplateSummary(template) {
    return {
      plan_id: template.plan_id,
      type: template.type,
      name_en: template.name_en,
      name_ar: template.name_ar,
      description_en: template.description_en,
      description_ar: template.description_ar,
      goal: template.goal,
      location: template.location,
      training_days: template.training_days,
      weeks: template.weeks,
      blocks: template.blocks,
      metadata: template.metadata,
      session_count: template.sessions.length
    };
  }

  /**
   * Get all template summaries
   */
  getAllTemplateSummaries() {
    return this.getAllTemplates().map(t => this.getTemplateSummary(t));
  }

  /**
   * Reload templates (useful for development)
   */
  async reloadTemplates() {
    this.templates.clear();
    this.templatesByType.clear();
    this.templatesByGoalLocation.clear();
    return this.loadTemplates();
  }

  /**
   * Get template statistics
   */
  getStatistics() {
    const stats = {
      total: this.templates.size,
      byType: {},
      byGoal: {},
      byLocation: {},
      byTrainingDays: {},
      byGoalLocation: {}
    };

    for (const template of this.templates.values()) {
      // Count by type
      stats.byType[template.type] = (stats.byType[template.type] || 0) + 1;

      // Count by goal
      stats.byGoal[template.goal] = (stats.byGoal[template.goal] || 0) + 1;

      // Count by location
      stats.byLocation[template.location] = (stats.byLocation[template.location] || 0) + 1;

      // Count by training days
      stats.byTrainingDays[`${template.training_days}d`] = (stats.byTrainingDays[`${template.training_days}d`] || 0) + 1;

      // Count by goal and location
      const key = `${template.goal}_${template.location}`;
      stats.byGoalLocation[key] = (stats.byGoalLocation[key] || 0) + 1;
    }

    return stats;
  }

  /**
   * Find best match template based on intake data
   */
  findBestMatch(intakeData) {
    const {
      intake_level = 'starter', // starter or advanced
      primary_goal,
      workout_location,
      available_days,
      fitness_level,
      experience_level
    } = intakeData;

    // Get templates for the intake level
    let candidates = this.getTemplatesByType(intake_level);

    if (candidates.length === 0) {
      // Fallback to starter if advanced not available
      candidates = this.getTemplatesByType('starter');
    }

    // Filter by goal if specified
    if (primary_goal) {
      const goalMap = {
        'lose_weight': 'fat_loss',
        'build_muscle': 'muscle_gain',
        'improve_endurance': 'endurance',
        'general_fitness': 'general_fitness',
        'get_stronger': 'strength'
      };
      const mappedGoal = goalMap[primary_goal] || primary_goal;
      candidates = candidates.filter(t => t.goal === mappedGoal);
    }

    // Filter by location if specified
    if (workout_location) {
      const locationMap = {
        'at_gym': 'gym',
        'at_home': 'home',
        'outdoors': 'outdoors',
        'both': 'hybrid'
      };
      const mappedLocation = locationMap[workout_location] || workout_location;
      candidates = candidates.filter(t => t.location === mappedLocation);
    }

    // Filter by available days if specified
    if (available_days) {
      candidates = candidates.filter(t => t.training_days <= parseInt(available_days));
    }

    // Sort by best match (prefer more training days if possible)
    if (available_days) {
      candidates.sort((a, b) => {
        const aDiff = Math.abs(a.training_days - parseInt(available_days));
        const bDiff = Math.abs(b.training_days - parseInt(available_days));
        return aDiff - bDiff;
      });
    }

    return candidates[0] || null;
  }

  /**
   * Extract sessions from advanced template based on user criteria
   */
  extractSessionsFromAdvancedTemplate(template, criteria) {
    const {
      location = 'gym',
      goal = 'general_fitness',
      experience_level = 'beginner',
      injuries = []
    } = criteria;

    // Check if template supports this location/goal/experience combination
    if (!template.programs || !template.programs[location]) {
      throw new Error(`Template does not support location: ${location}`);
    }

    if (!template.programs[location][goal]) {
      throw new Error(`Template does not support goal: ${goal} at location: ${location}`);
    }

    if (!template.programs[location][goal][experience_level]) {
      throw new Error(`Template does not support experience: ${experience_level} for ${goal} at ${location}`);
    }

    // Get base sessions
    let sessions = JSON.parse(JSON.stringify(template.programs[location][goal][experience_level]));

    // Apply injury swaps if needed
    if (injuries && injuries.length > 0 && template.injury_swaps) {
      sessions = this.applyInjurySwaps(sessions, injuries, template);
    }

    // Apply experience adjustments if present
    if (template.experience_adjustments && template.experience_adjustments[experience_level]) {
      sessions = this.applyExperienceAdjustments(sessions, experience_level, template);
    }

    return sessions;
  }

  /**
   * Apply injury swaps to sessions
   */
  applyInjurySwaps(sessions, injuries, template) {
    if (!template.injury_swaps) return sessions;

    const modifiedSessions = JSON.parse(JSON.stringify(sessions));

    injuries.forEach(injury => {
      const injurySwapConfig = template.injury_swaps[injury];
      if (!injurySwapConfig || !injurySwapConfig.swap_map) return;

      modifiedSessions.forEach(session => {
        session.work = session.work.map(exercise => {
          // Check if this exercise needs to be swapped
          if (injurySwapConfig.swap_map[exercise.ex_id]) {
            const swapOptions = injurySwapConfig.swap_map[exercise.ex_id];
            const newExId = swapOptions[0]; // Use first swap option

            // Find exercise definition
            const newExercise = template.exercises?.find(ex => ex.ex_id === newExId);
            
            if (newExercise) {
              return {
                ...exercise,
                ex_id: newExId,
                name_en: newExercise.name_en,
                name_ar: newExercise.name_ar,
                video_id: newExercise.video_id,
                equip: newExercise.equip,
                muscles: newExercise.muscles,
                was_substituted: true,
                original_ex_id: exercise.ex_id,
                substitution_reason: `Swapped due to ${injury.replace('_', ' ')}`
              };
            }
          }
          return exercise;
        });
      });
    });

    return modifiedSessions;
  }

  /**
   * Apply experience adjustments to sessions
   */
  applyExperienceAdjustments(sessions, experienceLevel, template) {
    const adjustments = template.experience_adjustments[experienceLevel];
    if (!adjustments) return sessions;

    const modifiedSessions = JSON.parse(JSON.stringify(sessions));

    modifiedSessions.forEach(session => {
      session.work = session.work.map(exercise => {
        const adjusted = { ...exercise };

        // Apply set multiplier
        if (adjustments.set_multiplier && adjustments.set_multiplier !== 1.0) {
          adjusted.sets = Math.round(exercise.sets * adjustments.set_multiplier);
        }

        // Apply intensity bias (RPE adjustment)
        if (adjustments.intensity_bias && exercise.rpe) {
          adjusted.rpe = Math.max(6, Math.min(10, exercise.rpe + adjustments.intensity_bias));
        }

        return adjusted;
      });
    });

    return modifiedSessions;
  }

  /**
   * Get sessions from template (works for both starter and advanced)
   */
  getSessionsFromTemplate(template, userCriteria = {}) {
    if (template.type === 'starter') {
      // Starter templates have direct sessions array
      return template.sessions;
    } else if (template.type === 'advanced') {
      // Advanced templates need extraction based on criteria
      return this.extractSessionsFromAdvancedTemplate(template, userCriteria);
    }

    throw new Error(`Unknown template type: ${template.type}`);
  }

  /**
   * Get exercise definition from template
   */
  getExerciseDefinition(template, exId) {
    if (!template.exercises) return null;
    return template.exercises.find(ex => ex.ex_id === exId);
  }

  /**
   * Get fitness score projection for user
   */
  getFitnessScoreProjection(template, experienceLevel = 'beginner') {
    if (!template.fitness_score) return null;

    // Advanced templates have by_experience breakdown
    if (template.fitness_score.by_experience && template.fitness_score.by_experience[experienceLevel]) {
      return template.fitness_score.by_experience[experienceLevel];
    }

    // Starter templates have simple weekly_expected
    if (template.fitness_score.weekly_expected) {
      return template.fitness_score.weekly_expected;
    }

    return null;
  }
}

// Singleton instance
const workoutTemplateService = new WorkoutTemplateService();

module.exports = workoutTemplateService;