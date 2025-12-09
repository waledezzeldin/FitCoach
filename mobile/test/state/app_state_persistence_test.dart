import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitcoach/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('AppState persists and loads locale and demo flag', () async {
    SharedPreferences.setMockInitialValues({
      'app.locale': 'ar',
      'app.demo': true,
    });
    final state = AppState();
    // Wait for AppState to load persisted values
    await Future.delayed(const Duration(milliseconds: 200));
    expect(state.locale.languageCode, 'ar');
    expect(state.isDemo, isTrue);

    await state.setLocale(const Locale('en'));
    await state.setDemo(false);
    final sp = await SharedPreferences.getInstance();
    expect(sp.getString('app.locale'), 'en');
    expect(sp.getBool('app.demo'), isFalse);
  });
}
