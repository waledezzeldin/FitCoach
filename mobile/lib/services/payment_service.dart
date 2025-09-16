import 'api_service.dart';

class PaymentService {
  final _api = ApiService();

  Future<Map<String, dynamic>> createCheckoutSession(String productId) async {
    final res = await _api.dio.post('/v1/payments/checkout', data: {
      "productId": productId,
      "currency": "usd",
    });
    return res.data; // returns sessionId, checkoutUrl
  }

  Future<Map<String, dynamic>> checkPaymentStatus(String sessionId) async {
    final res = await _api.dio.get('/v1/payments/status/$sessionId');
    return res.data;
  }
}
