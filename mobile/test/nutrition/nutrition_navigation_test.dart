import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitcoach/screens/nutrition/nutrition_plan_screen.dart';
import 'package:fitcoach/screens/nutrition/nutrition_preferences_screen.dart';
import '../test_utils.dart';

void main() {
  testWidgets('Navigate from plan to preferences', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1200));
    await tester.pumpThemed(
      const NutritionPlanScreen(),
      routes: {
        '/nutrition/preferences': (context) => const NutritionPreferencesScreen(),
      },
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.textContaining('Nutrition'), findsOneWidget);
    await tester.tap(find.textContaining('Edit'));
    for (int i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 125));
    }

    expect(find.textContaining('Nutrition'), findsOneWidget);
    expect(find.textContaining('Diet'), findsOneWidget);
    expect(find.textContaining('Calorie'), findsOneWidget);
  });
}
