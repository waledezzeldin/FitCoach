import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:fitcoach/app.dart';
import 'package:fitcoach/theme/fitcoach_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fitcoach/l10n/app_localizations.dart';
import 'package:fitcoach/screens/workouts/workout_detail_screen.dart';
import 'package:fitcoach/screens/workouts/session_player_screen.dart';
import 'package:fitcoach/screens/workouts/session_complete_screen.dart';
import 'package:fitcoach/workouts/session_models.dart';
import 'package:fitcoach/screens/home/home_screen.dart';

void main() {
  testWidgets('Completing session navigates to summary screen', (tester) async {
    final router = GoRouter(
      initialLocation: '/workouts/w2/session',
      routes: [
        GoRoute(path: '/', builder: (c, s) => const HomeScreen()),
        GoRoute(path: '/workouts/:id', builder: (c, s) => WorkoutDetailScreen(id: s.pathParameters['id']!)),
        GoRoute(path: '/workouts/:id/session', builder: (c, s) => SessionPlayerScreen(id: s.pathParameters['id']!)),
        GoRoute(path: '/workouts/:id/session/complete', builder: (c, s) {
          final id = s.pathParameters['id']!;
          final extra = s.extra;
          final result = extra is SessionResult
              ? extra
              : SessionResult(workoutId: id, elapsed: Duration.zero, completedSteps: 0, totalSteps: 0);
          return SessionCompleteScreen(result: result);
        }),
      ],
    );

    await tester.binding.setSurfaceSize(const Size(390, 1200));
    await tester.pumpWidget(MaterialApp.router(
      theme: FitCoachTheme.light(),
      darkTheme: FitCoachTheme.dark(),
      routerConfig: router,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
    ));
    await tester.pumpAndSettle();

    // Toggle all steps to enable Complete
    final warmup = find.text('Warm-up');
    final set1 = find.text('Set 1');
    final set2 = find.text('Set 2');
    final cooldown = find.text('Cooldown');
    expect(warmup, findsOneWidget);
    await tester.tap(warmup); await tester.pump();
    await tester.tap(set1); await tester.pump();
    await tester.tap(set2); await tester.pump();
    await tester.tap(cooldown); await tester.pump();

    await tester.tap(find.text('Complete Session'));
    await tester.pumpAndSettle();

    expect(find.text('Session Complete'), findsOneWidget);
    expect(find.textContaining('Duration'), findsOneWidget);
    expect(find.textContaining('Steps'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
  });
}
