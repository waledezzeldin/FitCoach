import 'package:flutter/material.dart';

import 'design_tokens.dart';

class FitCoachTypography {
  const FitCoachTypography._();

  static const List<String> latinFallback = <String>[
    'SF Pro Display',
    'Segoe UI',
    'Roboto',
    'Helvetica Neue',
    'Arial',
  ];

  static const List<String> arabicFallback = <String>[
    'Cairo',
    'IBM Plex Sans Arabic',
    'Segoe UI',
    'Roboto',
  ];

  static TextTheme get light => _base.apply(
        bodyColor: FitCoachColors.foreground,
        displayColor: FitCoachColors.foreground,
      );

  static TextTheme get dark => _base.apply(
        bodyColor: FitCoachColors.textOnDark,
        displayColor: FitCoachColors.textOnDark,
      );

  static TextStyle _style({
    required double size,
    required FontWeight weight,
    double height = 1.4,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
      fontFamilyFallback: latinFallback,
    );
  }

  static final TextTheme _base = TextTheme(
    displayLarge: _style(size: 48, weight: FontWeight.w600, height: 1.15, letterSpacing: -0.5),
    displayMedium: _style(size: 40, weight: FontWeight.w600, height: 1.2, letterSpacing: -0.3),
    displaySmall: _style(size: 34, weight: FontWeight.w600, height: 1.2, letterSpacing: -0.2),
    headlineLarge: _style(size: 28, weight: FontWeight.w600, height: 1.25, letterSpacing: -0.12),
    headlineMedium: _style(size: 24, weight: FontWeight.w600, height: 1.3, letterSpacing: -0.08),
    headlineSmall: _style(size: 22, weight: FontWeight.w600, height: 1.35, letterSpacing: -0.04),
    titleLarge: _style(size: 20, weight: FontWeight.w600, height: 1.35),
    titleMedium: _style(size: 18, weight: FontWeight.w500, height: 1.4),
    titleSmall: _style(size: 16, weight: FontWeight.w500, height: 1.4, letterSpacing: 0.1),
    bodyLarge: _style(size: 16, weight: FontWeight.w400, height: 1.55),
    bodyMedium: _style(size: 15, weight: FontWeight.w400, height: 1.5),
    bodySmall: _style(size: 13, weight: FontWeight.w400, height: 1.45),
    labelLarge: _style(size: 15, weight: FontWeight.w600, height: 1.3, letterSpacing: 0.1),
    labelMedium: _style(size: 13, weight: FontWeight.w500, height: 1.25, letterSpacing: 0.4),
    labelSmall: _style(size: 11, weight: FontWeight.w500, height: 1.2, letterSpacing: 0.4),
  );
}
