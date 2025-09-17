import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class DeliveryStatusScreen extends StatefulWidget {
  final String orderId;
  const DeliveryStatusScreen({super.key, required this.orderId});

  @override
  State<DeliveryStatusScreen> createState() => _DeliveryStatusScreenState();
}

class _DeliveryStatusScreenState extends State<DeliveryStatusScreen> {
  Map<String, dynamic>? delivery;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchDelivery();
  }

  Future<void> fetchDelivery() async {
    try {
      final response = await Dio().get(
        'http://localhost:3000/api/delivery',
        queryParameters: {'orderId': widget.orderId},
      );
      setState(() {
        delivery = response.data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load delivery status';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delivery Status')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : delivery == null
                  ? Center(child: Text('No delivery info found'))
                  : ListView(
                      children: [
                        ListTile(
                          title: Text('Status'),
                          subtitle: Text(delivery!['status'] ?? ''),
                        ),
                        if (delivery!['trackingUrl'] != null)
                          ListTile(
                            title: Text('Tracking'),
                            subtitle: Text(delivery!['trackingUrl']),
                          ),
                        ListTile(
                          title: Text('Address'),
                          subtitle: Text(delivery!['address'] ?? ''),
                        ),
                        if (delivery!['courier'] != null)
                          ListTile(
                            title: Text('Courier'),
                            subtitle: Text(delivery!['courier']),
                          ),
                        if (delivery!['estimatedDate'] != null)
                          ListTile(
                            title: Text('Estimated Delivery'),
                            subtitle: Text(delivery!['estimatedDate']),
                          ),
                      ],
                    ),
    );
  }
}