import 'package:flutter/material.dart';
import 'brand.dart';

class SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const SurfaceCard({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    final b = context.brand;
    final t = context.theme;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: b.radius as BorderRadius,
        side: BorderSide(color: b.border),
      ),
      color: t.colorScheme.surface,
      elevation: 0,
      child: Padding(padding: padding, child: child),
    );
  }
}
