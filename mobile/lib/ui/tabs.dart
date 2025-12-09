import 'package:flutter/material.dart';
import 'brand.dart';

class PrimaryTabs extends StatelessWidget {
  final List<String> tabs;
  final TabController controller;
  const PrimaryTabs({super.key, required this.tabs, required this.controller});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return TabBar(
      controller: controller,
      tabs: [for (final l in tabs) Tab(text: l)],
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: t.colorScheme.primary, width: 2),
      ),
      labelColor: t.colorScheme.primary,
      unselectedLabelColor: t.colorScheme.onSurface.withValues(alpha: 0.7),
      isScrollable: true,
    );
  }
}

class SecondaryTabs extends StatelessWidget {
  final List<String> tabs;
  final TabController controller;
  const SecondaryTabs({super.key, required this.tabs, required this.controller});

  @override
  Widget build(BuildContext context) {
    final b = context.brand;
    final t = context.theme;
    return Container(
      decoration: BoxDecoration(
        color: b.accent,
        borderRadius: b.radius as BorderRadius,
        border: Border.all(color: b.border),
      ),
      padding: const EdgeInsets.all(4),
      child: TabBar(
        controller: controller,
        tabs: [for (final l in tabs) Tab(text: l)],
        indicator: BoxDecoration(
          color: t.colorScheme.primary,
          borderRadius: b.radius as BorderRadius,
        ),
        labelColor: t.colorScheme.onPrimary,
        unselectedLabelColor: t.colorScheme.onSurface,
        dividerColor: Colors.transparent,
      ),
    );
  }
}
