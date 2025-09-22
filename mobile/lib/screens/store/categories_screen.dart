import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'product_details_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List categories = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await Dio().get('http://localhost:3000/categories');
      setState(() {
        categories = response.data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load categories';
        isLoading = false;
      });
    }
  }

  Future<void> fetchProducts(String categoryId) async {
    try {
      final response = await Dio().get('http://localhost:3000/categories/$categoryId/products');
      final products = response.data as List;
      if (products.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: products[0]),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load products', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final green = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Categories'),
        backgroundColor: Colors.black,
        foregroundColor: green,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!, style: const TextStyle(color: Colors.white)))
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return Card(
                      color: Colors.black,
                      child: ListTile(
                        leading: Icon(Icons.category, color: green),
                        title: Text(category['name'], style: TextStyle(color: green)),
                        onTap: () => fetchProducts(category['id']),
                      ),
                    );
                  },
                ),
    );
  }
}