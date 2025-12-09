import 'dart:async';
import 'package:flutter/foundation.dart';
import 'session_models.dart';

class SessionController extends ChangeNotifier {
  final Duration tick;
  Timer? _timer;
  int _elapsedMs = 0;
  bool _running = false;
  final List<WorkoutStep> steps;
  int _index = 0;
  int _currentStepElapsedMs = 0;
  bool autoAdvanced = false;

  SessionController({this.tick = const Duration(seconds: 1), List<WorkoutStep>? initialSteps})
      : steps = initialSteps ?? [];

  Duration get elapsed => Duration(milliseconds: _elapsedMs);
  Duration get currentStepElapsed => Duration(milliseconds: _currentStepElapsedMs);
  bool get running => _running;
  int get currentIndex => _index;
  bool get allComplete => steps.isNotEmpty && steps.every((s) => s.completed);
  int? get currentStepDuration => steps.isEmpty ? null : steps[_index].durationSeconds;
  int? get currentStepRemainingSeconds {
    final total = currentStepDuration;
    if (total == null) return null;
    final remainingMs = total * 1000 - _currentStepElapsedMs;
    return remainingMs <= 0 ? 0 : (remainingMs / 1000).ceil();
  }

  void start() {
    if (_running) return;
    _running = true;
    _timer?.cancel();
    _timer = Timer.periodic(tick, (_) {
      _elapsedMs += tick.inMilliseconds;
      _currentStepElapsedMs += tick.inMilliseconds;
      _maybeCompleteCurrentStep();
      notifyListeners();
    });
    notifyListeners();
  }

  void pause() {
    if (!_running) return;
    _running = false;
    _timer?.cancel();
    notifyListeners();
  }

  void reset() {
    _timer?.cancel();
    _running = false;
    _elapsedMs = 0;
    _currentStepElapsedMs = 0;
    notifyListeners();
  }

  void next() {
    if (_index < steps.length - 1) {
      _index++;
      _currentStepElapsedMs = 0;
      notifyListeners();
    }
  }

  void prev() {
    if (_index > 0) {
      _index--;
      _currentStepElapsedMs = 0;
      notifyListeners();
    }
  }

  void toggleComplete(int i, {bool? value}) {
    if (i < 0 || i >= steps.length) return;
    steps[i].completed = value ?? !steps[i].completed;
    notifyListeners();
  }

  void skipCurrent() {
    if (steps.isEmpty) return;
    steps[_index].completed = true;
    _currentStepElapsedMs = 0;
    if (_index < steps.length - 1) {
      _index++;
    }
    autoAdvanced = true;
    notifyListeners();
  }

  void _maybeCompleteCurrentStep() {
    if (steps.isEmpty) return;
    final s = steps[_index];
    if (s.completed) return;
    if (s.durationSeconds != null) {
      final totalMs = s.durationSeconds! * 1000;
      if (_currentStepElapsedMs >= totalMs) {
        s.completed = true;
        _currentStepElapsedMs = 0;
        if (_index < steps.length - 1) {
          _index++;
        }
        autoAdvanced = true;
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
