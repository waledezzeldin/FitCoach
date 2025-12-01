import 'package:fitcoach_plus/models/home_summary.dart';
import 'package:fitcoach_plus/screens/home/home_screen.dart';
import 'package:fitcoach_plus/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitcoach_plus/localization/app_localizations.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    binding.window.physicalSizeTestValue = const Size(1080, 1920);
    binding.window.devicePixelRatioTestValue = 1.0;
  });

  tearDown(() {
    binding.window.clearPhysicalSizeTestValue();
    binding.window.clearDevicePixelRatioTestValue();
  });

  group('HomeScreen quick actions', () {
    testWidgets('disables video booking when the action is locked', (tester) async {
      final app = _buildAppState(
        const HomeQuickActions(
          canBookVideoSession: false,
          canViewProgress: true,
          canAccessExerciseLibrary: true,
          hasInBodyData: false,
          canShopSupplements: true,
        ),
      );

      await tester.pumpWidget(_wrapWithApp(app));
      await tester.pumpAndSettle();

      final bookVideoButton = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Book Video Session'),
      );
      expect(bookVideoButton.onPressed, isNull);
      expect(find.text('Add your metrics'), findsOneWidget);
    });

    testWidgets('routes to bookings when the video action is available', (tester) async {
      final app = _buildAppState(
        const HomeQuickActions(
          canBookVideoSession: true,
          canViewProgress: true,
          canAccessExerciseLibrary: true,
          hasInBodyData: true,
          canShopSupplements: true,
        ),
      );

      await tester.pumpWidget(_wrapWithApp(app));
      await tester.pumpAndSettle();

      expect(find.text('View latest stats'), findsOneWidget);

      final videoAction = find.widgetWithText(OutlinedButton, 'Book Video Session');
      await tester.tap(videoAction);
      await tester.pumpAndSettle();

      expect(find.text('Bookings'), findsOneWidget);
    });
  });
}

Widget _wrapWithApp(AppState app) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    routes: {
      '/bookings': (_) => const Scaffold(body: Center(child: Text('Bookings'))),
      '/workout_session': (_) => const Scaffold(body: Center(child: Text('Workout Session'))),
      '/workout_history': (_) => const Scaffold(body: Center(child: Text('Workout History'))),
      '/workout_plan': (_) => const Scaffold(body: Center(child: Text('Workout Plan'))),
      '/store': (_) => const Scaffold(body: Center(child: Text('Store'))),
    },
    home: AppStateScope(
      notifier: app,
      child: const HomeScreen(),
    ),
  );
}

AppState _buildAppState(HomeQuickActions quickActions) {
  final app = AppState(enableNetworkSync: false);
  app.user = {'id': 'user-1', 'name': 'Laila Idris'};
  app.subscriptionType = 'premium';
  app.homeSummary = _buildHomeSummary(quickActions);
  app.homeSummaryLoading = false;
  app.homeSummaryError = null;
  app.workoutPlan = app.demoWorkoutPlan;
  return app;
}

HomeSummary _buildHomeSummary(HomeQuickActions quickActions) {
  return HomeSummary(
    userId: 'user-1',
    generatedAt: DateTime(2025, 1, 1),
    quickStats: const HomeQuickStats(
      workoutsCompletedWeek: 3,
      caloriesBurnedWeek: 950,
      caloriesConsumedToday: 1400,
      targetCalories: 2100,
      streakDays: 4,
      programWeek: 6,
      nutritionAdherencePct: 72,
    ),
    macros: const HomeMacroSummary(
      protein: MacroEntry(consumed: 90, target: 140),
      carbs: MacroEntry(consumed: 210, target: 250),
      fats: MacroEntry(consumed: 60, target: 70),
    ),
    weeklyProgress: const HomeWeeklyProgress(
      completionPct: 45,
      completedSessions: 3,
      targetSessions: 6,
    ),
    quickActions: quickActions,
    todayWorkout: const HomeWorkoutPreview(
      title: 'Upper Body Power',
      durationMin: 42,
      exercisesLogged: 8,
      completed: false,
    ),
    upcomingSession: null,
    quota: null,
  );
}
