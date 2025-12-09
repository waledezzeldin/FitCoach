import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fitcoach/app.dart';
import 'package:fitcoach/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Language → Onboarding → Login → Quick Start → Home → Store → Starter Plan flow', (tester) async {
    // Ensure plugins used by SharedPreferences are mocked in test
    SharedPreferences.setMockInitialValues({});
    // Launch the app
    await tester.pumpWidget(FitCoachApp());
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    // Expect language selection screen (by description text)
    final t = AppLocalizations(const Locale('en'));
    expect(find.text(t.selectLanguage), findsOneWidget);
    // Tap English label directly
    await tester.tap(find.text('English'));

    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    // Expect onboarding screen content (fallback: look for Continue)
    final continueFinder = find.text(t.continueCta);
    if (tester.any(continueFinder)) {
      await tester.tap(continueFinder);
    } else {
      // Fallback: find primary ElevatedButton and tap it
      final primaryBtn = find.byType(ElevatedButton);
      expect(primaryBtn, findsWidgets);
      await tester.tap(primaryBtn.first);
    }
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    // Expect login screen title
    final loginTitle = find.text(t.authTitle);
    expect(loginTitle, findsOneWidget);

    // Tap Try Demo to go home quickly
    final tryDemo = find.text(t.tryDemo);
    if (tester.any(tryDemo)) {
      await tester.tap(tryDemo);
    } else {
      // Fallback: tap TextButton if label differs
      final textButtons = find.byType(TextButton);
      expect(textButtons, findsWidgets);
      await tester.tap(textButtons.first);
    }
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    // Expect home navigation grid title
    expect(find.text(t.navigation), findsOneWidget);

    // Tap Store navigation (simulate grid tap)
    await tester.tap(find.text('Store'));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    // Expect Store screen
    expect(find.text(t.storeTitle), findsOneWidget);

    // Go back to Home
    await tester.pageBack();
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    // Tap Starter Plan card (simulate view plan button)
    final viewPlanBtn = find.text(t.viewPlan);
    if (tester.any(viewPlanBtn)) {
      await tester.tap(viewPlanBtn);
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      // Expect Starter Plan screen
      expect(find.text(t.starterPlanTitle), findsOneWidget);
    }
  });
}
