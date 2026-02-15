const db = require('../database');
const logger = require('../utils/logger');
const exerciseCatalogService = require('../services/exerciseCatalogService');

const applyCatalogFallback = async (row) => {
  if (!row || !row.ex_id) return row;
  const catalog = await exerciseCatalogService.getById(row.ex_id);
  if (!catalog) return row;

  return {
    ...row,
    name_en: row.name_en || catalog.name_en,
    name_ar: row.name_ar || catalog.name_ar,
    instructions_en: row.instructions_en || catalog.instructions_en,
    instructions_ar: row.instructions_ar || catalog.instructions_ar,
    common_mistakes_en: row.common_mistakes_en || catalog.common_mistakes_en,
    common_mistakes_ar: row.common_mistakes_ar || catalog.common_mistakes_ar,
    equipment: row.equipment && row.equipment.length ? row.equipment : catalog.equip,
    muscle_groups: row.muscle_groups && row.muscle_groups.length ? row.muscle_groups : catalog.muscles,
    video_url: row.video_url || catalog.video_url,
    thumbnail_url: row.thumbnail_url || catalog.thumbnail_url,
  };
};

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
        name_en AS name,
        name_en AS "nameEn",
        name_ar AS "nameAr",
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
        contraindications,
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
    const enrichedRows = await Promise.all(result.rows.map(applyCatalogFallback));

    res.json({
      success: true,
      exercises: enrichedRows.map((row) => ({
        ...row,
        name: row.name || row.name_en,
        nameEn: row.nameEn || row.name_en,
        nameAr: row.nameAr || row.name_ar,
        muscleGroup: row.muscle_group || null
      })),
      total: enrichedRows.length
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
      `SELECT *, name_en AS name, name_en AS "nameEn", name_ar AS "nameAr"
       FROM exercises WHERE ex_id = $1 OR id = $1`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Exercise not found'
      });
    }

    // Get alternative exercises
    let exercise = result.rows[0];
    exercise = await applyCatalogFallback(exercise);
    if (exercise.alternatives && exercise.alternatives.length > 0) {
      const alternativesResult = await db.query(
        `SELECT id, ex_id, name_en, name_ar, name_en AS name, name_en AS "nameEn", name_ar AS "nameAr",
                muscle_groups, equipment, difficulty, contraindications, alternatives
         FROM exercises 
         WHERE ex_id = ANY($1) OR id::text = ANY($1)`,
        [exercise.alternatives]
      );
      const enrichedAlternatives = await Promise.all(alternativesResult.rows.map(applyCatalogFallback));
      exercise.alternative_exercises = enrichedAlternatives;
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
 * Get exercise alternatives (Flutter-compatible)
 */
exports.getExerciseAlternatives = async (req, res) => {
  try {
    const { id } = req.params;
    const { injuries = [] } = req.body;

    const result = await db.query(
      `SELECT *, name_en AS name, name_en AS "nameEn", name_ar AS "nameAr"
       FROM exercises WHERE ex_id = $1 OR id = $1`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Exercise not found'
      });
    }

    let exercise = result.rows[0];
    exercise = await applyCatalogFallback(exercise);
    const alternatives = exercise.alternatives || [];

    if (alternatives.length === 0) {
      return res.json([]);
    }

    const alternativesResult = await db.query(
      `SELECT id, ex_id, name_en, name_ar, name_en AS name, name_en AS "nameEn", name_ar AS "nameAr",
              muscle_groups, equipment, difficulty, contraindications, alternatives, video_url, thumbnail_url,
              instructions_en, instructions_ar
       FROM exercises
       WHERE ex_id = ANY($1) OR id::text = ANY($1)`,
      [alternatives]
    );

    const enrichedAlternatives = await Promise.all(alternativesResult.rows.map(applyCatalogFallback));

    const normalizedInjuries = (injuries || []).map((inj) => String(inj).toLowerCase());
    const safeAlternatives = enrichedAlternatives.filter((row) => {
      const contra = (row.contraindications || []).map((c) => String(c).toLowerCase());
      return !contra.some((c) => normalizedInjuries.includes(c));
    });

    res.json(safeAlternatives);
  } catch (error) {
    logger.error('Get exercise alternatives error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get alternatives'
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

    const enrichedRows = await Promise.all(result.rows.map(applyCatalogFallback));

    res.json({
      success: true,
      muscleGroup,
      exercises: enrichedRows,
      total: enrichedRows.length
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

    const enrichedRows = await Promise.all(result.rows.map(applyCatalogFallback));

    res.json({
      success: true,
      favorites: enrichedRows
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
