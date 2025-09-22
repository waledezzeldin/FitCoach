import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;
  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  Map<String, dynamic>? order;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchOrderDetails();
  }

  Future<void> fetchOrderDetails() async {
    try {
      final response = await Dio().get('http://localhost:3000/orders/${widget.orderId}');
      setState(() {
        order = response.data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load order details';
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
        title: const Text('Order Details'),
        backgroundColor: Colors.black,
        foregroundColor: green,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!, style: const TextStyle(color: Colors.white)))
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order #${order!['id']}', style: TextStyle(fontSize: 20, color: green)),
                      const SizedBox(height: 8),
                      Text('Status: ${order!['status']}', style: const TextStyle(color: Colors.white)),
                      Text('Date: ${order!['createdAt']}', style: const TextStyle(color: Colors.white)),
                      Text('Total: \$${order!['total']}', style: TextStyle(color: green)),
                      const SizedBox(height: 16),
                      Text('Items:', style: TextStyle(color: green, fontSize: 16)),
                      ...((order!['items'] ?? []) as List)
                          .map((item) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Text(
                                  '${item['name']} x${item['quantity']} - \$${item['price']}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ))
                          .toList(),
                      const SizedBox(height: 16),
                      Text('Shipping Address:', style: TextStyle(color: green, fontSize: 16)),
                      Text(order!['shippingAddress'] ?? 'N/A', style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
    );
  }
}