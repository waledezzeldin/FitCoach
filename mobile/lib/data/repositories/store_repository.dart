import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../../core/config/api_config.dart';

class StoreRepository {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  
  static const String _tokenKey = 'fitcoach_auth_token';
  
  StoreRepository()
      : _dio = Dio(BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        )),
        _secureStorage = const FlutterSecureStorage();

  /// Get authentication headers
  Future<Map<String, String>> _getHeaders() async {
    final token = await _secureStorage.read(key: _tokenKey);
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Get products with filters
  Future<List<Product>> getProducts({
    String? category,
    String? search,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortOrder,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final headers = await _getHeaders();
      
      final queryParams = {
        'limit': limit,
        'offset': offset,
        if (category != null && category != 'all') 'category': category,
        if (search != null && search.isNotEmpty) 'search': search,
        if (minPrice != null) 'minPrice': minPrice,
        if (maxPrice != null) 'maxPrice': maxPrice,
        if (sortBy != null) 'sortBy': sortBy,
        if (sortOrder != null) 'sortOrder': sortOrder,
      };

      final response = await _dio.get(
        '/store/products',
        queryParameters: queryParams,
        options: Options(headers: headers),
      );

      final data = response.data as Map<String, dynamic>;
      final productsList = data['products'] as List;
      
      return productsList
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get products');
    }
  }

  /// Get product by ID
  Future<Product> getProductById(String productId) async {
    try {
      final headers = await _getHeaders();

      final response = await _dio.get(
        '/store/products/$productId',
        options: Options(headers: headers),
      );

      final data = response.data as Map<String, dynamic>;
      return Product.fromJson(data['product'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get product');
    }
  }

  /// Get product categories
  Future<List<String>> getCategories() async {
    try {
      final headers = await _getHeaders();

      final response = await _dio.get(
        '/store/categories',
        options: Options(headers: headers),
      );

      final data = response.data as Map<String, dynamic>;
      final categories = data['categories'] as List;
      
      return categories.map((c) => c['name'] as String).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get categories');
    }
  }

  /// Create order
  Future<Order> createOrder({
    required List<Map<String, dynamic>> items,
    required String shippingAddress,
    String? notes,
    String? promoCode,
  }) async {
    try {
      final headers = await _getHeaders();

      final response = await _dio.post(
        '/orders',
        data: {
          'items': items,
          'shippingAddress': shippingAddress,
          'notes': notes,
          'promoCode': promoCode,
        },
        options: Options(headers: headers),
      );

      final data = response.data as Map<String, dynamic>;
      return Order.fromJson(data['order'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to create order');
    }
  }

  /// Get user orders
  Future<List<Order>> getOrders({
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final headers = await _getHeaders();
      
      final queryParams = {
        'limit': limit,
        'offset': offset,
        if (status != null) 'status': status,
      };

      final response = await _dio.get(
        '/orders',
        queryParameters: queryParams,
        options: Options(headers: headers),
      );

      final data = response.data as Map<String, dynamic>;
      final ordersList = data['orders'] as List;
      
      return ordersList
          .map((json) => Order.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get orders');
    }
  }

  /// Get order by ID
  Future<Order> getOrderById(String orderId) async {
    try {
      final headers = await _getHeaders();

      final response = await _dio.get(
        '/orders/$orderId',
        options: Options(headers: headers),
      );

      final data = response.data as Map<String, dynamic>;
      return Order.fromJson(data['order'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get order');
    }
  }

  /// Cancel order
  Future<void> cancelOrder(String orderId, String reason) async {
    try {
      final headers = await _getHeaders();

      await _dio.put(
        '/orders/$orderId/cancel',
        data: {'reason': reason},
        options: Options(headers: headers),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to cancel order');
    }
  }

  /// Track order
  Future<Map<String, dynamic>> trackOrder(String orderId) async {
    try {
      final headers = await _getHeaders();

      final response = await _dio.get(
        '/orders/$orderId/track',
        options: Options(headers: headers),
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to track order');
    }
  }

  /// Submit product review
  Future<void> submitReview({
    required String productId,
    required int rating,
    String? comment,
  }) async {
    try {
      final headers = await _getHeaders();

      await _dio.post(
        '/store/products/$productId/reviews',
        data: {
          'rating': rating,
          'comment': comment,
        },
        options: Options(headers: headers),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to submit review');
    }
  }

  /// Get product reviews
  Future<List<Map<String, dynamic>>> getReviews({
    required String productId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final headers = await _getHeaders();
      
      final queryParams = {
        'limit': limit,
        'offset': offset,
      };

      final response = await _dio.get(
        '/store/products/$productId/reviews',
        queryParameters: queryParams,
        options: Options(headers: headers),
      );

      final data = response.data as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(data['reviews'] as List);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get reviews');
    }
  }

  /// Check product availability
  Future<bool> checkAvailability(String productId, int quantity) async {
    try {
      final headers = await _getHeaders();

      final response = await _dio.post(
        '/store/products/$productId/check-availability',
        data: {'quantity': quantity},
        options: Options(headers: headers),
      );

      final data = response.data as Map<String, dynamic>;
      return data['available'] as bool;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to check availability');
    }
  }

  /// Apply promo code
  Future<Map<String, dynamic>> applyPromoCode(String code, double subtotal) async {
    try {
      final headers = await _getHeaders();

      final response = await _dio.post(
        '/store/promo-codes/apply',
        data: {
          'code': code,
          'subtotal': subtotal,
        },
        options: Options(headers: headers),
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to apply promo code');
    }
  }

  /// Calculate shipping cost
  Future<double> calculateShipping({
    required String address,
    required double weight,
  }) async {
    try {
      final headers = await _getHeaders();

      final response = await _dio.post(
        '/store/shipping/calculate',
        data: {
          'address': address,
          'weight': weight,
        },
        options: Options(headers: headers),
      );

      final data = response.data as Map<String, dynamic>;
      return (data['shippingCost'] as num).toDouble();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to calculate shipping');
    }
  }
}
