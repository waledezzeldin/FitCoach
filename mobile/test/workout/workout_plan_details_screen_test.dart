import 'package:fitcoach_plus/screens/workout/workout_plan_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows an empty state when no workout is provided',
      (tester) async {
    await tester
        .pumpWidget(const MaterialApp(home: WorkoutPlanDetailsScreen()));

    expect(find.text('No workout details available.'), findsOneWidget);
  });

  testWidgets('renders workout details when arguments are supplied',
      (tester) async {
    final workout = {
      'day': 'Day 2',
      'exercise': 'Interval Ride',
      'details':
          'Alternate between 30s sprint and 60s recovery for 20 minutes.',
    };

    await tester.pumpWidget(_withWorkoutArguments(workout));
    await tester.pumpAndSettle();

    expect(find.text('Day 2 Details'), findsOneWidget);
    expect(find.text('Interval Ride'), findsOneWidget);
    expect(find.textContaining('Alternate between'), findsOneWidget);
  });
}

Widget _withWorkoutArguments(Map<String, dynamic> workout) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/workout_details',
    onGenerateRoute: (settings) {
      if (settings.name == '/workout_details') {
        return MaterialPageRoute(
          settings: RouteSettings(name: settings.name, arguments: workout),
          builder: (_) => const WorkoutPlanDetailsScreen(),
        );
      }
      return null;
    },
  );
}
