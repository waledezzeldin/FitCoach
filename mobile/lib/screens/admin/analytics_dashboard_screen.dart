import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  Map<String, dynamic>? analytics;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchAnalytics();
  }

  Future<void> fetchAnalytics() async {
    try {
      final response = await Dio().get('http://localhost:3000/api/analytics');
      setState(() {
        analytics = response.data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load analytics';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics Dashboard')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : analytics == null
                  ? Center(child: Text('No analytics data found'))
                  : ListView(
                      children: [
                        ListTile(
                          title: Text('Revenue'),
                          subtitle: Text('\$${analytics!['revenue']}'),
                        ),
                        ListTile(
                          title: Text('Active Users'),
                          subtitle: Text('${analytics!['engagement']}'),
                        ),
                        ListTile(
                          title: Text('Supplement Sales'),
                          subtitle: Text('${analytics!['supplementSales']}'),
                        ),
                      ],
                    ),
    );
  }
}