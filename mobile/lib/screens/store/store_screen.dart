import 'package:flutter/material.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final green = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Store'),
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
              title: Text('Supplements', style: TextStyle(color: green)),
              subtitle: const Text('Browse all supplements', style: TextStyle(color: Colors.white)),
              onTap: () {
                // Navigate to supplements list
              },
            ),
          ),
          Card(
            color: Colors.black,
            child: ListTile(
              leading: Icon(Icons.category, color: green),
              title: Text('Categories', style: TextStyle(color: green)),
              subtitle: const Text('View by category', style: TextStyle(color: Colors.white)),
              onTap: () {
                // Navigate to categories list
              },
            ),
          ),
          Card(
            color: Colors.black,
            child: ListTile(
              leading: Icon(Icons.shopping_bag, color: green),
              title: Text('Bundles', style: TextStyle(color: green)),
              subtitle: const Text('Personalized supplement bundles', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pushNamed(context, '/bundles');
              },
            ),
          ),
          Card(
            color: Colors.black,
            child: ListTile(
              leading: Icon(Icons.receipt_long, color: green),
              title: Text('Orders', style: TextStyle(color: green)),
              subtitle: const Text('View your orders', style: TextStyle(color: Colors.white)),
              onTap: () {
                // Navigate to orders list
              },
            ),
          ),
        ],
      ),
    );
  }
}