import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../test_utils.dart';
import 'package:fitcoach/nutrition/nutrition_state.dart';
import 'package:fitcoach/screens/nutrition/nutrition_plan_screen.dart';
import 'package:fitcoach/subscription/subscription_state.dart';

// Use shared pump utility that injects providers and localization

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Freemium nutrition expires after 7 days and shows upgrade', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'subscription.tier': 'freemium',
    });
    await tester.pumpThemed(const NutritionPlanScreen());
    await tester.pumpAndSettle();

    final ns = tester.widgetList(find.byType(NutritionPlanScreen)).isNotEmpty
        ? Provider.of<NutritionState>(tester.element(find.byType(NutritionPlanScreen)), listen: false)
        : null;
    expect(ns, isNotNull);
    await ns!.startFreemiumTrial(windowDays: 0); // expire immediately
    await tester.pumpAndSettle();

    expect(find.text('Your trial nutrition plan has expired'), findsOneWidget);
    expect(find.text('Upgrade'), findsOneWidget);
  });

  testWidgets('Premium unlocks permanent nutrition access', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'subscription.tier': 'premium',
    });
    await tester.pumpThemed(const NutritionPlanScreen());
    await tester.pumpAndSettle();

    expect(find.text('Nutrition Plan'), findsOneWidget);
    expect(find.text('Your trial nutrition plan has expired'), findsNothing);
  });
}
