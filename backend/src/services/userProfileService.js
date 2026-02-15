const db = require('../database');
const { mapDbUserToAppProfile } = require('../utils/userProfileMapper');

class UserProfileService {
  async getUserProfileForApp(userId) {
    const result = await db.query(
      `SELECT 
        u.*, 
        ui.primary_goal,
        ui.workout_location,
        ui.training_days_per_week,
        ui.experience_level,
        ui.fitness_level AS intake_fitness_level,
        ui.injury_history,
        ui.intake_completed_stage
       FROM users u
       LEFT JOIN user_intake ui ON u.id = ui.user_id
       WHERE u.id = $1`,
      [userId]
    );

    if (result.rows.length === 0) {
      return null;
    }

    const user = result.rows[0];
    if (!user.experience_level && user.intake_fitness_level) {
      user.experience_level = user.intake_fitness_level;
    }

    return mapDbUserToAppProfile(user);
  }
}

module.exports = new UserProfileService();
