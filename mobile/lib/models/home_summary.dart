import 'quota_models.dart';

class HomeSummary {
  const HomeSummary({
    required this.userId,
    required this.generatedAt,
    required this.quickStats,
    required this.macros,
    required this.weeklyProgress,
    required this.quickActions,
    this.todayWorkout,
    this.upcomingSession,
    this.quota,
  });

  final String userId;
  final DateTime generatedAt;
  final HomeQuickStats quickStats;
  final HomeMacroSummary macros;
  final HomeWeeklyProgress weeklyProgress;
  final HomeQuickActions quickActions;
  final HomeWorkoutPreview? todayWorkout;
  final HomeSessionSummary? upcomingSession;
  final QuotaSnapshot? quota;

  factory HomeSummary.fromJson(Map<String, dynamic> json) {
    return HomeSummary(
      userId: json['userId']?.toString() ?? '',
      generatedAt: DateTime.tryParse(json['generatedAt'] ?? '') ?? DateTime.now(),
      quickStats: HomeQuickStats.fromJson(_coerceMap(json['quickStats'])),
      macros: HomeMacroSummary.fromJson(_coerceMap(json['macros'])),
      weeklyProgress: HomeWeeklyProgress.fromJson(_coerceMap(json['weeklyProgress'])),
      quickActions: HomeQuickActions.fromJson(_coerceMap(json['quickActions'])),
      todayWorkout: json['todayWorkout'] == null
          ? null
          : HomeWorkoutPreview.fromJson(_coerceMap(json['todayWorkout'])),
      upcomingSession: json['upcomingSession'] == null
          ? null
          : HomeSessionSummary.fromJson(_coerceMap(json['upcomingSession'])),
      quota: json['quota'] is Map ? QuotaSnapshot.fromJson(_coerceMap(json['quota'])) : null,
    );
  }

  static HomeSummary fromLegacyStats(Map<String, dynamic> stats) {
    final quickStats = HomeQuickStats(
      workoutsCompletedWeek: stats['workouts_completed_week'] ?? 0,
      caloriesBurnedWeek: stats['calories_burned_week'] ?? 0,
      caloriesConsumedToday: stats['calories_consumed_today'] ?? 0,
      targetCalories: stats['target_calories'] ?? 2000,
      streakDays: stats['streak_days'] ?? 0,
      programWeek: stats['program_week'] ?? 1,
      weightProgressKg: (stats['weight_progress_kg'] as num?)?.toDouble(),
      nutritionAdherencePct: stats['nutrition_adherence_pct'] ?? 0,
    );
    return HomeSummary(
      userId: 'legacy',
      generatedAt: DateTime.now(),
      quickStats: quickStats,
      macros: const HomeMacroSummary.placeholder(),
      weeklyProgress: HomeWeeklyProgress(
        completionPct: 0,
        completedSessions: quickStats.workoutsCompletedWeek,
        targetSessions: 4,
      ),
      quickActions: const HomeQuickActions(
        canBookVideoSession: true,
        canViewProgress: true,
        canAccessExerciseLibrary: true,
        hasInBodyData: false,
        canShopSupplements: true,
      ),
      todayWorkout: null,
      upcomingSession: null,
      quota: null,
    );
  }
}

class HomeQuickStats {
  const HomeQuickStats({
    required this.workoutsCompletedWeek,
    required this.caloriesBurnedWeek,
    required this.caloriesConsumedToday,
    required this.targetCalories,
    required this.streakDays,
    required this.programWeek,
    this.weightProgressKg,
    required this.nutritionAdherencePct,
  });

  final int workoutsCompletedWeek;
  final int caloriesBurnedWeek;
  final int caloriesConsumedToday;
  final int targetCalories;
  final int streakDays;
  final int programWeek;
  final double? weightProgressKg;
  final int nutritionAdherencePct;

  double get nutritionProgress => targetCalories == 0
      ? 0
      : (caloriesConsumedToday / targetCalories).clamp(0, targetCalories) / targetCalories;

