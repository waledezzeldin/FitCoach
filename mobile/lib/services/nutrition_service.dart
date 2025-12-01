import 'dart:convert';

import 'package:dio/dio.dart';

import 'api_service.dart';
import '../config/env.dart';
import '../demo/demo_data.dart';
import '../models/quota_models.dart';

class NutritionService {
  final _api = ApiService();
  static const _base = '/v1/nutrition';

  Future<Map<String, dynamic>> todayPlan({DateTime? day}) async {
    if (Env.demo) return DemoData.plan;
    final d = (day ?? DateTime.now()).toIso8601String().substring(0, 10);
    try {
      final res = await _api.dio.get('$_base/plan', queryParameters: {'date': d});
      return (res.data as Map).cast<String, dynamic>();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        final legacy = await _api.dio.get('/nutrition/plan', queryParameters: {'date': d});
        return (legacy.data as Map).cast<String, dynamic>();
      }
      throw Exception(_api.mapError(e, fallback: 'Failed to load plan'));
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
      await _api.dio.post('$_base/logs/toggle', data: {
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

  Future<NutritionAccessSnapshot> fetchAccess(String userId, {SubscriptionTier? tier}) async {
    if (Env.demo) {
      return NutritionAccessSnapshot.fromJson({
        'plan': {
          'generatedAt': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
          'expiresAt': tier == SubscriptionTier.freemium
              ? DateTime.now().add(const Duration(days: 5)).toIso8601String()
              : null,
          'locked': false,
        },
        'status': {
          'isExpired': false,
          'isLocked': false,
          'canAccess': true,
          'daysRemaining': tier == SubscriptionTier.freemium ? 5 : null,
          'hoursRemaining': null,
        },
      });
    }
    final res = await _api.dio.get('$_base/access/$userId', queryParameters: {
      if (tier != null) 'tier': tier.apiValue,
    });
    return NutritionAccessSnapshot.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<NutritionPreferences?> fetchPreferences(String userId) async {
    if (Env.demo) {
      return const NutritionPreferences(
        proteinSources: ['chicken', 'tuna'],
        proteinAllergies: <String>[],
        dinnerPreferences: {'portionSize': 'moderate'},
        additionalNotes: 'Demo user',
        completedAt: null,
      );
    }
    final res = await _api.dio.get('$_base/preferences/$userId');
    final map = Map<String, dynamic>.from(res.data as Map);
    if (map['preferences'] == null) return null;
    return NutritionPreferences.fromJson(Map<String, dynamic>.from(map['preferences'] as Map));
  }

  Future<NutritionPreferences> savePreferences(String userId, NutritionPreferences prefs) async {
    if (Env.demo) return prefs;
    final res = await _api.dio.post('$_base/preferences', data: {
      'userId': userId,
      ...prefs.toJson(),
    });
    final map = Map<String, dynamic>.from(res.data as Map);
    return NutritionPreferences.fromJson(Map<String, dynamic>.from(map['preferences'] as Map));
  }

  Future<NutritionAccessSnapshot> regeneratePlan(String userId, SubscriptionTier tier) async {
    if (Env.demo) {
      return fetchAccess(userId, tier: tier);
    }
    final res = await _api.dio.post('$_base/access/regenerate', data: {
      'userId': userId,
      'tier': tier.apiValue,
    });
    return NutritionAccessSnapshot.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<List<Map<String, dynamic>>> fetchLogs(String userId, {DateTime? day}) async {
    if (Env.demo) {
      return [
        {
          'id': 'demo_log_1',
          'meal': 'Greek Yogurt Parfait',
          'mealType': 'breakfast',
          'calories': 220,
          'protein': 18,
          'carbs': 28,
          'fats': 5,
          'notes': jsonEncode({'serving': '1 bowl', 'mealLabel': 'Breakfast'}),
          'date': DateTime.now().toIso8601String(),
        },
      ];
    }
    final res = await _api.dio.get('$_base/logs/$userId', queryParameters: {
      if (day != null) 'date': day.toIso8601String(),
    });
    final map = Map<String, dynamic>.from(res.data as Map);
    final logs = (map['logs'] as List?) ?? const [];
    return logs.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>> createLog({
    required String userId,
    required String foodName,
    required double calories,
    required double protein,
    required double carbs,
    required double fats,
    required DateTime date,
    String? mealType,
    Map<String, dynamic>? notes,
  }) async {
    if (Env.demo) {
      return {
        'id': 'demo_${DateTime.now().millisecondsSinceEpoch}',
        'meal': foodName,
        'mealType': mealType,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fats': fats,
        'notes': notes != null ? jsonEncode(notes) : null,
        'date': date.toIso8601String(),
      };
    }
    final res = await _api.dio.post('$_base/logs', data: {
      'userId': userId,
      'meal': foodName,
      'mealType': mealType,
      'date': date.toIso8601String(),
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      if (notes != null) 'notes': jsonEncode(notes),
    });
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> updateLog({
    required String logId,
    required String foodName,
    required double calories,
    required double protein,
    required double carbs,
    required double fats,
    required DateTime date,
    String? mealType,
    Map<String, dynamic>? notes,
  }) async {
    if (Env.demo) {
      return {
        'id': logId,
        'meal': foodName,
        'mealType': mealType,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fats': fats,
        'notes': notes != null ? jsonEncode(notes) : null,
        'date': date.toIso8601String(),
      };
    }
    final res = await _api.dio.put('$_base/logs/$logId', data: {
      'meal': foodName,
      'mealType': mealType,
      'date': date.toIso8601String(),
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      if (notes != null) 'notes': jsonEncode(notes),
    });
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<void> deleteLog(String logId) async {
    if (Env.demo) return;
    await _api.dio.delete('$_base/logs/$logId');
  }
}