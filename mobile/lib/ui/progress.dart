import 'package:flutter/material.dart';
import 'brand.dart';

class FCLinearProgress extends StatelessWidget {
  final double value; // 0..1
  const FCLinearProgress({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    final b = context.brand;
    final t = context.theme;
    return ClipRRect(
      borderRadius: b.radius as BorderRadius,
      child: LinearProgressIndicator(
        value: value,
        minHeight: 10,
        borderRadius: b.radius as BorderRadius,
        backgroundColor: b.muted,
        color: t.colorScheme.primary,
      ),
    );
  }
}
