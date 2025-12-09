import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:fitcoach/app.dart';
import 'package:fitcoach/theme/fitcoach_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fitcoach/l10n/app_localizations.dart';
import 'package:fitcoach/screens/workouts/workouts_list_screen.dart';
import 'package:fitcoach/screens/workouts/workout_detail_screen.dart';
import 'package:fitcoach/screens/workouts/session_player_screen.dart';
import 'package:fitcoach/screens/home/home_screen.dart';

void main() {
  testWidgets('Navigate to session from workout detail', (tester) async {
    final router = GoRouter(
      initialLocation: '/workouts/w1',
      routes: [
        GoRoute(path: '/', builder: (c, s) => const HomeScreen()),
        GoRoute(path: '/workouts', builder: (c, s) => const WorkoutsListScreen()),
        GoRoute(path: '/workouts/:id', builder: (c, s) => WorkoutDetailScreen(id: s.pathParameters['id']!)),
        GoRoute(path: '/workouts/:id/session', builder: (c, s) => SessionPlayerScreen(id: s.pathParameters['id']!)),
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

    expect(find.text('Workout w1'), findsOneWidget);
    await tester.tap(find.text('Start Session'));
    await tester.pumpAndSettle();

    expect(find.text('Session - w1'), findsOneWidget);
    expect(find.textContaining('Elapsed'), findsOneWidget);
    expect(find.textContaining(':'), findsOneWidget);
  });
}
