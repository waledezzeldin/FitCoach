import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FitCoach+ Dashboard')),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(child: Text('Welcome!')),
            ListTile(
              leading: Icon(Icons.store),
              title: Text('Store'),
              onTap: () => Navigator.pushNamed(context, '/store'),
            ),
            ListTile(
              leading: Icon(Icons.subscriptions),
              title: Text('Subscriptions'),
              onTap: () => Navigator.pushNamed(context, '/subscriptions'),
            ),
            ListTile(
              leading: Icon(Icons.fitness_center),
              title: Text('Coaching Bundles'),
              onTap: () => Navigator.pushNamed(context, '/bundles'),
            ),
            ListTile(
              leading: Icon(Icons.video_call),
              title: Text('Video Coaching'),
              onTap: () => Navigator.pushNamed(context, '/video'),
            ),
            ListTile(
              leading: Icon(Icons.recommend),
              title: Text('Recommendations'),
              onTap: () => Navigator.pushNamed(context, '/recommendations'),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () => Navigator.pushNamed(context, '/profile'),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () => Navigator.pushNamed(context, '/login'),
            ),
          ],
        ),
      ),
      body: Center(
        child: Text('Welcome to FitCoach+! Use the menu to navigate.'),
      ),
    );
  }
}

