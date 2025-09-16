import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final cartItems = [
      {'name': 'Whey Protein', 'price': 45.0},
    ];
    final total = cartItems.fold(0.0, (sum, item) => sum + (item['price'] as double));
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: Column(
        children: [
          Expanded(
            child: ListView(children: cartItems.map((item) => ListTile(title: Text(item['name'] as String), trailing: Text('${item['price']} USD'))).toList()),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [Text('Total: \$${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 10), ElevatedButton(onPressed: () {}, child: const Text('Checkout'))]),
          )
        ],
      ),
    );
  }
}
