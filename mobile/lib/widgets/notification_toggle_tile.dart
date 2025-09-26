import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationToggleTile extends StatefulWidget {
  const NotificationToggleTile({super.key});

  @override
  State<NotificationToggleTile> createState() => _NotificationToggleTileState();
}

class _NotificationToggleTileState extends State<NotificationToggleTile> {
  bool? enabled;

  @override
  void initState() {
    super.initState();
    enabled = NotificationService().enabled;
  }

  @override
  Widget build(BuildContext context) {
    final green = Theme.of(context).colorScheme.primary;
    return SwitchListTile(
      title: Text('Push notifications', style: TextStyle(color: green, fontWeight: FontWeight.w600)),
      subtitle: const Text('Show alerts for orders, chats, and calls', style: TextStyle(color: Colors.white70)),
      activeColor: green,
      value: enabled ?? true,
      onChanged: (v) async {
        setState(() => enabled = v);
        await NotificationService().setEnabled(v);
        if (!context.mounted) return;
        final msg = v ? 'Notifications enabled' : 'Notifications disabled';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      },
    );
  }
}