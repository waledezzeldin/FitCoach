import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitcoach/app.dart';
import 'package:fitcoach/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Language → Onboarding → Login flow works', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
          DefaultMaterialLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: FitCoachApp(),
      ),
    );
    await tester.pumpAndSettle();

    // On first run, SplashGate routes to language selection.
    expect(find.text('English'), findsOneWidget);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    // Onboarding should appear.
    expect(find.textContaining('Welcome'), findsOneWidget);

    // Walk through pages to Get Started.
    await tester.tap(find.textContaining('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Sign'));
    await tester.pumpAndSettle();

    // Login screen should be visible.
    expect(find.byType(TextFormField), findsWidgets);
  });
}
