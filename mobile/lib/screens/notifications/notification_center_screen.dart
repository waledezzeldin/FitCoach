import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class NotificationCenterScreen extends StatefulWidget {
  final String userId;
  const NotificationCenterScreen({super.key, required this.userId});

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      final response = await Dio().get(
        'http://localhost:3000/api/notifications',
        queryParameters: {'userId': widget.userId},
      );
      setState(() {
        notifications = List<Map<String, dynamic>>.from(response.data);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load notifications';
        isLoading = false;
      });
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await Dio().put(
      'http://your-backend-url/v1/notifications/$notificationId/read',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return ListTile(
                      title: Text(notification['title'] ?? ''),
                      subtitle: Text(notification['message'] ?? ''),
                      trailing: notification['read'] == true
                          ? const Icon(Icons.check, color: Colors.green)
                          : IconButton(
                              icon: const Icon(Icons.mark_email_read),
                              onPressed: () => markNotificationAsRead(notification['id']),
                            ),
                    );
                  },
                ),
    );
  }
}