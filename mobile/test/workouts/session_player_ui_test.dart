import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitcoach/screens/workouts/session_player_screen.dart';
import 'package:fitcoach/workouts/session_models.dart';
import '../test_utils.dart';

void main() {
  testWidgets('Complete Session enables when all steps complete', (tester) async {
    final steps = [
      WorkoutStep(id: 's1', title: 'Warm-up'),
      WorkoutStep(id: 's2', title: 'Set 1'),
    ];
    await tester.pumpThemed(SessionPlayerScreen(id: 'w1', initialSteps: steps));

    final completeBtn = find.textContaining('Complete');
    expect(completeBtn, findsOneWidget);

    // Initially disabled
    var btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton).last);
    expect(btn.onPressed, isNull);

    // Toggle all steps
    await tester.tap(find.text('Warm-up'));
    await tester.pump();
    await tester.tap(find.text('Set 1'));
    await tester.pump();

    btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton).last);
    expect(btn.onPressed, isNotNull);
  });
}
