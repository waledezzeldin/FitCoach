import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitcoach/app.dart';
import 'package:fitcoach/screens/home/home_screen.dart';
import 'package:fitcoach/l10n/app_localizations.dart';

void main() {
  testWidgets('Quick Start 3-step flow completes and navigates home', (tester) async {
    SharedPreferences.setMockInitialValues({
      'auth.logged_in': true,
      'auth.email': 'user@example.com',
      'intake.completed': false,
    });

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          // Add localization delegates for AppLocalizations
          AppLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
          DefaultMaterialLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('ar')],
        home: FitCoachApp(),
      ),
    );
    for (int i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 125));
    }

    // Step 1: Gender
    expect(find.textContaining('Quick Start'), findsOneWidget);
    await tester.tap(find.text('Male').first);
    await tester.pump();
    await tester.tap(find.text('Continue').first);
    for (int i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 125));
    }

    // Step 2: Goal
    await tester.tap(find.text('Fat Loss').first);
    await tester.pump();
    await tester.tap(find.text('Continue').first);
    for (int i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 125));
    }

    // Step 3: Location
    await tester.tap(find.text('Gym').first);
    await tester.pump();
    await tester.tap(find.text('Start My Journey').first);
    for (int i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 125));
    }

    // Should be on home screen
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
