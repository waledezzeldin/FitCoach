# Frontend Migration Guide
## عاش (FitCoach+) v2.0 - Complete Flutter Implementation

## Document Information
- **Document**: Flutter Frontend Migration Guide
- **Version**: 1.0.0
- **Last Updated**: December 21, 2024
- **Purpose**: Step-by-step Flutter app implementation
- **Audience**: Flutter Developers, Mobile Engineers

---

## Table of Contents

1. [Project Setup](#1-project-setup)
2. [Theme & Design System](#2-theme--design-system)
3. [State Management](#3-state-management)
4. [Navigation System](#4-navigation-system)
5. [API Integration](#5-api-integration)
6. [Bilingual Support (AR/EN)](#6-bilingual-support-aren)
7. [Offline Storage](#7-offline-storage)
8. [Real-time Features](#8-real-time-features)
9. [Screen Implementation](#9-screen-implementation)
10. [Testing Strategy](#10-testing-strategy)

---

## 1. Project Setup

### 1.1 Initialize Flutter Project

```bash
# Create new Flutter project
flutter create fitcoach_mobile \
  --org com.fitcoach \
  --platforms android,ios \
  --description "عاش - Comprehensive bilingual fitness coaching platform"

cd fitcoach_mobile

# Configure minimum versions
# ios/Podfile: platform :ios, '12.0'
# android/app/build.gradle: minSdkVersion 21
```

### 1.2 Project Structure

```
lib/
├── main.dart
├── app.dart
│
├── core/
│   ├── config/
│   │   ├── app_config.dart
│   │   ├── api_config.dart
│   │   └── theme_config.dart
│   ├── constants/
│   │   ├── app_constants.dart
│   │   ├── api_constants.dart
│   │   ├── colors.dart
│   │   └── text_styles.dart
│   ├── utils/
│   │   ├── validators.dart
│   │   ├── formatters.dart
│   │   ├── date_utils.dart
│   │   └── logger.dart
│   ├── network/
│   │   ├── dio_client.dart
│   │   ├── api_client.dart
│   │   ├── socket_client.dart
│   │   └── interceptors/
│   │       ├── auth_interceptor.dart
│   │       └── logging_interceptor.dart
│   └── errors/
│       ├── app_exception.dart
│       └── error_handler.dart
│
├── data/
│   ├── models/
│   │   ├── user/
│   │   │   ├── user_profile.dart
│   │   │   ├── subscription.dart
│   │   │   └── quota.dart
│   │   ├── workout/
│   │   │   ├── workout_plan.dart
│   │   │   ├── exercise.dart
│   │   │   ├── exercise_set.dart
│   │   │   └── workout_session.dart
│   │   ├── nutrition/
│   │   │   ├── nutrition_plan.dart
│   │   │   ├── meal.dart
│   │   │   └── food_item.dart
│   │   ├── messaging/
│   │   │   ├── message.dart
│   │   │   ├── conversation.dart
│   │   │   └── attachment.dart
│   │   ├── store/
│   │   │   ├── product.dart
│   │   │   ├── order.dart
│   │   │   └── cart_item.dart
│   │   └── common/
│   │       ├── api_response.dart
│   │       └── paginated_response.dart
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   ├── user_repository.dart
│   │   ├── workout_repository.dart
│   │   ├── nutrition_repository.dart
│   │   ├── messaging_repository.dart
│   │   ├── store_repository.dart
│   │   └── coach_repository.dart
│   ├── local/
│   │   ├── hive_service.dart
│   │   ├── secure_storage_service.dart
│   │   └── cache_service.dart
│   └── remote/
│       ├── auth_api_service.dart
│       ├── user_api_service.dart
│       ├── workout_api_service.dart
│       ├── nutrition_api_service.dart
│       ├── messaging_api_service.dart
│       └── store_api_service.dart
│
├── presentation/
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── splash_screen.dart
│   │   │   ├── language_selection_screen.dart
│   │   │   ├── onboarding_screen.dart
│   │   │   └── otp_auth_screen.dart
│   │   ├── intake/
│   │   │   ├── first_intake_screen.dart
│   │   │   └── second_intake_screen.dart
│   │   ├── home/
│   │   │   └── home_dashboard_screen.dart
│   │   ├── workout/
│   │   │   ├── workout_screen.dart
│   │   │   ├── exercise_detail_screen.dart
│   │   │   └── workout_welcome_screen.dart
│   │   ├── nutrition/
│   │   │   ├── nutrition_screen.dart
│   │   │   ├── meal_detail_screen.dart
│   │   │   └── nutrition_welcome_screen.dart
│   │   ├── messaging/
│   │   │   ├── coach_messaging_screen.dart
│   │   │   └── message_detail_screen.dart
│   │   ├── store/
│   │   │   ├── store_screen.dart
│   │   │   ├── product_detail_screen.dart
│   │   │   └── store_welcome_screen.dart
│   │   ├── account/
│   │   │   ├── account_screen.dart
│   │   │   ├── profile_edit_screen.dart
│   │   │   └── subscription_screen.dart
│   │   ├── coach/
│   │   │   ├── coach_dashboard.dart
│   │   │   ├── coach_calendar_screen.dart
│   │   │   ├── coach_client_list.dart
│   │   │   ├── workout_plan_builder.dart
│   │   │   ├── nutrition_plan_builder.dart
│   │   │   └── coach_earnings_screen.dart
│   │   └── admin/
│   │       ├── admin_dashboard.dart
│   │       ├── user_management_screen.dart
│   │       ├── coach_management_screen.dart
│   │       ├── content_management_screen.dart
│   │       ├── store_management_screen.dart
│   │       ├── subscription_management_screen.dart
│   │       ├── system_settings_screen.dart
│   │       └── analytics_dashboard.dart
│   ├── widgets/
│   │   ├── common/
│   │   │   ├── custom_button.dart
│   │   │   ├── custom_text_field.dart
│   │   │   ├── custom_app_bar.dart
│   │   │   ├── loading_indicator.dart
│   │   │   ├── error_widget.dart
│   │   │   ├── empty_state_widget.dart
│   │   │   └── quota_indicator.dart
│   │   ├── workout/
│   │   │   ├── exercise_card.dart
│   │   │   ├── workout_day_card.dart
│   │   │   ├── rest_timer.dart
│   │   │   └── injury_substitution_dialog.dart
│   │   ├── nutrition/
│   │   │   ├── meal_card.dart
│   │   │   ├── macro_chart.dart
│   │   │   └── nutrition_expiry_banner.dart
│   │   ├── messaging/
│   │   │   ├── message_bubble.dart
│   │   │   ├── typing_indicator.dart
│   │   │   └── attachment_preview.dart
│   │   └── charts/
│   │       ├── progress_chart.dart
│   │       ├── weight_chart.dart
│   │       └── workout_frequency_chart.dart
│   └── providers/
│       ├── auth_provider.dart
│       ├── user_provider.dart
│       ├── workout_provider.dart
│       ├── nutrition_provider.dart
│       ├── messaging_provider.dart
│       ├── quota_provider.dart
│       ├── theme_provider.dart
│       └── language_provider.dart
│
├── l10n/
│   ├── app_en.arb
│   ├── app_ar.arb
│   └── l10n.dart
│
├── routes/
│   ├── app_router.dart
│   └── route_guards.dart
│
└── generated/
    └── l10n/
```

### 1.3 Dependencies (pubspec.yaml)

```yaml
name: fitcoach_mobile
description: عاش - Comprehensive bilingual fitness coaching platform
version: 2.0.0+1

environment:
  sdk: '>=3.2.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # State Management
  provider: ^6.1.1
  flutter_riverpod: ^2.4.9
  flutter_bloc: ^8.1.3

  # Navigation
  go_router: ^13.0.0

  # Networking
  dio: ^5.4.0
  retrofit: ^4.0.3
  retrofit_generator: ^8.0.4
  socket_io_client: ^2.0.3

  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  flutter_secure_storage: ^9.0.0
  shared_preferences: ^2.2.2

  # UI Components
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0
  lottie: ^2.7.0
  flutter_animate: ^4.3.0

  # Forms
  flutter_form_builder: ^9.1.1
  form_builder_validators: ^9.1.0

  # Internationalization
  intl: ^0.18.1
  easy_localization: ^3.0.4

  # Utilities
  url_launcher: ^6.2.2
  permission_handler: ^11.1.0
  image_picker: ^1.0.5
  file_picker: ^6.1.1
  path_provider: ^2.1.1
  share_plus: ^7.2.1

  # Firebase
  firebase_core: ^2.24.2
  firebase_analytics: ^10.8.0
  firebase_crashlytics: ^3.4.9
  firebase_messaging: ^14.7.10

  # Charts
  fl_chart: ^0.66.0
  syncfusion_flutter_charts: ^24.1.41

  # Time/Date
  intl: ^0.18.1
  timeago: ^3.6.0

  # Media
  video_player: ^2.8.2
  chewie: ^1.7.4

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  mockito: ^5.4.4
  build_runner: ^2.4.7
  json_serializable: ^6.7.1
  hive_generator: ^2.0.1
  bloc_test: ^9.1.5
  integration_test:
    sdk: flutter

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/icons/
    - assets/animations/
    - assets/fonts/
  
  fonts:
    - family: Cairo
      fonts:
        - asset: assets/fonts/Cairo-Regular.ttf
        - asset: assets/fonts/Cairo-Bold.ttf
          weight: 700
```

---

## 2. Theme & Design System

### 2.1 Color System

```dart
// core/constants/colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors (from logo)
  static const Color primary = Color(0xFF3B82F6);      // Blue
  static const Color primaryDark = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF60A5FA);
  
  // Secondary Colors (from logo)
  static const Color secondary = Color(0xFF7C5FDC);    // Purple
  static const Color secondaryLight = Color(0xFFE9D5FF);
  
  // Accent Colors (from logo)
  static const Color accent = Color(0xFFF59E0B);       // Orange
  static const Color accentLight = Color(0xFFFBBF24);
  
  // Neutral Colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF1F2937);
  static const Color surface = Color(0xFFF3F4F6);
  static const Color surfaceDark = Color(0xFF374151);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFF9CA3AF);
  static const Color textWhite = Color(0xFFFFFFFF);
  
  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Border & Divider
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFD1D5DB);
  
  // Chart Colors
  static const Color chart1 = Color(0xFF3B82F6);       // Blue
  static const Color chart2 = Color(0xFF7C5FDC);       // Purple
  static const Color chart3 = Color(0xFFF59E0B);       // Orange
  static const Color chart4 = Color(0xFF10B981);       // Green
  static const Color chart5 = Color(0xFFEC4899);       // Pink
}
```

### 2.2 Typography System

```dart
// core/constants/text_styles.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // Font Families
  static const String fontFamilyEn = 'Inter';
  static const String fontFamilyAr = 'Cairo';
  
  // Headings
  static TextStyle h1(BuildContext context) => TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    fontFamily: _getFontFamily(context),
    height: 1.2,
  );
  
  static TextStyle h2(BuildContext context) => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    fontFamily: _getFontFamily(context),
    height: 1.3,
  );
  
  static TextStyle h3(BuildContext context) => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFamily: _getFontFamily(context),
    height: 1.4,
  );
  
  static TextStyle h4(BuildContext context) => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFamily: _getFontFamily(context),
    height: 1.4,
  );
  
  // Body Text
  static TextStyle bodyLarge(BuildContext context) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    fontFamily: _getFontFamily(context),
    height: 1.5,
  );
  
  static TextStyle bodyMedium(BuildContext context) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    fontFamily: _getFontFamily(context),
    height: 1.5,
  );
  
  static TextStyle bodySmall(BuildContext context) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    fontFamily: _getFontFamily(context),
    height: 1.5,
  );
  
  // Button Text
  static TextStyle button(BuildContext context) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
    fontFamily: _getFontFamily(context),
    letterSpacing: 0.5,
  );
  
  // Helper to get font family based on locale
  static String _getFontFamily(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar' ? fontFamilyAr : fontFamilyEn;
  }
}
```

### 2.3 Theme Configuration

```dart
// core/config/theme_config.dart
import 'package:flutter/material.dart';
import '../constants/colors.dart';

class AppTheme {
  static ThemeData lightTheme(Locale locale) {
    final isArabic = locale.languageCode == 'ar';
    
    return ThemeData(
      useMaterial3: true,
      
      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.accent,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
      ),
      
      // Typography
      fontFamily: isArabic ? 'Cairo' : 'Inter',
      textTheme: TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
      ),
      
      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      
      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
      
      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      
      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      
      // Card
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
  
  static ThemeData darkTheme(Locale locale) {
    final isArabic = locale.languageCode == 'ar';
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryLight,
        secondary: AppColors.secondary,
        tertiary: AppColors.accent,
        surface: AppColors.surfaceDark,
        background: AppColors.backgroundDark,
        error: AppColors.error,
      ),
      
      fontFamily: isArabic ? 'Cairo' : 'Inter',
      
      // Similar theme configuration for dark mode
    );
  }
}
```

---

## 3. State Management

### 3.1 Provider Setup (Simple State)

```dart
// presentation/providers/auth_provider.dart
import 'package:flutter/material.dart';
import '../../data/models/user/user_profile.dart';
import '../../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  
  bool _isAuthenticated = false;
  bool _isLoading = false;
  UserProfile? _user;
  String? _error;
  
  AuthProvider(this._authRepository) {
    _checkAuthStatus();
  }
  
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  UserProfile? get user => _user;
  String? get error => _error;
  
  Future<void> _checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final token = await _authRepository.getStoredToken();
      if (token != null) {
        _user = await _authRepository.getUserProfile();
        _isAuthenticated = true;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> requestOTP(String phoneNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _authRepository.requestOTP(phoneNumber);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> verifyOTP(String phoneNumber, String otp) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final authResponse = await _authRepository.verifyOTP(phoneNumber, otp);
      _user = authResponse.user;
      _isAuthenticated = true;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> logout() async {
    await _authRepository.logout();
    _isAuthenticated = false;
    _user = null;
    notifyListeners();
  }
}
```

### 3.2 Riverpod Setup (Complex State with Caching)

```dart
// presentation/providers/workout_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/workout/workout_plan.dart';
import '../../data/repositories/workout_repository.dart';

// Repository Provider
final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return WorkoutRepository();
});

// Workout Plan Provider (with auto-caching)
final workoutPlanProvider = FutureProvider.autoDispose<WorkoutPlan?>((ref) async {
  final repository = ref.watch(workoutRepositoryProvider);
  return repository.getWorkoutPlan();
});

// Workout Plan State Provider (for mutations)
class WorkoutPlanNotifier extends StateNotifier<AsyncValue<WorkoutPlan?>> {
  final WorkoutRepository _repository;
  
  WorkoutPlanNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadWorkoutPlan();
  }
  
  Future<void> loadWorkoutPlan() async {
    state = const AsyncValue.loading();
    try {
      final plan = await _repository.getWorkoutPlan();
      state = AsyncValue.data(plan);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> completeExercise(String exerciseId) async {
    try {
      await _repository.completeExercise(exerciseId);
      await loadWorkoutPlan(); // Reload after completion
    } catch (error) {
      // Handle error
    }
  }
  
  Future<void> substituteExercise(String exerciseId) async {
    try {
      final substitute = await _repository.getExerciseSubstitute(exerciseId);
      // Update state with substituted exercise
      await loadWorkoutPlan();
    } catch (error) {
      // Handle error
    }
  }
}

final workoutPlanNotifierProvider = 
    StateNotifierProvider<WorkoutPlanNotifier, AsyncValue<WorkoutPlan?>>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  return WorkoutPlanNotifier(repository);
});
```

### 3.3 Quota Provider (Real-time Updates)

```dart
// presentation/providers/quota_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user/quota.dart';
import '../../data/repositories/user_repository.dart';

class QuotaNotifier extends StateNotifier<Quota> {
  final UserRepository _repository;
  
  QuotaNotifier(this._repository) : super(Quota.empty()) {
    loadQuota();
  }
  
  Future<void> loadQuota() async {
    try {
      final quota = await _repository.getQuota();
      state = quota;
    } catch (error) {
      // Handle error
    }
  }
  
  void updateMessageQuota(int used) {
    state = state.copyWith(messagesUsed: used);
  }
  
  void updateVideoCallQuota(int used) {
    state = state.copyWith(videoCallsUsed: used);
  }
  
  bool canSendMessage() {
    return state.messagesRemaining > 0 || state.tier == 'Smart Premium';
  }
  
  bool canBookVideoCall() {
    return state.videoCallsRemaining > 0;
  }
  
  bool shouldShowWarning() {
    final usagePercent = state.messagesUsed / state.messagesLimit;
    return usagePercent >= 0.8; // Warning at 80%
  }
}

final quotaProvider = StateNotifierProvider<QuotaNotifier, Quota>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return QuotaNotifier(repository);
});
```

---

## 4. Navigation System

### 4.1 GoRouter Configuration

```dart
// routes/app_router.dart
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../presentation/screens/auth/splash_screen.dart';
import '../presentation/screens/auth/language_selection_screen.dart';
import '../presentation/screens/auth/onboarding_screen.dart';
import '../presentation/screens/auth/otp_auth_screen.dart';
import '../presentation/providers/auth_provider.dart';

class AppRouter {
  final AuthProvider authProvider;
  
  AppRouter(this.authProvider);
  
  late final GoRouter router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: authProvider, // Rebuild routes on auth changes
    redirect: _handleRedirect,
    routes: [
      // Auth Routes
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/language',
        name: 'language',
        builder: (context, state) => const LanguageSelectionScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const OTPAuthScreen(),
      ),
      
      // Intake Routes
      GoRoute(
        path: '/intake/first',
        name: 'firstIntake',
        builder: (context, state) => const FirstIntakeScreen(),
      ),
      GoRoute(
        path: '/intake/second',
        name: 'secondIntake',
        builder: (context, state) => const SecondIntakeScreen(),
      ),
      
      // Main App Routes (Authenticated)
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeDashboardScreen(),
      ),
      GoRoute(
        path: '/workout',
        name: 'workout',
        builder: (context, state) => const WorkoutScreen(),
        routes: [
          GoRoute(
            path: 'exercise/:id',
            name: 'exerciseDetail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ExerciseDetailScreen(exerciseId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/nutrition',
        name: 'nutrition',
        builder: (context, state) => const NutritionScreen(),
      ),
      GoRoute(
        path: '/coach',
        name: 'coach',
        builder: (context, state) => const CoachMessagingScreen(),
      ),
      GoRoute(
        path: '/store',
        name: 'store',
        builder: (context, state) => const StoreScreen(),
        routes: [
          GoRoute(
            path: 'product/:id',
            name: 'productDetail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ProductDetailScreen(productId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/account',
        name: 'account',
        builder: (context, state) => const AccountScreen(),
      ),
      
      // Coach Routes
      GoRoute(
        path: '/coach-dashboard',
        name: 'coachDashboard',
        builder: (context, state) => const CoachDashboard(),
      ),
      
      // Admin Routes
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminDashboard(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
  
  String? _handleRedirect(BuildContext context, GoRouterState state) {
    final isAuthenticated = authProvider.isAuthenticated;
    final user = authProvider.user;
    
    final isSplash = state.matchedLocation == '/splash';
    final isLanguage = state.matchedLocation == '/language';
    final isOnboarding = state.matchedLocation == '/onboarding';
    final isAuth = state.matchedLocation == '/auth';
    final isIntake = state.matchedLocation.startsWith('/intake');
    
    // Allow splash, language, onboarding, and auth screens always
    if (isSplash || isLanguage || isOnboarding || isAuth) {
      return null;
    }
    
    // Redirect to auth if not authenticated
    if (!isAuthenticated) {
      return '/auth';
    }
    
    // Redirect to intake if not completed
    if (user != null && !user.hasCompletedFirstIntake && !isIntake) {
      return '/intake/first';
    }
    
    // Allow navigation
    return null;
  }
}
```

---

## 5. API Integration

### 5.1 Dio Client Setup

```dart
// core/network/dio_client.dart
import 'package:dio/dio.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import '../config/api_config.dart';

class DioClient {
  late final Dio _dio;
  
  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    
    // Add interceptors
    _dio.interceptors.addAll([
      AuthInterceptor(),
      LoggingInterceptor(),
    ]);
  }
  
  Dio get dio => _dio;
  
  // GET Request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // POST Request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // PUT Request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // DELETE Request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException();
      case DioExceptionType.badResponse:
        return ServerException(
          statusCode: error.response?.statusCode ?? 500,
          message: error.response?.data['message'] ?? 'Server error',
        );
      case DioExceptionType.cancel:
        return CancelledException();
      default:
        return NetworkException();
    }
  }
}
```

### 5.2 Auth Interceptor

```dart
// core/network/interceptors/auth_interceptor.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final _storage = const FlutterSecureStorage();
  
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Get token from secure storage
    final token = await _storage.read(key: 'auth_token');
    
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    handler.next(options);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized - token expired
    if (err.response?.statusCode == 401) {
      // Try to refresh token
      final refreshed = await _refreshToken();
      
      if (refreshed) {
        // Retry the request
        final response = await _retry(err.requestOptions);
        handler.resolve(response);
        return;
      }
    }
    
    handler.next(err);
  }
  
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) return false;
      
      final dio = Dio();
      final response = await dio.post(
        '${ApiConfig.baseUrl}/auth/refresh-token',
        data: {'refreshToken': refreshToken},
      );
      
      final newToken = response.data['token'];
      await _storage.write(key: 'auth_token', value: newToken);
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<Response> _retry(RequestOptions requestOptions) async {
    final dio = Dio();
    final token = await _storage.read(key: 'auth_token');
    
    requestOptions.headers['Authorization'] = 'Bearer $token';
    
    return dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: Options(
        method: requestOptions.method,
        headers: requestOptions.headers,
      ),
    );
  }
}
```

### 5.3 API Service Example

```dart
// data/remote/auth_api_service.dart
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import '../models/user/user_profile.dart';

part 'auth_api_service.g.dart'; // Generated file

@RestApi()
abstract class AuthApiService {
  factory AuthApiService(Dio dio, {String baseUrl}) = _AuthApiService;
  
  @POST('/auth/request-otp')
  Future<ApiResponse> requestOTP(@Body() Map<String, String> body);
  
  @POST('/auth/verify-otp')
  Future<AuthResponse> verifyOTP(@Body() Map<String, String> body);
  
  @POST('/auth/refresh-token')
  Future<TokenResponse> refreshToken(@Body() Map<String, String> body);
  
  @POST('/auth/logout')
  Future<void> logout();
}

// Response Models
class ApiResponse {
  final bool success;
  final String message;
  
  ApiResponse({required this.success, required this.message});
  
  factory ApiResponse.fromJson(Map<String, dynamic> json) => ApiResponse(
    success: json['success'],
    message: json['message'],
  );
}

class AuthResponse {
  final String token;
  final String refreshToken;
  final UserProfile user;
  
  AuthResponse({
    required this.token,
    required this.refreshToken,
    required this.user,
  });
  
  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    token: json['token'],
    refreshToken: json['refreshToken'],
    user: UserProfile.fromJson(json['user']),
  );
}

class TokenResponse {
  final String token;
  
  TokenResponse({required this.token});
  
  factory TokenResponse.fromJson(Map<String, dynamic> json) => TokenResponse(
    token: json['token'],
  );
}
```

---

## 6. Bilingual Support (AR/EN)

### 6.1 Localization Setup

```dart
// l10n/app_en.arb
{
  "@@locale": "en",
  
  "appName": "FitCoach+",
  "welcome": "Welcome to FitCoach+",
  
  "languageSelection": "Select your language",
  "english": "English",
  "arabic": "Arabic",
  
  "auth": {
    "enterPhone": "Enter your phone number",
    "phoneHint": "+966 5X XXX XXXX",
    "sendOTP": "Send OTP",
    "enterOTP": "Enter verification code",
    "otpHint": "6-digit code",
    "verifyOTP": "Verify",
    "resendOTP": "Resend code",
    "otpSent": "Verification code sent!"
  },
  
  "intake": {
    "welcome": "Let's get to know you",
    "gender": "Gender",
    "male": "Male",
    "female": "Female",
    "goal": "What's your main goal?",
    "fatLoss": "Fat Loss",
    "muscleGain": "Muscle Gain",
    "generalFitness": "General Fitness",
    "location": "Where do you work out?",
    "home": "Home",
    "gym": "Gym",
    "continue": "Continue",
    "skip": "Skip for now"
  },
  
  "home": {
    "greeting": "Hello, {name}",
    "@greeting": {
      "placeholders": {
        "name": {
          "type": "String"
        }
      }
    },
    "todaysWorkout": "Today's Workout",
    "nutritionPlan": "Nutrition Plan",
    "messageCoach": "Message Coach",
    "shop": "Shop"
  },
  
  "workout": {
    "title": "Workout",
    "noPlan": "No workout plan yet",
    "askCoach": "Ask your coach for a plan",
    "startWorkout": "Start Workout",
    "completeSet": "Complete Set",
    "restTimer": "Rest: {seconds}s",
    "@restTimer": {
      "placeholders": {
        "seconds": {
          "type": "int"
        }
      }
    },
    "substituteExercise": "Substitute Exercise",
    "reasonInjury": "Due to {injury} injury",
    "@reasonInjury": {
      "placeholders": {
        "injury": {
          "type": "String"
        }
      }
    }
  },
  
  "nutrition": {
    "title": "Nutrition",
    "noPlan": "No nutrition plan yet",
    "trialExpiring": "Trial expires in {days} days",
    "@trialExpiring": {
      "placeholders": {
        "days": {
          "type": "int"
        }
      }
    },
    "trialExpired": "Trial expired",
    "upgradePrompt": "Upgrade to Premium for unlimited access",
    "macros": "Macros",
    "protein": "Protein",
    "carbs": "Carbs",
    "fats": "Fats",
    "calories": "Calories"
  },
  
  "messaging": {
    "title": "Coach",
    "typeMessage": "Type a message...",
    "send": "Send",
    "attachment": "Attachment",
    "quotaWarning": "{remaining} messages remaining this month",
    "@quotaWarning": {
      "placeholders": {
        "remaining": {
          "type": "int"
        }
      }
    },
    "quotaExceeded": "Message quota exceeded",
    "upgradeForMore": "Upgrade for more messages"
  },
  
  "store": {
    "title": "Store",
    "categories": "Categories",
    "featured": "Featured Products",
    "addToCart": "Add to Cart",
    "buyNow": "Buy Now",
    "cart": "Cart",
    "checkout": "Checkout"
  },
  
  "account": {
    "title": "Account",
    "profile": "Profile",
    "subscription": "Subscription",
    "currentPlan": "{tier} Plan",
    "@currentPlan": {
      "placeholders": {
        "tier": {
          "type": "String"
        }
      }
    },
    "upgrade": "Upgrade",
    "settings": "Settings",
    "language": "Language",
    "theme": "Theme",
    "notifications": "Notifications",
    "logout": "Logout"
  },
  
  "common": {
    "save": "Save",
    "cancel": "Cancel",
    "delete": "Delete",
    "edit": "Edit",
    "loading": "Loading...",
    "error": "An error occurred",
    "retry": "Retry",
    "success": "Success!",
    "confirm": "Confirm"
  }
}
```

```dart
// l10n/app_ar.arb
{
  "@@locale": "ar",
  
  "appName": "عاش",
  "welcome": "مرحباً بك في عاش",
  
  "languageSelection": "اختر لغتك",
  "english": "English",
  "arabic": "العربية",
  
  "auth": {
    "enterPhone": "أدخل رقم هاتفك",
    "phoneHint": "+966 5X XXX XXXX",
    "sendOTP": "إرسال رمز التحقق",
    "enterOTP": "أدخل رمز التحقق",
    "otpHint": "رمز مكون من 6 أرقام",
    "verifyOTP": "تحقق",
    "resendOTP": "إعادة إرسال الرمز",
    "otpSent": "تم إرسال رمز التحقق!"
  },
  
  "intake": {
    "welcome": "دعنا نتعرف عليك",
    "gender": "الجنس",
    "male": "ذكر",
    "female": "أنثى",
    "goal": "ما هو هدفك الرئيسي؟",
    "fatLoss": "فقدان الدهون",
    "muscleGain": "بناء العضلات",
    "generalFitness": "لياقة عامة",
    "location": "أين تتمرن؟",
    "home": "المنزل",
    "gym": "الجيم",
    "continue": "متابعة",
    "skip": "تخطي الآن"
  },
  
  "home": {
    "greeting": "مرحباً، {name}",
    "@greeting": {
      "placeholders": {
        "name": {
          "type": "String"
        }
      }
    },
    "todaysWorkout": "تمرين اليوم",
    "nutritionPlan": "خطة التغذية",
    "messageCoach": "راسل المدرب",
    "shop": "المتجر"
  },
  
  "workout": {
    "title": "التمرين",
    "noPlan": "لا توجد خطة تمرين بعد",
    "askCoach": "اطلب خطة من مدربك",
    "startWorkout": "ابدأ التمرين",
    "completeSet": "إكمال المجموعة",
    "restTimer": "راحة: {seconds} ث",
    "@restTimer": {
      "placeholders": {
        "seconds": {
          "type": "int"
        }
      }
    },
    "substituteExercise": "استبدال التمرين",
    "reasonInjury": "بسبب إصابة {injury}",
    "@reasonInjury": {
      "placeholders": {
        "injury": {
          "type": "String"
        }
      }
    }
  },
  
  "nutrition": {
    "title": "التغذية",
    "noPlan": "لا توجد خطة تغذية بعد",
    "trialExpiring": "تنتهي التجربة خلال {days} أيام",
    "@trialExpiring": {
      "placeholders": {
        "days": {
          "type": "int"
        }
      }
    },
    "trialExpired": "انتهت فترة التجربة",
    "upgradePrompt": "قم بالترقية إلى Premium للوصول غير المحدود",
    "macros": "العناصر الغذائية",
    "protein": "البروتين",
    "carbs": "الكربوهيدرات",
    "fats": "الدهون",
    "calories": "السعرات الحرارية"
  },
  
  "messaging": {
    "title": "المدرب",
    "typeMessage": "اكتب رسالة...",
    "send": "إرسال",
    "attachment": "مرفق",
    "quotaWarning": "{remaining} رسالة متبقية هذا الشهر",
    "@quotaWarning": {
      "placeholders": {
        "remaining": {
          "type": "int"
        }
      }
    },
    "quotaExceeded": "تم تجاوز حصة الرسائل",
    "upgradeForMore": "قم بالترقية للمزيد من الرسائل"
  },
  
  "store": {
    "title": "المتجر",
    "categories": "الفئات",
    "featured": "منتجات مميزة",
    "addToCart": "أضف إلى السلة",
    "buyNow": "اشتر الآن",
    "cart": "السلة",
    "checkout": "الدفع"
  },
  
  "account": {
    "title": "الحساب",
    "profile": "الملف الشخصي",
    "subscription": "الاشتراك",
    "currentPlan": "خطة {tier}",
    "@currentPlan": {
      "placeholders": {
        "tier": {
          "type": "String"
        }
      }
    },
    "upgrade": "ترقية",
    "settings": "الإعدادات",
    "language": "اللغة",
    "theme": "المظهر",
    "notifications": "الإشعارات",
    "logout": "تسجيل الخروج"
  },
  
  "common": {
    "save": "حفظ",
    "cancel": "إلغاء",
    "delete": "حذف",
    "edit": "تعديل",
    "loading": "جاري التحميل...",
    "error": "حدث خطأ",
    "retry": "إعادة المحاولة",
    "success": "نجح!",
    "confirm": "تأكيد"
  }
}
```

### 6.2 RTL Support

```dart
// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        ...context.localizationDelegates,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      
      // RTL Support
      builder: (context, child) {
        final locale = context.locale;
        final isRTL = locale.languageCode == 'ar';
        
        return Directionality(
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },
      
      theme: AppTheme.lightTheme(context.locale),
      darkTheme: AppTheme.darkTheme(context.locale),
      
      home: const SplashScreen(),
    );
  }
}
```

---

This document continues with sections 7-10 covering Offline Storage, Real-time Features, Screen Implementation, and Testing Strategy. Due to character limits, I'll create the next document.

**Document Version**: 1.0.0  
**Last Updated**: December 21, 2024
