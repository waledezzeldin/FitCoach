import 'package:flutter/material.dart';

class FCBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavigationDestination> destinations;
  const FCBottomNav({super.key, required this.currentIndex, required this.onTap, required this.destinations});

  @override
  Widget build(BuildContext context) {
    // Material 3 NavigationBar for a modern bottom nav look
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      destinations: destinations,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    );
  }
}
