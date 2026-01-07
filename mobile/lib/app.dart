import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/language_provider.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/language_selection_screen.dart';
import 'presentation/screens/onboarding_screen.dart';
import 'presentation/screens/auth/auth_screen.dart';
import 'presentation/screens/intake/first_intake_screen.dart';
import 'presentation/screens/intake/second_intake_screen.dart';
import 'presentation/screens/home/home_dashboard_screen.dart';
import 'presentation/screens/workout/workout_screen.dart';
import 'presentation/screens/nutrition/nutrition_screen.dart';
import 'presentation/screens/messaging/coach_messaging_screen.dart';
import 'presentation/screens/store/store_screen.dart';
import 'presentation/screens/account/account_screen.dart';
import 'presentation/screens/coach/coach_dashboard_screen.dart';
import 'presentation/screens/admin/admin_dashboard_screen.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool _showSplash = true;
  String _currentScreen = 'splash';

  @override
  void initState() {
    super.initState();
  }

  void _completeSplash() {
    final languageProvider = context.read<LanguageProvider>();
    final authProvider = context.read<AuthProvider>();

    setState(() {
      _showSplash = false;

      // Determine initial screen
      if (!languageProvider.hasSelectedLanguage) {
        _currentScreen = 'language';
      } else if (!authProvider.isAuthenticated) {
        _currentScreen = 'onboarding';
      } else {
        _currentScreen = _resolvePostAuthScreen(authProvider);
      }
    });
  }

  String _resolvePostAuthScreen(AuthProvider authProvider) {
    final role = authProvider.user?.role.toLowerCase();
    if (role == 'coach') {
      return 'coachDashboard';
    }
    if (role == 'admin') {
      return 'adminDashboard';
    }
    if (authProvider.user != null && !authProvider.user!.hasCompletedFirstIntake) {
      return 'firstIntake';
    }
    return 'home';
  }

  void _handlePostAuthNavigation() {
    final authProvider = context.read<AuthProvider>();
    _navigateToScreen(_resolvePostAuthScreen(authProvider));
  }

  void _navigateToScreen(String screen) {
    setState(() {
      _currentScreen = screen;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SplashScreen(onStart: _completeSplash);
    }

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Auto-navigate based on auth state
        if (!authProvider.isAuthenticated && 
            _currentScreen != 'language' && 
            _currentScreen != 'onboarding' && 
            _currentScreen != 'auth') {
          Future.microtask(() => _navigateToScreen('auth'));
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
            final slide = Tween<Offset>(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
            return FadeTransition(
              opacity: fade,
              child: SlideTransition(position: slide, child: child),
            );
          },
          child: KeyedSubtree(
            key: ValueKey<String>(_currentScreen),
            child: _buildCurrentScreen(),
          ),
        );
      },
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentScreen) {
      case 'language':
        return LanguageSelectionScreen(
          onLanguageSelected: () => _navigateToScreen('onboarding'),
        );
      
      case 'onboarding':
        return OnboardingScreen(
          onComplete: () => _navigateToScreen('auth'),
        );
      
      case 'auth':
        return AuthScreen(
          onAuthenticated: _handlePostAuthNavigation,
        );
      
      case 'firstIntake':
        return FirstIntakeScreen(
          onComplete: () => _navigateToScreen('home'),
          onSkip: () => _navigateToScreen('home'),
        );
      
      case 'secondIntake':
        return SecondIntakeScreen(
          onComplete: () => _navigateToScreen('home'),
        );
      
      case 'home':
        return const HomeDashboardScreen();
      
      case 'workout':
        return const WorkoutScreen();
      
      case 'nutrition':
        return const NutritionScreen();
      
      case 'coach':
        return const CoachMessagingScreen();
      
      case 'store':
        return const StoreScreen(
          // Replace 'onBack' with the correct parameter name or remove if not needed
          // For example, if the correct parameter is 'onClose':
          // onClose: () => _navigateToScreen('home'),
        );
      
      case 'account':
        return const AccountScreen();
      
      case 'coachDashboard':
        return const CoachDashboardScreen(
          // If CoachDashboardScreen has a parameter like 'onClose', use it instead:
          // onClose: () => _navigateToScreen('home'),
          // Otherwise, remove the parameter if not needed:
        );
      
      case 'adminDashboard':
        return const AdminDashboardScreen();
      
      default:
        return const HomeDashboardScreen();
    }
  }
}
