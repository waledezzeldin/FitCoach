const db = require('../database');
const logger = require('../utils/logger');

/**
 * Submit rating
 */
exports.submitRating = async (req, res) => {
  const client = await db.getClient();
  
  try {
    const { coachId, context, referenceId, rating, feedback } = req.body;
    
    // Validate rating
    if (rating < 1 || rating > 5) {
      return res.status(400).json({
        success: false,
        message: 'Rating must be between 1 and 5'
      });
    }
    
    // Validate context
    const validContexts = ['message', 'video_call', 'workout', 'nutrition'];
    if (!validContexts.includes(context)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid rating context'
      });
    }
    
    await client.query('BEGIN');
    
    // Insert rating
    const ratingResult = await client.query(
      `INSERT INTO ratings (user_id, coach_id, context, reference_id, rating, feedback)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING *`,
      [req.user.userId, coachId, context, referenceId, rating, feedback]
    );
    
    const newRating = ratingResult.rows[0];
    
    // Update coach's average rating
    const avgResult = await client.query(
      `SELECT AVG(rating)::DECIMAL(3,2) as avg_rating, COUNT(*) as total
       FROM ratings
       WHERE coach_id = $1`,
      [coachId]
    );
    
    const { avg_rating, total } = avgResult.rows[0];
    
    await client.query(
      `UPDATE coaches
       SET average_rating = $1,
           total_ratings = $2
       WHERE id = $3`,
      [avg_rating, total, coachId]
    );
    
    await client.query('COMMIT');
    
    logger.info(`Rating submitted: ${newRating.id} for coach ${coachId}`);
    
    res.status(201).json({
      success: true,
      message: 'Rating submitted successfully',
      rating: newRating,
      coachStats: {
        averageRating: parseFloat(avg_rating),
        totalRatings: parseInt(total)
      }
    });
    
  } catch (error) {
    await client.query('ROLLBACK');
    logger.error('Submit rating error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to submit rating'
    });
  } finally {
    client.release();
  }
};

/**
 * Get coach ratings
 */
exports.getCoachRatings = async (req, res) => {
  try {
    const { id } = req.params;
    const { page = 1, limit = 20, context } = req.query;
    const offset = (page - 1) * limit;
    
    // Build query
    let query = `
      SELECT 
        r.*,
        u.full_name as user_name,
        u.profile_photo_url as user_photo
      FROM ratings r
      JOIN users u ON r.user_id = u.id
      WHERE r.coach_id = $1
    `;
    
    const params = [id];
    
    if (context) {
      query += ` AND r.context = $${params.length + 1}`;
      params.push(context);
    }
    
    query += ` ORDER BY r.created_at DESC LIMIT $${params.length + 1} OFFSET $${params.length + 2}`;
    params.push(limit, offset);
    
    const result = await db.query(query, params);
    
    // Get total count
    let countQuery = 'SELECT COUNT(*) FROM ratings WHERE coach_id = $1';
    const countParams = [id];
    
    if (context) {
      countQuery += ' AND context = $2';
      countParams.push(context);
    }
    
    const countResult = await db.query(countQuery, countParams);
    const total = parseInt(countResult.rows[0].count);
    
    // Get rating distribution
    const distResult = await db.query(
      `SELECT rating, COUNT(*) as count
       FROM ratings
       WHERE coach_id = $1
       GROUP BY rating
       ORDER BY rating DESC`,
      [id]
    );
    
    const distribution = {
      5: 0, 4: 0, 3: 0, 2: 0, 1: 0
    };
    
    distResult.rows.forEach(row => {
      distribution[row.rating] = parseInt(row.count);
    });
    
    // Get coach average
    const coachResult = await db.query(
      'SELECT average_rating, total_ratings FROM coaches WHERE id = $1',
      [id]
    );
    
    const coach = coachResult.rows[0] || { average_rating: 0, total_ratings: 0 };
    
    res.json({
      success: true,
      ratings: result.rows,
      pagination: {
        total,
        page: parseInt(page),
        limit: parseInt(limit),
        totalPages: Math.ceil(total / limit)
      },
      stats: {
        averageRating: parseFloat(coach.average_rating || 0),
        totalRatings: parseInt(coach.total_ratings || 0),
        distribution
      }
    });
    
  } catch (error) {
    logger.error('Get coach ratings error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get ratings'
    });
  }
};

/**
 * Get user's ratings (ratings they've given)
 */
exports.getUserRatings = async (req, res) => {
  try {
    const { id } = req.params;
    
    // Check authorization
    if (req.user.userId !== id && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Unauthorized'
      });
    }
    
    const result = await db.query(
      `SELECT 
        r.*,
        c.id as coach_id,
        u.full_name as coach_name,
        u.profile_photo_url as coach_photo,
        c.average_rating as coach_average_rating
       FROM ratings r
       JOIN coaches c ON r.coach_id = c.id
       JOIN users u ON c.user_id = u.id
       WHERE r.user_id = $1
       ORDER BY r.created_at DESC`,
      [id]
    );
    
    res.json({
      success: true,
      ratings: result.rows
    });
    
  } catch (error) {
    logger.error('Get user ratings error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get ratings'
    });
  }
};
