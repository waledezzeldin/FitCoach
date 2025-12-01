import 'package:fitcoach_plus/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/mock_secure_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final secureStorageMock = MockSecureStorageChannel()..install();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    secureStorageMock.reset();
  });

  group('AppState.resolveLandingRoute', () {
    test('requires language selection first', () {
      final app = AppState(enableNetworkSync: false);
      expect(app.resolveLandingRoute(), '/language_select');
    });

    test('shows intro after language selection', () {
      final app = AppState(enableNetworkSync: false)
        ..locale = const Locale('en');
      expect(app.resolveLandingRoute(), '/app_intro');
    });

    test('defaults to phone login after intro is seen', () {
      final app = AppState(enableNetworkSync: false)
        ..locale = const Locale('ar')
        ..introSeen = true;
      expect(app.resolveLandingRoute(), '/phone_login');
    });

    test('routes to intake when authenticated but onboarding incomplete', () async {
      final app = AppState(enableNetworkSync: false)
        ..locale = const Locale('en')
        ..introSeen = true;
      await app.signIn(user: {'id': 'user-1'}); // missing intake map
      expect(app.resolveLandingRoute(), '/intake');
    });

    test('routes to dashboard once language, intro, auth, and intake are satisfied', () async {
      final intakeNow = DateTime.now().toIso8601String();
      final app = AppState(enableNetworkSync: false)
        ..locale = const Locale('en')
        ..introSeen = true;
      await app.signIn(user: {
        'id': 'user-1',
        'intake': {
          'first': {
            'gender': 'female',
            'mainGoal': 'general_fitness',
            'workoutLocation': 'home',
            'completedAt': intakeNow,
          },
          'second': {
            'age': 28,
            'weight': 70,
            'height': 168,
            'experienceLevel': 'intermediate',
            'workoutFrequency': 4,
            'injuries': <String>[],
            'completedAt': intakeNow,
          },
        },
      });
      expect(app.resolveLandingRoute(), '/dashboard');
    });
  });
}

