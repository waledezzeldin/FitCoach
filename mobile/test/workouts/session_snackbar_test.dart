import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:fitcoach/screens/workouts/session_player_screen.dart';
import 'package:fitcoach/workouts/session_models.dart';
import '../test_utils.dart';

void main() {
  testWidgets('Shows snackbar on skip (advance)', (tester) async {
    final steps = [
      WorkoutStep(id: 's1', title: 'Warm-up', durationSeconds: 60),
      WorkoutStep(id: 's2', title: 'Set 1', durationSeconds: 60),
    ];
    await tester.pumpThemed(SessionPlayerScreen(id: 'w1', initialSteps: steps));

    // Tap Skip via stable key
    await tester.tap(find.byKey(const Key('sessionSkip')));
    await tester.pumpAndSettle();

    // Snackbar should appear (look for its text)
    expect(find.textContaining('Step completed'), findsOneWidget);
  });
}
