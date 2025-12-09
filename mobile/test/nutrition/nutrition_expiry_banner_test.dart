import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fitcoach/screens/nutrition/nutrition_plan_screen.dart';
import 'package:fitcoach/nutrition/nutrition_state.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fitcoach/l10n/app_localizations.dart';

void main() {
  Widget buildApp(NutritionState state) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => state),
      ],
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
    );
  }

  testWidgets('Shows expiry banner when expiresAt is set', (tester) async {
    final s = NutritionState();
    await s.startFreemiumTrial(windowDays: 10);
    await tester.pumpWidget(buildApp(s));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.textContaining('Expires in'), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 10)));

  testWidgets('Hides expiry banner when expiresAt is null', (tester) async {
    final s = NutritionState();
    await s.unlockPermanentAccess();
    await tester.pumpWidget(buildApp(s));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.textContaining('Expires in'), findsNothing);
  }, timeout: const Timeout(Duration(seconds: 10)));
}
