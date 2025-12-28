const db = require('../database');
const logger = require('../utils/logger');

/**
 * Get platform analytics/dashboard stats
 */
exports.getDashboardAnalytics = async (req, res) => {
  try {
    // Total users
    const usersResult = await db.query(
      'SELECT COUNT(*) as total, COUNT(*) FILTER (WHERE is_active = TRUE) as active FROM users WHERE role = $1',
      ['user']
    );
    
    // Total coaches
    const coachesResult = await db.query(
      'SELECT COUNT(*) as total, COUNT(*) FILTER (WHERE is_approved = TRUE AND is_active = TRUE) as active FROM coaches'
    );
    
    // Subscription distribution
    const subsResult = await db.query(
      `SELECT 
        subscription_tier,
        COUNT(*) as count
       FROM users
       WHERE role = 'user'
       GROUP BY subscription_tier`
    );
    
    // Total revenue (last 30 days)
    const revenueResult = await db.query(
      `SELECT COALESCE(SUM(amount), 0) as total
       FROM payments
       WHERE status = 'completed'
       AND created_at >= NOW() - INTERVAL '30 days'`
    );
    
    // New users (last 7 days)
    const newUsersResult = await db.query(
      `SELECT COUNT(*) as count
       FROM users
       WHERE created_at >= NOW() - INTERVAL '7 days'`
    );
    
    // Active sessions today
    const sessionsResult = await db.query(
      `SELECT COUNT(*) as count
       FROM appointments
       WHERE DATE(scheduled_at) = CURRENT_DATE
       AND status IN ('scheduled', 'in_progress')`
    );
    
    res.json({
      success: true,
      analytics: {
        users: {
          total: parseInt(usersResult.rows[0].total),
          active: parseInt(usersResult.rows[0].active)
        },
        coaches: {
          total: parseInt(coachesResult.rows[0].total),
          active: parseInt(coachesResult.rows[0].active)
        },
        subscriptions: subsResult.rows,
        revenue: {
          last30Days: parseFloat(revenueResult.rows[0].total)
        },
        growth: {
          newUsersLast7Days: parseInt(newUsersResult.rows[0].count)
        },
        sessions: {
          today: parseInt(sessionsResult.rows[0].count)
        }
      }
    });
    
  } catch (error) {
    logger.error('Get dashboard analytics error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get analytics'
    });
  }
};

/**
 * Get all users with filters
 */
exports.getUsers = async (req, res) => {
  try {
    const { 
      search, 
      subscriptionTier, 
      status, 
      coachId,
      limit = 50, 
      offset = 0 
    } = req.query;
    
    let query = `
      SELECT 
        u.*,
        c.full_name as coach_name,
        uc.coach_id
      FROM users u
      LEFT JOIN user_coaches uc ON u.id = uc.user_id AND uc.is_active = TRUE
      LEFT JOIN users c ON uc.coach_id = c.id
      WHERE u.role = 'user'
    `;
    
    const params = [];
    let paramCount = 1;
    
    if (search) {
      query += ` AND (u.full_name ILIKE $${paramCount} OR u.email ILIKE $${paramCount} OR u.phone_number ILIKE $${paramCount})`;
      params.push(`%${search}%`);
      paramCount++;
    }
    
    if (subscriptionTier) {
      query += ` AND u.subscription_tier = $${paramCount}`;
      params.push(subscriptionTier);
      paramCount++;
    }
    
    if (status !== undefined) {
      query += ` AND u.is_active = $${paramCount}`;
      params.push(status === 'active');
      paramCount++;
    }
    
    if (coachId) {
      query += ` AND uc.coach_id = $${paramCount}`;
      params.push(coachId);
      paramCount++;
    }
    
    query += `
      ORDER BY u.created_at DESC
      LIMIT $${paramCount} OFFSET $${paramCount + 1}
    `;
    
    params.push(parseInt(limit), parseInt(offset));
    
    const result = await db.query(query, params);
    
    // Remove sensitive data
    const users = result.rows.map(user => {
      delete user.password_hash;
      return user;
    });
    
    res.json({
      success: true,
      users,
      total: users.length
    });
    
  } catch (error) {
    logger.error('Get users error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get users'
    });
  }
};

/**
 * Get user by ID
 */
