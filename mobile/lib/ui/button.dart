import 'package:flutter/material.dart';
import 'brand.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry padding;
  final IconData? leadingIcon;

  const PrimaryButton({super.key, required this.label, this.onPressed, this.padding = const EdgeInsets.symmetric(vertical: 14), this.leadingIcon});

  @override
  Widget build(BuildContext context) {
    final b = context.brand;
    final t = context.theme;
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: t.colorScheme.primary,
        foregroundColor: t.colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: b.radius as BorderRadius),
        padding: padding,
        elevation: 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (leadingIcon != null) ...[
            Icon(leadingIcon, size: 18),
            const SizedBox(width: 8),
          ],
          Text(label, style: t.textTheme.titleMedium),
        ],
      ),
    );
  }
}

class GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry padding;

  const GhostButton({super.key, required this.label, this.onPressed, this.padding = const EdgeInsets.symmetric(vertical: 14)});

  @override
  Widget build(BuildContext context) {
    final b = context.brand;
    final t = context.theme;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: t.colorScheme.onSurface,
        side: BorderSide(color: b.border),
        shape: RoundedRectangleBorder(borderRadius: b.radius as BorderRadius),
        padding: padding,
      ),
      child: Text(label, style: t.textTheme.titleMedium),
    );
  }
}
