import 'package:flutter/material.dart';
import 'brand.dart';

enum BadgeVariant { info, success, warn, danger }

class FCBadge extends StatelessWidget {
  final String text;
  final BadgeVariant variant;
  const FCBadge({super.key, required this.text, this.variant = BadgeVariant.info});

  @override
  Widget build(BuildContext context) {
    final b = context.brand;
    final t = context.theme;
    final bg = switch (variant) {
      BadgeVariant.info => t.colorScheme.primary.withValues(alpha: .12),
      BadgeVariant.success => const Color(0xFF10B981).withValues(alpha: .12),
      BadgeVariant.warn => const Color(0xFFF59E0B).withValues(alpha: .12),
      BadgeVariant.danger => t.colorScheme.error.withValues(alpha: .12),
    };
    final fg = switch (variant) {
      BadgeVariant.info => t.colorScheme.primary,
      BadgeVariant.success => const Color(0xFF10B981),
      BadgeVariant.warn => const Color(0xFFF59E0B),
      BadgeVariant.danger => t.colorScheme.error,
    };
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: b.radius as BorderRadius,
        border: Border.all(color: b.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(text, style: t.textTheme.labelSmall?.copyWith(color: fg)),
    );
  }
}
