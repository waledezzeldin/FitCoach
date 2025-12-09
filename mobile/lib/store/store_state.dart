import 'package:flutter/foundation.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  Product({required this.id, required this.name, required this.description, required this.price, required this.imageUrl});
}

class StoreState extends ChangeNotifier {
  final List<Product> products = [
    Product(id: '1', name: 'Protein Bar', description: 'High protein snack.', price: 2.99, imageUrl: ''),
    Product(id: '2', name: 'Yoga Mat', description: 'Non-slip mat for workouts.', price: 19.99, imageUrl: ''),
    Product(id: '3', name: 'Water Bottle', description: 'Stay hydrated.', price: 9.99, imageUrl: ''),
  ];

  final List<Product> cart = [];

  void addToCart(Product p) {
    cart.add(p);
    notifyListeners();
  }

  void removeFromCart(Product p) {
    cart.remove(p);
    notifyListeners();
  }

  double get cartTotal => cart.fold(0, (sum, p) => sum + p.price);
}
