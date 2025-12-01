import 'package:flutter/material.dart';

/// Centralized palette, spacing, and asset references that mirror the
/// FitCoach React/Tailwind design kit.
class FitCoachColors {
  const FitCoachColors._();

  static const Color background = Color(0xFFFFFFFF);
  static const Color foreground = Color(0xFF010101);
  static const Color primary = Color(0xFF030213);
  static const Color primaryForeground = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFFD7DBE3);
  static const Color secondaryForeground = Color(0xFF030213);
  static const Color accent = Color(0xFFE9EBEF);
  static const Color accentForeground = Color(0xFF030213);
  static const Color muted = Color(0xFFECECF0);
  static const Color mutedForeground = Color(0xFF717182);
  static const Color primaryContainer = Color(0xFFE0E7FF);
  static const Color onPrimaryContainer = Color(0xFF030213);
  static const Color secondaryContainer = Color(0xFFF3F4F6);
  static const Color onSecondaryContainer = Color(0xFF030213);
  static const Color tertiaryContainer = Color(0xFFF5E8FF);
  static const Color onTertiaryContainer = Color(0xFF3F1C5F);
  static const Color errorContainer = Color(0xFFFEE3E7);
  static const Color onErrorContainer = Color(0xFF751B2B);
  static const Color border = Color(0x1A000000); // rgba(0,0,0,0.1)
  static const Color inputBackground = Color(0xFFF3F3F5);
  static const Color switchTrack = Color(0xFFCBCED4);
  static const Color destructive = Color(0xFFD4183D);
  static const Color destructiveForeground = Color(0xFFFFFFFF);
  static const Color info = Color(0xFF3B82F6);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color freemium = Color(0xFF6B7280);
  static const Color premium = Color(0xFFA855F7);
  static const Color smartPremium = Color(0xFFF59E0B);
  static const Color chart1 = Color(0xFFE91100);
  static const Color chart2 = Color(0xFF004E40);
  static const Color chart3 = Color(0xFF011421);
  static const Color chart4 = Color(0xFFFF7C00);
  static const Color chart5 = Color(0xFFFC5200);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF8FAFC);
  static const Color surfaceInverse = Color(0xFF0B0B0F);
  static const Color surfaceCardDark = Color(0xFF121318);
  static const Color outlineDark = Color(0x26FFFFFF);
  static const Color textOnDark = Color(0xFFF4F4F4);

  // Gradient anchor colors taken directly from the Tailwind UI kit.
  static const Color gradientBlueStart = Color(0xFFEFF6FF); // blue-50
  static const Color gradientBlueEnd = Color(0xFFE0E7FF); // indigo-100
  static const Color gradientPurpleStart = Color(0xFFFAF5FF); // purple-50
  static const Color gradientPurpleEnd = Color(0xFFDBEAFE); // blue-100
  static const Color gradientCoachStart = Color(0xFF7C3AED); // purple-600
  static const Color gradientCoachEnd = Color(0xFFEC4899); // pink-500
  static const Color gradientAdminStart = Color(0xFF475569); // slate-600
  static const Color gradientAdminEnd = Color(0xFF1F2937); // gray-800
  static const Color gradientCTAStart = Color(0xFF2563EB); // blue-600
  static const Color gradientCTAEnd = Color(0xFF7C3AED); // purple-600
}

class FitCoachSpacing {
  const FitCoachSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

class FitCoachRadii {
  const FitCoachRadii._();

  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double pill = 999;
}

class FitCoachDurations {
  const FitCoachDurations._();

  static const Duration quick = Duration(milliseconds: 150);
  static const Duration regular = Duration(milliseconds: 250);
  static const Duration relaxed = Duration(milliseconds: 400);
}

class FitCoachShadows {
  const FitCoachShadows._();

  static const BoxShadow soft = BoxShadow(
    color: Color(0x14000000), // 8% black
    blurRadius: 24,
    offset: Offset(0, 12),
  );

  static const BoxShadow card = BoxShadow(
    color: Color(0x0F0F172A), // slate tint
    blurRadius: 32,
    spreadRadius: -8,
    offset: Offset(0, 18),
  );
}

class FitCoachGradients {
  const FitCoachGradients._();

  static const LinearGradient firstIntake = LinearGradient(
    colors: [FitCoachColors.gradientBlueStart, FitCoachColors.gradientBlueEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondIntake = LinearGradient(
    colors: [FitCoachColors.gradientPurpleStart, FitCoachColors.gradientPurpleEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient coachHeader = LinearGradient(
    colors: [FitCoachColors.gradientCoachStart, FitCoachColors.gradientCoachEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient adminHeader = LinearGradient(
    colors: [FitCoachColors.gradientAdminStart, FitCoachColors.gradientAdminEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryCTA = LinearGradient(
    colors: [FitCoachColors.gradientCTAStart, FitCoachColors.gradientCTAEnd],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

class FitCoachAssets {
  const FitCoachAssets._();

  static const String logo = 'assets/branding/logo.png';
  static const String intakeAge = 'assets/images/intake/age';
  static const String intakeGoal = 'assets/images/intake/goal';
  static const String intakeLocation = 'assets/images/intake/location';
  static const String intakeExperience = 'assets/images/intake/experience';
  static const String intakeGender = 'assets/images/intake/gender';
  static const String store = 'assets/images/store';
}
