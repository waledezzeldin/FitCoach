import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/recommendations/recommendation_screen.dart';
import 'screens//coaching/video_call_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens//profile/profile_screen.dart';


void main() {
  runApp(FitCoachApp());
}

class FitCoachApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitCoach+',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      routes: {
        '/login': (_) => LoginScreen(),
        '/signup': (_) => SignupScreen(),
        '/dashboard': (_) => DashboardScreen(),
        '/recommendations': (c) => const RecommendationsScreen(),
        '/video': (_) => const VideoCallScreen(key: const ValueKey("testchannel"), coachId: "yourCoachId"),
        '/checkout': (_) => CheckoutScreen(),
        '/profile': (_) => ProfileScreen(),
      },
    );
  }
}
