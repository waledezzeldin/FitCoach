import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/recommendations/recommendation_screen.dart';
import 'screens//coaching/video_call_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens//profile/profile_screen.dart';
import 'screens/store/store_screen.dart';
import 'screens/subscriptions/subscription_screen.dart';
import 'screens/store/bundle_list_screen.dart';
import 'screens/splash/splash_screen.dart'; // Add this import for SplashScreen
import 'screens/intake/intake_screen.dart'; // Import IntakeScreen


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
 //final fcmToken = await FirebaseMessaging.instance.getToken();
  // Send fcmToken to backend and associate with userId
  runApp(const FitCoachApp());
}

class FitCoachApp extends StatelessWidget {
  const FitCoachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitCoach+',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.green[700],
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.dark(
          primary: Colors.green[700]!,
          secondary: Colors.greenAccent,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.green[700],
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
            foregroundColor: Colors.white,
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/login': (_) => LoginScreen(),
        '/signup': (_) => const SignupScreen(),
        '/dashboard': (_) => const DashboardScreen(),
        '/intake': (_) => IntakeScreen(),
        '/recommendations': (c) => const RecommendationsScreen(),
        '/video': (_) => const VideoCallScreen(key: const ValueKey("testchannel"), coachId: "yourCoachId"),
        '/checkout': (_) => CheckoutScreen(),
        '/profile': (_) => ProfileScreen(),
        '/store': (_) => StoreScreen(),
        '/subscriptions': (_) => SubscriptionScreen(),
        '/bundles': (_) => BundleListScreen(),
      },
    );
  }
}
