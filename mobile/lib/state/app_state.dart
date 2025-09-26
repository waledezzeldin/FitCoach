import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppState extends ChangeNotifier {
  AppState() {
    // Honor --dart-define=DEMO=true
    const fromDefine = bool.fromEnvironment('DEMO', defaultValue: false);
    if (fromDefine) demoMode = true;
  }
  static const _kAuth = 'fc_isAuthenticated';
  static const _kIntake = 'fc_intakeComplete';
  static const _kSub = 'fc_subscriptionType';

  final FlutterSecureStorage _secure = const FlutterSecureStorage();

  bool isAuthenticated = false;
  bool intakeComplete = false;
  String subscriptionType = 'freemium';
  bool initialized = false;
  String? role;
  String units = 'metric'; // Default value, adjust as needed

  Map<String, dynamic>? user;
  String? subscription;
  Map<String,dynamic>? workoutPlan;
  Map<String,dynamic>? nutritionPlan;
  Map<String, dynamic>? stats;

  bool demoMode = false;

  // Optional real user stats if you already have them
  Map<String, dynamic>? userStats;

  bool get needsIntake => user == null || user?['intake'] == null;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    isAuthenticated = prefs.getBool(_kAuth) ?? false;
    intakeComplete = prefs.getBool(_kIntake) ?? false;
    subscriptionType = prefs.getString(_kSub) ?? 'freemium';

    // If token exists, user is authenticated
    try {
      final token = await _secure.read(key: 'access_token');
      if (token != null && token.isNotEmpty) {
        isAuthenticated = true;
      }
    } catch (_) {}

    initialized = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAuth, isAuthenticated);
    await prefs.setBool(_kIntake, intakeComplete);
    await prefs.setString(_kSub, subscriptionType);
  }

  Future<void> signIn({Map<String, dynamic>? user, String? subscription}) async {
    this.user = user ?? this.user;
    this.subscription = subscription ?? this.subscription;
    isAuthenticated = true;
    await _persist();
    notifyListeners();
  }

  Future<void> completeIntake() async {
    intakeComplete = true;
    await _persist();
    notifyListeners();
  }

  Future<void> setSubscription(String type) async {
    subscriptionType = type;
    await _persist();
    notifyListeners();
  }

  Future<void> signOut() async {
    isAuthenticated = false;
    intakeComplete = false;
    subscriptionType = 'freemium';
    await _persist();
    notifyListeners();
  }

  Future<void> setUnits(String v) async {
    units = v;
    notifyListeners();
  }

  Future<void> setSubscriptionType(String v) async {
    subscriptionType = v;
    notifyListeners();
  }

  Future<void> updatePlans({Map<String,dynamic>? workout, Map<String,dynamic>? nutrition}) async {
    workoutPlan = workout ?? workoutPlan;
    nutritionPlan = nutrition ?? nutritionPlan;
    notifyListeners();
  }

  void setDemoMode(bool value) {
    if (demoMode == value) return;
    demoMode = value;
    notifyListeners();
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

  Map<String, dynamic> get demoSubscription => {
        'plan': 'Pro (Demo)',
        'status': 'active',
        'renews_on': '2030-01-01',
      };
}

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState notifier,
    required Widget child,
  }) : super(notifier: notifier, child: child);

  static AppState of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AppStateScope>()!.notifier!;
}