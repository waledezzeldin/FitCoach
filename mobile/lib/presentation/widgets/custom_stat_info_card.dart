import 'package:flutter/material.dart';

/// A placeholder for the missing CustomStatCard widget.
class CustomStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap; // <-- Add this line

  const CustomStatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap, // <-- Add this line
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // <-- Add this line
      borderRadius: BorderRadius.circular(12),
      child: Container(
        // ...existing code...
      ),
    );
  }
}

/// A placeholder for the missing CustomInfoCard widget.
class CustomInfoCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap; // <-- Add this line

  const CustomInfoCard({
    Key? key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.iconColor,
    this.onTap, // <-- Add this line
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // <-- Add this line
      child: Card(
        child: ListTile(
          leading: Icon(icon, color: iconColor),
          title: Text(title),
          subtitle: subtitle != null ? Text(subtitle!) : null,
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}
