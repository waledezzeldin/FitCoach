import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      final response = await Dio().get('http://localhost:3000/orders');
      setState(() {
        orders = List<Map<String, dynamic>>.from(response.data);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load orders';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final green = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Orders'),
        backgroundColor: Colors.black,
        foregroundColor: green,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!, style: const TextStyle(color: Colors.white)))
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Card(
                      color: Colors.black,
                      child: ListTile(
                        leading: Icon(Icons.receipt_long, color: green),
                        title: Text('Order #${order['id']}', style: TextStyle(color: green)),
                        subtitle: Text('${order['status']} - ${order['date']}', style: const TextStyle(color: Colors.white)),
                        trailing: Text('\$${order['total']}', style: TextStyle(color: green)),
                        onTap: () {
                          // Show order details
                        },
                      ),
                    );
                  },
                ),
    );
  }
}