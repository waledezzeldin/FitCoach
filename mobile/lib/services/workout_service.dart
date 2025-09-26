import 'api_service.dart';
import '../config/env.dart';
import '../demo/demo_data.dart';

class WorkoutService {
  final _api = ApiService();

  Future<List<Map<String, dynamic>>> history() async {
    if (Env.demo) return List<Map<String, dynamic>>.from(DemoData.history);
    try {
      final res = await _api.dio.get('/workouts/history');
      return (res.data as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Failed to load history'));
    }
  }

  Future<Map<String, dynamic>> getWorkout(String id) async {
    if (Env.demo) return DemoData.workout();
    try {
      final res = await _api.dio.get('/workouts/$id');
      return (res.data as Map).cast<String, dynamic>();
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Failed to load workout'));
    }
  }

  Future<Map<String, dynamic>> startSession(String workoutId) async {
    if (Env.demo) return {'sessionId': 'demo_session'};
    try {
      final res = await _api.dio.post('/workouts/$workoutId/start');
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
      await _api.dio.post('/workouts/sessions/$sessionId/set', data: {
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
      await _api.dio.post('/workouts/sessions/$sessionId/finish');
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Failed to finish session'));
    }
  }
}