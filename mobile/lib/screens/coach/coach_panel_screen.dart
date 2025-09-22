import 'package:flutter/material.dart';

class CoachPanelScreen extends StatelessWidget {
  const CoachPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final green = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Coach Panel'),
        backgroundColor: Colors.black,
        foregroundColor: green,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            color: Colors.black,
            child: ListTile(
              leading: Icon(Icons.schedule, color: green),
              title: Text('My Schedule', style: TextStyle(color: green)),
              onTap: () {
                // Show coach schedule
              },
            ),
          ),
          Card(
            color: Colors.black,
            child: ListTile(
              leading: Icon(Icons.people, color: green),
              title: Text('Clients', style: TextStyle(color: green)),
              onTap: () {
                // Show coach clients
              },
            ),
          ),
          Card(
            color: Colors.black,
            child: ListTile(
              leading: Icon(Icons.attach_money, color: green),
              title: Text('Earnings', style: TextStyle(color: green)),
              onTap: () {
                // Show coach earnings
              },
            ),
          ),
        ],
      ),
    );
  }
}