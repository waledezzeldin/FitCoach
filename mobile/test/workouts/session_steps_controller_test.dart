import 'package:flutter_test/flutter_test.dart';
import 'package:fitcoach/workouts/session_controller.dart';
import 'package:fitcoach/workouts/session_models.dart';

void main() {
  test('SessionController step navigation and completion', () async {
    final steps = [
      WorkoutStep(id: 's1', title: 'A'),
      WorkoutStep(id: 's2', title: 'B'),
      WorkoutStep(id: 's3', title: 'C'),
    ];
    final c = SessionController(initialSteps: steps, tick: const Duration(milliseconds: 5));

    expect(c.currentIndex, 0);
    expect(c.allComplete, isFalse);

    c.next();
    expect(c.currentIndex, 1);
    c.prev();
    expect(c.currentIndex, 0);

    c.toggleComplete(0, value: true);
    c.toggleComplete(1, value: true);
    expect(c.allComplete, isFalse);
    c.toggleComplete(2, value: true);
    expect(c.allComplete, isTrue);
  });
}
