import 'package:fitcoach_plus/models/intake_models.dart';
import 'package:fitcoach_plus/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/mock_secure_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final secureStorageMock = MockSecureStorageChannel()..install();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    secureStorageMock.reset();
  });

  test('phase 2 flow resumes and completes two-stage intake', () async {
    final app = AppState(enableNetworkSync: false);
    await app.load();

    await app.setLocale(const Locale('en'));
    await app.markIntroSeen();
    await app.signIn(user: {'id': 'phase2-user'});

    final firstStage = FirstIntakeData(
      gender: 'female',
      mainGoal: 'strength',
      workoutLocation: 'gym',
    );

    await app.saveFirstIntake(firstStage);

    expect(app.intakeProgress.isFirstComplete, isTrue);
    expect(app.needsSecondIntake, isTrue);
    expect(app.resolveLandingRoute(), '/intake');

    final resumed = AppState(enableNetworkSync: false);
    await resumed.load();

    expect(resumed.intakeProgress.isFirstComplete, isTrue);
    expect(resumed.needsSecondIntake, isTrue);
    expect(resumed.intakeProgress.first?.mainGoal, 'strength');

    final secondStage = SecondIntakeData(
      age: 32,
      weight: 68,
      height: 170,
      experienceLevel: 'intermediate',
      workoutFrequency: 4,
      injuries: const ['knee'],
    );

    await resumed.saveSecondIntake(secondStage);

    expect(resumed.intakeComplete, isTrue);
    expect(resumed.needsIntake, isFalse);
    expect(resumed.resolveLandingRoute(), '/dashboard');

    final hydrated = AppState(enableNetworkSync: false);
    await hydrated.load();

    expect(hydrated.intakeComplete, isTrue);
    expect(hydrated.resolveLandingRoute(), '/dashboard');
    expect(hydrated.intakeProgress.second?.experienceLevel, 'intermediate');
  });
}
