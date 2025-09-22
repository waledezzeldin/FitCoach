import 'package:flutter/material.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final green = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: Colors.black,
        foregroundColor: green,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            color: Colors.black,
            child: ListTile(
              leading: Icon(Icons.verified_user, color: green),
              title: Text('Coach Approvals', style: TextStyle(color: green)),
              onTap: () {
                // Show coach approval requests
              },
            ),
          ),
          Card(
            color: Colors.black,
            child: ListTile(
              leading: Icon(Icons.inventory, color: green),
              title: Text('Catalog Management', style: TextStyle(color: green)),
              onTap: () {
                // Show catalog management
              },
            ),
          ),
          Card(
            color: Colors.black,
            child: ListTile(
              leading: Icon(Icons.analytics, color: green),
              title: Text('Analytics', style: TextStyle(color: green)),
              onTap: () {
                // Show analytics dashboard
              },
            ),
          ),
        ],
      ),
    );
  }
}