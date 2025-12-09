import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:fitcoach/screens/workouts/workouts_list_screen.dart';
import 'package:fitcoach/screens/intake/intake_state.dart';
import 'package:fitcoach/subscription/subscription_state.dart';
import 'package:fitcoach/theme/fitcoach_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fitcoach/l10n/app_localizations.dart';

void main() {
  testWidgets('Shows intake reminder banner and navigates via actions', (tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (c, s) => const WorkoutsListScreen()),
        GoRoute(path: '/intake/second', builder: (c, s) => const Scaffold(body: Center(child: Text('Second Intake')))),
        GoRoute(path: '/coach', builder: (c, s) => const Scaffold(body: Center(child: Text('Coach')))),
        GoRoute(path: '/workouts/w1', builder: (c, s) => const Scaffold(body: Center(child: Text('Workout w1')))),
      ],
    );

    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => IntakeState()..load()),
        ChangeNotifierProvider(create: (_) => SubscriptionState()..load()),
      ],
      child: MaterialApp.router(
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
      ),
    ));
    for (int i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 125));
    }

    // Banner should appear because second intake is not valid by default
    expect(find.textContaining('Unlock your Customized Plan'), findsOneWidget);

    // Tap Complete Intake -> navigates to intake second
    await tester.tap(find.text('Complete Intake'));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('Second Intake'), findsOneWidget);

    // Go back to workouts via router
    router.go('/');
    for (int i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Tap Talk to Coach -> navigates to coach
    await tester.tap(find.text('Talk to Coach'));
    for (int i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Coach'), findsOneWidget);

    // Back to workouts via router
    router.go('/');
    for (int i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Tap a workout card -> navigates to generic workout
    await tester.tap(find.text('Workout 1'));
    for (int i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Workout w1'), findsOneWidget);
  });
}
