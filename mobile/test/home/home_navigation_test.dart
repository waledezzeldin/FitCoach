import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:fitcoach/app.dart';
import 'package:fitcoach/screens/nutrition/nutrition_plan_screen.dart';
import 'package:fitcoach/nutrition/nutrition_state.dart';
import 'package:fitcoach/theme/fitcoach_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fitcoach/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:fitcoach/subscription/subscription_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitcoach/screens/home/home_screen.dart';
import 'package:fitcoach/screens/coach/coach_screen.dart';

void main() {
  testWidgets('Tapping quick actions navigates to feature screens', (tester) async {
    SharedPreferences.setMockInitialValues({'subscription.tier': 'premium'});
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (c, s) => const HomeScreen()),
        GoRoute(path: '/workouts', builder: (c, s) => const WorkoutsScreen()),
        GoRoute(path: '/nutrition', builder: (c, s) => const NutritionPlanScreen()),
        GoRoute(path: '/coach', builder: (c, s) => const CoachScreen()),
        GoRoute(path: '/store', builder: (c, s) => const StoreScreen()),
      ],
    );

    await tester.binding.setSurfaceSize(const Size(390, 1200));
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SubscriptionState()..load()),
        ChangeNotifierProvider(create: (_) => NutritionState()..load()),
      ],
      child: MaterialApp.router(
      theme: FitCoachTheme.light(),
      darkTheme: FitCoachTheme.dark(),
      routerConfig: router,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      ),
    ));
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.text('Workouts'));
    for (int i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 125));
    }
    expect(find.byType(WorkoutsScreen), findsOneWidget);

    await tester.pageBack();
    for (int i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 125));
    }

    // Ensure subscription state has loaded premium tier before tapping Nutrition
    final homeCtx = tester.element(find.byType(HomeScreen));
    final sub = Provider.of<SubscriptionState>(homeCtx, listen: false);
    int guard = 0;
    while (sub.tier == SubscriptionTier.freemium && guard < 20) {
      await tester.pump(const Duration(milliseconds: 100));
      guard++;
    }

    await tester.tap(find.text('Nutrition'));
    for (int i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 125));
    }
    final navigated = find.byType(NutritionPlanScreen).evaluate().isNotEmpty ||
      find.textContaining('Nutrition Plan').evaluate().isNotEmpty;
    expect(navigated, isTrue);
  });
}
