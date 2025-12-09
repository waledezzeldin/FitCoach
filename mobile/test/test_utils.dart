import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fitcoach/theme/fitcoach_theme.dart';
import 'package:fitcoach/l10n/app_localizations.dart';
import 'package:fitcoach/screens/nutrition/nutrition_preferences_screen.dart';
import 'package:fitcoach/screens/home/home_screen.dart';
import 'package:fitcoach/app.dart';
import 'package:fitcoach/screens/intake/intake_state.dart';
import 'package:fitcoach/nutrition/nutrition_state.dart';
import 'package:fitcoach/auth/auth_state.dart';
import 'package:fitcoach/subscription/subscription_state.dart';
import 'package:fitcoach/coach/coach_state.dart';

extension PumpApp on WidgetTester {
  /// Pumps a MaterialApp with FitCoach theme, localization, and minimal providers
  /// so widgets depending on SubscriptionState/NutritionState/CoachState can build.
  Future<void> pumpThemed(
    Widget child, {
    Brightness brightness = Brightness.light,
    Locale locale = const Locale('en'),
    Map<String, WidgetBuilder>? routes,
  }) async {
    final theme = brightness == Brightness.light ? FitCoachTheme.light() : FitCoachTheme.dark();

    // Minimal provider tree matching app.dart
    final providers = [
      ChangeNotifierProvider(create: (_) => AppState()),
      ChangeNotifierProvider(create: (_) => IntakeState()),
      ChangeNotifierProvider(create: (_) => NutritionState()),
      ChangeNotifierProvider(create: (_) => AuthState()),
      ChangeNotifierProvider(create: (_) => SubscriptionState()..load()),
      ChangeNotifierProvider(create: (_) => CoachState()..load()),
    ];

    await pumpWidget(
      MultiProvider(
        providers: providers,
        child: MaterialApp(
          theme: theme,
          darkTheme: FitCoachTheme.dark(),
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          // Provide common named routes used in tests
          routes: {
            '/nutrition/preferences': (context) => const NutritionPreferencesScreen(),
            '/home': (context) => const HomeScreen(),
            if (routes != null) ...routes,
          },
          home: Scaffold(body: Center(child: child)),
        ),
      ),
    );
    await pump();
  }
}
