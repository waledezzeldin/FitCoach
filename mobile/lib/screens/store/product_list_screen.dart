import 'package:flutter/material.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final products = [
      {'name': 'Whey Protein', 'price': 45.0},
      {'name': 'Creatine', 'price': 25.0},
      {'name': 'Omega 3', 'price': 15.0},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Store')),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final p = products[index];
          return ListTile(
            title: Text(p['name'] as String),
            subtitle: Text('${p['price']} USD'),
            trailing: IconButton(icon: const Icon(Icons.add_shopping_cart), onPressed: () => Navigator.pushNamed(context, '/cart')),
          );
        },
      ),
    );
  }
}
