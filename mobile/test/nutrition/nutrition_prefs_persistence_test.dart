import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitcoach/nutrition/nutrition_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('NutritionState save/load persistence', () async {
    SharedPreferences.setMockInitialValues({});
    final s = NutritionState();
    await s.load();
    final initial = s.prefs;

    final updated = NutritionPrefs(dietType: 'keto', calorieTarget: 2000, allergies: ['nuts', 'dairy']);
    await s.save(updated);

    final s2 = NutritionState();
    await s2.load();
    expect(s2.prefs.dietType, 'keto');
    expect(s2.prefs.calorieTarget, 2000);
    expect(s2.prefs.allergies, containsAll(['nuts', 'dairy']));

    // Restore
    await s2.save(initial);
  });
}
