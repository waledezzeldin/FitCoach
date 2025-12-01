import 'package:flutter/material.dart';

import '../design_system/design_tokens.dart';
import '../design_system/theme_extensions.dart';
import '../design_system/typography.dart';

class AppTheme {
  const AppTheme._();

  static const Color brand = FitCoachColors.primary;
  static const Color brandDark = FitCoachColors.gradientCTAStart;
  static const Color brandLight = FitCoachColors.gradientCTAEnd;

  static ThemeData get light {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: FitCoachColors.primary,
      onPrimary: FitCoachColors.primaryForeground,
      primaryContainer: FitCoachColors.primaryContainer,
      onPrimaryContainer: FitCoachColors.onPrimaryContainer,
      secondary: FitCoachColors.secondary,
      onSecondary: FitCoachColors.secondaryForeground,
      secondaryContainer: FitCoachColors.secondaryContainer,
      onSecondaryContainer: FitCoachColors.onSecondaryContainer,
      tertiary: FitCoachColors.accent,
      onTertiary: FitCoachColors.accentForeground,
      tertiaryContainer: FitCoachColors.tertiaryContainer,
      onTertiaryContainer: FitCoachColors.onTertiaryContainer,
      error: FitCoachColors.destructive,
      onError: FitCoachColors.destructiveForeground,
      errorContainer: FitCoachColors.errorContainer,
      onErrorContainer: FitCoachColors.onErrorContainer,
      background: FitCoachColors.background,
      onBackground: FitCoachColors.foreground,
      surface: FitCoachColors.surface,
      onSurface: FitCoachColors.foreground,
      surfaceVariant: FitCoachColors.muted,
      onSurfaceVariant: FitCoachColors.mutedForeground,
      outline: FitCoachColors.border,
      outlineVariant: FitCoachColors.mutedForeground,
      shadow: const Color(0x14000000),
      scrim: const Color(0x66000000),
      inverseSurface: FitCoachColors.foreground,
      onInverseSurface: FitCoachColors.background,
      inversePrimary: FitCoachColors.info,
      surfaceTint: FitCoachColors.primary,
    );
    final textTheme = FitCoachTypography.light;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      fontFamilyFallback: FitCoachTypography.latinFallback,
      scaffoldBackgroundColor: FitCoachColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: FitCoachColors.background,
        foregroundColor: FitCoachColors.foreground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: FitCoachColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FitCoachRadii.md),
        ),
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: const DividerThemeData(
        color: FitCoachColors.border,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FitCoachColors.inputBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FitCoachRadii.md),
          borderSide: const BorderSide(color: FitCoachColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FitCoachRadii.md),
          borderSide: const BorderSide(color: FitCoachColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FitCoachRadii.md),
          borderSide: const BorderSide(color: FitCoachColors.primary, width: 1.6),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: FitCoachColors.mutedForeground),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: textTheme.labelLarge,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FitCoachRadii.pill),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: textTheme.labelLarge,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FitCoachRadii.pill),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: textTheme.labelLarge,
          side: const BorderSide(color: FitCoachColors.primary, width: 1.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FitCoachRadii.pill),
          ),
          minimumSize: const Size.fromHeight(52),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: FitCoachColors.info,
          textStyle: textTheme.labelLarge,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: FitCoachColors.accent,
        disabledColor: FitCoachColors.muted,
        selectedColor: FitCoachColors.primary,
        secondarySelectedColor: FitCoachColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: textTheme.labelMedium?.copyWith(color: FitCoachColors.accentForeground),
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(color: FitCoachColors.primaryForeground),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FitCoachRadii.sm),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 70,
        backgroundColor: FitCoachColors.surface,
        indicatorColor: FitCoachColors.secondary.withOpacity(0.35),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          final color = states.contains(MaterialState.selected)
              ? FitCoachColors.primary
              : FitCoachColors.mutedForeground;
          return textTheme.labelMedium?.copyWith(color: color);
        }),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          final color = states.contains(MaterialState.selected)
              ? FitCoachColors.primary
              : FitCoachColors.mutedForeground;
          return IconThemeData(color: color);
        }),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: FitCoachColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(FitCoachRadii.lg)),
        ),
        showDragHandle: true,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: FitCoachColors.foreground,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: FitCoachColors.primaryForeground),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FitCoachRadii.md),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return FitCoachColors.primaryForeground;
          }
          return FitCoachColors.primaryForeground;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return FitCoachColors.primary;
          }
          return FitCoachColors.switchTrack;
        }),
      ),
      iconTheme: const IconThemeData(color: FitCoachColors.foreground),
      extensions: <ThemeExtension<dynamic>>[
        FitCoachSurfaces.light(),
      ],
    );
  }

  static ThemeData get dark {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: FitCoachColors.primary,
      onPrimary: FitCoachColors.primaryForeground,
      primaryContainer: const Color(0xFF1F1F2A),
      onPrimaryContainer: FitCoachColors.primaryForeground,
      secondary: const Color(0xFF22232B),
      onSecondary: FitCoachColors.textOnDark,
      secondaryContainer: const Color(0xFF2C2D37),
      onSecondaryContainer: FitCoachColors.textOnDark,
      tertiary: const Color(0xFF2E1B3C),
      onTertiary: FitCoachColors.primaryForeground,
      tertiaryContainer: const Color(0xFF3B1F52),
      onTertiaryContainer: FitCoachColors.primaryForeground,
      error: FitCoachColors.destructive,
      onError: FitCoachColors.destructiveForeground,
      errorContainer: const Color(0xFF5D1321),
      onErrorContainer: FitCoachColors.destructiveForeground,
      background: FitCoachColors.surfaceInverse,
      onBackground: FitCoachColors.textOnDark,
      surface: FitCoachColors.surfaceCardDark,
      onSurface: FitCoachColors.textOnDark,
      surfaceVariant: const Color(0xFF23242B),
      onSurfaceVariant: FitCoachColors.textOnDark,
      outline: FitCoachColors.outlineDark,
      outlineVariant: FitCoachColors.outlineDark,
      shadow: const Color(0x66000000),
      scrim: const Color(0x99000000),
      inverseSurface: FitCoachColors.surface,
      onInverseSurface: FitCoachColors.foreground,
      inversePrimary: FitCoachColors.info,
      surfaceTint: FitCoachColors.primary,
    );
    final textTheme = FitCoachTypography.dark;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      fontFamilyFallback: FitCoachTypography.latinFallback,
      scaffoldBackgroundColor: FitCoachColors.surfaceInverse,
      appBarTheme: AppBarTheme(
        backgroundColor: FitCoachColors.surfaceInverse,
        foregroundColor: FitCoachColors.textOnDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: FitCoachColors.surfaceCardDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FitCoachRadii.md),
        ),
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: const DividerThemeData(
        color: FitCoachColors.outlineDark,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A1A22),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FitCoachRadii.md),
          borderSide: const BorderSide(color: FitCoachColors.outlineDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FitCoachRadii.md),
          borderSide: const BorderSide(color: FitCoachColors.outlineDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FitCoachRadii.md),
          borderSide: const BorderSide(color: FitCoachColors.primary, width: 1.6),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: FitCoachColors.mutedForeground.withOpacity(0.7)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: textTheme.labelLarge,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FitCoachRadii.pill),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: textTheme.labelLarge,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FitCoachRadii.pill),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: FitCoachColors.primaryForeground,
          textStyle: textTheme.labelLarge,
          side: const BorderSide(color: FitCoachColors.primaryForeground, width: 1.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FitCoachRadii.pill),
          ),
          minimumSize: const Size.fromHeight(52),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 70,
        backgroundColor: FitCoachColors.surfaceInverse,
        indicatorColor: FitCoachColors.primary.withOpacity(0.2),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          final color = states.contains(MaterialState.selected)
              ? FitCoachColors.primaryForeground
              : FitCoachColors.textOnDark.withOpacity(0.7);
          return textTheme.labelMedium?.copyWith(color: color);
        }),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          final color = states.contains(MaterialState.selected)
              ? FitCoachColors.primaryForeground
              : FitCoachColors.textOnDark.withOpacity(0.7);
          return IconThemeData(color: color);
        }),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: FitCoachColors.surfaceCardDark,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(FitCoachRadii.lg)),
        ),
        showDragHandle: true,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: FitCoachColors.surfaceCardDark,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: FitCoachColors.primaryForeground),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FitCoachRadii.md),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return FitCoachColors.primaryForeground;
          }
          return FitCoachColors.primaryForeground;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return FitCoachColors.primary;
          }
          return FitCoachColors.outlineDark;
        }),
      ),
      iconTheme: const IconThemeData(color: FitCoachColors.textOnDark),
      extensions: <ThemeExtension<dynamic>>[
        FitCoachSurfaces.dark(),
      ],
    );
  }
}