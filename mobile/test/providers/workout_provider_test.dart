import 'package:flutter_test/flutter_test.dart';
import 'package:fitapp/presentation/providers/workout_provider.dart';
import 'package:fitapp/data/repositories/workout_repository.dart';

void main() {
  group('WorkoutProvider Tests', () {
    late WorkoutProvider workoutProvider;

    setUp(() {
      final repo = WorkoutRepository();
      workoutProvider = WorkoutProvider(repo);
    });

    test('initial state should have no active plan', () {
      expect(workoutProvider.activePlan, null);
      expect(workoutProvider.isLoading, false);
    });

    test('loadActivePlan should fetch and set workout data', () async {
      await workoutProvider.loadActivePlan();
      expect(workoutProvider.activePlan, isNotNull);
      expect(workoutProvider.isLoading, false);
    });

    test('completeExercise should mark exercise as completed', () async {
      await workoutProvider.loadActivePlan();
      final plan = workoutProvider.activePlan;
      if (plan != null && plan.days != null && plan.days!.isNotEmpty) {
        final firstDay = plan.days!.first;
        if (firstDay.exercises.isNotEmpty) {
          final exerciseId = firstDay.exercises.first.id;
          final result = await workoutProvider.completeExercise(exerciseId);
          expect(result, true);
          expect(workoutProvider.isExerciseCompleted(exerciseId), true);
        }
      }
    });

    test('setCurrentDay should update current day index', () async {
      workoutProvider.setCurrentDay(1);
      expect(workoutProvider.currentDayIndex, 1);
    });

    test('currentDay should return correct day', () async {
      await workoutProvider.loadActivePlan();
      workoutProvider.setCurrentDay(0);
      final day = workoutProvider.currentDay;
      expect(day, isNotNull);
    });

    test('loadExerciseLibrary should fetch exercises', () async {
      await workoutProvider.loadExerciseLibrary();
      expect(workoutProvider.exerciseLibrary, isA<List>());
    });

    test('clearError should reset error state', () async {
      workoutProvider.clearError();
      expect(workoutProvider.error, null);
    });
  });
}