exports.getUserById = async (req, res) => {
  try {
    const { id } = req.params;
    
    const result = await db.query(
      `SELECT 
        u.*,
        c.full_name as coach_name,
        uc.coach_id,
        uc.assigned_date as coach_assigned_date
       FROM users u
       LEFT JOIN user_coaches uc ON u.id = uc.user_id AND uc.is_active = TRUE
       LEFT JOIN users c ON uc.coach_id = c.id
       WHERE u.id = $1`,
      [id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }
    
    const user = result.rows[0];
    delete user.password_hash;
    
    res.json({
      success: true,
      user
    });
    
  } catch (error) {
    logger.error('Get user by ID error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get user'
    });
  }
};

/**
 * Update user
 */
exports.updateUser = async (req, res) => {
  try {
    const { id } = req.params;
    const { 
      fullName, 
      email, 
      subscriptionTier, 
      isActive,
      coachId 
    } = req.body;
    
    const result = await db.query(
      `UPDATE users
       SET full_name = COALESCE($1, full_name),
           email = COALESCE($2, email),
           subscription_tier = COALESCE($3, subscription_tier),
           is_active = COALESCE($4, is_active),
           updated_at = NOW()
       WHERE id = $5
       RETURNING *`,
      [fullName, email, subscriptionTier, isActive, id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }
    
    // Update coach assignment if provided
    if (coachId !== undefined) {
      if (coachId === null) {
        // Remove coach assignment
        await db.query(
          'UPDATE user_coaches SET is_active = FALSE WHERE user_id = $1',
          [id]
        );
      } else {
        // Deactivate old assignments
        await db.query(
          'UPDATE user_coaches SET is_active = FALSE WHERE user_id = $1',
          [id]
        );
        
        // Create new assignment
        await db.query(
          `INSERT INTO user_coaches (user_id, coach_id, is_active)
           VALUES ($1, $2, TRUE)
           ON CONFLICT (user_id, coach_id) 
           DO UPDATE SET is_active = TRUE, assigned_date = NOW()`,
          [id, coachId]
        );
      }
    }
    
    const user = result.rows[0];
    delete user.password_hash;
    
    res.json({
      success: true,
      message: 'User updated successfully',
      user
    });
    
    logger.info(`User ${id} updated by admin`);
    
  } catch (error) {
    logger.error('Update user error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update user'
    });
  }
};

/**
 * Suspend user
 */
exports.suspendUser = async (req, res) => {
  try {
    const { id } = req.params;
    const { reason } = req.body;
    
    const result = await db.query(
      `UPDATE users
       SET is_active = FALSE,
           suspension_reason = $1,
           suspended_at = NOW(),
           updated_at = NOW()
       WHERE id = $2
       RETURNING id, full_name, is_active`,
      [reason, id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }
    
    res.json({
      success: true,
      message: 'User suspended successfully',
      user: result.rows[0]
    });
    
    logger.info(`User ${id} suspended by admin. Reason: ${reason}`);
    
  } catch (error) {
    logger.error('Suspend user error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to suspend user'
    });
  }
};

/**
 * Delete user (soft delete)
 */
exports.deleteUser = async (req, res) => {
  try {
    const { id } = req.params;
    
    const result = await db.query(
      `UPDATE users
       SET is_deleted = TRUE,
           deleted_at = NOW(),
           updated_at = NOW()
       WHERE id = $1
       RETURNING id, full_name`,
      [id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }
    
    res.json({
      success: true,
      message: 'User deleted successfully'
    });
    
    logger.info(`User ${id} deleted by admin`);
    
  } catch (error) {
    logger.error('Delete user error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete user'
    });
  }
};

/**
 * Get all coaches (admin view)
 */
