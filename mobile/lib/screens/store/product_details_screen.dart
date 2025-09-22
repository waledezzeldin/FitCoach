import 'package:flutter/material.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Map product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final green = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(product['name']),
        backgroundColor: Colors.black,
        foregroundColor: green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product['name'], style: TextStyle(fontSize: 24, color: green)),
            const SizedBox(height: 8),
            Text(product['description'] ?? '', style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 16),
            Text('Price: \$${product['price']}', style: TextStyle(color: green, fontSize: 18)),
            // Add allergen/age warnings if available
          ],
        ),
      ),
    );
  }
}