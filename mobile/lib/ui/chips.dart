import 'package:flutter/material.dart';
import 'brand.dart';

class FCChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;

  const FCChoiceChip({super.key, required this.label, required this.selected, this.onSelected});

  @override
  Widget build(BuildContext context) {
    final b = context.brand;
    final t = context.theme;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      labelStyle: t.textTheme.bodyMedium?.copyWith(
        color: selected ? t.colorScheme.onPrimary : t.colorScheme.onSurface,
      ),
      selectedColor: t.colorScheme.primary,
      backgroundColor: b.accent,
      shape: StadiumBorder(side: BorderSide(color: b.border)),
      showCheckmark: false,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}

class FCFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;

  const FCFilterChip({super.key, required this.label, required this.selected, this.onSelected});

  @override
  Widget build(BuildContext context) {
    final b = context.brand;
    final t = context.theme;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      labelStyle: t.textTheme.bodyMedium?.copyWith(
        color: selected ? t.colorScheme.onPrimary : t.colorScheme.onSurface,
      ),
      selectedColor: t.colorScheme.primary,
      backgroundColor: b.accent,
      shape: StadiumBorder(side: BorderSide(color: b.border)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      showCheckmark: false,
    );
  }
}
