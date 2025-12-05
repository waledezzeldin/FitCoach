import { Router, Request, Response } from 'express';
import {
  PrismaClient,
  WorkoutLog,
  NutritionLog,
  SubscriptionQuota,
  SubscriptionTier,
  UserIntake,
} from '@prisma/client';
import { getDemoFixture } from '../demo/demo.fixtures';
import { TIER_QUOTAS } from '../subscription/quota.config';

const router = Router();
const prisma = new PrismaClient();

const DEFAULT_DAILY_CALORIES = Number(process.env.HOME_SUMMARY_DEFAULT_CALORIES ?? 2100);
const DEFAULT_WEEKLY_WORKOUTS = Number(process.env.HOME_SUMMARY_WEEKLY_WORKOUTS ?? 4);

router.get('/summary/:userId', async (req: Request, res: Response) => {
  const { userId } = req.params;
  if (!userId) {
    return res.status(400).json({ error: 'userId is required' });
  }

  try {
    if (req.isDemoMode) {
      const persona = req.query.persona?.toString() ?? 'user';
      return res.json(buildDemoSummary(persona));
    }

    const now = new Date();
    const startWeek = startOfWeek(now);
    const startToday = startOfDay(now);

    const [user, workouts, nutritionToday, nutritionWeek, upcomingSession, quota] = await Promise.all([
      prisma.user.findUnique({
        where: { id: userId },
        include: {
          intake: true,
          nutritionPreference: true,
          subscriptionQuota: true,
          coach: { include: { user: true } },
        },
      }),
      prisma.workoutLog.findMany({
        where: { userId, date: { gte: startWeek } },
        orderBy: { date: 'desc' },
        take: 28,
      }),
      prisma.nutritionLog.findMany({
        where: { userId, date: { gte: startToday } },
        orderBy: { date: 'desc' },
      }),
      prisma.nutritionLog.findMany({
        where: { userId, date: { gte: startWeek } },
        orderBy: { date: 'desc' },
      }),
      prisma.session.findFirst({
        where: {
          userId,
          scheduledAt: { gte: now },
          status: { in: ['scheduled', 'pending', 'confirmed'] },
        },
        orderBy: { scheduledAt: 'asc' },
        include: {
          coach: {
            include: {
              user: true,
            },
          },
        },
      }),
      prisma.subscriptionQuota.findUnique({ where: { userId } }),
    ]);

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    const workoutsCompletedWeek = workouts.length;
    const caloriesBurnedWeek = estimateCalories(workouts);
    const caloriesConsumedToday = sumCalories(nutritionToday);
    const targetCalories = resolveTargetCalories(user.subscriptionQuota, user.nutritionPreference);
    const streakDays = computeStreak(workouts, now);
    const weeklyCompletion = computeWeeklyCompletion(workoutsCompletedWeek);
    const macros = aggregateMacros(nutritionToday, targetCalories);
    const adherence = computeNutritionAdherence(nutritionWeek, targetCalories);

    const summary = {
      userId,
      generatedAt: now.toISOString(),
      quickStats: {
        workoutsCompletedWeek,
        caloriesBurnedWeek,
        caloriesConsumedToday,
        targetCalories,
        streakDays,
        programWeek: computeProgramWeek(user.intake ?? undefined),
        weightProgressKg: null,
        nutritionAdherencePct: adherence,
      },
      macros,
      weeklyProgress: {
        completionPct: weeklyCompletion,
        completedSessions: workoutsCompletedWeek,
        targetSessions: DEFAULT_WEEKLY_WORKOUTS,
      },
      todayWorkout: buildTodayWorkout(workouts, now),
      upcomingSession: upcomingSession
        ? {
            id: upcomingSession.id,
            scheduledAt: upcomingSession.scheduledAt,
            durationMin: upcomingSession.durationMin,
            coachName: upcomingSession.coach?.user?.name ?? null,
            type: upcomingSession.status,
          }
        : null,
      quickActions: buildQuickActions({
        tier: user.subscriptionQuota?.tier,
        quota: quota ?? user.subscriptionQuota ?? undefined,
        workoutsCompletedWeek,
        hasNutritionEntries: nutritionToday.length > 0 || nutritionWeek.length > 0,
        hasInBodyData: hasBodyCompositionMetrics(user.intake ?? undefined),
      }),
      quota,
    };

    res.json(summary);
  } catch (error) {
    console.error('[home] Failed to build summary', error);
    res.status(500).json({ error: 'Unable to build home summary' });
  }
});