exports.getCoaches = async (req, res) => {
  try {
    const { 
      search, 
      status, 
      approved,
      limit = 50, 
      offset = 0 
    } = req.query;
    
    let query = `
      SELECT 
        c.*,
        u.full_name,
        u.email,
        u.phone_number,
        u.profile_photo_url,
        u.is_active,
        COUNT(DISTINCT uc.user_id) as client_count,
        COALESCE(SUM(ce.coach_commission), 0) as total_earnings
      FROM coaches c
      JOIN users u ON c.user_id = u.id
      LEFT JOIN user_coaches uc ON c.user_id = uc.coach_id AND uc.is_active = TRUE
      LEFT JOIN coach_earnings ce ON c.user_id = ce.coach_id AND ce.status = 'paid'
      WHERE 1=1
    `;
    
    const params = [];
    let paramCount = 1;
    
    if (search) {
      query += ` AND (u.full_name ILIKE $${paramCount} OR u.email ILIKE $${paramCount})`;
      params.push(`%${search}%`);
      paramCount++;
    }
    
    if (status !== undefined) {
      query += ` AND u.is_active = $${paramCount}`;
      params.push(status === 'active');
      paramCount++;
    }
    
    if (approved !== undefined) {
      query += ` AND c.is_approved = $${paramCount}`;
      params.push(approved === 'true');
      paramCount++;
    }
    
    query += `
      GROUP BY c.id, u.id
      ORDER BY c.created_at DESC
      LIMIT $${paramCount} OFFSET $${paramCount + 1}
    `;
    
    params.push(parseInt(limit), parseInt(offset));
    
    const result = await db.query(query, params);
    
    res.json({
      success: true,
      coaches: result.rows,
      total: result.rowCount
    });
    
  } catch (error) {
    logger.error('Get coaches error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get coaches'
    });
  }
};

/**
 * Approve coach
 */
exports.approveCoach = async (req, res) => {
  try {
    const { id } = req.params;
    
    const result = await db.query(
      `UPDATE coaches
       SET is_approved = TRUE,
           approved_at = NOW(),
           updated_at = NOW()
       WHERE user_id = $1
       RETURNING *`,
      [id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Coach not found'
      });
    }
    
    // Update user role
    await db.query(
      'UPDATE users SET role = $1 WHERE id = $2',
      ['coach', id]
    );
    
    res.json({
      success: true,
      message: 'Coach approved successfully',
      coach: result.rows[0]
    });
    
    logger.info(`Coach ${id} approved by admin`);
    
  } catch (error) {
    logger.error('Approve coach error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to approve coach'
    });
  }
};

/**
 * Suspend coach
 */
exports.suspendCoach = async (req, res) => {
  try {
    const { id } = req.params;
    const { reason } = req.body;
    
    const result = await db.query(
      `UPDATE coaches
       SET is_active = FALSE,
           suspension_reason = $1,
           suspended_at = NOW(),
           updated_at = NOW()
       WHERE user_id = $2
       RETURNING *`,
      [reason, id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Coach not found'
      });
    }
    
    // Update user status
    await db.query(
      'UPDATE users SET is_active = FALSE WHERE id = $1',
      [id]
    );
    
    res.json({
      success: true,
      message: 'Coach suspended successfully'
    });
    
    logger.info(`Coach ${id} suspended by admin. Reason: ${reason}`);
    
  } catch (error) {
    logger.error('Suspend coach error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to suspend coach'
    });
  }
};

/**
 * Get revenue analytics
 */
exports.getRevenueAnalytics = async (req, res) => {
  try {
    const { period = 'month', startDate, endDate } = req.query;
    
    // Total revenue
    const totalResult = await db.query(
      `SELECT 
        COALESCE(SUM(amount), 0) as total,
        COUNT(*) as transaction_count
       FROM payments
       WHERE status = 'completed'`
    );
    
    // Revenue by period
    let periodQuery = `
      SELECT 
        DATE_TRUNC($1, created_at) as period,
        SUM(amount) as revenue,
        COUNT(*) as transactions
      FROM payments
      WHERE status = 'completed'
    `;
    
    const params = [period];
    
    if (startDate) {
      periodQuery += ` AND created_at >= $2`;
      params.push(startDate);
    }
    
    if (endDate) {
      periodQuery += ` AND created_at <= $${params.length + 1}`;
      params.push(endDate);
    }
    
    periodQuery += ` GROUP BY period ORDER BY period DESC LIMIT 12`;
    
    const periodResult = await db.query(periodQuery, params);
    
    // Revenue by subscription tier
    const tierResult = await db.query(
      `SELECT 
        subscription_tier,
        SUM(amount) as revenue,
        COUNT(*) as count
       FROM payments p
       JOIN users u ON p.user_id = u.id
       WHERE p.status = 'completed'
       GROUP BY subscription_tier`
    );
    
    res.json({
      success: true,
      revenue: {
        total: parseFloat(totalResult.rows[0].total),
        transactionCount: parseInt(totalResult.rows[0].transaction_count),
        byPeriod: periodResult.rows,
        byTier: tierResult.rows
      }
    });
    
  } catch (error) {
    logger.error('Get revenue analytics error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get revenue analytics'
    });
  }
};

/**
 * Get audit logs
 */
