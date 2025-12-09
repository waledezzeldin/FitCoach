import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NutritionPrefs {
  final String dietType; // e.g., balanced, keto, vegan
  final int calorieTarget; // daily kcal
  final List<String> allergies;
  final int proteinTarget; // grams
  final int carbsTarget; // grams
  final int fatsTarget; // grams

  NutritionPrefs({
    required this.dietType,
    required this.calorieTarget,
    required this.allergies,
    this.proteinTarget = 140,
    this.carbsTarget = 210,
    this.fatsTarget = 60,
  });

  Map<String, dynamic> toJson() => {
    'dietType': dietType,
    'calorieTarget': calorieTarget,
    'allergies': allergies,
    'proteinTarget': proteinTarget,
    'carbsTarget': carbsTarget,
    'fatsTarget': fatsTarget,
  };

  static NutritionPrefs fromJson(Map<String, dynamic> j) => NutritionPrefs(
    dietType: j['dietType'] as String? ?? 'balanced',
    calorieTarget: (j['calorieTarget'] as int?) ?? 2200,
    allergies: List<String>.from(j['allergies'] as List? ?? const []),
    proteinTarget: (j['proteinTarget'] as int?) ?? 140,
    carbsTarget: (j['carbsTarget'] as int?) ?? 210,
    fatsTarget: (j['fatsTarget'] as int?) ?? 60,
  );
}

class NutritionState extends ChangeNotifier {
  NutritionPrefs _prefs = NutritionPrefs(dietType: 'balanced', calorieTarget: 2200, allergies: const []);
  bool loaded = false;
  DateTime? lastUpdated;
  DateTime? expiresAt; // Freemium trial expiry; Premium+ keeps null
  bool get isLocked => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  // New: Daily/weekly tracking
  int caloriesBurnedToday = 0;
  int caloriesConsumedToday = 0;
  int caloriesDeltaToday = 0;
  int proteinToday = 0;
  int carbsToday = 0;
  int fatsToday = 0;
  List<double> weeklyProgress = List<double>.filled(7, 0.0);

  NutritionPrefs get prefs => _prefs;
  // New: Update daily nutrition (call from UI or service)
  void updateDaily({
    int? burned,
    int? consumed,
    int? protein,
    int? carbs,
    int? fats,
    int? delta,
    List<double>? weekly,
  }) {
    if (burned != null) caloriesBurnedToday = burned;
    if (consumed != null) caloriesConsumedToday = consumed;
    if (protein != null) proteinToday = protein;
    if (carbs != null) carbsToday = carbs;
    if (fats != null) fatsToday = fats;
    if (delta != null) caloriesDeltaToday = delta;
    if (weekly != null && weekly.length == 7) weeklyProgress = weekly;
    notifyListeners();
  }

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    final diet = sp.getString('nutrition.dietType');
    final cal = sp.getInt('nutrition.calorieTarget');
    final allergies = sp.getStringList('nutrition.allergies');
    final protein = sp.getInt('nutrition.proteinTarget');
    final carbs = sp.getInt('nutrition.carbsTarget');
    final fats = sp.getInt('nutrition.fatsTarget');
    final ts = sp.getString('nutrition.lastUpdated');
    _prefs = NutritionPrefs(
      dietType: diet ?? 'balanced',
      calorieTarget: cal ?? 2200,
      allergies: allergies ?? const [],
      proteinTarget: protein ?? 140,
      carbsTarget: carbs ?? 210,
      fatsTarget: fats ?? 60,
    );
    lastUpdated = ts != null ? DateTime.tryParse(ts) : null;
    final exp = sp.getString('nutrition.expiresAt');
    expiresAt = exp != null ? DateTime.tryParse(exp) : null;
    loaded = true;
    notifyListeners();
  }

  Future<void> save(NutritionPrefs p) async {
    _prefs = p;
    final sp = await SharedPreferences.getInstance();
    await sp.setString('nutrition.dietType', p.dietType);
    await sp.setInt('nutrition.calorieTarget', p.calorieTarget);
    await sp.setStringList('nutrition.allergies', p.allergies);
    await sp.setInt('nutrition.proteinTarget', p.proteinTarget);
    await sp.setInt('nutrition.carbsTarget', p.carbsTarget);
    await sp.setInt('nutrition.fatsTarget', p.fatsTarget);
    await sp.setString('nutrition.lastUpdated', DateTime.now().toIso8601String());
    lastUpdated = DateTime.now();
    notifyListeners();
  }

  Map<String, int> macroSummary() {
    return {
      'protein': _prefs.proteinTarget,
      'carbs': _prefs.carbsTarget,
      'fats': _prefs.fatsTarget,
    };
  }

  Future<void> refreshPlan() async {
    // Mock recompute based on prefs; just update timestamp.
    final sp = await SharedPreferences.getInstance();
    lastUpdated = DateTime.now();
    await sp.setString('nutrition.lastUpdated', lastUpdated!.toIso8601String());
    notifyListeners();
  }

  Future<void> startFreemiumTrial({int windowDays = 7}) async {
    final sp = await SharedPreferences.getInstance();
    expiresAt = DateTime.now().add(Duration(days: windowDays));
    await sp.setString('nutrition.expiresAt', expiresAt!.toIso8601String());
    notifyListeners();
  }

  Future<void> unlockPermanentAccess() async {
    final sp = await SharedPreferences.getInstance();
    expiresAt = null;
    await sp.remove('nutrition.expiresAt');
    notifyListeners();
  }
}