function startOfDay(date: Date) {
  const copy = new Date(date);
  copy.setHours(0, 0, 0, 0);
  return copy;
}

function startOfWeek(date: Date) {
  const copy = startOfDay(date);
  const day = copy.getDay();
  const diff = (day + 6) % 7; // Monday start
  copy.setDate(copy.getDate() - diff);
  return copy;
}

function estimateCalories(workouts: WorkoutLog[]): number {
  return workouts.reduce((total, log) => total + Math.round(log.duration * 5.5), 0);
}

function sumCalories(entries: NutritionLog[]): number {
  return entries.reduce((total, log) => total + (log.calories ?? 0), 0);
}

function resolveTargetCalories(quota: SubscriptionQuota | null | undefined, preference: any): number {
  if (preference?.dailyCalorieTarget && typeof preference.dailyCalorieTarget === 'number') {
    return preference.dailyCalorieTarget;
  }
  if (quota?.tier === SubscriptionTier.smart_premium) {
    return 2200;
  }
  if (quota?.tier === SubscriptionTier.premium) {
    return 2000;
  }
  return DEFAULT_DAILY_CALORIES;
}

function computeStreak(workouts: WorkoutLog[], now: Date): number {
  if (!workouts.length) return 0;
  const uniqueDays = new Set<string>();
  workouts.forEach((log) => {
    uniqueDays.add(startOfDay(log.date).toISOString());
  });
  let streak = 0;
  for (let i = 0; i < 14; i += 1) {
    const day = startOfDay(new Date(now));
    day.setDate(day.getDate() - i);
    if (uniqueDays.has(day.toISOString())) {
      streak += 1;
    } else {
      break;
    }
  }
  return streak;
}

function computeWeeklyCompletion(workoutsCompleted: number): number {
  if (!DEFAULT_WEEKLY_WORKOUTS) return 0;
  return Math.min(100, Math.round((workoutsCompleted / DEFAULT_WEEKLY_WORKOUTS) * 100));
}

type NutritionLogWithMacros = NutritionLog & { protein?: number | null; carbs?: number | null; fats?: number | null };

function aggregateMacros(entries: NutritionLogWithMacros[], targetCalories: number) {
  const totals = entries.reduce(
    (acc, log) => {
      acc.protein += log.protein ?? 0;
      acc.carbs += log.carbs ?? 0;
      acc.fats += log.fats ?? 0;
      return acc;
    },
    { protein: 0, carbs: 0, fats: 0 }
  );

  const macroTargets = estimateMacroTargets(targetCalories);
  return {
    protein: { consumed: Math.round(totals.protein), target: macroTargets.protein },
    carbs: { consumed: Math.round(totals.carbs), target: macroTargets.carbs },
    fats: { consumed: Math.round(totals.fats), target: macroTargets.fats },
  };
}

function estimateMacroTargets(calories: number) {
  const proteinCalories = calories * 0.3;
  const carbCalories = calories * 0.45;
  const fatCalories = calories * 0.25;
  return {
    protein: Math.round(proteinCalories / 4),
    carbs: Math.round(carbCalories / 4),
    fats: Math.round(fatCalories / 9),
  };
}

function computeNutritionAdherence(entries: NutritionLog[], targetCalories: number): number {
  if (!entries.length || !targetCalories) return 0;
  const grouped = new Map<string, number>();
  entries.forEach((log) => {
    const key = startOfDay(log.date).toISOString();
    grouped.set(key, (grouped.get(key) ?? 0) + (log.calories ?? 0));
  });
  const adherenceScores: number[] = [];
  grouped.forEach((calories) => {
    const pct = (calories / targetCalories) * 100;
    const bounded = Math.max(0, Math.min(120, pct));
    adherenceScores.push(120 - Math.abs(100 - bounded));
  });
  const average = adherenceScores.reduce((sum, value) => sum + value, 0) / adherenceScores.length;
  return Math.round(Math.min(100, Math.max(0, average)));
}

