const db = require('../database');
const logger = require('../utils/logger');
const s3Service = require('../services/s3Service');
const aiExtractionService = require('../services/aiExtractionService');

/**
 * InBody Controller
 * Handles body composition tracking via InBody scans
 */

/**
 * Save new InBody scan
 */
exports.saveInBodyScan = async (req, res) => {
  try {
    const userId = req.user.userId;
    const {
      totalBodyWater,
      intracellularWater,
      extracellularWater,
      dryLeanMass,
      bodyFatMass,
      weight,
      skeletalMuscleMass,
      bodyShape,
      bmi,
      percentBodyFat,
      segmentalLean,
      basalMetabolicRate,
      visceralFatLevel,
      ecwTbwRatio,
      inBodyScore,
      scanDate,
      scanLocation,
      notes,
      extractedViaAi,
      aiConfidenceScore,
      originalImageUrl
    } = req.body;

    // Validate required fields
    if (!weight || !bmi || !percentBodyFat) {
      return res.status(400).json({
        success: false,
        message: 'Weight, BMI, and body fat percentage are required'
      });
    }

    const result = await db.query(
      `INSERT INTO inbody_scans (
        user_id, total_body_water, intracellular_water, extracellular_water,
        dry_lean_mass, body_fat_mass, weight, skeletal_muscle_mass, body_shape,
        bmi, percent_body_fat, basal_metabolic_rate, visceral_fat_level,
        ecw_tbw_ratio, inbody_score, scan_date, scan_location, notes,
        left_arm_muscle_percent, right_arm_muscle_percent, trunk_muscle_percent,
        left_leg_muscle_percent, right_leg_muscle_percent,
        extracted_via_ai, ai_confidence_score, original_image_url
      ) VALUES (
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18,
        $19, $20, $21, $22, $23, $24, $25, $26
      ) RETURNING *`,
      [
        userId, totalBodyWater, intracellularWater, extracellularWater,
        dryLeanMass, bodyFatMass, weight, skeletalMuscleMass, bodyShape,
        bmi, percentBodyFat, basalMetabolicRate, visceralFatLevel,
        ecwTbwRatio, inBodyScore, scanDate || new Date(), scanLocation, notes,
        segmentalLean?.leftArm, segmentalLean?.rightArm, segmentalLean?.trunk,
        segmentalLean?.leftLeg, segmentalLean?.rightLeg,
        extractedViaAi, aiConfidenceScore, originalImageUrl
      ]
    );

    res.json({
      success: true,
      scan: result.rows[0],
      message: 'InBody scan saved successfully'
    });

  } catch (error) {
    logger.error('Save InBody scan error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to save InBody scan'
    });
  }
};

/**
 * Get all InBody scans for user
 */
exports.getAllScans = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { limit = 50, offset = 0 } = req.query;

    const result = await db.query(
      `SELECT * FROM inbody_scans
       WHERE user_id = $1
       ORDER BY scan_date DESC
       LIMIT $2 OFFSET $3`,
      [userId, limit, offset]
    );

    res.json({
      success: true,
      scans: result.rows,
      total: result.rows.length
    });

  } catch (error) {
    logger.error('Get InBody scans error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get InBody scans'
    });
  }
};

/**
 * Get latest InBody scan
 */
exports.getLatestScan = async (req, res) => {
  try {
    const userId = req.user.userId;

    const result = await db.query(
      `SELECT * FROM inbody_scans
       WHERE user_id = $1
       ORDER BY scan_date DESC
       LIMIT 1`,
      [userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'No InBody scans found'
      });
    }

    res.json({
      success: true,
      scan: result.rows[0]
    });

  } catch (error) {
    logger.error('Get latest InBody scan error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get latest scan'
    });
  }
};

/**
 * Get InBody scan by ID
 */
exports.getScanById = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { id } = req.params;

    const result = await db.query(
      `SELECT * FROM inbody_scans
       WHERE id = $1 AND user_id = $2`,
      [id, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'InBody scan not found'
      });
    }

    res.json({
      success: true,
      scan: result.rows[0]
    });

  } catch (error) {
    logger.error('Get InBody scan by ID error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get scan'
    });
  }
};

/**
 * Update InBody scan
 */
exports.updateScan = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { id } = req.params;
    const { notes, scanLocation } = req.body;

    // Check ownership
    const existing = await db.query(
      `SELECT id FROM inbody_scans WHERE id = $1 AND user_id = $2`,
      [id, userId]
    );

    if (existing.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'InBody scan not found'
      });
    }

    const result = await db.query(
      `UPDATE inbody_scans
       SET notes = COALESCE($1, notes),
           scan_location = COALESCE($2, scan_location),
           updated_at = NOW()
       WHERE id = $3
       RETURNING *`,
      [notes, scanLocation, id]
    );

    res.json({
      success: true,
      scan: result.rows[0],
      message: 'InBody scan updated successfully'
    });

  } catch (error) {
    logger.error('Update InBody scan error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update scan'
    });
  }
};

/**
 * Delete InBody scan
 */
exports.deleteScan = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { id } = req.params;

    // Check ownership and delete
    const result = await db.query(
      `DELETE FROM inbody_scans
       WHERE id = $1 AND user_id = $2
       RETURNING id`,
      [id, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'InBody scan not found'
      });
    }

    res.json({
      success: true,
      message: 'InBody scan deleted successfully'
    });

  } catch (error) {
    logger.error('Delete InBody scan error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete scan'
    });
  }
};

/**
 * Get body composition trends
 */
