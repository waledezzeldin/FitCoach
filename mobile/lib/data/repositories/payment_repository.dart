import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/config/api_config.dart';

class PaymentRepository {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  
  static const String _tokenKey = 'fitcoach_auth_token';
  
  PaymentRepository()
      : _dio = Dio(BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: ApiConfig.connectTimeout,
          receiveTimeout: ApiConfig.receiveTimeout,
        )),
        _secureStorage = const FlutterSecureStorage();
  
  Future<String?> _getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }
  
  Future<Options> _getAuthOptions() async {
    final token = await _getToken();
    return Options(
      headers: {'Authorization': 'Bearer $token'},
    );
  }
  
  /// Create Stripe payment intent for subscription
  Future<Map<String, dynamic>> createStripePayment({
    required String tier,
    required String billingCycle,
  }) async {
    try {
      final response = await _dio.post(
        '/payments/stripe/create-intent',
        data: {
          'tier': tier,
          'billingCycle': billingCycle,
        },
        options: await _getAuthOptions(),
      );
      
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to create payment');
    }
  }
  
  /// Confirm Stripe payment
  Future<Map<String, dynamic>> confirmStripePayment(String paymentIntentId) async {
    try {
      final response = await _dio.post(
        '/payments/stripe/confirm',
        data: {'paymentIntentId': paymentIntentId},
        options: await _getAuthOptions(),
      );
      
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Payment confirmation failed');
    }
  }
  
  /// Create Tap Payment (Middle East payment gateway)
  Future<Map<String, dynamic>> createTapPayment({
    required String tier,
    required String billingCycle,
  }) async {
    try {
      final response = await _dio.post(
        '/payments/tap/create-charge',
        data: {
          'tier': tier,
          'billingCycle': billingCycle,
        },
        options: await _getAuthOptions(),
      );
      
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to create Tap payment');
    }
  }
  
  /// Check payment status (Tap)
  Future<Map<String, dynamic>> checkTapPaymentStatus(String chargeId) async {
    try {
      final response = await _dio.get(
        '/payments/tap/status/$chargeId',
        options: await _getAuthOptions(),
      );
      
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to check payment status');
    }
  }
  
  /// Get subscription prices
  Future<Map<String, dynamic>> getSubscriptionPrices() async {
    try {
      final response = await _dio.get(
        '/payments/prices',
        options: await _getAuthOptions(),
      );
      
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get prices');
    }
  }
  
  /// Get payment history
  Future<List<Map<String, dynamic>>> getPaymentHistory() async {
    try {
      final response = await _dio.get(
        '/payments/history',
        options: await _getAuthOptions(),
      );
      
      return List<Map<String, dynamic>>.from(response.data['payments'] ?? []);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get payment history');
    }
  }
  
  /// Cancel subscription
  Future<void> cancelSubscription() async {
    try {
      await _dio.post(
        '/payments/cancel-subscription',
        options: await _getAuthOptions(),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to cancel subscription');
    }
  }
  
  /// Update payment method
  Future<void> updatePaymentMethod(Map<String, dynamic> paymentMethodData) async {
    try {
      await _dio.put(
        '/payments/payment-method',
        data: paymentMethodData,
        options: await _getAuthOptions(),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to update payment method');
    }
  }
  
  /// Apply promo code
  Future<Map<String, dynamic>> applyPromoCode(String code) async {
    try {
      final response = await _dio.post(
        '/payments/apply-promo',
        data: {'code': code},
        options: await _getAuthOptions(),
      );
      
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Invalid promo code');
    }
  }
}
