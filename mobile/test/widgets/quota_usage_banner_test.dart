import 'package:fitcoach_plus/localization/app_localizations.dart';
import 'package:fitcoach_plus/models/quota_models.dart';
import 'package:fitcoach_plus/widgets/quota_usage_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('QuotaUsageBanner', () {
    testWidgets('shows running low warning at 80% usage', (tester) async {
      final snapshot = _snapshot(messagesUsed: 8, messageLimit: 10, callsUsed: 1, callLimit: 2);
      await tester.pumpWidget(_wrapBanner(snapshot));
      await tester.pumpAndSettle();

      expect(find.text('Running low'), findsOneWidget);
      expect(find.text('Messages'), findsOneWidget);
    });

    testWidgets('renders upgrade + nutrition window pills when locked', (tester) async {
      final snapshot = _snapshot(
        messagesUsed: 2,
        messageLimit: 10,
        callsUsed: 0,
        callLimit: 1,
        attachmentsEnabled: false,
        nutritionPersistent: false,
        nutritionWindowDays: 7,
      );

      await tester.pumpWidget(_wrapBanner(snapshot));
      await tester.pumpAndSettle();

      expect(find.text('Upgrade to continue'), findsOneWidget);
      expect(find.text('7-day window'), findsOneWidget);
    });

    testWidgets('invokes the upgrade callback', (tester) async {
      var tapped = false;
      final snapshot = _snapshot(messagesUsed: 1, messageLimit: 100);
      await tester.pumpWidget(_wrapBanner(snapshot, onUpgrade: () => tapped = true));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}

Widget _wrapBanner(QuotaSnapshot snapshot, {VoidCallback? onUpgrade}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Center(
        child: QuotaUsageBanner(
          snapshot: snapshot,
          onUpgrade: onUpgrade,
        ),
      ),
    ),
  );
}

QuotaSnapshot _snapshot({
  required int messagesUsed,
  required dynamic messageLimit,
  int callsUsed = 0,
  int callLimit = 1,
  bool attachmentsEnabled = true,
  bool nutritionPersistent = true,
  int? nutritionWindowDays,
}) {
  return QuotaSnapshot(
    userId: 'user-1',
    tier: SubscriptionTier.premium,
    usage: QuotaUsage(
      messagesUsed: messagesUsed,
      callsUsed: callsUsed,
      attachmentsUsed: 0,
      resetAt: DateTime(2025, 1, 1),
    ),
    limits: QuotaLimits(
      messages: messageLimit,
      calls: callLimit,
      callDuration: 30,
      chatAttachments: attachmentsEnabled,
      nutritionPersistent: nutritionPersistent,
      nutritionWindowDays: nutritionWindowDays,
    ),
  );
}
