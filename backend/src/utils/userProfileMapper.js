const mapSubscriptionTier = (tier) => {
  const normalized = (tier || '').toLowerCase();
  if (normalized === 'premium') return 'Premium';
  if (normalized === 'smart_premium') return 'Smart Premium';
  return 'Freemium';
};

const parseJsonList = (value) => {
  if (!value) return [];
  if (Array.isArray(value)) return value;
  try {
    const parsed = JSON.parse(value);
    return Array.isArray(parsed) ? parsed : [];
  } catch (_) {
    return [];
  }
};

const mapDbUserToAppProfile = (user) => {
  const injuries = parseJsonList(user.injury_history || user.injuries);
  const hasCompletedFirstIntake = Boolean(user.first_intake_completed) ||
    user.intake_completed_stage === 'basic' ||
    user.intake_completed_stage === 'full';
  const hasCompletedSecondIntake = Boolean(user.second_intake_completed) ||
    user.intake_completed_stage === 'full';

  return {
    id: user.id,
    name: user.full_name || user.name || 'User',
    phoneNumber: user.phone_number || user.phoneNumber || '',
    email: user.email || null,
    age: user.age ?? null,
    weight: user.weight !== null && user.weight !== undefined ? Number(user.weight) : null,
    height: user.height ?? null,
    gender: user.gender || null,
    workoutFrequency: user.training_days_per_week
      ? parseInt(user.training_days_per_week, 10)
      : (user.workout_frequency ? parseInt(user.workout_frequency, 10) : null),
    workoutLocation: user.workout_location || user.preferred_location || null,
    experienceLevel: user.experience_level || user.fitness_level || null,
    mainGoal: user.primary_goal || user.goal || null,
    injuries,
    subscriptionTier: mapSubscriptionTier(user.subscription_tier),
    coachId: user.assigned_coach_id || user.coach_id || null,
    hasCompletedFirstIntake,
    hasCompletedSecondIntake,
    fitnessScore: user.fitness_score ?? null,
    fitnessScoreUpdatedBy: user.fitness_score_updated_by || null,
    fitnessScoreLastUpdated: user.fitness_score_last_updated || null,
    role: user.role || 'user'
  };
};

module.exports = {
  mapDbUserToAppProfile,
  mapSubscriptionTier
};
