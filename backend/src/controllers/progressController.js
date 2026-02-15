const db = require('../database');
const logger = require('../utils/logger');

/**
 * Progress Controller
 * Handles progress entry CRUD
 */

exports.getUserProgress = async (req, res) => {
  try {
    const { limit = 50, offset = 0 } = req.query;
    const result = await db.query(
      `SELECT * FROM progress_entries
       WHERE user_id = $1
       ORDER BY date DESC
       LIMIT $2 OFFSET $3`,
      [req.user.userId, parseInt(limit), parseInt(offset)]
    );

    res.json({
      success: true,
      entries: result.rows
    });
  } catch (error) {
    logger.error('Get progress error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to load progress'
    });
  }
};

exports.createEntry = async (req, res) => {
  try {
    const {
      date,
      weight,
      bodyFatPercentage,
      chest,
      waist,
      hips,
      bicepsLeft,
      bicepsRight,
      thighLeft,
      thighRight,
      frontPhotoUrl,
      sidePhotoUrl,
      backPhotoUrl,
      notes
    } = req.body;

    if (!date) {
      return res.status(400).json({
        success: false,
        message: 'Date is required'
      });
    }

    const result = await db.query(
      `INSERT INTO progress_entries (
        user_id, date, weight, body_fat_percentage,
        chest, waist, hips, biceps_left, biceps_right,
        thigh_left, thigh_right, front_photo_url, side_photo_url,
        back_photo_url, notes, created_at, updated_at
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, NOW(), NOW())
      RETURNING *`,
      [
        req.user.userId,
        date,
        weight || null,
        bodyFatPercentage || null,
        chest || null,
        waist || null,
        hips || null,
        bicepsLeft || null,
        bicepsRight || null,
        thighLeft || null,
        thighRight || null,
        frontPhotoUrl || null,
        sidePhotoUrl || null,
        backPhotoUrl || null,
        notes || null
      ]
    );

    res.status(201).json({
      success: true,
      entry: result.rows[0]
    });
  } catch (error) {
    logger.error('Create progress entry error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create progress entry'
    });
  }
};

exports.updateEntry = async (req, res) => {
  try {
    const { id } = req.params;
    const {
      weight,
      bodyFatPercentage,
      chest,
      waist,
      hips,
      bicepsLeft,
      bicepsRight,
      thighLeft,
      thighRight,
      frontPhotoUrl,
      sidePhotoUrl,
      backPhotoUrl,
      notes
    } = req.body;

    const result = await db.query(
      `UPDATE progress_entries
       SET weight = COALESCE($1, weight),
           body_fat_percentage = COALESCE($2, body_fat_percentage),
           chest = COALESCE($3, chest),
           waist = COALESCE($4, waist),
           hips = COALESCE($5, hips),
           biceps_left = COALESCE($6, biceps_left),
           biceps_right = COALESCE($7, biceps_right),
           thigh_left = COALESCE($8, thigh_left),
           thigh_right = COALESCE($9, thigh_right),
           front_photo_url = COALESCE($10, front_photo_url),
           side_photo_url = COALESCE($11, side_photo_url),
           back_photo_url = COALESCE($12, back_photo_url),
           notes = COALESCE($13, notes),
           updated_at = NOW()
       WHERE id = $14 AND user_id = $15
       RETURNING *`,
      [
        weight || null,
        bodyFatPercentage || null,
        chest || null,
        waist || null,
        hips || null,
        bicepsLeft || null,
        bicepsRight || null,
        thighLeft || null,
        thighRight || null,
        frontPhotoUrl || null,
        sidePhotoUrl || null,
        backPhotoUrl || null,
        notes || null,
        id,
        req.user.userId
      ]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Progress entry not found'
      });
    }

    res.json({
      success: true,
      entry: result.rows[0]
    });
  } catch (error) {
    logger.error('Update progress entry error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update progress entry'
    });
  }
};

exports.deleteEntry = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await db.query(
      'DELETE FROM progress_entries WHERE id = $1 AND user_id = $2 RETURNING id',
      [id, req.user.userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Progress entry not found'
      });
    }

    res.json({
      success: true,
      message: 'Progress entry deleted'
    });
  } catch (error) {
    logger.error('Delete progress entry error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete progress entry'
    });
  }
};
