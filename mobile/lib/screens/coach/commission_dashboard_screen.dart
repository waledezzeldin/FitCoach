import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class CommissionDashboardScreen extends StatefulWidget {
  final String coachId;
  const CommissionDashboardScreen({super.key, required this.coachId});

  @override
  State<CommissionDashboardScreen> createState() => _CommissionDashboardScreenState();
}

class _CommissionDashboardScreenState extends State<CommissionDashboardScreen> {
  List<Map<String, dynamic>> commissions = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchCommissions();
  }

  Future<void> fetchCommissions() async {
    try {
      final response = await Dio().get(
        'http://localhost:3000/api/commissions',
        queryParameters: {'coachId': widget.coachId},
      );
      setState(() {
        commissions = List<Map<String, dynamic>>.from(response.data);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load commissions';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Commissions')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : ListView.builder(
                  itemCount: commissions.length,
                  itemBuilder: (context, index) {
                    final commission = commissions[index];
                    return ListTile(
                      title: Text('Order: ${commission['orderId']}'),
                      subtitle: Text('Amount: \$${commission['amount']}'),
                      trailing: commission['affiliate'] != null
                          ? Text('Affiliate: ${commission['affiliate']['name']}')
                          : null,
                    );
                  },
                ),
    );
  }
}