export type DemoPersona = 'user' | 'coach' | 'admin';

export interface DemoFixture {
  user: Record<string, unknown>;
  subscription: string;
  stats: Record<string, unknown>;
  workoutPlan: Record<string, unknown>;
  nutritionPlan: Record<string, unknown>;
}

const sharedStats = {
  workouts_completed_week: 4,
  calories_burned_week: 1850,
  calories_consumed_today: 1625,
  target_calories: 2100,
  streak_days: 6,
  program_week: 3,
  weight_progress_kg: -1.4,
  nutrition_adherence_pct: 74,
};

const sharedWorkout = {
  name: 'Full Body Builder (Demo)',
  days: [
    {
      day: 'Day 1',
      blocks: [
        { exercise: 'Back Squat', sets: 4, reps: 8 },
        { exercise: 'Incline DB Press', sets: 3, reps: 10 },
        { exercise: 'Lat Pulldown', sets: 3, reps: 12 },
        { exercise: 'Plank', sets: 3, reps: 40 },
        { exercise: 'DB Romanian Deadlift', sets: 3, reps: 10 },
      ],
    },
    {
      day: 'Day 2',
      blocks: [
        { exercise: 'Deadlift', sets: 3, reps: 5 },
        { exercise: 'Seated Row', sets: 3, reps: 10 },
        { exercise: 'Shoulder Press', sets: 3, reps: 10 },
        { exercise: 'Cable Fly', sets: 2, reps: 15 },
        { exercise: 'Hanging Leg Raise', sets: 3, reps: 12 },
      ],
    },
  ],
};

const sharedNutrition = {
  calories: 2100,
  protein_g: 160,
  carbs_g: 220,
  fats_g: 70,
  meals: [
    { name: 'Breakfast', kcal: 420 },
    { name: 'Lunch', kcal: 650 },
    { name: 'Snack', kcal: 180 },
    { name: 'Dinner', kcal: 720 },
  ],
};

const baseFixtures: Record<DemoPersona, DemoFixture> = {
  user: {
    user: {
      id: 'demo_user',
      role: 'user',
      name: 'Jordan Demo',
      email: 'demo.user@fitcoach.dev',
      preferredLocale: 'en',
      intake: {
        first: {
          gender: 'female',
          mainGoal: 'build_muscle',
          workoutLocation: 'gym',
          completedAt: new Date('2025-10-01').toISOString(),
        },
        second: {
          age: 31,
          weight: 67,
          height: 168,
          experienceLevel: 'intermediate',
          workoutFrequency: 4,
          injuries: 'none',
          completedAt: new Date('2025-10-02').toISOString(),
        },
      },
    },
    subscription: 'smart_premium',
    stats: sharedStats,
    workoutPlan: sharedWorkout,
    nutritionPlan: sharedNutrition,
  },
  coach: {
    user: {
      id: 'demo_coach',
      role: 'coach',
      name: 'Coach Riley Demo',
      email: 'coach.demo@fitcoach.dev',
      preferredLocale: 'en',
    },
    subscription: 'coach_pro',
    stats: sharedStats,
    workoutPlan: sharedWorkout,
    nutritionPlan: sharedNutrition,
  },
  admin: {
    user: {
      id: 'demo_admin',
      role: 'admin',
      name: 'Admin Casey Demo',
      email: 'admin.demo@fitcoach.dev',
      preferredLocale: 'en',
    },
    subscription: 'enterprise',
    stats: sharedStats,
    workoutPlan: sharedWorkout,
    nutritionPlan: sharedNutrition,
  },
};

export const getDemoFixture = (persona: string): DemoFixture => {
  const key = (persona?.toLowerCase?.() ?? 'user') as DemoPersona;
  return baseFixtures[key] ?? baseFixtures.user;
};

export const availableDemoPersonas = Object.keys(baseFixtures) as DemoPersona[];
