import 'package:fitcoach_plus/localization/app_localizations.dart';
import 'package:fitcoach_plus/screens/workout/workout_plan_screen.dart';
import 'package:fitcoach_plus/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders the workout plan when demo data is available',
      (tester) async {
    final app = AppState(enableNetworkSync: false)
      ..demoMode = true
      ..user = {'id': 'user-1'};

    await tester.pumpWidget(_wrapWithState(app, const WorkoutPlanScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Full Body Builder (Demo)'), findsOneWidget);
  });

  testWidgets('shows a fallback message when no plan is present',
      (tester) async {
    final app = AppState(enableNetworkSync: false)
      ..user = {'id': 'user-1'}
      ..demoMode = false
      ..workoutPlan = null;

    await tester.pumpWidget(_wrapWithState(app, const WorkoutPlanScreen()));
    await tester.pumpAndSettle();

    expect(find.text('No plan available'), findsOneWidget);
  });
}

Widget _wrapWithState(AppState app, Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: AppStateScope(
      notifier: app,
      child: Scaffold(body: child),
    ),
  );
}
