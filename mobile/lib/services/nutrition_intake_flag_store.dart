import 'package:shared_preferences/shared_preferences.dart';

class NutritionIntakeFlagStore {
  static const _pendingPrefix = 'pending_nutrition_intake_';
  static const _completedPrefix = 'nutrition_preferences_completed_';

  static Future<void> markPending(String? phone) async {
    final key = _pendingKey(phone);
    if (key == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, true);
  }

  static Future<void> clearPending(String? phone) async {
    final key = _pendingKey(phone);
    if (key == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  static Future<bool> hasPending(String? phone) async {
    final key = _pendingKey(phone);
    if (key == null) return false;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  static Future<void> markCompleted(String? phone, {bool value = true}) async {
    final key = _completedKey(phone);
    if (key == null) return;
    final prefs = await SharedPreferences.getInstance();
    if (value) {
      await prefs.setBool(key, true);
    } else {
      await prefs.remove(key);
    }
  }

  static Future<bool> isCompleted(String? phone) async {
    final key = _completedKey(phone);
    if (key == null) return false;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  static String? phoneFromProfile(Map<String, dynamic>? profile) {
    if (profile == null) return null;
    final candidates = [
      profile['phoneNumber'],
      profile['phone'],
      profile['phone_number'],
      profile['mobile'],
    ];
    for (final value in candidates) {
      final normalized = _normalizePhone(value?.toString());
      if (normalized != null) return normalized;
    }
    return null;
  }

  static String? _pendingKey(String? phone) {
    final normalized = _normalizePhone(phone);
    if (normalized == null) return null;
    return '$_pendingPrefix$normalized';
  }

  static String? _completedKey(String? phone) {
    final normalized = _normalizePhone(phone);
    if (normalized == null) return null;
    return '$_completedPrefix$normalized';
  }

  static String? _normalizePhone(String? raw) {
    final trimmed = raw?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}
