const db = require('../database');
const logger = require('../utils/logger');

/**
 * Nutrition Access Service
 * Manages time-limited nutrition access for Freemium users
 * 
 * Rules:
 * - Freemium: 7-day trial after first workout completion
 * - Premium: Unlimited access
 * - Smart Premium: Unlimited + custom meal plans
 */

class NutritionAccessService {
  /**
   * Check if user has access to nutrition features
   */
  async checkAccess(userId) {
    try {
      const result = await db.query(
        `SELECT 
          u.id,
          u.subscription_tier,
          u.nutrition_access_unlocked_at,
          u.nutrition_access_expires_at,
          u.first_workout_completed_at,
          CASE 
            WHEN u.subscription_tier IN ('premium', 'smart_premium') THEN true
            WHEN u.subscription_tier = 'freemium' AND u.nutrition_access_unlocked_at IS NOT NULL 
                 AND (u.nutrition_access_expires_at IS NULL OR u.nutrition_access_expires_at > NOW()) THEN true
            ELSE false
          END as has_access,
          CASE
            WHEN u.subscription_tier = 'freemium' AND u.nutrition_access_expires_at IS NOT NULL THEN
              EXTRACT(EPOCH FROM (u.nutrition_access_expires_at - NOW())) / 86400
            ELSE NULL
          END as days_remaining
         FROM users u
         WHERE u.id = $1`,
        [userId]
      );

      if (result.rows.length === 0) {
        throw new Error('User not found');
      }

      const user = result.rows[0];

      return {
        hasAccess: user.has_access,
        tier: user.subscription_tier,
        isTrialActive: user.subscription_tier === 'freemium' && user.has_access,
        trialStartedAt: user.nutrition_access_unlocked_at,
        trialExpiresAt: user.nutrition_access_expires_at,
        daysRemaining: user.days_remaining ? Math.max(0, Math.ceil(user.days_remaining)) : null,
        requiresUpgrade: !user.has_access && user.subscription_tier === 'freemium'
      };

    } catch (error) {
      logger.error('Check nutrition access error:', error);
      throw error;
    }
  }

  /**
   * Unlock nutrition trial for Freemium user (7 days)
   * Triggered when user completes first workout
   */
  async unlockTrialAfterFirstWorkout(userId) {
    const client = await db.getClient();

    try {
      await client.query('BEGIN');

      // Check if user is freemium and hasn't unlocked trial yet
      const userResult = await client.query(
        `SELECT subscription_tier, nutrition_access_unlocked_at, first_workout_completed_at
         FROM users 
         WHERE id = $1`,
        [userId]
      );

      if (userResult.rows.length === 0) {
        throw new Error('User not found');
      }

      const user = userResult.rows[0];

      // Only freemium users get trial
      if (user.subscription_tier !== 'freemium') {
        await client.query('ROLLBACK');
        return {
          unlocked: false,
          reason: 'User is already premium - has unlimited access'
        };
      }

      // Already unlocked
      if (user.nutrition_access_unlocked_at) {
        await client.query('ROLLBACK');
        return {
          unlocked: false,
          reason: 'Trial already activated',
          unlockedAt: user.nutrition_access_unlocked_at
        };
      }

      // Unlock 7-day trial
      const now = new Date();
      const expiresAt = new Date(now.getTime() + (7 * 24 * 60 * 60 * 1000)); // 7 days

      await client.query(
        `UPDATE users 
         SET nutrition_access_unlocked_at = $1,
             nutrition_access_expires_at = $2,
             first_workout_completed_at = COALESCE(first_workout_completed_at, $1),
             updated_at = NOW()
         WHERE id = $3`,
        [now, expiresAt, userId]
      );

      await client.query('COMMIT');

      logger.info(`Nutrition trial unlocked for user ${userId} - expires ${expiresAt}`);

      return {
        unlocked: true,
        unlockedAt: now,
        expiresAt: expiresAt,
        daysGranted: 7
      };

    } catch (error) {
      await client.query('ROLLBACK');
      logger.error('Unlock nutrition trial error:', error);
      throw error;
    } finally {
      client.release();
    }
  }

