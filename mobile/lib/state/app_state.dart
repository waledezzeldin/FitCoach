import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/home_summary.dart';
import '../models/intake_models.dart';
import '../models/quota_models.dart';
import '../services/api_service.dart';
import '../services/nutrition_intake_flag_store.dart';
import '../services/quota_service.dart';
import '../services/home_summary_service.dart';

class AppState extends ChangeNotifier {
  AppState({
    FlutterSecureStorage? secureStorage,
    ApiService? api,
    bool enableNetworkSync = true,
    QuotaService? quotaService,
    HomeSummaryService? homeSummaryService,
  })  : _secure = secureStorage ?? const FlutterSecureStorage(),
        _api = api ?? ApiService(),
        _enableNetworkSync = enableNetworkSync,
        _quotaService = quotaService ?? QuotaService(),
        _homeSummaryService = homeSummaryService ?? HomeSummaryService() {
    // Honor --dart-define=DEMO=true
    const fromDefine = bool.fromEnvironment('DEMO', defaultValue: false);
    if (fromDefine) demoMode = true;
    if (demoMode) {
      _api.setDemoMode(true);
    }
  }
  static const _kAuth = 'fc_isAuthenticated';
  static const _kIntake = 'fc_intakeComplete';
  static const _kSub = 'fc_subscriptionType';
  static const _kLocale = 'fc_locale_code';
  static const _kIntroSeen = 'fc_intro_seen';
  static const _kIntakeData = 'fc_intake_data';

  final FlutterSecureStorage _secure;
  final ApiService _api;
  final bool _enableNetworkSync;
  final QuotaService _quotaService;
  final HomeSummaryService _homeSummaryService;

  bool isAuthenticated = false;
  bool intakeComplete = false;
  String subscriptionType = 'freemium';
  bool initialized = false;
  bool introSeen = false;
  String? role;
  String units = 'metric'; // Default value, adjust as needed
  Locale? locale;
  Map<String, dynamic>? user;
  String? subscription;
  Map<String, dynamic>? workoutPlan;
  Map<String, dynamic>? nutritionPlan;
  Map<String, dynamic>? stats;
  QuotaSnapshot? quotaSnapshot;
  HomeSummary? homeSummary;
  bool homeSummaryLoading = false;
  String? homeSummaryError;

  bool demoMode = false;

  IntakeProgress intakeProgress = const IntakeProgress();

  // Optional real user stats if you already have them
  Map<String, dynamic>? userStats;

  bool _loading = false;
  DateTime? _quotaFetchedAt;
  DateTime? _homeSummaryFetchedAt;

  bool get needsFirstIntake => !intakeProgress.isFirstComplete;
  bool get needsSecondIntake => intakeProgress.requiresSecondStage;
  bool get needsIntake => needsFirstIntake || needsSecondIntake;
  bool get hasSelectedLanguage => locale != null;
  bool get hasSeenIntro => introSeen;

  Future<void> load() async {
    if (_loading) return;
    _loading = true;
    final prefs = await SharedPreferences.getInstance();
    isAuthenticated = prefs.getBool(_kAuth) ?? false;
    intakeComplete = prefs.getBool(_kIntake) ?? false;
    subscriptionType = prefs.getString(_kSub) ?? 'freemium';
    introSeen = prefs.getBool(_kIntroSeen) ?? false;
    final localeCode = prefs.getString(_kLocale);
    if (localeCode != null && localeCode.isNotEmpty) {
      locale = Locale(localeCode);
      _api.setPreferredLocale(localeCode);
    }

    final intakeRaw = prefs.getString(_kIntakeData);
    if (intakeRaw != null && intakeRaw.isNotEmpty) {
      try {
        final map = jsonDecode(intakeRaw);
        if (map is Map<String, dynamic>) {
          intakeProgress = IntakeProgress.fromJson(map);
        }
      } catch (_) {}
    }

    // If token exists, user is authenticated
    try {
      final token = await _secure.read(key: 'access_token');
      if (token != null && token.isNotEmpty) {
        isAuthenticated = true;
      }
    } catch (_) {}

    initialized = true;
    _loading = false;
    notifyListeners();
  }

