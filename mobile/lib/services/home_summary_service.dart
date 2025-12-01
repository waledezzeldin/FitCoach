import 'package:dio/dio.dart';

import '../models/home_summary.dart';
import 'api_service.dart';

class HomeSummaryService {
  HomeSummaryService({ApiService? api}) : _api = api ?? ApiService();

  final ApiService _api;

  Future<HomeSummary> fetchSummary(String userId) async {
    try {
      final response = await _api.dio.get('/v1/home/summary/$userId');
      if (response.data is Map<String, dynamic>) {
        return HomeSummary.fromJson(response.data as Map<String, dynamic>);
      }
      if (response.data is Map) {
        final mapped = (response.data as Map).map((key, value) => MapEntry(key.toString(), value));
        return HomeSummary.fromJson(mapped);
      }
      throw DioException(
        requestOptions: response.requestOptions,
        error: 'Unexpected response for home summary',
      );
    } on DioException catch (error) {
      throw DioException(
        requestOptions: error.requestOptions,
        response: error.response,
        error: _api.mapError(error, fallback: 'Unable to fetch home summary'),
        type: error.type,
      );
    }
  }
}
