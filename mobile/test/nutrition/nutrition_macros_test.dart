import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fitcoach/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitcoach/nutrition/nutrition_state.dart';
import 'package:fitcoach/screens/nutrition/nutrition_plan_screen.dart';

void main() {
  testWidgets('Macro summary reflects preferences', (tester) async {
    SharedPreferences.setMockInitialValues({
      'nutrition.dietType': 'balanced',
      'nutrition.calorieTarget': 2300,
      'nutrition.allergies': <String>[],
      'nutrition.proteinTarget': 150,
      'nutrition.carbsTarget': 200,
      'nutrition.fatsTarget': 70,
    });
    final state = NutritionState();
    await state.load();

    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider.value(value: state)],
        child: MaterialApp(
          supportedLocales: const [Locale('en'), Locale('ar')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: const NutritionPlanScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.textContaining('Protein'), findsOneWidget);
    expect(find.textContaining('150g'), findsOneWidget);
    expect(find.textContaining('Carbs'), findsOneWidget);
    expect(find.textContaining('200g'), findsOneWidget);
    expect(find.textContaining('Fats'), findsOneWidget);
    expect(find.textContaining('70g'), findsOneWidget);
  });
}
