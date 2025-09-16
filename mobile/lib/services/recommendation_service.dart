import 'api_service.dart';

class RecommendationService {
  final _api = ApiService();

  Future<Map<String, dynamic>> getRecommendations(Map<String, dynamic> input) async {
    final res = await _api.dio.post('/v1/recommendations', data: input);
    return res.data;
  }
}
