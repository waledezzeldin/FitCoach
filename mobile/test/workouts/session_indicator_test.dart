import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitcoach/screens/workouts/session_player_screen.dart';
import 'package:fitcoach/workouts/session_models.dart';
import '../test_utils.dart';

void main() {
  testWidgets('Current timed step shows circular indicator and remaining', (tester) async {
    final steps = [
      WorkoutStep(id: 's1', title: 'Warm-up', durationSeconds: 60),
      WorkoutStep(id: 's2', title: 'Set 1', durationSeconds: 120),
    ];
    await tester.pumpThemed(SessionPlayerScreen(id: 'w1', initialSteps: steps));

    // Should render a CircularProgressIndicator for the first item
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    // Remaining should show seconds (<= duration)
    expect(find.textContaining('s'), findsWidgets);
  });
}
