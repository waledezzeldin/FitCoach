import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import '../test_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitcoach/screens/nutrition/nutrition_plan_screen.dart';
import 'package:fitcoach/nutrition/nutrition_state.dart';

void main() {
  testWidgets('Shows banner when stale and hides after refresh', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final state = NutritionState();
    await state.load();
    // Make it stale: set lastUpdated to 3 days ago
    state.lastUpdated = DateTime.now().subtract(const Duration(days: 3));

    await tester.pumpThemed(const NutritionPlanScreen());
    // Inject the preloaded state into the provider tree
    final element = tester.element(find.byType(NutritionPlanScreen));
    Provider.of<NutritionState>(element, listen: false)
      ..lastUpdated = state.lastUpdated;
    await tester.pump();

    // Banner visible
    expect(find.textContaining('Plan updated'), findsOneWidget);

    // Tap Refresh
    await tester.tap(find.text('Refresh'));
    await tester.pump();

    // After refresh, banner should hide
    expect(find.textContaining('Plan updated'), findsNothing);
  });
}
