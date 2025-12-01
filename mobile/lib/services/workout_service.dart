import 'api_service.dart';
import '../config/env.dart';
import '../demo/demo_data.dart';

class WorkoutService {
  final _api = ApiService();
  static const _basePath = '/v1/workouts';

  Future<List<Map<String, dynamic>>> history() async {
    if (Env.demo) return List<Map<String, dynamic>>.from(DemoData.history);
    try {
      final res = await _api.dio.get('$_basePath/history');
      return (res.data as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Failed to load history'));
    }
  }

  Future<Map<String, dynamic>> getWorkout(String id) async {
    if (Env.demo) return DemoData.workout();
    try {
      final res = await _api.dio.get('$_basePath/$id');
      return (res.data as Map).cast<String, dynamic>();
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Failed to load workout'));
    }
  }

  Future<Map<String, dynamic>> startSession(String workoutId) async {
    if (Env.demo) return {'sessionId': 'demo_session'};
    try {
      final res = await _api.dio.post('$_basePath/$workoutId/start');
      return (res.data as Map).cast<String, dynamic>(); // { sessionId, ... }
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Failed to start session'));
    }
  }

  Future<void> recordSet({
    required String sessionId,
    required String exerciseId,
    required int setIndex,
    required int reps,
    required double weight,
    int? seconds,
  }) async {
    if (Env.demo) return;
    try {
      await _api.dio.post('$_basePath/sessions/$sessionId/set', data: {
        'exerciseId': exerciseId,
        'setIndex': setIndex,
        'reps': reps,
        'weight': weight,
        if (seconds != null) 'seconds': seconds,
      });
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Failed to save set'));
    }
  }

  Future<void> finishSession(String sessionId) async {
    if (Env.demo) return;
    try {
      await _api.dio.post('$_basePath/sessions/$sessionId/finish');
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Failed to finish session'));
    }
  }

  Future<List<Map<String, dynamic>>> injuryAlternatives({
    required String injuryArea,
    String? muscleGroup,
  }) async {
    if (Env.demo) {
      return [
        {
          'id': 'alt_pushup',
          'name': 'Incline Push-Up',
          'muscleGroup': 'chest',
          'difficulty': 'beginner',
        },
        {
          'id': 'alt_band',
          'name': 'Resistance Band Press',
          'muscleGroup': 'chest',
          'difficulty': 'all',
        },
      ];
    }
    try {
      final res = await _api.dio.get('$_basePath/alternatives', queryParameters: {
        'injuryArea': injuryArea,
        if (muscleGroup != null && muscleGroup.isNotEmpty) 'muscleGroup': muscleGroup,
      });
      final data = res.data as Map<String, dynamic>;
      final list = (data['alternatives'] as List?) ?? const [];
      return list.map((item) => (item as Map).cast<String, dynamic>()).toList();
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Failed to load alternatives'));
    }
  }

  Future<void> recordInjurySwap({
    required String userId,
    required String originalExerciseId,
    required String alternativeExerciseId,
    String? sessionId,
    String? injuryArea,
  }) async {
    if (Env.demo) return;
    try {
      await _api.dio.post('$_basePath/swaps', data: {
        'userId': userId,
        'sessionId': sessionId,
        'originalExerciseId': originalExerciseId,
        'alternativeExerciseId': alternativeExerciseId,
        if (injuryArea != null) 'injuryArea': injuryArea,
      });
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Failed to record swap'));
    }
  }
}