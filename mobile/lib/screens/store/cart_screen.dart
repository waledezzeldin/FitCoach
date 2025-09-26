import 'package:flutter/material.dart';
import '../../state/cart_state.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final green = Theme.of(context).colorScheme.primary;
    final cart = CartStateScope.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: Colors.black,
        foregroundColor: green,
      ),
      body: cart.isEmpty
          ? Center(
              child: Text('Your cart is empty.', style: TextStyle(color: green, fontSize: 18)),
            )
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cart.items.length,
                      itemBuilder: (context, index) {
                        final item = cart.items[index];
                        return Card(
                          color: Colors.black,
                          child: ListTile(
                            leading: Icon(Icons.shopping_cart, color: green),
                            title: Text(item.name, style: TextStyle(color: green)),
                            subtitle: Row(
                              children: [
                                IconButton(
                                  onPressed: () => cart.updateQty(item.id, item.quantity - 1),
                                  icon: const Icon(Icons.remove, color: Colors.white),
                                ),
                                Text('${item.quantity}', style: const TextStyle(color: Colors.white)),
                                IconButton(
                                  onPressed: () => cart.updateQty(item.id, item.quantity + 1),
                                  icon: const Icon(Icons.add, color: Colors.white),
                                ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('\$${item.price.toStringAsFixed(2)}', style: TextStyle(color: green)),
                                IconButton(
                                  onPressed: () => cart.remove(item.id),
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Total: \$${cart.total.toStringAsFixed(2)}', style: TextStyle(color: green, fontSize: 20)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/checkout'),
                    child: const Text('Proceed to Checkout'),
                  ),
                ],
              ),
            ),
    );
  }
}