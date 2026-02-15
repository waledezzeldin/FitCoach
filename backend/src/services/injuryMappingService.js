const fs = require('fs').promises;
const path = require('path');
const logger = require('../utils/logger');

/**
 * Injury Mapping Service
 * Handles keyword-based injury substitutions for exercises
 */

class InjuryMappingService {
  constructor() {
    this.injuryMappings = null;
    this.loaded = false;
  }

  /**
   * Load injury mappings from JSON file
   */
  async loadMappings() {
    try {
      const backendPath = path.join(__dirname, '../data/injury-swaps.json');
      const mobilePath = path.resolve(__dirname, '../../../mobile/assets/data/new/injury_swap_table.json');

      let content = null;
      try {
        content = await fs.readFile(mobilePath, 'utf8');
        logger.info('Loaded injury mappings from mobile assets');
      } catch (_) {
        content = await fs.readFile(backendPath, 'utf8');
        logger.info('Loaded injury mappings from backend data');
      }

      const rawMappings = JSON.parse(content);
      this.injuryMappings = Object.keys(rawMappings || {}).reduce((acc, key) => {
        const entry = rawMappings[key] || {};
        acc[key] = {
          description_en: entry.description_en || entry.description || entry.description_ar || key,
          description_ar: entry.description_ar || entry.description || entry.description_en || key,
          avoid_keywords: entry.avoid_keywords || [],
          substitute_exercises: entry.substitute_exercises || []
        };
        return acc;
      }, {});
      this.loaded = true;
      logger.info(`Loaded ${Object.keys(this.injuryMappings).length} injury mappings`);
      return this.injuryMappings;
    } catch (error) {
      logger.error('Error loading injury mappings:', error);
      this.injuryMappings = {};
      this.loaded = true;
      return this.injuryMappings;
    }
  }

  /**
   * Ensure mappings are loaded
   */
  async ensureLoaded() {
    if (!this.loaded) {
      await this.loadMappings();
    }
  }

  /**
   * Get all injury types
   */
  async getInjuryTypes() {
    await this.ensureLoaded();
    return Object.keys(this.injuryMappings);
  }

  /**
   * Get injury mapping by type
   */
  async getInjuryMapping(injuryType) {
    await this.ensureLoaded();
    return this.injuryMappings[injuryType] || null;
  }

  /**
   * Check if exercise should be avoided based on injuries
   * Uses keyword matching
   */
  async shouldAvoidExercise(exerciseId, exerciseName, injuries) {
    await this.ensureLoaded();
    
    if (!injuries || injuries.length === 0) {
      return { shouldAvoid: false, reason: null };
    }

    // Normalize exercise identifiers for matching
    const searchString = `${exerciseId}_${exerciseName}`.toLowerCase().replace(/[^a-z_]/g, '_');

    for (const injury of injuries) {
      const mapping = this.injuryMappings[injury];
      if (!mapping || !mapping.avoid_keywords) continue;

      // Check if any avoid_keyword matches the exercise
      for (const keyword of mapping.avoid_keywords) {
        const normalizedKeyword = keyword.toLowerCase().replace(/[^a-z_]/g, '_');
        
        if (searchString.includes(normalizedKeyword)) {
          return {
            shouldAvoid: true,
            reason: `Exercise contains "${keyword}" which is not recommended for ${mapping.description_en}`,
            reason_ar: `التمرين يحتوي على "${keyword}" وهو غير موصى به لـ ${mapping.description_ar}`,
            injury: injury,
            injuryDescription: mapping.description_en,
            injuryDescription_ar: mapping.description_ar
          };
        }
      }
    }

    return { shouldAvoid: false, reason: null };
  }

  /**
   * Get substitute exercises for an injury
   */
  async getSubstituteExercises(injury) {
    await this.ensureLoaded();
    
    const mapping = this.injuryMappings[injury];
    if (!mapping || !mapping.substitute_exercises) {
      return [];
    }

    return mapping.substitute_exercises;
  }

  /**
   * Find best substitute exercise for a given exercise and injuries
   * Returns first available substitute that doesn't conflict with other injuries
   */
  async findSubstituteExercise(originalExercise, injuries, availableExercises = []) {
    await this.ensureLoaded();

    if (!injuries || injuries.length === 0) {
      return null;
    }

    // Collect all possible substitutes from all injuries
    const allSubstitutes = [];
    for (const injury of injuries) {
      const substitutes = await this.getSubstituteExercises(injury);
      allSubstitutes.push(...substitutes);
    }

    // Remove duplicates
    const uniqueSubstitutes = [...new Set(allSubstitutes)];

    // If available exercises provided, filter to those
    const candidateSubstitutes = availableExercises.length > 0
      ? uniqueSubstitutes.filter(sub => availableExercises.includes(sub))
      : uniqueSubstitutes;

    // Find first substitute that doesn't conflict with any injury
    for (const substitute of candidateSubstitutes) {
      const check = await this.shouldAvoidExercise(substitute, substitute, injuries);
      if (!check.shouldAvoid) {
        return substitute;
      }
    }

    // If no perfect match, return first substitute
    return candidateSubstitutes[0] || null;
  }

