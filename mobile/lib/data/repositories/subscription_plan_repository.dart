import 'package:dio/dio.dart';
import '../../core/config/api_config.dart';
import '../models/subscription_plan.dart';

class SubscriptionPlanRepository {
  final Dio _dio;

  SubscriptionPlanRepository()
      : _dio = Dio(
          BaseOptions(
            baseUrl: ApiConfig.baseUrl,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
          ),
        );

  Future<List<SubscriptionPlan>> getPlans() async {
    try {
      final response = await _dio.get('/subscriptions/plans');
      final data = response.data as Map<String, dynamic>;
      final plans = data['plans'] as List? ?? [];
      return plans
          .map((json) => SubscriptionPlan.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load plans');
    }
  }

  Future<SubscriptionPlan> createPlan(SubscriptionPlan plan) async {
    try {
      final response = await _dio.post(
        '/admin/subscriptions/plans',
        data: plan.toJson(),
      );
      final data = response.data as Map<String, dynamic>;
      return SubscriptionPlan.fromJson(data['plan'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to create plan');
    }
  }

  Future<SubscriptionPlan> updatePlan(SubscriptionPlan plan) async {
    try {
      final response = await _dio.put(
        '/admin/subscriptions/plans/${plan.id}',
        data: plan.toJson(),
      );
      final data = response.data as Map<String, dynamic>;
      return SubscriptionPlan.fromJson(data['plan'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to update plan');
    }
  }

  Future<void> deletePlan(String id) async {
    try {
      await _dio.delete('/admin/subscriptions/plans/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to delete plan');
    }
  }
}