  String? get _userId {
    final source = user ?? {};
    final dynamic id = source['id'] ?? source['_id'] ?? source['userId'];
    return id?.toString();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAuth, isAuthenticated);
    await prefs.setBool(_kIntake, intakeComplete);
    await prefs.setString(_kSub, subscriptionType);
    await prefs.setString(_kIntakeData, jsonEncode(intakeProgress.toJson()));
  }

  Future<void> _syncIntakeFromServer() async {
    if (!_enableNetworkSync) return;
    final id = _userId;
    if (id == null) return;
    try {
      final response = await _api.dio.get('/v1/intake/$id');
      final dynamic raw = response.data;
      Map<String, dynamic>? body;
      if (raw is Map<String, dynamic>) {
        body = raw;
      } else if (raw is Map) {
        body = raw.map((key, value) => MapEntry(key.toString(), value));
      }

      final progress = body?['intake'] ?? body;
      if (progress is Map) {
        final mapped = progress.map((key, value) => MapEntry(key.toString(), value));
        intakeProgress = IntakeProgress.fromJson(Map<String, dynamic>.from(mapped));
        intakeComplete = intakeProgress.isSecondComplete || intakeProgress.skippedSecond;
        _syncUserIntake();
        await _persist();
        notifyListeners();
      }
    } catch (error) {
      debugPrint('Unable to fetch intake: ${_api.mapError(error)}');
    }
  }

  Future<void> _pushFirstStageRemote(FirstIntakeData data) async {
    final id = _userId;
    if (id == null) return;
    try {
      await _api.dio.post('/v1/intake/first', data: {
        'userId': id,
        'gender': data.gender,
        'mainGoal': data.mainGoal,
        'workoutLocation': data.workoutLocation,
        'completedAt': data.completedAt.toIso8601String(),
      });
    } catch (error) {
      debugPrint('Unable to persist first intake stage: ${_api.mapError(error)}');
    }
  }

  Future<void> _pushSecondStageRemote(SecondIntakeData data) async {
    final id = _userId;
    if (id == null) return;
    try {
      await _api.dio.post('/v1/intake/second', data: {
        'userId': id,
        'age': data.age,
        'weight': data.weight,
        'height': data.height,
        'experienceLevel': data.experienceLevel,
        'workoutFrequency': data.workoutFrequency,
        'injuries': data.injuries,
        'completedAt': data.completedAt.toIso8601String(),
      });
    } catch (error) {
      debugPrint('Unable to persist second intake stage: ${_api.mapError(error)}');
    }
  }

  Future<void> _pushSkipSecondRemote() async {
    final id = _userId;
    if (id == null) return;
    try {
      await _api.dio.post('/v1/intake/skip-second', data: {'userId': id});
    } catch (error) {
      debugPrint('Unable to persist skip-second action: ${_api.mapError(error)}');
    }
  }

  Future<void> signIn({Map<String, dynamic>? user, String? subscription, String? role}) async {
    this.user = user ?? this.user;
    this.subscription = subscription ?? this.subscription;
    if (subscription != null && subscription.isNotEmpty) {
      subscriptionType = subscription;
    }
    if (role != null) {
      this.role = role;
    } else {
      final inferredRole = (this.user?['role'] ?? user?['role'])?.toString();
      if (inferredRole != null && inferredRole.isNotEmpty) {
        this.role = inferredRole;
      }
    }
    final serverLocale = (this.user?['preferredLocale'] ?? user?['preferredLocale'])?.toString();
    if (serverLocale != null && serverLocale.isNotEmpty) {
      await _cacheLocale(serverLocale);
    }
    _hydrateIntakeFromUser();
    isAuthenticated = true;
    await _persist();
    notifyListeners();
    unawaited(_syncIntakeFromServer());
    unawaited(refreshQuota(force: true));
    unawaited(refreshHomeSummary(force: true));
  }

  Future<void> completeIntake() async {
    intakeComplete = true;
    await _persist();
    notifyListeners();
  }

  Future<void> setSubscription(String type) async {
    final previous = subscriptionType;
    subscriptionType = type;
    await _handleSubscriptionTierChange(previous, type);
    await _persist();
    notifyListeners();
    unawaited(refreshQuota(force: true));
  }

  Future<void> signOut() async {
    isAuthenticated = false;
    intakeComplete = false;
    subscriptionType = 'freemium';
    subscription = null;
    user = null;
    role = null;
    demoMode = false;
    _api.setDemoMode(false);
    intakeProgress = const IntakeProgress();
    _clearQuota();
    _clearHomeSummary();
    await _persist();
    notifyListeners();
  }

  void _clearQuota() {
    quotaSnapshot = null;
    _quotaFetchedAt = null;
  }

  void _clearHomeSummary() {
    homeSummary = null;
    homeSummaryError = null;
    homeSummaryLoading = false;
    _homeSummaryFetchedAt = null;
  }

  Future<void> setUnits(String v) async {
    units = v;
    notifyListeners();
  }

  Future<void> setLocale(Locale next) async {
    await _cacheLocale(next.languageCode);
    notifyListeners();
    unawaited(_syncPreferredLocaleRemote(next.languageCode));
  }

  Future<void> markIntroSeen() async {
    introSeen = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIntroSeen, true);
    notifyListeners();
  }

  String resolveLandingRoute() {
    if (!hasSelectedLanguage) return '/language_select';
    if (!hasSeenIntro) return '/app_intro';
    if (!isAuthenticated) return '/phone_login';
    return needsIntake ? '/intake' : '/dashboard';
  }

  Future<void> setSubscriptionType(String v) async {
    final previous = subscriptionType;
    subscriptionType = v;
    await _handleSubscriptionTierChange(previous, v);
    notifyListeners();
    unawaited(refreshQuota(force: true));
  }

  Future<void> saveFirstIntake(FirstIntakeData data) async {
    intakeProgress = intakeProgress.copyWith(first: data, skippedSecond: false);
    intakeComplete = intakeProgress.isSecondComplete || intakeProgress.skippedSecond;
    _syncUserIntake();
    await _persist();
    notifyListeners();
    unawaited(_pushFirstStageRemote(data));
  }

  Future<void> saveSecondIntake(SecondIntakeData data) async {
    intakeProgress = intakeProgress.copyWith(second: data);
    intakeComplete = true;
    _syncUserIntake();
    await _persist();
    notifyListeners();
    unawaited(_pushSecondStageRemote(data));
  }

  Future<void> skipSecondIntake() async {
    intakeProgress = intakeProgress.copyWith(skippedSecond: true);
    intakeComplete = true;
    _syncUserIntake();
    await _persist();
    notifyListeners();
    unawaited(_pushSkipSecondRemote());
  }

  Future<void> updatePlans({Map<String,dynamic>? workout, Map<String,dynamic>? nutrition}) async {
    workoutPlan = workout ?? workoutPlan;
    nutritionPlan = nutrition ?? nutritionPlan;
    notifyListeners();
  }

  void setDemoMode(bool value) {
    if (demoMode == value) return;
    demoMode = value;
    _api.setDemoMode(value);
    notifyListeners();
    unawaited(refreshHomeSummary(force: true));
  }

  void toggleDemoMode() => setDemoMode(!demoMode);

  Map<String, dynamic> get demoStats => {
        'workouts_completed_week': 4,
        'calories_burned_week': 1850,
        'calories_consumed_today': 1625,
        'target_calories': 2100,
        'streak_days': 6,
        'program_week': 3,
        'weight_progress_kg': -1.4,
        'nutrition_adherence_pct': 74,
      };

  Map<String, dynamic> get effectiveStats =>
      demoMode ? demoStats : (userStats ?? {});

  Map<String, dynamic> get demoNutritionPlan => {
        'calories': 2100,
        'protein_g': 160,
        'carbs_g': 220,
        'fats_g': 70,
        'meals': [
          {'name': 'Breakfast', 'kcal': 420},
          {'name': 'Lunch', 'kcal': 650},
          {'name': 'Snack', 'kcal': 180},
          {'name': 'Dinner', 'kcal': 720},
        ]
      };

  Map<String, dynamic> get demoWorkoutPlan => {
        'name': 'Full Body Builder (Demo)',
        'days': [
          {
            'day': 'Day 1',
            'blocks': [
              {'exercise': 'Back Squat', 'sets': 4, 'reps': 8},
              {'exercise': 'Incline DB Press', 'sets': 3, 'reps': 10},
              {'exercise': 'Lat Pulldown', 'sets': 3, 'reps': 12},
              {'exercise': 'Plank', 'sets': 3, 'reps': 40},
              {'exercise': 'DB Romanian Deadlift', 'sets': 3, 'reps': 10},
            ]
          },
          {
            'day': 'Day 2',
            'blocks': [
              {'exercise': 'Deadlift', 'sets': 3, 'reps': 5},
              {'exercise': 'Seated Row', 'sets': 3, 'reps': 10},
              {'exercise': 'Shoulder Press', 'sets': 3, 'reps': 10},
              {'exercise': 'Cable Fly', 'sets': 2, 'reps': 15},
              {'exercise': 'Hanging Leg Raise', 'sets': 3, 'reps': 12},
            ]
          },
        ]
      };

  Map<String, dynamic> get demoProfile => {
        'name': 'Demo User',
        'email': 'demo@example.com',
        'goal': 'Muscle Gain',
        'experience': 'Intermediate',
      };

  Future<void> _handleSubscriptionTierChange(String previous, String next) async {
    if (previous == next) return;
    final prevTier = SubscriptionTierDisplay.parse(previous);
    final nextTier = SubscriptionTierDisplay.parse(next);
    if (prevTier == nextTier) return;
    final phone = NutritionIntakeFlagStore.phoneFromProfile(user);
    if (phone == null) return;
    if (prevTier == SubscriptionTier.freemium && nextTier != SubscriptionTier.freemium) {
      await NutritionIntakeFlagStore.markPending(phone);
      await NutritionIntakeFlagStore.markCompleted(phone, value: false);
    } else if (nextTier == SubscriptionTier.freemium) {
      await NutritionIntakeFlagStore.clearPending(phone);
      await NutritionIntakeFlagStore.markCompleted(phone, value: false);
    }
  }

  Map<String, dynamic> get demoSubscription => {
        'plan': 'Pro (Demo)',
        'status': 'active',
        'renews_on': '2030-01-01',
      };

  Future<void> refreshQuota({bool force = false}) async {
    final userId = _userId;
    if (userId == null) return;
    if (!force && _quotaFetchedAt != null) {
      final delta = DateTime.now().difference(_quotaFetchedAt!);
      if (delta < const Duration(minutes: 5)) return;
    }
    try {
      final snapshot = await _quotaService.fetchSnapshot(userId);
      quotaSnapshot = snapshot;
      _quotaFetchedAt = DateTime.now();
      notifyListeners();
    } catch (error) {
      debugPrint('Unable to fetch quota: ${_api.mapError(error)}');
    }
  }

  Future<void> refreshHomeSummary({bool force = false}) async {
    final userId = _userId;
    if (userId == null) return;
    if (!force && _homeSummaryFetchedAt != null) {
      final delta = DateTime.now().difference(_homeSummaryFetchedAt!);
      if (delta < const Duration(minutes: 3)) return;
    }
    homeSummaryLoading = true;
    homeSummaryError = null;
    notifyListeners();
    try {
      final summary = await _homeSummaryService.fetchSummary(userId);
      homeSummary = summary;
      homeSummaryLoading = false;
      _homeSummaryFetchedAt = DateTime.now();
      notifyListeners();
    } catch (error) {
      homeSummaryLoading = false;
      homeSummaryError = _api.mapError(error, fallback: 'Unable to load home summary');
      notifyListeners();
    }
  }

  Future<void> applyDemoFixtures(Map<String, dynamic> payload) async {
    final statsMap = _coerceMap(payload['stats']);
    final workoutMap = _coerceMap(payload['workoutPlan']);
    final nutritionMap = _coerceMap(payload['nutritionPlan']);
    if (statsMap != null) {
      userStats = statsMap;
      homeSummary = HomeSummary.fromLegacyStats(statsMap);
      _homeSummaryFetchedAt = DateTime.now();
    }
    if (workoutMap != null) {
      workoutPlan = workoutMap;
    }
    if (nutritionMap != null) {
      nutritionPlan = nutritionMap;
    }
    notifyListeners();
  }

  Map<String, dynamic>? _coerceMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return Map<String, dynamic>.from(value);
    }
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return null;
  }
}

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState notifier,
    required Widget child,
  }) : super(notifier: notifier, child: child);

  static AppState of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AppStateScope>()!.notifier!;
}

extension on AppState {
  void _hydrateIntakeFromUser() {
    final data = user?['intake'];
    if (data is Map<dynamic, dynamic>) {
      final mapped = data.map((key, value) => MapEntry(key.toString(), value));
      intakeProgress = IntakeProgress.fromJson(mapped.cast<String, dynamic>());
      intakeComplete = intakeProgress.isSecondComplete || intakeProgress.skippedSecond;
      _syncUserIntake();
    }
  }

  void _syncUserIntake() {
    final intakeJson = intakeProgress.toJson();
    if (user == null) {
      user = {'intake': intakeJson};
    } else {
      user = {
        ...user!,
        'intake': intakeJson,
      };
    }
  }

  Future<void> _cacheLocale(String code) async {
    locale = Locale(code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppState._kLocale, code);
    _api.setPreferredLocale(code);
  }

  Future<void> _syncPreferredLocaleRemote(String code) async {
    if (!_enableNetworkSync) return;
    final id = _userId;
    if (id == null) return;
    try {
      await _api.dio.put('/v1/users/$id', data: {'preferredLocale': code});
    } catch (error) {
      debugPrint('Unable to sync locale: ${_api.mapError(error)}');
    }
  }

}