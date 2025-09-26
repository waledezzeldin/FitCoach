import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String name;
  final double price;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
  });
}

class CartState extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();
  bool get isEmpty => _items.isEmpty;

  double get total =>
      _items.values.fold(0.0, (sum, i) => sum + (i.price * i.quantity));

  String? couponCode;
  double discount = 0.0; // absolute amount in currency

  double get totalAfterDiscount {
    final t = total;
    final d = discount.clamp(0, t);
    return (t - d);
  }

  void clearCoupon() {
    couponCode = null;
    discount = 0.0;
    notifyListeners();
  }

  void applyCoupon({required String code, required double amountOff}) {
    couponCode = code;
    discount = amountOff;
    notifyListeners();
  }

  void addItem(CartItem item) {
    if (_items.containsKey(item.id)) {
      _items[item.id]!.quantity += item.quantity;
    } else {
      _items[item.id] = item;
    }
    notifyListeners();
  }

  void updateQty(String id, int qty) {
    if (!_items.containsKey(id)) return;
    if (qty <= 0) {
      _items.remove(id);
    } else {
      _items[id]!.quantity = qty;
    }
    notifyListeners();
  }

  void remove(String id) {
    _items.remove(id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

class CartStateScope extends InheritedNotifier<CartState> {
  const CartStateScope({
    super.key,
    required CartState super.notifier,
    required super.child,
  });

  static CartState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CartStateScope>();
    assert(scope != null, 'CartStateScope not found in widget tree');
    return scope!.notifier!;
  }

  @override
  bool updateShouldNotify(covariant InheritedNotifier<CartState> oldWidget) => true;
}