exports.getAuditLogs = async (req, res) => {
  try {
    const { 
      userId, 
      action, 
      startDate, 
      endDate,
      limit = 100, 
      offset = 0 
    } = req.query;
    
    let query = `
      SELECT 
        al.*,
        u.full_name as user_name
      FROM audit_logs al
      LEFT JOIN users u ON al.user_id = u.id
      WHERE 1=1
    `;
    
    const params = [];
    let paramCount = 1;
    
    if (userId) {
      query += ` AND al.user_id = $${paramCount}`;
      params.push(userId);
      paramCount++;
    }
    
    if (action) {
      query += ` AND al.action = $${paramCount}`;
      params.push(action);
      paramCount++;
    }
    
    if (startDate) {
      query += ` AND al.created_at >= $${paramCount}`;
      params.push(startDate);
      paramCount++;
    }
    
    if (endDate) {
      query += ` AND al.created_at <= $${paramCount}`;
      params.push(endDate);
      paramCount++;
    }
    
    query += `
      ORDER BY al.created_at DESC
      LIMIT $${paramCount} OFFSET $${paramCount + 1}
    `;
    
    params.push(parseInt(limit), parseInt(offset));
    
    const result = await db.query(query, params);
    
    res.json({
      success: true,
      logs: result.rows,
      total: result.rowCount
    });
    
  } catch (error) {
    logger.error('Get audit logs error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get audit logs'
    });
  }
};

/**
 * Get all exercises
 */
exports.getExercises = async (req, res) => {
  try {
    const { search, category, difficulty, limit = 50, offset = 0 } = req.query;
    
    let query = 'SELECT * FROM exercises WHERE 1=1';
    const params = [];
    let paramCount = 1;
    
    if (search) {
      query += ` AND (name ILIKE $${paramCount} OR name_ar ILIKE $${paramCount})`;
      params.push(`%${search}%`);
      paramCount++;
    }
    
    if (category) {
      query += ` AND category = $${paramCount}`;
      params.push(category);
      paramCount++;
    }
    
    if (difficulty) {
      query += ` AND difficulty = $${paramCount}`;
      params.push(difficulty);
      paramCount++;
    }
    
    query += ` ORDER BY name LIMIT $${paramCount} OFFSET $${paramCount + 1}`;
    params.push(parseInt(limit), parseInt(offset));
    
    const result = await db.query(query, params);
    
    res.json({
      success: true,
      exercises: result.rows,
      total: result.rowCount
    });
    
  } catch (error) {
    logger.error('Get exercises error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get exercises'
    });
  }
};

/**
 * Create exercise
 */
exports.createExercise = async (req, res) => {
  try {
    const {
      name,
      nameAr,
      description,
      descriptionAr,
      category,
      difficulty,
      muscleGroups,
      equipment,
      videoUrl,
      thumbnailUrl,
      instructions
    } = req.body;
    
    const result = await db.query(
      `INSERT INTO exercises (
        name,
        name_ar,
        description,
        description_ar,
        category,
        difficulty,
        muscle_groups,
        equipment,
        video_url,
        thumbnail_url,
        instructions
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
      RETURNING *`,
      [name, nameAr, description, descriptionAr, category, difficulty,
       muscleGroups, equipment, videoUrl, thumbnailUrl, instructions]
    );
    
    res.status(201).json({
      success: true,
      message: 'Exercise created successfully',
      exercise: result.rows[0]
    });
    
    logger.info(`Exercise created: ${result.rows[0].id}`);
    
  } catch (error) {
    logger.error('Create exercise error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create exercise'
    });
  }
};

/**
 * Update exercise
 */
exports.updateExercise = async (req, res) => {
  try {
    const { id } = req.params;
    const {
      name,
      nameAr,
      description,
      descriptionAr,
      category,
      difficulty,
      muscleGroups,
      equipment,
      videoUrl,
      thumbnailUrl,
      instructions
    } = req.body;
    
    const result = await db.query(
      `UPDATE exercises
       SET name = COALESCE($1, name),
           name_ar = COALESCE($2, name_ar),
           description = COALESCE($3, description),
           description_ar = COALESCE($4, description_ar),
           category = COALESCE($5, category),
           difficulty = COALESCE($6, difficulty),
           muscle_groups = COALESCE($7, muscle_groups),
           equipment = COALESCE($8, equipment),
           video_url = COALESCE($9, video_url),
           thumbnail_url = COALESCE($10, thumbnail_url),
           instructions = COALESCE($11, instructions),
           updated_at = NOW()
       WHERE id = $12
       RETURNING *`,
      [name, nameAr, description, descriptionAr, category, difficulty,
       muscleGroups, equipment, videoUrl, thumbnailUrl, instructions, id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Exercise not found'
      });
    }
    
    res.json({
      success: true,
      message: 'Exercise updated successfully',
      exercise: result.rows[0]
    });
    
    logger.info(`Exercise updated: ${id}`);
    
  } catch (error) {
    logger.error('Update exercise error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update exercise'
    });
  }
};

