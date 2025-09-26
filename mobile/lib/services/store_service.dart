import 'api_service.dart';

class StoreService {
  final _api = ApiService();

  Future<List<Map<String, dynamic>>> categories() async {
    try {
      final res = await _api.dio.get('/store/categories');
      return (res.data as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Failed to load categories'));
    }
  }

  Future<List<Map<String, dynamic>>> products({
    String? categoryId,
    String? query,
    int page = 1,
    int pageSize = 20,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final res = await _api.dio.get('/products', queryParameters: {
        if (categoryId != null) 'categoryId': categoryId,
        if (query != null && query.isNotEmpty) 'q': query,
        'page': page,
        'pageSize': pageSize,
        if (filters != null) ...filters,
      });
      return (res.data as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Failed to load products'));
    }
  }

  Future<Map<String, dynamic>> validateCoupon({
    required String code,
    required double subtotal,
  }) async {
    try {
      final res = await _api.dio.post('/coupons/validate', data: {
        'code': code,
        'subtotal': subtotal,
      });
      return (res.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Invalid coupon'));
    }
  }
}