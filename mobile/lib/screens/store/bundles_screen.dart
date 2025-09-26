import 'package:flutter/material.dart';

class BundlesScreen extends StatelessWidget {
  const BundlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final green = Theme.of(context).colorScheme.primary;
    // TODO: Replace with actual bundles data from backend
    final bundles = [
      {
        'name': 'Muscle Gain Bundle',
        'description': 'Includes protein, creatine, and pre-workout.',
        'price': 59.99,
      },
      {
        'name': 'Wellness Bundle',
        'description': 'Includes multivitamins, omega-3, and probiotics.',
        'price': 39.99,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Bundles'),
        backgroundColor: Colors.black,
        foregroundColor: green,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: bundles.length,
        itemBuilder: (context, index) {
          final bundle = bundles[index];
          return Card(
            color: Colors.black,
            child: ListTile(
              leading: Icon(Icons.card_giftcard, color: green),
              title: Text(bundle['name'] as String, style: TextStyle(color: green)),
              subtitle: Text(bundle['description'] as String, style: const TextStyle(color: Colors.white)),
              trailing: Text('\$${bundle['price']}', style: TextStyle(color: green)),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/bundle_details',
                  arguments: bundle,
                );
              },
            ),
          );
        },
      ),
    );
  }
}