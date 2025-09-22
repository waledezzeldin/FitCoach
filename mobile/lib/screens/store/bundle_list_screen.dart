import 'package:flutter/material.dart';

class BundleListScreen extends StatelessWidget {
  const BundleListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final green = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Bundles'),
        backgroundColor: Colors.black,
        foregroundColor: green,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            color: Colors.black,
            child: ListTile(
              leading: Icon(Icons.shopping_bag, color: green),
              title: Text('Starter Bundle', style: TextStyle(color: green)),
              subtitle: const Text('Recommended for beginners', style: TextStyle(color: Colors.white)),
              onTap: () {
                // Navigate to bundle details
              },
            ),
          ),
          Card(
            color: Colors.black,
            child: ListTile(
              leading: Icon(Icons.shopping_bag, color: green),
              title: Text('Muscle Gain Bundle', style: TextStyle(color: green)),
              subtitle: const Text('For muscle building goals', style: TextStyle(color: Colors.white)),
              onTap: () {
                // Navigate to bundle details
              },
            ),
          ),
          Card(
            color: Colors.black,
            child: ListTile(
              leading: Icon(Icons.shopping_bag, color: green),
              title: Text('Fat Loss Bundle', style: TextStyle(color: green)),
              subtitle: const Text('For fat loss goals', style: TextStyle(color: Colors.white)),
              onTap: () {
                // Navigate to bundle details
              },
            ),
          ),
        ],
      ),
    );
  }
}