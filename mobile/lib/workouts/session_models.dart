class WorkoutStep {
  final String id;
  final String title;
  final int? durationSeconds;
  bool completed;

  WorkoutStep({required this.id, required this.title, this.durationSeconds, this.completed = false});
}

class SessionResult {
  final String workoutId;
  final Duration elapsed;
  final int completedSteps;
  final int totalSteps;

  SessionResult({
    required this.workoutId,
    required this.elapsed,
    required this.completedSteps,
    required this.totalSteps,
  });
}
