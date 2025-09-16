import 'package:flutter/material.dart';
// Update the import path below if the file exists elsewhere, for example:
import '../recommendations/recommendation_screen.dart';
// Or create the file at lib/screens/recommendations/recommendation_screen.dart if it does not exist.
import '../coaching/video_call_screen.dart';
import '../checkout_screen.dart';
import '../profile/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _index = 0;
  final _screens = [
    Center(child: Text("Home - Welcome to FitCoach+")),
    const RecommendationsScreen(),
    VideoCallScreen(key: const ValueKey("coaching123"), coachId: "yourCoachId"),
    CheckoutScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: "Recs"),
          BottomNavigationBarItem(icon: Icon(Icons.video_call), label: "Video"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Store"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

