import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:go_router/go_router.dart'; // Duplicate import removed
import 'l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'workouts/session_models.dart';
import 'nutrition/nutrition_state.dart'; // Ensure NutritionState is imported
import 'subscription/subscription_state.dart'; // Ensure SubscriptionState is imported
import 'screens/intake/intake_state.dart'; // Ensure IntakeState is imported
// ...existing code...

import 'package:go_router/go_router.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/coach/coach_screen.dart';
import 'screens/onboarding/language_selection_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/intake/quick_start_step1.dart';
import 'screens/intake/quick_start_step2.dart';
import 'screens/intake/quick_start_step3.dart';
import 'screens/plan/starter_plan_screen.dart';
import 'screens/intake/second_intake_screen.dart';
import 'screens/intake/second_intake_step1.dart';
import 'screens/intake/second_intake_step2.dart';
import 'screens/intake/second_intake_step3.dart';
import 'screens/workouts/workouts_list_screen.dart';
import 'screens/workouts/workout_detail_screen.dart';
import 'screens/workouts/session_player_screen.dart';
import 'screens/workouts/session_complete_screen.dart';
import 'screens/nutrition/nutrition_plan_screen.dart';
import 'screens/nutrition/nutrition_preferences_screen.dart';
import 'screens/subscription/subscription_screen.dart';
import 'screens/store/store_list_screen.dart';

class FitCoachApp extends StatelessWidget {
  const FitCoachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => NutritionState()),
        ChangeNotifierProvider(create: (_) => SubscriptionState()),
        ChangeNotifierProvider(create: (_) => IntakeState()),
      ],
      child: Consumer<AppState>(
        builder: (context, appState, _) {
          final router = GoRouter(
            initialLocation: '/language',
            routes: [
              GoRoute(path: '/language', builder: (c, s) => LanguageSelectionScreen(
                onSelected: (_) => c.go('/onboarding'),
              )),
              GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingScreen()),
              GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
              GoRoute(path: '/signup', builder: (c, s) => const SignUpScreen()),
              GoRoute(path: '/quickstart/1', builder: (c, s) => const QuickStartStep1()),
              GoRoute(path: '/quickstart/2', builder: (c, s) => const QuickStartStep2()),
              GoRoute(path: '/quickstart/3', builder: (c, s) => const QuickStartStep3()),
              GoRoute(path: '/plan/starter', builder: (c, s) => const StarterPlanScreen()),
              GoRoute(path: '/intake/second', builder: (c, s) => const SecondIntakeScreen()),
              GoRoute(path: '/intake/second/1', builder: (c, s) => const SecondIntakeStep1()),
              GoRoute(path: '/intake/second/2', builder: (c, s) => const SecondIntakeStep2()),
              GoRoute(path: '/intake/second/3', builder: (c, s) => const SecondIntakeStep3()),
              GoRoute(path: '/workouts', builder: (c, s) => const WorkoutsListScreen()),
              GoRoute(
                path: '/workouts/:id',
                builder: (c, s) {
                  final id = s.pathParameters['id']!;
                  return WorkoutDetailScreen(id: id);
                },
              ),
              GoRoute(
                path: '/workouts/:id/session',
                builder: (c, s) {
                  final id = s.pathParameters['id']!;
                  return SessionPlayerScreen(id: id);
                },
              ),
              GoRoute(
                path: '/workouts/:id/session/complete',
                builder: (c, s) {
                  final id = s.pathParameters['id']!;
                  // Provide a dummy SessionResult to satisfy the argument type
                  return SessionCompleteScreen(
                    result: SessionResult(
                      workoutId: id,
                      elapsed: Duration.zero,
                      completedSteps: 0,
                      totalSteps: 0,
                    ),
                  );
                },
              ),
              GoRoute(path: '/home', builder: (c, s) => const HomeScreen()),
              GoRoute(path: '/coach', builder: (c, s) => const CoachScreen()),
              GoRoute(path: '/nutrition', builder: (c, s) => const NutritionPlanScreen()),
              GoRoute(path: '/nutrition/preferences', builder: (c, s) => const NutritionPreferencesScreen()),
              GoRoute(path: '/subscription', builder: (c, s) => const SubscriptionScreen()),
              GoRoute(path: '/store', builder: (c, s) => const StoreListScreen()),
            ],
          );
          return MaterialApp.router(
            title: 'FitCoach+',
            routerConfig: router,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              DefaultWidgetsLocalizations.delegate,
              DefaultMaterialLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('ar')],
            locale: appState.locale,
          );
        },
      ),
    );
  }
}

enum Screen { language, auth, home }

class AppState extends ChangeNotifier {
  Locale _locale = const Locale('en');
  bool _isDemo = false;
  final bool _loaded = false;

  Locale get locale => _locale;
  bool get isDemo => _isDemo;
  bool get isLoaded => _loaded;

  Future<void> setLocale(Locale l) async {
    _locale = l;
    final sp = await SharedPreferences.getInstance();
    await sp.setString('app.locale', l.languageCode);
    notifyListeners();
  }

  Future<void> setDemo(bool demo) async {
    _isDemo = demo;
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('app.demo', demo);
    notifyListeners();
  }
}

// Home private widgets are now consolidated in screens/home/home_widgets.dart


class WorkoutsScreen extends StatelessWidget {
  const WorkoutsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.workoutsTitle)),
      body: const Center(child: Text('Workouts List')), // keep workouts accessible and non-gated per plan
    );
  }
}

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Store')),
      body: const Center(child: Text('Store Screen')),
    );
  }
}
