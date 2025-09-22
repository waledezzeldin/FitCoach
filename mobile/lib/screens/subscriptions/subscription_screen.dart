import 'package:flutter/material.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final green = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Subscriptions'),
        backgroundColor: Colors.black,
        foregroundColor: green,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            color: Colors.black,
            child: ListTile(
              leading: Icon(Icons.subscriptions, color: green),
              title: Text('Monthly Coaching', style: TextStyle(color: green)),
              subtitle: const Text('Active - Renews every month', style: TextStyle(color: Colors.white)),
              trailing: ElevatedButton(
                onPressed: () {
                  // Pause or cancel subscription
                },
                child: const Text('Manage'),
              ),
            ),
          ),
          Card(
            color: Colors.black,
            child: ListTile(
              leading: Icon(Icons.subscriptions, color: green),
              title: Text('Supplement Bundle Subscription', style: TextStyle(color: green)),
              subtitle: const Text('Active - Renews every 30 days', style: TextStyle(color: Colors.white)),
              trailing: ElevatedButton(
                onPressed: () {
                  // Pause or cancel subscription
                },
                child: const Text('Manage'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}