  factory HomeQuickStats.fromJson(Map<String, dynamic> json) => HomeQuickStats(
        workoutsCompletedWeek: json['workoutsCompletedWeek'] ?? 0,
        caloriesBurnedWeek: json['caloriesBurnedWeek'] ?? 0,
        caloriesConsumedToday: json['caloriesConsumedToday'] ?? 0,
        targetCalories: json['targetCalories'] ?? 2000,
        streakDays: json['streakDays'] ?? 0,
        programWeek: json['programWeek'] ?? 1,
        weightProgressKg: (json['weightProgressKg'] as num?)?.toDouble(),
        nutritionAdherencePct: json['nutritionAdherencePct'] ?? 0,
      );
}

class HomeMacroSummary {
  const HomeMacroSummary({
    required this.protein,
    required this.carbs,
    required this.fats,
  });

  final MacroEntry protein;
  final MacroEntry carbs;
  final MacroEntry fats;

  factory HomeMacroSummary.fromJson(Map<String, dynamic> json) => HomeMacroSummary(
        protein: MacroEntry.fromJson(_coerceMap(json['protein'])),
        carbs: MacroEntry.fromJson(_coerceMap(json['carbs'])),
        fats: MacroEntry.fromJson(_coerceMap(json['fats'])),
      );

  const HomeMacroSummary.placeholder()
      : protein = const MacroEntry(consumed: 0, target: 0),
        carbs = const MacroEntry(consumed: 0, target: 0),
        fats = const MacroEntry(consumed: 0, target: 0);
}

class MacroEntry {
  const MacroEntry({required this.consumed, required this.target});
  final num consumed;
  final num target;

  factory MacroEntry.fromJson(Map<String, dynamic> json) => MacroEntry(
        consumed: json['consumed'] ?? 0,
        target: json['target'] ?? 0,
      );
}

class HomeWeeklyProgress {
  const HomeWeeklyProgress({
    required this.completionPct,
    required this.completedSessions,
    required this.targetSessions,
  });

  final int completionPct;
  final int completedSessions;
  final int targetSessions;

  factory HomeWeeklyProgress.fromJson(Map<String, dynamic> json) => HomeWeeklyProgress(
        completionPct: json['completionPct'] ?? 0,
        completedSessions: json['completedSessions'] ?? 0,
        targetSessions: json['targetSessions'] ?? 0,
      );
}

class HomeWorkoutPreview {
  const HomeWorkoutPreview({
    required this.title,
    required this.durationMin,
    required this.exercisesLogged,
    required this.completed,
  });

  final String title;
  final num durationMin;
  final int exercisesLogged;
  final bool completed;

  factory HomeWorkoutPreview.fromJson(Map<String, dynamic> json) => HomeWorkoutPreview(
        title: json['title']?.toString() ?? 'Today\'s Workout',
        durationMin: json['durationMin'] ?? 0,
        exercisesLogged: json['exercisesLogged'] ?? 0,
        completed: json['completed'] == true,
      );
}

class HomeSessionSummary {
  const HomeSessionSummary({
    required this.id,
    required this.scheduledAt,
    required this.durationMin,
    this.coachName,
    this.type,
  });

  final String id;
  final DateTime scheduledAt;
  final int durationMin;
  final String? coachName;
  final String? type;

  factory HomeSessionSummary.fromJson(Map<String, dynamic> json) => HomeSessionSummary(
        id: json['id']?.toString() ?? '',
        scheduledAt: DateTime.tryParse(json['scheduledAt']?.toString() ?? '') ?? DateTime.now(),
        durationMin: json['durationMin'] ?? 0,
        coachName: json['coachName']?.toString(),
        type: json['type']?.toString(),
      );
}

class HomeQuickActions {
  const HomeQuickActions({
    required this.canBookVideoSession,
    required this.canViewProgress,
    required this.canAccessExerciseLibrary,
    required this.hasInBodyData,
    required this.canShopSupplements,
  });

  final bool canBookVideoSession;
  final bool canViewProgress;
  final bool canAccessExerciseLibrary;
  final bool hasInBodyData;
  final bool canShopSupplements;

  factory HomeQuickActions.fromJson(Map<String, dynamic> json) => HomeQuickActions(
        canBookVideoSession: json['canBookVideoSession'] == true,
        canViewProgress: json['canViewProgress'] != false,
        canAccessExerciseLibrary: json['canAccessExerciseLibrary'] != false,
        hasInBodyData: json['hasInBodyData'] == true,
        canShopSupplements: json['canShopSupplements'] != false,
      );
}

Map<String, dynamic> _coerceMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, val) => MapEntry(key.toString(), val));
  }
  return <String, dynamic>{};
}
