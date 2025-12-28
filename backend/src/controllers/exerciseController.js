const db = require('../database');
const logger = require('../utils/logger');

/**
 * Exercise Controller
 * Manages exercise library, definitions, and metadata
 */

/**
 * Get all exercises with optional filtering
 */
exports.getAllExercises = async (req, res) => {
  try {
    const { 
      muscle_group, 
      equipment, 
      difficulty, 
      search,
      location // gym or home
    } = req.query;

    let query = `
      SELECT 
        id,
        ex_id,
        name_en,
        name_ar,
        description_en,
        description_ar,
        muscle_groups,
        equipment,
        difficulty,
        video_url,
        thumbnail_url,
        instructions_en,
        instructions_ar,
        common_mistakes_en,
        common_mistakes_ar,
        default_sets,
        default_reps,
        default_rest_seconds,
        location_type,
        is_compound,
        alternatives,
        created_at,
        updated_at
      FROM exercises
      WHERE 1=1
    `;

    const params = [];
    let paramCount = 1;

    // Filter by muscle group
    if (muscle_group) {
      query += ` AND $${paramCount} = ANY(muscle_groups)`;
      params.push(muscle_group);
      paramCount++;
    }

    // Filter by equipment
    if (equipment) {
      query += ` AND $${paramCount} = ANY(equipment)`;
      params.push(equipment);
      paramCount++;
    }

    // Filter by difficulty
    if (difficulty) {
      query += ` AND difficulty = $${paramCount}`;
      params.push(difficulty);
      paramCount++;
    }

    // Filter by location (gym/home)
    if (location) {
      query += ` AND (location_type = $${paramCount} OR location_type = 'both')`;
      params.push(location);
      paramCount++;
    }

    // Search by name
    if (search) {
      query += ` AND (name_en ILIKE $${paramCount} OR name_ar ILIKE $${paramCount})`;
      params.push(`%${search}%`);
      paramCount++;
    }

    query += ` ORDER BY name_en ASC`;

    const result = await db.query(query, params);

    res.json({
      success: true,
      exercises: result.rows,
      total: result.rows.length
    });

  } catch (error) {
    logger.error('Get all exercises error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get exercises'
    });
  }
};

/**
 * Get exercise by ID
 */
exports.getExerciseById = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await db.query(
      `SELECT * FROM exercises WHERE ex_id = $1 OR id = $1`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Exercise not found'
      });
    }

    // Get alternative exercises
    const exercise = result.rows[0];
    if (exercise.alternatives && exercise.alternatives.length > 0) {
      const alternativesResult = await db.query(
        `SELECT id, ex_id, name_en, name_ar, muscle_groups, equipment, difficulty
         FROM exercises 
         WHERE ex_id = ANY($1)`,
        [exercise.alternatives]
      );
      exercise.alternative_exercises = alternativesResult.rows;
    }

    res.json({
      success: true,
      exercise: exercise
    });

  } catch (error) {
    logger.error('Get exercise by ID error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get exercise'
    });
  }
};

/**
 * Get exercises by muscle group
 */
exports.getExercisesByMuscleGroup = async (req, res) => {
  try {
    const { muscleGroup } = req.params;

    const result = await db.query(
      `SELECT id, ex_id, name_en, name_ar, muscle_groups, equipment, difficulty, thumbnail_url
       FROM exercises
       WHERE $1 = ANY(muscle_groups)
       ORDER BY name_en ASC`,
      [muscleGroup]
    );

    res.json({
      success: true,
      muscleGroup,
      exercises: result.rows,
      total: result.rows.length
    });

  } catch (error) {
    logger.error('Get exercises by muscle group error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get exercises'
    });
  }
};

/**
 * Get user's favorite exercises
 */
exports.getUserFavorites = async (req, res) => {
  try {
    const userId = req.user.userId;

    const result = await db.query(
      `SELECT 
        e.id,
        e.ex_id,
        e.name_en,
        e.name_ar,
        e.muscle_groups,
        e.equipment,
        e.difficulty,
        e.thumbnail_url,
        uf.added_at
       FROM user_favorite_exercises uf
       JOIN exercises e ON uf.exercise_id = e.id
       WHERE uf.user_id = $1
       ORDER BY uf.added_at DESC`,
      [userId]
    );

    res.json({
      success: true,
      favorites: result.rows
    });

  } catch (error) {
    logger.error('Get user favorites error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get favorite exercises'
    });
  }
};

/**
 * Add exercise to favorites
 */
exports.addToFavorites = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { exerciseId } = req.body;

    // Check if already favorited
    const existing = await db.query(
      `SELECT id FROM user_favorite_exercises 
       WHERE user_id = $1 AND exercise_id = $2`,
      [userId, exerciseId]
    );

    if (existing.rows.length > 0) {
      return res.json({
        success: true,
        message: 'Already in favorites',
        alreadyExists: true
      });
    }

    // Add to favorites
    await db.query(
      `INSERT INTO user_favorite_exercises (user_id, exercise_id)
       VALUES ($1, $2)`,
      [userId, exerciseId]
    );

    res.json({
      success: true,
      message: 'Added to favorites'
    });

  } catch (error) {
    logger.error('Add to favorites error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to add to favorites'
    });
  }
};

/**
 * Remove exercise from favorites
 */
exports.removeFromFavorites = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { exerciseId } = req.params;

    await db.query(
      `DELETE FROM user_favorite_exercises 
       WHERE user_id = $1 AND exercise_id = $2`,
      [userId, exerciseId]
    );

    res.json({
      success: true,
      message: 'Removed from favorites'
    });

  } catch (error) {
    logger.error('Remove from favorites error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to remove from favorites'
    });
  }
};

/**
 * Get exercise statistics (for admin)
 */
exports.getExerciseStats = async (req, res) => {
  try {
    const result = await db.query(`
      SELECT 
        COUNT(*) as total_exercises,
        COUNT(DISTINCT unnest(muscle_groups)) as muscle_groups_count,
        COUNT(CASE WHEN difficulty = 'beginner' THEN 1 END) as beginner_count,
        COUNT(CASE WHEN difficulty = 'intermediate' THEN 1 END) as intermediate_count,
        COUNT(CASE WHEN difficulty = 'advanced' THEN 1 END) as advanced_count,
        COUNT(CASE WHEN location_type = 'gym' THEN 1 END) as gym_only,
        COUNT(CASE WHEN location_type = 'home' THEN 1 END) as home_only,
        COUNT(CASE WHEN location_type = 'both' THEN 1 END) as both_locations,
        COUNT(CASE WHEN is_compound = true THEN 1 END) as compound_exercises,
        COUNT(CASE WHEN video_url IS NOT NULL THEN 1 END) as with_video
      FROM exercises
    `);

    res.json({
      success: true,
      stats: result.rows[0]
    });

  } catch (error) {
    logger.error('Get exercise stats error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get exercise statistics'
    });
  }
};

module.exports = exports;
