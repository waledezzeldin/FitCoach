import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final green = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('FitCoach+ Dashboard'),
        backgroundColor: Colors.black,
        foregroundColor: green,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(24),
        children: [
          _DashboardTile(
            icon: Icons.store,
            label: 'Store',
            onTap: () => Navigator.pushNamed(context, '/store'),
            color: green,
          ),
          _DashboardTile(
            icon: Icons.subscriptions,
            label: 'Subscriptions',
            onTap: () => Navigator.pushNamed(context, '/subscriptions'),
            color: green,
          ),
          _DashboardTile(
            icon: Icons.fitness_center,
            label: 'Bundles',
            onTap: () => Navigator.pushNamed(context, '/bundles'),
            color: green,
          ),
          _DashboardTile(
            icon: Icons.video_call,
            label: 'Video Coaching',
            onTap: () => Navigator.pushNamed(context, '/video'),
            color: green,
          ),
          _DashboardTile(
            icon: Icons.recommend,
            label: 'Recommendations',
            onTap: () => Navigator.pushNamed(context, '/recommendations'),
            color: green,
          ),
          _DashboardTile(
            icon: Icons.person,
            label: 'Profile',
            onTap: () => Navigator.pushNamed(context, '/profile'),
            color: green,
          ),
          _DashboardTile(
            icon: Icons.shopping_cart,
            label: 'Checkout',
            onTap: () => Navigator.pushNamed(context, '/checkout'),
            color: green,
          ),
          _DashboardTile(
            icon: Icons.logout,
            label: 'Logout',
            onTap: () => Navigator.pushNamed(context, '/login'),
            color: green,
          ),
        ],
      ),
    );
  }
}

class _DashboardTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _DashboardTile({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black,
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              Text(label, style: TextStyle(fontSize: 16, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

