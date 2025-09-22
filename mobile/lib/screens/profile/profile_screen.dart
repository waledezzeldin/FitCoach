import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final green = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.black,
        foregroundColor: green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: green,
                  child: Icon(Icons.person, size: 32, color: Colors.black),
                ),
                const SizedBox(width: 16),
                Text('Your Name', style: TextStyle(fontSize: 20, color: green)),
              ],
            ),
            const SizedBox(height: 32),
            Text('Email:', style: TextStyle(color: green)),
            Text('your.email@example.com', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 16),
            Text('Health Info:', style: TextStyle(color: green)),
            Text('Goals: Fat Loss', style: TextStyle(color: Colors.white)),
            Text('Allergies: None', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 16),
            Text('Addresses:', style: TextStyle(color: green)),
            Text('123 Main St, City', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 16),
            Text('Payment Methods:', style: TextStyle(color: green)),
            Text('Visa **** 1234', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Edit profile logic
              },
              child: const Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }
}