function computeProgramWeek(intake?: { createdAt?: Date }): number {
  if (!intake?.createdAt) return 1;
  const weeks = Math.floor((Date.now() - intake.createdAt.getTime()) / (7 * 24 * 60 * 60 * 1000));
  return Math.max(1, weeks + 1);
}

function buildTodayWorkout(workouts: WorkoutLog[], now: Date) {
  const startToday = startOfDay(now);
  const todaysEntries = workouts.filter((log) => log.date >= startToday);
  if (!todaysEntries.length) {
    return null;
  }
  const duration = todaysEntries.reduce((sum, log) => sum + log.duration, 0);
  return {
    title: 'Today\'s Workout',
    durationMin: duration,
    exercisesLogged: todaysEntries.length,
    completed: true,
  };
}

type QuickActionInputs = {
  tier?: SubscriptionTier | null;
  quota?: SubscriptionQuota | null;
  workoutsCompletedWeek: number;
  hasNutritionEntries: boolean;
  hasInBodyData: boolean;
};

function buildQuickActions({ tier, quota, workoutsCompletedWeek, hasNutritionEntries, hasInBodyData }: QuickActionInputs) {
  const resolvedTier = tier ?? SubscriptionTier.freemium;
  const limits = TIER_QUOTAS[resolvedTier];
  const callsUsed = quota?.callsUsed ?? 0;
  const remainingCalls = Math.max(limits.calls - callsUsed, 0);
  return {
    canBookVideoSession: resolvedTier !== SubscriptionTier.freemium && remainingCalls > 0,
    canViewProgress: workoutsCompletedWeek > 0 || hasNutritionEntries,
    canAccessExerciseLibrary: true,
    hasInBodyData,
    canShopSupplements: true,
  };
}

function hasBodyCompositionMetrics(intake?: UserIntake | null) {
  if (!intake) return false;
  const hasWeight = typeof intake.weightKg === 'number';
  const hasHeight = typeof intake.heightCm === 'number';
  return hasWeight && hasHeight;
}

function buildDemoSummary(persona: string) {
  const fixture = getDemoFixture(persona);
  const stats = fixture.stats as Record<string, number>;
  const now = new Date();
  return {
    userId: fixture.user?.id ?? 'demo_user',
    generatedAt: now.toISOString(),
    quickStats: {
      workoutsCompletedWeek: stats?.workouts_completed_week ?? 0,
      caloriesBurnedWeek: stats?.calories_burned_week ?? 0,
      caloriesConsumedToday: stats?.calories_consumed_today ?? 0,
      targetCalories: stats?.target_calories ?? DEFAULT_DAILY_CALORIES,
      streakDays: stats?.streak_days ?? 0,
      programWeek: stats?.program_week ?? 1,
      weightProgressKg: stats?.weight_progress_kg ?? null,
      nutritionAdherencePct: stats?.nutrition_adherence_pct ?? 0,
    },
    macros: {
      protein: { consumed: 120, target: 160 },
      carbs: { consumed: 220, target: 240 },
      fats: { consumed: 60, target: 70 },
    },
    weeklyProgress: {
      completionPct: 75,
      completedSessions: stats?.workouts_completed_week ?? 0,
      targetSessions: DEFAULT_WEEKLY_WORKOUTS,
    },
    todayWorkout: {
      title: 'Upper Body Strength',
      durationMin: 45,
      exercisesLogged: 6,
      completed: false,
    },
    upcomingSession: null,
    quickActions: buildQuickActions({
      tier: SubscriptionTier.smart_premium,
      quota: null,
      workoutsCompletedWeek: stats?.workouts_completed_week ?? 0,
      hasNutritionEntries: true,
      hasInBodyData: true,
    }),
    quota: null,
  };
}

export default router;