/**
 * Delete exercise
 */
exports.deleteExercise = async (req, res) => {
  try {
    const { id } = req.params;
    
    // Check if exercise is used in any workout plans
    const usageCheck = await db.query(
      `SELECT COUNT(*) as count
       FROM workout_exercises
       WHERE exercise_id = $1`,
      [id]
    );
    
    if (parseInt(usageCheck.rows[0].count) > 0) {
      return res.status(400).json({
        success: false,
        message: 'Cannot delete exercise that is used in workout plans'
      });
    }
    
    const result = await db.query(
      'DELETE FROM exercises WHERE id = $1 RETURNING id',
      [id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Exercise not found'
      });
    }
    
    res.json({
      success: true,
      message: 'Exercise deleted successfully'
    });
    
    logger.info(`Exercise deleted: ${id}`);
    
  } catch (error) {
    logger.error('Delete exercise error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete exercise'
    });
  }
};

/**
 * Get subscription plans
 */
exports.getSubscriptionPlans = async (req, res) => {
  try {
    const result = await db.query(
      `SELECT * FROM subscription_plans ORDER BY price ASC`
    );
    
    res.json({
      success: true,
      plans: result.rows
    });
    
  } catch (error) {
    logger.error('Get subscription plans error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get subscription plans'
    });
  }
};

/**
 * Update subscription plan
 */
exports.updateSubscriptionPlan = async (req, res) => {
  try {
    const { id } = req.params;
    const {
      name,
      nameAr,
      price,
      features,
      messageQuota,
      callQuota,
      hasNutritionAccess,
      hasChatAttachments
    } = req.body;
    
    const result = await db.query(
      `UPDATE subscription_plans
       SET name = COALESCE($1, name),
           name_ar = COALESCE($2, name_ar),
           price = COALESCE($3, price),
           features = COALESCE($4, features),
           message_quota = COALESCE($5, message_quota),
           call_quota = COALESCE($6, call_quota),
           has_nutrition_access = COALESCE($7, has_nutrition_access),
           has_chat_attachments = COALESCE($8, has_chat_attachments),
           updated_at = NOW()
       WHERE id = $9
       RETURNING *`,
      [name, nameAr, price, features, messageQuota, callQuota,
       hasNutritionAccess, hasChatAttachments, id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Subscription plan not found'
      });
    }
    
    res.json({
      success: true,
      message: 'Subscription plan updated successfully',
      plan: result.rows[0]
    });
    
    logger.info(`Subscription plan updated: ${id}`);
    
  } catch (error) {
    logger.error('Update subscription plan error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update subscription plan'
    });
  }
};

/**
 * Get system settings
 */
exports.getSystemSettings = async (req, res) => {
  try {
    const result = await db.query(
      'SELECT * FROM system_settings ORDER BY key'
    );
    
    // Convert to key-value object
    const settings = {};
    result.rows.forEach(row => {
      settings[row.key] = {
        value: row.value,
        description: row.description,
        updatedAt: row.updated_at
      };
    });
    
    res.json({
      success: true,
      settings
    });
    
  } catch (error) {
    logger.error('Get system settings error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get system settings'
    });
  }
};

/**
 * Update system settings
 */
exports.updateSystemSettings = async (req, res) => {
  try {
    const { settings } = req.body;
    
    // Update each setting
    for (const [key, value] of Object.entries(settings)) {
      await db.query(
        `INSERT INTO system_settings (key, value, updated_at)
         VALUES ($1, $2, NOW())
         ON CONFLICT (key) 
         DO UPDATE SET value = $2, updated_at = NOW()`,
        [key, value]
      );
    }
    
    res.json({
      success: true,
      message: 'System settings updated successfully'
    });
    
    logger.info('System settings updated');
    
  } catch (error) {
    logger.error('Update system settings error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update system settings'
    });
  }
};

module.exports = exports;
