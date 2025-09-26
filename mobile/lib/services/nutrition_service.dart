import 'api_service.dart';
import '../config/env.dart';
import '../demo/demo_data.dart';

class NutritionService {
  final _api = ApiService();

  Future<Map<String, dynamic>> todayPlan({DateTime? day}) async {
    if (Env.demo) return DemoData.plan;
    final d = (day ?? DateTime.now()).toIso8601String().substring(0, 10);
    try {
      final res = await _api.dio.get('/nutrition/plan', queryParameters: {'date': d});
      return (res.data as Map).cast<String, dynamic>();
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Failed to load plan'));
    }
  }

  Future<void> logToggle({
    required String mealId,
    required String itemId,
    required bool consumed,
    DateTime? day,
  }) async {
    if (Env.demo) return;
    final d = (day ?? DateTime.now()).toIso8601String().substring(0, 10);
    try {
      final res = await _api.dio.post('/nutrition/logs/toggle', data: {
        'date': d,
        'mealId': mealId,
        'itemId': itemId,
        'consumed': consumed,
      });
      // No need to return anything since the return type is Future<void>
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Failed to update log'));
    }
  }
}