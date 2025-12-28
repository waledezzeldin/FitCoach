import 'package:dio/dio.dart';
import '../models/admin_analytics.dart';
import '../models/admin_user.dart';
import '../models/admin_coach.dart';
import '../models/revenue_analytics.dart';
import '../models/audit_log.dart';
import '../../core/config/api_config.dart';

class AdminRepository {
  final Dio _dio;

  AdminRepository()
      : _dio = Dio(BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ));

  /// Get dashboard analytics
  Future<AdminAnalytics> getDashboardAnalytics() async {
    try {
      final response = await _dio.get('/admin/analytics');
      final data = response.data as Map<String, dynamic>;
      return AdminAnalytics.fromJson(data['analytics'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get analytics');
    }
  }

  /// Get all users with filters
  Future<List<AdminUser>> getUsers({
    String? search,
    String? subscriptionTier,
    String? status,
    String? coachId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final queryParams = {
        'limit': limit,
        'offset': offset,
        if (search != null) 'search': search,
        if (subscriptionTier != null) 'subscriptionTier': subscriptionTier,
        if (status != null) 'status': status,
        if (coachId != null) 'coachId': coachId,
      };

      final response = await _dio.get(
        '/admin/users',
        queryParameters: queryParams,
      );

      final data = response.data as Map<String, dynamic>;
      final usersList = data['users'] as List;
      
      return usersList
          .map((json) => AdminUser.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get users');
    }
  }

  /// Get user by ID
  Future<AdminUser> getUserById(String id) async {
    try {
      final response = await _dio.get('/admin/users/$id');
      final data = response.data as Map<String, dynamic>;
      return AdminUser.fromJson(data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get user');
    }
  }

  /// Update user
  Future<AdminUser> updateUser(
    String id, {
    String? fullName,
    String? email,
    String? subscriptionTier,
    bool? isActive,
    String? coachId,
  }) async {
    try {
      final response = await _dio.put(
        '/admin/users/$id',
        data: {
          if (fullName != null) 'fullName': fullName,
          if (email != null) 'email': email,
          if (subscriptionTier != null) 'subscriptionTier': subscriptionTier,
          if (isActive != null) 'isActive': isActive,
          if (coachId != null) 'coachId': coachId,
        },
      );

      final data = response.data as Map<String, dynamic>;
      return AdminUser.fromJson(data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to update user');
    }
  }

  /// Suspend user
  Future<void> suspendUser(String id, String reason) async {
    try {
      await _dio.post(
        '/admin/users/$id/suspend',
        data: {'reason': reason},
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to suspend user');
    }
  }

  /// Delete user
  Future<void> deleteUser(String id) async {
    try {
      await _dio.delete('/admin/users/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to delete user');
    }
  }

  /// Get all coaches
  Future<List<AdminCoach>> getCoaches({
    String? search,
    String? status,
    String? approved,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final queryParams = {
        'limit': limit,
        'offset': offset,
        if (search != null) 'search': search,
        if (status != null) 'status': status,
        if (approved != null) 'approved': approved,
      };

      final response = await _dio.get(
        '/admin/coaches',
        queryParameters: queryParams,
      );

      final data = response.data as Map<String, dynamic>;
      final coachesList = data['coaches'] as List;
      
      return coachesList
          .map((json) => AdminCoach.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get coaches');
    }
  }

  /// Approve coach
  Future<void> approveCoach(String id) async {
    try {
      await _dio.post('/admin/coaches/$id/approve');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to approve coach');
    }
  }

  /// Suspend coach
  Future<void> suspendCoach(String id, String reason) async {
    try {
      await _dio.post(
        '/admin/coaches/$id/suspend',
        data: {'reason': reason},
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to suspend coach');
    }
  }

  /// Get revenue analytics
  Future<RevenueAnalytics> getRevenueAnalytics({
    String period = 'month',
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = {
        'period': period,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
      };

      final response = await _dio.get(
        '/admin/revenue',
        queryParameters: queryParams,
      );

      final data = response.data as Map<String, dynamic>;
      return RevenueAnalytics.fromJson(data['revenue'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get revenue analytics');
    }
  }

  /// Get audit logs
  Future<List<AuditLog>> getAuditLogs({
    String? userId,
    String? action,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final queryParams = {
        'limit': limit,
        'offset': offset,
        if (userId != null) 'userId': userId,
        if (action != null) 'action': action,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
      };

      final response = await _dio.get(
        '/admin/audit-logs',
        queryParameters: queryParams,
      );

      final data = response.data as Map<String, dynamic>;
      final logsList = data['logs'] as List;
      
      return logsList
          .map((json) => AuditLog.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get audit logs');
    }
  }
}