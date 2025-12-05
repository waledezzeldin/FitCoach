import 'package:fitcoach_plus/localization/app_localizations.dart';
import 'package:fitcoach_plus/screens/workout/workout_plan_screen.dart';
import 'package:fitcoach_plus/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders plan timeline and starts the current session', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final app = AppState(enableNetworkSync: false)
      ..demoMode = true
      ..user = {'id': 'user-1'};

    await tester.pumpWidget(_wrapWithState(app, const WorkoutPlanScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Full Body Builder (Demo)'), findsOneWidget);
    await tester.tap(find.text("Start today's session"));
    await tester.pumpAndSettle();

    expect(find.text('Workout Session Stub'), findsOneWidget);
  });

  testWidgets('shows an empty state when no plan is present', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final app = AppState(enableNetworkSync: false)
      ..user = {'id': 'user-1'}
      ..demoMode = false
      ..workoutPlan = null;

    await tester.pumpWidget(_wrapWithState(app, const WorkoutPlanScreen()));
    await tester.pumpAndSettle();

    expect(find.text('No workout plan available'), findsOneWidget);
  });

  testWidgets('dismisses the tutorial card once acknowledged', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final app = AppState(enableNetworkSync: false)
      ..demoMode = true
      ..user = {'id': 'user-1'};

    await tester.pumpWidget(_wrapWithState(app, const WorkoutPlanScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Follow your two-week plan'), findsOneWidget);
    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();

    expect(find.text('Follow your two-week plan'), findsNothing);
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
    routes: {
      '/workout_session': (_) => const Scaffold(body: Center(child: Text('Workout Session Stub'))),
      '/workout_plan_details': (_) => const Scaffold(body: Center(child: Text('Plan Details Stub'))),
    },
    home: AppStateScope(
      notifier: app,
      child: Scaffold(body: child),
    ),
  );
}
