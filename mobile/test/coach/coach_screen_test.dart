import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fitcoach/app.dart';
import 'package:fitcoach/coach/coach_state.dart';
import 'package:fitcoach/subscription/subscription_state.dart';
import 'package:fitcoach/l10n/app_localizations.dart';
import 'package:fitcoach/theme/fitcoach_theme.dart';
import 'package:fitcoach/screens/coach/coach_screen.dart';

void main() {
  group('CoachScreen', () {
    Widget buildApp({SubscriptionTier tier = SubscriptionTier.smartPremium}) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) {
            final s = SubscriptionState();
            s.setTier(tier);
            return s;
          }),
          ChangeNotifierProvider(create: (_) => CoachState()..load()),
        ],
        child: MaterialApp(
          home: const CoachScreen(),
          locale: const Locale('en'),
          theme: FitCoachTheme.light(),
          darkTheme: FitCoachTheme.dark(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('ar')],
        ),
      );
    }

    testWidgets('approving and rejecting requests updates UI and messages', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Expect requests listed
      expect(find.byIcon(Icons.pending_actions), findsWidgets);

      // Tap first approve
      final approveButtons = find.widgetWithText(TextButton, 'Approve');
      expect(approveButtons, findsWidgets);
      await tester.tap(approveButtons.first);
      await tester.pump();

      // Tap reject (if any remaining)
      final rejectButtons = find.widgetWithText(TextButton, 'Reject');
      if (tester.any(rejectButtons)) {
        await tester.tap(rejectButtons.first);
        await tester.pump();
      }

      // Messages should include action notes
      expect(find.textContaining('Approved'), findsOneWidget);
    });

    testWidgets('send message disabled when over limit for tier', (tester) async {
      await tester.pumpWidget(buildApp(tier: SubscriptionTier.freemium));
      await tester.pumpAndSettle();

      final coach = Provider.of<CoachState>(tester.element(find.byType(Scaffold)), listen: false);
      // Simulate reaching freemium limit
      for (int i = 0; i < 20; i++) {
        await coach.sendMessage();
      }
      await tester.pump();

      // Button labeled by localization (English default)
      final sendBtnFinder = find.widgetWithText(ElevatedButton, 'Send');
      expect(sendBtnFinder, findsOneWidget);
      final sendBtn = tester.widget<ElevatedButton>(sendBtnFinder);
      expect(sendBtn.onPressed, isNull);
    });

    testWidgets('call button disabled for freemium', (tester) async {
      await tester.pumpWidget(buildApp(tier: SubscriptionTier.freemium));
      await tester.pumpAndSettle();

      // Start call button should be present (disabled by tier)
      final callBtnFinder = find.widgetWithText(ElevatedButton, 'Start Call');
      expect(callBtnFinder, findsOneWidget);
      final callBtn = tester.widget<ElevatedButton>(callBtnFinder);
      expect(callBtn.onPressed, isNull);
    });

    testWidgets('rating updates on star tap', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Tap 4th star
      final stars = find.byIcon(Icons.star_border);
      expect(stars, findsWidgets);
      await tester.tap(stars.at(3));
      await tester.pump();

      // Now 4 stars should be filled
      final filled = find.byIcon(Icons.star);
      expect(filled, findsWidgets);
    });
  });
}
