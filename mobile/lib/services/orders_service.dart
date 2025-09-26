import 'api_service.dart';

class OrdersService {
  final _api = ApiService();

  Future<List<Map<String, dynamic>>> list() async {
    try {
      final res = await _api.dio.get('/orders');
      return (res.data as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Failed to load orders'));
    }
  }

  Future<Map<String, dynamic>> getById(String id) async {
    try {
      final res = await _api.dio.get('/orders/$id');
      return (res.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Failed to load order'));
    }
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> payload) async {
    try {
      final res = await _api.dio.post('/orders', data: payload);
      return (res.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Failed to place order'));
    }
  }

  Future<void> cancel(String id) async {
    try {
      await _api.dio.post('/orders/$id/cancel');
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Failed to cancel order'));
    }
  }

  Future<void> requestReturn(String id, {String? reason}) async {
    try {
      await _api.dio.post('/orders/$id/return', data: {'reason': reason});
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Failed to request return'));
    }
  }
}