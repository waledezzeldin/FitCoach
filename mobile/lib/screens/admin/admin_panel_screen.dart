import 'package:flutter/material.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Example: Only show admin panel if user.role == 'admin'
    final user = {'role': 'admin'}; // This should come from your user management logic
    if (user['role'] != 'admin') {
      return const Center(child: Text('Access denied'));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Manage Users'),
            onTap: () {
              // TODO: Navigate to user management screen
            },
          ),
          ListTile(
            title: const Text('Manage Coaches'),
            onTap: () {
              // TODO: Navigate to coach management screen
            },
          ),
          ListTile(
            title: const Text('Manage Products'),
            onTap: () {
              // TODO: Navigate to product management screen
            },
          ),
          ListTile(
            title: const Text('View Analytics'),
            onTap: () {
              // TODO: Navigate to analytics dashboard
            },
          ),
        ],
      ),
    );
  }
}