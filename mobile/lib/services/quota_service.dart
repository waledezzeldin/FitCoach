import '../config/env.dart';
import '../models/quota_models.dart';
import 'api_service.dart';

class QuotaService {
  QuotaService() : _api = ApiService();

  final ApiService _api;

  Future<QuotaSnapshot> fetchSnapshot(String userId) async {
    if (Env.demo) {
      return QuotaSnapshot.fromJson({
        'userId': userId,
        'tier': 'premium',
        'usage': {
          'messagesUsed': 42,
          'callsUsed': 1,
          'attachmentsUsed': 0,
          'resetAt': DateTime.now().add(const Duration(days: 12)).toIso8601String(),
        },
        'limits': {
          'messages': 200,
          'calls': 2,
          'callDuration': 25,
          'chatAttachments': true,
          'nutritionPersistent': true,
          'nutritionWindowDays': null,
        },
      });
    }
    final res = await _api.dio.get('/v1/subscription/quota/$userId');
    return QuotaSnapshot.fromJson(Map<String, dynamic>.from(res.data as Map));
  }
}
