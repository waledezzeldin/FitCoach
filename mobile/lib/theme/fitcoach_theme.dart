import 'package:flutter/material.dart';

/// FitCoach+ color tokens ported from UI_UX globals.css
class FitCoachBrand extends ThemeExtension<FitCoachBrand> {
  final Color muted;
  final Color accent;
  final Color inputBg;
  final Color switchBg;
  final Color border;
  final BorderRadiusGeometry radius;
  final Color chart1,
      chart2,
      chart3,
      chart4,
      chart5;

  const FitCoachBrand({
    required this.muted,
    required this.accent,
    required this.inputBg,
    required this.switchBg,
    required this.border,
    required this.radius,
    required this.chart1,
    required this.chart2,
    required this.chart3,
    required this.chart4,
    required this.chart5,
  });

  @override
  ThemeExtension<FitCoachBrand> copyWith({
    Color? muted,
    Color? accent,
    Color? inputBg,
    Color? switchBg,
    Color? border,
    BorderRadiusGeometry? radius,
    Color? chart1,
    Color? chart2,
    Color? chart3,
    Color? chart4,
    Color? chart5,
  }) => FitCoachBrand(
        muted: muted ?? this.muted,
        accent: accent ?? this.accent,
        inputBg: inputBg ?? this.inputBg,
        switchBg: switchBg ?? this.switchBg,
        border: border ?? this.border,
        radius: radius ?? this.radius,
        chart1: chart1 ?? this.chart1,
        chart2: chart2 ?? this.chart2,
        chart3: chart3 ?? this.chart3,
        chart4: chart4 ?? this.chart4,
        chart5: chart5 ?? this.chart5,
      );

  @override
  ThemeExtension<FitCoachBrand> lerp(covariant ThemeExtension<FitCoachBrand>? other, double t) {
    if (other is! FitCoachBrand) return this;
    Color lerpColor(Color a, Color b) => Color.lerp(a, b, t)!;
    return FitCoachBrand(
      muted: lerpColor(muted, other.muted),
      accent: lerpColor(accent, other.accent),
      inputBg: lerpColor(inputBg, other.inputBg),
      switchBg: lerpColor(switchBg, other.switchBg),
      border: lerpColor(border, other.border),
      radius: BorderRadius.lerp(radius as BorderRadius?, other.radius as BorderRadius?, t) ?? radius,
      chart1: lerpColor(chart1, other.chart1),
      chart2: lerpColor(chart2, other.chart2),
      chart3: lerpColor(chart3, other.chart3),
      chart4: lerpColor(chart4, other.chart4),
      chart5: lerpColor(chart5, other.chart5),
    );
  }

  static const light = FitCoachBrand(
    muted: Color(0xFFECECF0),
    accent: Color(0xFFE9EBEF),
    inputBg: Color(0xFFF3F3F5),
    switchBg: Color(0xFFCBCED4),
    border: Color(0x1A000000), // rgba(0,0,0,0.1)
    radius: BorderRadius.all(Radius.circular(10)),
    chart1: Color(0xFFA6571F), // oklch mapped close
    chart2: Color(0xFF2AA3A3),
    chart3: Color(0xFF5870D6),
    chart4: Color(0xFFD6A12F),
    chart5: Color(0xFFC7842D),
  );

  static const dark = FitCoachBrand(
    muted: Color(0xFF454545),
    accent: Color(0xFF444444),
    inputBg: Color(0xFF444444),
    switchBg: Color(0xFF6B7280),
    border: Color(0xFF444444),
    radius: BorderRadius.all(Radius.circular(10)),
    chart1: Color(0xFF6473E3),
    chart2: Color(0xFF79CBAE),
    chart3: Color(0xFFC7842D),
    chart4: Color(0xFFA260E0),
    chart5: Color(0xFFD46C39),
  );
}

class FitCoachTheme {
  static ThemeData light() {
    const primary = Color(0xFF030213);
    const onPrimary = Colors.white;
    const surface = Colors.white;
    const onSurface = Color(0xFF232326);
    const secondary = Color(0xFFF2F3F7);
    const onSecondary = Color(0xFF030213);
    const error = Color(0xFFD4183D);
    const onError = Colors.white;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      onSecondary: onSecondary,
      surface: surface,
      onSurface: onSurface,
      error: error,
      onError: onError,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surface,
      extensions: const [FitCoachBrand.light],
      textTheme: Typography.material2021().black.apply(
            bodyColor: onSurface,
            displayColor: onSurface,
          ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FitCoachBrand.light.inputBg,
        border: OutlineInputBorder(
          borderRadius: FitCoachBrand.light.radius as BorderRadius,
          borderSide: BorderSide(color: FitCoachBrand.light.border),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: FitCoachBrand.light.radius as BorderRadius,
          side: BorderSide(color: FitCoachBrand.light.border),
        ),
      ),
    );
  }

  static ThemeData dark() {
    const primary = Color(0xFFFFFFFF);
    const onPrimary = Color(0xFF34343A);
    const surface = Color(0xFF242428);
    const onSurface = Color(0xFFF2F2F4);
    const secondary = Color(0xFF444444);
    const onSecondary = Color(0xFFF2F2F4);
    const error = Color(0xFF64343A);
    const onError = Color(0xFFA34C40);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      onSecondary: onSecondary,
      surface: surface,
      onSurface: onSurface,
      error: error,
      onError: onError,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surface,
      extensions: const [FitCoachBrand.dark],
      textTheme: Typography.material2021().white.apply(
            bodyColor: onSurface,
            displayColor: onSurface,
          ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FitCoachBrand.dark.inputBg,
        border: OutlineInputBorder(
          borderRadius: FitCoachBrand.dark.radius as BorderRadius,
          borderSide: BorderSide(color: FitCoachBrand.dark.border),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: FitCoachBrand.dark.radius as BorderRadius,
          side: BorderSide(color: FitCoachBrand.dark.border),
        ),
      ),
    );
  }
}
