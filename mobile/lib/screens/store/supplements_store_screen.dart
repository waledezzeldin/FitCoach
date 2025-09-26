import 'package:flutter/material.dart';

class SupplementsStoreScreen extends StatelessWidget {
  const SupplementsStoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final green = Theme.of(context).colorScheme.primary;
    // TODO: Replace with actual supplements data from backend
    final supplements = [
      {
        'name': 'Whey Protein',
        'description': 'High-quality protein for muscle recovery.',
        'price': 29.99,
      },
      {
        'name': 'Multivitamin',
        'description': 'Daily vitamins for overall health.',
        'price': 14.99,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Supplements Store'),
        backgroundColor: Colors.black,
        foregroundColor: green,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: supplements.length,
        itemBuilder: (context, index) {
          final supplement = supplements[index];
          return Card(
            color: Colors.black,
            child: ListTile(
              leading: Icon(Icons.local_offer, color: green),
              title: Text(supplement['name'] as String, style: TextStyle(color: green)),
              subtitle: Text(supplement['description'] as String, style: const TextStyle(color: Colors.white)),
              trailing: Text('\$${supplement['price']}', style: TextStyle(color: green)),
              onTap: () {
                // TODO: Navigate to supplement details or add to cart
              },
            ),
          );
        },
      ),
    );
  }
}