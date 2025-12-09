import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:fitcoach/screens/workouts/session_player_screen.dart';
import 'package:fitcoach/workouts/session_models.dart';
import '../test_utils.dart';

void main() {
  testWidgets('Prev/Skip/Next controls update current index', (tester) async {
    final steps = [
      WorkoutStep(id: 's1', title: 'Warm-up', durationSeconds: 1),
      WorkoutStep(id: 's2', title: 'Set 1', durationSeconds: 1),
      WorkoutStep(id: 's3', title: 'Set 2', durationSeconds: 1),
    ];
    await tester.pumpThemed(SessionPlayerScreen(id: 'w1', initialSteps: steps), locale: const Locale('en'));

    // Start session, then Next advances
    await tester.tap(find.textContaining('Start'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('sessionNext')));
    await tester.pump();
    // Current is 'Set 1'
    expect(find.text('Set 1'), findsOneWidget);

    // Prev goes back
    await tester.tap(find.byKey(const Key('sessionPrev')));
    await tester.pump();
    expect(find.text('Warm-up'), findsOneWidget);

    // Skip marks current complete and advances
    await tester.tap(find.byKey(const Key('sessionSkip')));
    await tester.pump();
    expect(find.text('Set 1'), findsOneWidget);
  });
}
