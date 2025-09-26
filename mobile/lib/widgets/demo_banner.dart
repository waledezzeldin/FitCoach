import 'package:flutter/material.dart';

class DemoBanner extends StatelessWidget {
  final EdgeInsets padding;
  const DemoBanner({super.key, this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4)});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.primary),
      ),
      child: Text('DEMO',
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: cs.primary)),
    );
  }
}