  /**
   * Check if user should trigger nutrition unlock (first workout completion)
   */
  async checkAndUnlockIfFirstWorkout(userId) {
    try {
      // Check if user has completed any workout exercises
      const workoutResult = await db.query(
        `SELECT COUNT(*) as completed_count
         FROM exercise_completions ec
         WHERE ec.user_id = $1`,
        [userId]
      );

      const hasCompletedWorkout = parseInt(workoutResult.rows[0].completed_count) > 0;

      if (!hasCompletedWorkout) {
        return {
          shouldUnlock: false,
          reason: 'No workouts completed yet'
        };
      }

      // Check current access status
      const accessStatus = await this.checkAccess(userId);

      // If already has access (premium or trial active), don't unlock again
      if (accessStatus.hasAccess) {
        return {
          shouldUnlock: false,
          reason: 'Already has access',
          currentStatus: accessStatus
        };
      }

      // Unlock trial
      const unlockResult = await this.unlockTrialAfterFirstWorkout(userId);

      return {
        shouldUnlock: true,
        unlockResult
      };

    } catch (error) {
      logger.error('Check and unlock nutrition error:', error);
      throw error;
    }
  }

  /**
   * Extend trial (admin/coach action)
   */
  async extendTrial(userId, additionalDays) {
    try {
      const result = await db.query(
        `UPDATE users 
         SET nutrition_access_expires_at = 
           CASE 
             WHEN nutrition_access_expires_at > NOW() THEN nutrition_access_expires_at + ($1 || ' days')::INTERVAL
             ELSE NOW() + ($1 || ' days')::INTERVAL
           END,
           updated_at = NOW()
         WHERE id = $2
         RETURNING nutrition_access_expires_at`,
        [additionalDays, userId]
      );

      if (result.rows.length === 0) {
        throw new Error('User not found');
      }

      logger.info(`Extended nutrition trial for user ${userId} by ${additionalDays} days`);

      return {
        extended: true,
        newExpiresAt: result.rows[0].nutrition_access_expires_at
      };

    } catch (error) {
      logger.error('Extend nutrition trial error:', error);
      throw error;
    }
  }

  /**
   * Grant unlimited nutrition access (on subscription upgrade)
   */
  async grantUnlimitedAccess(userId) {
    try {
      await db.query(
        `UPDATE users 
         SET nutrition_access_expires_at = NULL,
             nutrition_access_unlocked_at = COALESCE(nutrition_access_unlocked_at, NOW()),
             updated_at = NOW()
         WHERE id = $1`,
        [userId]
      );

      logger.info(`Granted unlimited nutrition access to user ${userId}`);

      return {
        granted: true,
        accessType: 'unlimited'
      };

    } catch (error) {
      logger.error('Grant unlimited nutrition access error:', error);
      throw error;
    }
  }

  /**
   * Revoke nutrition access (on subscription downgrade)
   */
  async revokeAccess(userId) {
    try {
      await db.query(
        `UPDATE users 
         SET nutrition_access_expires_at = NOW() - INTERVAL '1 day',
             updated_at = NOW()
         WHERE id = $1`,
        [userId]
      );

      logger.info(`Revoked nutrition access for user ${userId}`);

      return {
        revoked: true
      };

    } catch (error) {
      logger.error('Revoke nutrition access error:', error);
      throw error;
    }
  }

  /**
   * Get nutrition access statistics (admin)
   */
  async getAccessStats() {
    try {
      const result = await db.query(`
        SELECT 
          subscription_tier,
          COUNT(*) as total_users,
          COUNT(CASE WHEN nutrition_access_unlocked_at IS NOT NULL THEN 1 END) as users_with_access,
          COUNT(CASE WHEN nutrition_access_expires_at > NOW() THEN 1 END) as active_trials,
          COUNT(CASE WHEN nutrition_access_expires_at < NOW() AND nutrition_access_expires_at IS NOT NULL THEN 1 END) as expired_trials
        FROM users
        GROUP BY subscription_tier
      `);

      return result.rows;

    } catch (error) {
      logger.error('Get nutrition access stats error:', error);
      throw error;
    }
  }
}

module.exports = new NutritionAccessService();
