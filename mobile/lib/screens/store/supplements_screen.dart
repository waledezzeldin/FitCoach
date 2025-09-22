import 'package:flutter/material.dart';

class SupplementsScreen extends StatelessWidget {
  const SupplementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final green = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Supplements'),
        backgroundColor: Colors.black,
        foregroundColor: green,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            color: Colors.black,
            child: ListTile(
              leading: Icon(Icons.local_offer, color: green),
              title: Text('Whey Protein', style: TextStyle(color: green)),
              subtitle: const Text('For muscle gain', style: TextStyle(color: Colors.white)),
              onTap: () {
                // Show supplement details
              },
            ),
          ),
          Card(
            color: Colors.black,
            child: ListTile(
              leading: Icon(Icons.local_offer, color: green),
              title: Text('Vitamin D', style: TextStyle(color: green)),
              subtitle: const Text('For wellness', style: TextStyle(color: Colors.white)),
              onTap: () {
                // Show supplement details
              },
            ),
          ),
        ],
      ),
    );
  }
}