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

  test('phase 1 flow persists locale, intro, and auth state', () async {
    final app = AppState(enableNetworkSync: false);
    await app.load();

    expect(app.resolveLandingRoute(), '/language_select');

    await app.setLocale(const Locale('ar'));
    expect(app.hasSelectedLanguage, isTrue);
    expect(app.resolveLandingRoute(), '/app_intro');

    await app.markIntroSeen();
    expect(app.hasSeenIntro, isTrue);
    expect(app.resolveLandingRoute(), '/phone_login');

    await app.signIn(user: {'id': 'phase1-user'});
    expect(app.isAuthenticated, isTrue);
    expect(app.resolveLandingRoute(), '/intake');

    final restored = AppState(enableNetworkSync: false);
    await restored.load();

    expect(restored.locale?.languageCode, 'ar');
    expect(restored.hasSeenIntro, isTrue);
    expect(restored.isAuthenticated, isTrue);
    expect(restored.resolveLandingRoute(), '/intake');
  });
}