exports.getTrends = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { startDate, endDate } = req.query;

    let query = `
      SELECT * FROM inbody_trends
      WHERE user_id = $1
    `;

    const params = [userId];
    let paramCount = 2;

    if (startDate) {
      query += ` AND scan_date >= $${paramCount}`;
      params.push(startDate);
      paramCount++;
    }

    if (endDate) {
      query += ` AND scan_date <= $${paramCount}`;
      params.push(endDate);
      paramCount++;
    }

    query += ` ORDER BY scan_date ASC`;

    const result = await db.query(query, params);

    res.json({
      success: true,
      trends: result.rows
    });

  } catch (error) {
    logger.error('Get InBody trends error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get trends'
    });
  }
};

/**
 * Get body composition progress
 */
exports.getProgress = async (req, res) => {
  try {
    const userId = req.user.userId;

    const result = await db.query(
      `SELECT * FROM calculate_body_comp_progress($1)`,
      [userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Not enough data to calculate progress'
      });
    }

    res.json({
      success: true,
      progress: result.rows[0]
    });

  } catch (error) {
    logger.error('Get body composition progress error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to calculate progress'
    });
  }
};

/**
 * Set body composition goals
 */
exports.setGoals = async (req, res) => {
  try {
    const userId = req.user.userId;
    const {
      targetWeight,
      targetBmi,
      targetBodyFatPercent,
      targetSkeletalMuscleMass,
      targetVisceralFatLevel,
      targetDate
    } = req.body;

    // Check if goals exist
    const existing = await db.query(
      `SELECT id FROM body_composition_goals WHERE user_id = $1`,
      [userId]
    );

    let result;

    if (existing.rows.length > 0) {
      // Update existing goals
      result = await db.query(
        `UPDATE body_composition_goals
         SET target_weight = COALESCE($1, target_weight),
             target_bmi = COALESCE($2, target_bmi),
             target_body_fat_percent = COALESCE($3, target_body_fat_percent),
             target_skeletal_muscle_mass = COALESCE($4, target_skeletal_muscle_mass),
             target_visceral_fat_level = COALESCE($5, target_visceral_fat_level),
             target_date = COALESCE($6, target_date),
             updated_at = NOW()
         WHERE user_id = $7
         RETURNING *`,
        [targetWeight, targetBmi, targetBodyFatPercent, targetSkeletalMuscleMass, 
         targetVisceralFatLevel, targetDate, userId]
      );
    } else {
      // Insert new goals
      result = await db.query(
        `INSERT INTO body_composition_goals 
         (user_id, target_weight, target_bmi, target_body_fat_percent, 
          target_skeletal_muscle_mass, target_visceral_fat_level, target_date)
         VALUES ($1, $2, $3, $4, $5, $6, $7)
         RETURNING *`,
        [userId, targetWeight, targetBmi, targetBodyFatPercent, targetSkeletalMuscleMass,
         targetVisceralFatLevel, targetDate]
      );
    }

    res.json({
      success: true,
      goals: result.rows[0],
      message: 'Body composition goals set successfully'
    });

  } catch (error) {
    logger.error('Set body composition goals error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to set goals'
    });
  }
};

/**
 * Get body composition goals
 */
exports.getGoals = async (req, res) => {
  try {
    const userId = req.user.userId;

    const result = await db.query(
      `SELECT * FROM body_composition_goals WHERE user_id = $1`,
      [userId]
    );

    if (result.rows.length === 0) {
      return res.json({
        success: true,
        goals: null,
        message: 'No goals set yet'
      });
    }

    res.json({
      success: true,
      goals: result.rows[0]
    });

  } catch (error) {
    logger.error('Get body composition goals error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get goals'
    });
  }
};

/**
 * Upload InBody scan image for AI extraction (Premium feature)
 * This endpoint handles file upload and AI processing
 */
exports.uploadScanImage = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { file } = req;

    if (!file) {
      return res.status(400).json({
        success: false,
        message: 'No file provided'
      });
    }

    // Validate image
    aiExtractionService.validateInBodyImage(file.mimetype, file.size);

    // Upload to S3
    const uploadResult = await s3Service.uploadFile(
      file.buffer,
      `inbody/${userId}/${Date.now()}_${file.originalname}`,
      file.mimetype
    );

    // Extract data using AI
    const extractionResult = await aiExtractionService.extractInBodyData(
      file.buffer,
      file.mimetype
    );

    res.json({
      success: true,
      imageUrl: uploadResult.url,
      extractedData: extractionResult.data,
      confidence: extractionResult.confidence,
      message: 'InBody data extracted successfully from image'
    });

  } catch (error) {
    logger.error('Upload InBody scan image error:', error);
    res.status(error.statusCode || 500).json({
      success: false,
      message: error.message || 'Failed to upload and process image'
    });
  }
};

/**
 * Get body composition statistics
 */
exports.getStatistics = async (req, res) => {
  try {
    const userId = req.user.userId;

    const result = await db.query(
      `SELECT 
        COUNT(*) as total_scans,
        MIN(scan_date) as first_scan_date,
        MAX(scan_date) as latest_scan_date,
        MIN(weight) as min_weight,
        MAX(weight) as max_weight,
        MIN(percent_body_fat) as min_body_fat,
        MAX(percent_body_fat) as max_body_fat,
        MAX(skeletal_muscle_mass) as max_muscle_mass,
        MIN(skeletal_muscle_mass) as min_muscle_mass,
        AVG(inbody_score) as avg_inbody_score
       FROM inbody_scans
       WHERE user_id = $1`,
      [userId]
    );

    res.json({
      success: true,
      statistics: result.rows[0]
    });

  } catch (error) {
    logger.error('Get InBody statistics error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get statistics'
    });
  }
};

module.exports = exports;
