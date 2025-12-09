import 'package:flutter_test/flutter_test.dart';
import 'package:fitcoach/screens/intake/intake_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('IntakeState validation and completion', () async {
    SharedPreferences.setMockInitialValues({});
    final s = IntakeState();
    await s.saveFirst(const FirstIntakeData(goal: 'lose_weight', heightCm: 175, weightKg: 80));
    expect(s.first.isValid, isTrue);
    expect(s.canComplete, isFalse);
    await s.saveSecond(const SecondIntakeData(experience: 'beginner', daysPerWeek: 3));
    expect(s.second.isValid, isTrue);
    expect(s.canComplete, isTrue);
    await s.markCompleted();
    expect(s.completed, isTrue);
  });
}