  /**
   * Apply injury swaps to a session's exercises
   * This is the main method that should be called
   */
  async applyInjurySwapsToSession(session, injuries, exerciseLibrary = {}) {
    await this.ensureLoaded();

    if (!injuries || injuries.length === 0) {
      return session;
    }

    const modifiedSession = JSON.parse(JSON.stringify(session));
    
    if (!modifiedSession.work || !Array.isArray(modifiedSession.work)) {
      return modifiedSession;
    }

    // Process each exercise
    for (let i = 0; i < modifiedSession.work.length; i++) {
      const exercise = modifiedSession.work[i];
      
      // Check if exercise should be avoided
      const avoidCheck = await this.shouldAvoidExercise(
        exercise.ex_id,
        exercise.name_en || exercise.name || exercise.ex_id,
        injuries
      );

      if (avoidCheck.shouldAvoid) {
        // Find substitute
        const availableExercises = Object.keys(exerciseLibrary);
        const substitute = await this.findSubstituteExercise(
          exercise.ex_id,
          injuries,
          availableExercises
        );

        if (substitute) {
          // Get exercise definition from library
          const substituteExercise = exerciseLibrary[substitute];
          
          if (substituteExercise) {
            // Replace exercise while preserving sets, reps, etc.
            modifiedSession.work[i] = {
              ...exercise,
              ex_id: substitute,
              name_en: substituteExercise.name_en,
              name_ar: substituteExercise.name_ar,
              video_id: substituteExercise.video_id,
              equip: substituteExercise.equip || exercise.equip,
              muscles: substituteExercise.muscles || exercise.muscles,
              was_substituted: true,
              original_ex_id: exercise.ex_id,
              original_name_en: exercise.name_en,
              substitution_reason: avoidCheck.reason,
              substitution_reason_ar: avoidCheck.reason_ar,
              injury_type: avoidCheck.injury
            };

            logger.info(`Swapped ${exercise.ex_id} → ${substitute} due to ${avoidCheck.injury}`);
          } else {
            logger.warn(`Substitute exercise ${substitute} not found in library`);
          }
        } else {
          logger.warn(`No suitable substitute found for ${exercise.ex_id} with injuries: ${injuries.join(', ')}`);
        }
      }
    }

    return modifiedSession;
  }

  /**
   * Apply injury swaps to all sessions
   */
  async applyInjurySwapsToSessions(sessions, injuries, exerciseLibrary = {}) {
    await this.ensureLoaded();

    if (!injuries || injuries.length === 0) {
      return sessions;
    }

    const modifiedSessions = [];

    for (const session of sessions) {
      const modifiedSession = await this.applyInjurySwapsToSession(
        session,
        injuries,
        exerciseLibrary
      );
      modifiedSessions.push(modifiedSession);
    }

    return modifiedSessions;
  }

  /**
   * Validate that substitute exercises don't conflict with injuries
   */
  async validateSubstitutes() {
    await this.ensureLoaded();

    const issues = [];

    for (const [injuryType, mapping] of Object.entries(this.injuryMappings)) {
      if (!mapping.substitute_exercises || !mapping.avoid_keywords) continue;

      // Check if any substitute contains avoid keywords
      for (const substitute of mapping.substitute_exercises) {
        for (const keyword of mapping.avoid_keywords) {
          if (substitute.toLowerCase().includes(keyword.toLowerCase())) {
            issues.push({
              injury: injuryType,
              substitute: substitute,
              conflict: keyword,
              message: `Substitute "${substitute}" for ${injuryType} contains avoid keyword "${keyword}"`
            });
          }
        }
      }
    }

    if (issues.length > 0) {
      logger.warn(`Found ${issues.length} potential issues in injury substitutes:`, issues);
    }

    return issues;
  }

  /**
   * Get statistics about injury mappings
   */
  async getStatistics() {
    await this.ensureLoaded();

    const stats = {
      total_injuries: Object.keys(this.injuryMappings).length,
      by_injury: {}
    };

    for (const [injuryType, mapping] of Object.entries(this.injuryMappings)) {
      stats.by_injury[injuryType] = {
        description: mapping.description_en,
        avoid_keywords_count: mapping.avoid_keywords?.length || 0,
        substitute_exercises_count: mapping.substitute_exercises?.length || 0
      };
    }

    return stats;
  }

  /**
   * Reload mappings from disk (useful for development)
   */
  async reload() {
    this.loaded = false;
    return this.loadMappings();
  }
}

// Singleton instance
const injuryMappingService = new InjuryMappingService();

module.exports = injuryMappingService;
