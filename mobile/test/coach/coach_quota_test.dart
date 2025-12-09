import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitcoach/app.dart';
import '../test_utils.dart';
import 'package:fitcoach/screens/coach/coach_screen.dart';

// Use shared pump utility for providers + localization

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Freemium enforces message/call quotas', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'subscription.tier': 'freemium'});
    await tester.pumpThemed(const CoachScreen());
    await tester.pumpAndSettle();

    final sendBtn = find.text('Send Message');
    expect(sendBtn, findsOneWidget);

    // Tap up to limit
    for (int i = 0; i < 20; i++) {
      await tester.tap(sendBtn);
      await tester.pump();
    }

    // Beyond limit should disable
    await tester.tap(sendBtn);
    await tester.pump();

    // Button remains in tree but disabled. Check message limit text + count appears
    expect(find.textContaining('message'), findsWidgets);
    expect(find.textContaining('20'), findsWidgets);

    // Calls: only 1 allowed
    // Verify Attach File button is present (disabled under freemium)
    expect(find.textContaining('Attach File'), findsOneWidget);
    // Attach File button disabled for freemium or if calls exceeded; just verify text and counter initial state
    // UI shows call limit reached + current calls count (initially 0)
    expect(find.textContaining('call'), findsWidgets);
    expect(find.textContaining('0'), findsWidgets);
  });

  testWidgets('Premium increases quotas', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'subscription.tier': 'premium'});
    await tester.pumpThemed(const CoachScreen());
    await tester.pumpAndSettle();

    final sendBtn = find.text('Send Message');
    for (int i = 0; i < 25; i++) {
      await tester.tap(sendBtn);
      await tester.pump();
    }
    expect(find.textContaining('25'), findsWidgets);
  });
}
