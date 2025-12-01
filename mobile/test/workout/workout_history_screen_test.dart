import 'package:fitcoach_plus/screens/workout/workout_history_screen.dart';
import 'package:fitcoach_plus/services/workout_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders workout history entries when the service succeeds',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: WorkoutHistoryScreen(service: _SuccessfulWorkoutService()),
    ));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('Push Day'), findsOneWidget);
    expect(find.text('Pull Day'), findsOneWidget);
    expect(find.text('1500.0 kg'), findsOneWidget);
  });

  testWidgets('shows an error state and retry button when the service fails',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: WorkoutHistoryScreen(service: _FailingWorkoutService()),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Failed to load history'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();

    expect(find.text('Failed to load history'), findsOneWidget);
  });
}

class _SuccessfulWorkoutService extends WorkoutService {
  @override
  Future<List<Map<String, dynamic>>> history() async {
    return [
      {
        'workoutName': 'Push Day',
        'date': '2025-01-01',
        'volume': 1500,
      },
      {
        'workoutName': 'Pull Day',
        'date': '2025-01-02',
        'volume': 1200,
      },
    ];
  }
}

class _FailingWorkoutService extends WorkoutService {
  @override
  Future<List<Map<String, dynamic>>> history() async {
    throw Exception('network');
  }
}
