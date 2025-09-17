import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Map<String, dynamic>> products = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await Dio().get('http://localhost:3000/api/products');
      setState(() {
        products = List<Map<String, dynamic>>.from(response.data);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load products';
        isLoading = false;
      });
    }
  }

  Future<List<dynamic>> fetchBundles() async {
    final response = await Dio().get('http://your-backend-url/v1/products/bundles');
    return response.data;
  }

  Future<List<dynamic>> fetchCategories() async {
    final response = await Dio().get('http://your-backend-url/v1/products/categories');
    return response.data;
  }

  Future<void> cancelOrder(String orderId) async {
    await Dio().post('http://your-backend-url/v1/orders/$orderId/cancel');
  }

  Future<void> returnOrder(String orderId) async {
    await Dio().post('http://your-backend-url/v1/orders/$orderId/return');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ListTile(
                      leading: product['imageUrl'] != null
                          ? Image.network(product['imageUrl'], width: 50, height: 50, fit: BoxFit.cover)
                          : null,
                      title: Text(product['name'] ?? ''),
                      subtitle: Text(product['description'] ?? ''),
                      trailing: Text('\$${product['price'] ?? ''}'),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Example order data, replace with your actual order data
          final order = {
            'id': '123',
            'product': 'Example Product',
            'price': 29.99,
          };

          // Cancel order button
          ElevatedButton(
            onPressed: () => cancelOrder(order['id'] as String),
            child: const Text('Cancel Order'),
          );

          // Return order button
          ElevatedButton(
            onPressed: () => returnOrder(order['id'] as String),
            child: const Text('Return Order'),
          );
        },
        label: const Text('Manage Order'),
        icon: const Icon(Icons.shopping_cart),
      ),
    );
  }
}
