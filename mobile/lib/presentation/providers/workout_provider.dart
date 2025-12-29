import 'package:flutter/material.dart';
import '../../core/config/demo_config.dart';
import '../../data/demo/demo_data.dart';
import '../../data/repositories/workout_repository.dart';
import '../../data/models/workout_plan.dart';

class WorkoutProvider extends ChangeNotifier {
  final WorkoutRepository _repository;

  WorkoutPlan? _activePlan;
  List<Exercise> _exerciseLibrary = [];
  bool _isLoading = false;
  String? _error;
  int? _currentDayIndex;
  final Map<String, bool> _completedExercises = {};

  WorkoutProvider(this._repository);

  WorkoutPlan? get activePlan => _activePlan;
  List<Exercise> get exerciseLibrary => _exerciseLibrary;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int? get currentDayIndex => _currentDayIndex;

  WorkoutDay? get currentDay {
    if (_activePlan == null || _currentDayIndex == null) return null;
    if (_activePlan!.days == null || _currentDayIndex! >= _activePlan!.days!.length) return null;
    return _activePlan!.days![_currentDayIndex!];
  }

  WorkoutPlan _buildFallbackPlan() {
    final exercise = Exercise(
      id: 'ex1',
      name: 'Push Up',
      nameAr: 'Push Up',
      nameEn: 'Push Up',
      sets: 3,
      reps: '12',
    );

    final day = WorkoutDay(
      id: 'day1',
      dayName: 'Day 1',
      dayNumber: 1,
      exercises: [exercise],
    );

    return WorkoutPlan(
      id: 'fallback-plan',
      userId: 'user',
      name: 'Fallback Plan',
      days: [day],
      startDate: DateTime.now(),
      createdAt: DateTime.now(),
    );
  }

  Future<void> loadActivePlan() async {
    if (DemoConfig.isDemo) {
      _activePlan = DemoData.workoutPlan(userId: 'demo-user');
      _currentDayIndex = 0;
      _error = null;
      _isLoading = false;
      notifyListeners();
      return;
    }
    _error = null;
    notifyListeners();

    try {
      final plan = await _repository.getActivePlan();
      _activePlan = plan;
    } catch (e) {
      _error = e.toString();
      _activePlan ??= _buildFallbackPlan();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadExerciseLibrary() async {
    if (DemoConfig.isDemo) {
      _exerciseLibrary = DemoData.exerciseLibrary();
      _error = null;
      _isLoading = false;
      notifyListeners();
      return;
    }
    _error = null;
    notifyListeners();

    try {
      final exercisesData = await _repository.getExerciseLibrary();
      _exerciseLibrary = exercisesData.map<Exercise>((e) => Exercise.fromJson(e)).toList();
    } catch (e) {
      _error = e.toString();
      _exerciseLibrary = [
        Exercise(
          id: 'ex1',
          name: 'Push Up',
          nameAr: 'Push Up',
          nameEn: 'Push Up',
          sets: 3,
          reps: '12',
        ),
      ];
    }

    _isLoading = false;
    notifyListeners();
  }

  void setCurrentDay(int dayIndex) {
    _currentDayIndex = dayIndex;
    notifyListeners();
  }

  Future<bool> completeExercise(String exerciseId) async {
    if (DemoConfig.isDemo) {
      _completedExercises[exerciseId] = true;
      notifyListeners();
      return true;
    }
    try {
      await _repository.markExerciseComplete(exerciseId);
    } catch (e) {
      _error = e.toString();
    }
    _completedExercises[exerciseId] = true;
    notifyListeners();
    return true;
  }

  Future<List<Exercise>> getExerciseAlternatives(
    String exerciseId,
    List<String> userInjuries,
  ) async {
    if (DemoConfig.isDemo) {
      return _exerciseLibrary.where((ex) => ex.id != exerciseId).toList();
    }
    _isLoading = true;
    notifyListeners();

    try {
      final alternatives = await _repository.getExerciseAlternatives(
        exerciseId,
        userInjuries,
      );
      _isLoading = false;
      notifyListeners();
      return alternatives;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  Future<bool> substituteExercise(
    String originalExerciseId,
    String newExerciseId,
  ) async {
    if (DemoConfig.isDemo) {
      _error = null;
      notifyListeners();
      return true;
    }
    try {
      await _repository.substituteExercise(
        originalExerciseId,
        newExerciseId,
      );
      await loadActivePlan();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> logWorkout(Map<String, dynamic> workoutData) async {
    if (DemoConfig.isDemo) {
      return true;
    }
    try {
      await _repository.logWorkout(workoutData);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  bool isExerciseCompleted(String exerciseId) {
    return _completedExercises[exerciseId] ?? false;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
