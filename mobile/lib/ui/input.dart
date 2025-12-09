import 'package:flutter/material.dart';
import 'brand.dart';

enum FCInputVariant { filled, outlined }

class FitTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final FCInputVariant variant;
  final Widget? leading;
  final Widget? trailing;

  const FitTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.keyboardType,
    this.obscureText = false,
    this.variant = FCInputVariant.filled,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final b = context.brand;
    final t = context.theme;
    final baseBorder = OutlineInputBorder(
      borderRadius: b.radius as BorderRadius,
      borderSide: BorderSide(color: b.border),
    );
    final isFilled = variant == FCInputVariant.filled;
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        prefixIcon: leading,
        suffixIcon: trailing,
        filled: isFilled,
        fillColor: isFilled ? b.inputBg : null,
        enabledBorder: baseBorder,
        focusedBorder: baseBorder.copyWith(
          borderSide: BorderSide(color: t.colorScheme.primary, width: 1.5),
        ),
        errorBorder: baseBorder.copyWith(
          borderSide: BorderSide(color: t.colorScheme.error, width: 1.5),
        ),
        focusedErrorBorder: baseBorder.copyWith(
          borderSide: BorderSide(color: t.colorScheme.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }
}
