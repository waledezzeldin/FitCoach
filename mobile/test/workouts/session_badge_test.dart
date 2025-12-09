import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitcoach/screens/workouts/session_player_screen.dart';
import 'package:fitcoach/workouts/session_models.dart';
import '../test_utils.dart';

void main() {
  testWidgets('Completed step shows badge overlay', (tester) async {
    final steps = [
      WorkoutStep(id: 's1', title: 'Warm-up'),
      WorkoutStep(id: 's2', title: 'Set 1'),
    ];
    await tester.pumpThemed(SessionPlayerScreen(id: 'w1', initialSteps: steps));

    // Mark first as completed by tapping
    await tester.tap(find.text('Warm-up'));
    await tester.pump();

    // Should still show title
    expect(find.text('Warm-up'), findsOneWidget);
    // Badge overlay check icon likely present; search by Icon and constraints
    expect(find.byIcon(Icons.check), findsWidgets);
  });
}
