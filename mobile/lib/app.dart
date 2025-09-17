import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/store/product_list_screen.dart';
import 'screens/store/cart_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/recommendations/recommendation_screen.dart';
import 'screens/coach/coach_onboarding_screen.dart';
import 'screens/progress/progress_screen.dart';
import 'screens/subscription/subscription_screen.dart';

class FitCoachApp extends StatelessWidget {
  const FitCoachApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitCoach+',
      initialRoute: '/',
      routes: {
        '/': (c) => LoginScreen(),
        '/dashboard': (c) => DashboardScreen(),
        '/store': (c) => const ProductListScreen(),
        '/cart': (c) => const CartScreen(),
        '/profile': (c) => ProfileScreen(),
        '/edit-profile': (c) => const EditProfileScreen(),
        '/chat': (c) => ChatScreen(
          channelId: 'global',
          userId: 'yourUserId', // Replace with actual user ID
          members: const [],    // Replace with actual members list
          token: 'yourToken',   // Replace with actual token
        ),
        '/recommendations': (c) => const RecommendationsScreen(),
        '/coach-onboarding': (c) => CoachOnboardingScreen(),
        '/progress': (c) => ProgressScreen(),
        '/subscription': (c) => SubscriptionScreen(),
      },
    );
  }
}
