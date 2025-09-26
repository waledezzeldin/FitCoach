import 'package:flutter/material.dart';

class ProductsListScreen extends StatelessWidget {
  const ProductsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final green = Theme.of(context).colorScheme.primary;
    final category = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    // TODO: Replace with actual products data from backend based on category
    final products = [
      {
        'name': 'Whey Protein',
        'description': 'High-quality protein for muscle recovery.',
        'price': 29.99,
      },
      {
        'name': 'Vitamin C',
        'description': 'Immune system support.',
        'price': 9.99,
      },
      {
        'name': 'Pre-Workout Formula',
        'description': 'Boosts energy and focus.',
        'price': 19.99,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(category != null ? '${category['name']} Products' : 'Products'),
        backgroundColor: Colors.black,
        foregroundColor: green,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            color: Colors.black,
            child: ListTile(
              leading: Icon(Icons.local_offer, color: green),
              title: Text(product['name'] as String, style: TextStyle(color: green)),
              subtitle: Text(product['description'] as String, style: const TextStyle(color: Colors.white)),
              trailing: Text('\$${product['price']}', style: TextStyle(color: green)),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/product_details',
                  arguments: product,
                );
              },
            ),
          );
        },
      ),
    );
  }
}