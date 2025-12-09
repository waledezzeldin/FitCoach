import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitcoach/app.dart';
import '../test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SplashGate routes logged-in user to Quick Start step 1', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'auth.logged_in': true,
      'auth.email': 'user@example.com',
      'intake.completed': false,
    });

    await tester.pumpThemed(FitCoachApp(), locale: const Locale('en'));
    for (int i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 125));
    }

    // Should navigate to Quick Start step 1.
    expect(find.textContaining('Quick Start'), findsOneWidget);
    expect(find.textContaining('What is your gender?'), findsOneWidget);
  });
}
