import 'package:flutter/material.dart';
import 'state/app_state.dart';
import 'navigation/app_navigator.dart';

import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/auth/phone_login_screen.dart';
import 'screens/auth/change_password_screen.dart';
import 'screens/intake/intake_flow.dart';
import 'screens/home/home_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/orders/order_details_screen.dart';
import 'screens/coach/coach_list_screen.dart';
import 'screens/coach/coach_reviews_screen.dart';
import 'screens/coach/coach_schedule_screen.dart';
import 'screens/coach/coach_session_screen.dart';
import 'screens/coach/booking_confirm_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/chat/chat_thread_screen.dart';
import 'screens/chat/assigned_chat_screen.dart';
import 'screens/chat/coach_conversations_screen.dart';
import 'screens/nutrition/nutrition_plan_screen.dart';
import 'screens/workout/workout_session_screen.dart';
import 'screens/workout/workout_history_screen.dart';
import 'screens/workout/workout_plan_screen.dart';
import 'screens/workout/workout_plan_details_screen.dart';
import 'screens/video/video_call_screen.dart';
import 'screens/store/supplements_store_screen.dart';
import 'screens/store/categories_screen.dart';
import 'screens/store/product_list_screen.dart';
import 'screens/store/product_details_screen.dart';
import 'screens/store/bundles_screen.dart';
import 'screens/store/bundle_details_screen.dart';
import 'screens/store/cart_screen.dart';
import 'screens/checkout/checkout_screen.dart';
import 'screens/coach/bookings_screen.dart';
import 'theme/app_theme.dart';

class FitCoachApp extends StatelessWidget {
  const FitCoachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      notifier: AppState(),
      child: MaterialApp(
        navigatorKey: appNavigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'FitCoach+',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.light,
        initialRoute: '/',
        routes: {
          '/': (c) => const SplashScreen(),
          '/home': (_) => const MainShell(), // unified shell with bottom nav
          '/dashboard': (_) => const MainShell(), // alias
          '/login': (c) => const LoginScreen(),
          '/signup': (c) => const SignupScreen(),
          '/register': (c) => const SignupScreen(),
          '/forgot_password': (c) => const ForgotPasswordScreen(),
          '/reset_password': (c) => const ResetPasswordScreen(),
          '/intake': (_) => const IntakeFlow(),
          '/orders': (c) => const OrdersScreen(),
          '/order_details': (c) => const OrderDetailsScreen(),
          '/edit_profile': (c) => const EditProfileScreen(),
          '/change_password': (c) => const ChangePasswordScreen(),
          '/coach_list': (c) => const CoachListScreen(),
          '/coach_reviews': (c) => const CoachReviewsScreen(),
          '/coach_schedule': (c) => const CoachScheduleScreen(),
          '/booking_confirm': (c) => const BookingConfirmScreen(),
          '/coach_session': (c) => const CoachSessionScreen(availableSessions: 1, usedSessions: 0),
          '/chat': (c) => const ChatScreen(),
          '/chat_thread': (c) {
            final args = ModalRoute.of(c)!.settings.arguments as Map<String, dynamic>?;
            if (args == null) return const AssignedChatScreen();
            return ChatThreadScreen(conversation: args);
          },
          '/coach_chats': (c) => const CoachConversationsScreen(),
          '/nutrition_plan': (c) {
            final s = AppStateScope.of(c);
            return NutritionPlanScreen(isFreemium: s.subscriptionType == 'freemium');
          },
          '/workout_session': (c) => const WorkoutSessionScreen(),
          '/workout_history': (c) => const WorkoutHistoryScreen(),
          '/video_calls': (c) => const VideoCallScreen(),
          '/store': (c) => const SupplementsStoreScreen(),
          '/categories': (c) => const CategoriesScreen(),
          '/products_list': (c) => const ProductListScreen(),
          '/product_details': (c) => const ProductDetailsScreen(),
          '/bundles': (c) => const BundlesScreen(),
          '/bundle_details': (c) => const BundleDetailsScreen(),
          '/cart': (c) => const CartScreen(),
          '/checkout': (c) => const CheckoutScreen(),
          '/workout_plan': (c) => const WorkoutPlanScreen(),
          '/workout_plan_details': (c) => const WorkoutPlanDetailsScreen(),
          '/phone_login': (c) => const PhoneLoginScreen(),
          '/bookings': (c) => const BookingsScreen(),
        },
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    final tabs = <Widget>[
      const HomeScreen(),
      // Workout tab (plan overview or session selector)
      const WorkoutPlanScreen(),
      NutritionPlanScreen(isFreemium: app.subscriptionType == 'freemium'),
      const CategoriesScreen(), // Store
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Workout',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Nutrition',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Store',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
