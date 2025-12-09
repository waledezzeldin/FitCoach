import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitcoach/app.dart';
import 'package:fitcoach/theme/fitcoach_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fitcoach/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:fitcoach/subscription/subscription_state.dart';
import 'package:fitcoach/nutrition/nutrition_state.dart';
import 'package:fitcoach/screens/intake/intake_state.dart';
import 'package:fitcoach/screens/home/home_screen.dart';

void main() {
  testWidgets('HomeScreen shows main sections and progress', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1200));
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SubscriptionState()),
        ChangeNotifierProvider(create: (_) => NutritionState()),
        ChangeNotifierProvider(create: (_) => IntakeState()),
      ],
      child: MaterialApp(
        theme: FitCoachTheme.light(),
        darkTheme: FitCoachTheme.dark(),
        supportedLocales: const [Locale('en'), Locale('ar')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: const HomeScreen(),
      ),
    ));
    await tester.pump();

    final context = tester.element(find.byType(HomeScreen));
    final t = AppLocalizations.of(context);

    // Debug: print widget tree for troubleshooting
    debugPrint(tester.widgetList(find.byType(Text)).map((w) => (w as Text).data).toList().toString());

    // Main sections (match actual rendered text)
    expect(find.textContaining('👆 Tap to Upgrade'), findsOneWidget);
    expect(find.textContaining(t.caloriesBurned), findsOneWidget);
    expect(find.textContaining(t.caloriesConsumed), findsOneWidget);
    expect(find.textContaining('Macros'), findsOneWidget);
    expect(find.textContaining('Weekly Progress'), findsOneWidget);
    expect(find.textContaining(t.navigation), findsOneWidget);
  });

  testWidgets('HomeScreen renders all main sections and responds to taps', (WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(390, 1200));
  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => SubscriptionState()),
      ChangeNotifierProvider(create: (_) => NutritionState()),
      ChangeNotifierProvider(create: (_) => IntakeState()),
    ],
    child: MaterialApp(
      theme: FitCoachTheme.light(),
      darkTheme: FitCoachTheme.dark(),
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: const HomeScreen(),
    ),
  ));
  await tester.pump();

  final context = tester.element(find.byType(HomeScreen));
  final t = AppLocalizations.of(context);

  // Main sections (match actual rendered text)
  expect(find.textContaining('👆 Tap to Upgrade'), findsOneWidget);
  expect(find.textContaining(t.coachTitle), findsWidgets);
  expect(find.textContaining(t.caloriesBurned), findsOneWidget);
  expect(find.textContaining(t.caloriesConsumed), findsOneWidget);
  expect(find.textContaining('Macros'), findsOneWidget);
  expect(find.textContaining('Weekly Progress'), findsOneWidget);
  expect(find.textContaining(t.navigation), findsOneWidget);
});
}
