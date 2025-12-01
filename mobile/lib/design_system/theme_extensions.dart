import 'package:flutter/material.dart';

import 'design_tokens.dart';

class FitCoachSurfaces extends ThemeExtension<FitCoachSurfaces> {
  final Gradient firstIntake;
  final Gradient secondIntake;
  final Gradient coachHeader;
  final Gradient adminHeader;
  final Gradient primaryCTA;

  const FitCoachSurfaces({
    required this.firstIntake,
    required this.secondIntake,
    required this.coachHeader,
    required this.adminHeader,
    required this.primaryCTA,
  });

  factory FitCoachSurfaces.light() => const FitCoachSurfaces(
        firstIntake: FitCoachGradients.firstIntake,
        secondIntake: FitCoachGradients.secondIntake,
        coachHeader: FitCoachGradients.coachHeader,
        adminHeader: FitCoachGradients.adminHeader,
        primaryCTA: FitCoachGradients.primaryCTA,
      );

  factory FitCoachSurfaces.dark() => const FitCoachSurfaces(
        firstIntake: FitCoachGradients.firstIntake,
        secondIntake: FitCoachGradients.secondIntake,
        coachHeader: FitCoachGradients.coachHeader,
        adminHeader: FitCoachGradients.adminHeader,
        primaryCTA: FitCoachGradients.primaryCTA,
      );

  @override
  ThemeExtension<FitCoachSurfaces> copyWith({
    Gradient? firstIntake,
    Gradient? secondIntake,
    Gradient? coachHeader,
    Gradient? adminHeader,
    Gradient? primaryCTA,
  }) {
    return FitCoachSurfaces(
      firstIntake: firstIntake ?? this.firstIntake,
      secondIntake: secondIntake ?? this.secondIntake,
      coachHeader: coachHeader ?? this.coachHeader,
      adminHeader: adminHeader ?? this.adminHeader,
      primaryCTA: primaryCTA ?? this.primaryCTA,
    );
  }

  @override
  ThemeExtension<FitCoachSurfaces> lerp(ThemeExtension<FitCoachSurfaces>? other, double t) {
    if (other is! FitCoachSurfaces) {
      return this;
    }

    Gradient? lerpGradient(Gradient a, Gradient b) {
      if (a is LinearGradient && b is LinearGradient) {
        return LinearGradient(
          begin: AlignmentGeometry.lerp(a.begin, b.begin, t) ?? a.begin,
          end: AlignmentGeometry.lerp(a.end, b.end, t) ?? a.end,
          colors: <Color>[
            for (int i = 0; i < a.colors.length && i < b.colors.length; i++)
              Color.lerp(a.colors[i], b.colors[i], t) ?? a.colors[i],
          ],
          stops: a.stops,
        );
      }
      return t < 0.5 ? a : b;
    }

    return FitCoachSurfaces(
      firstIntake: lerpGradient(firstIntake, other.firstIntake) ?? firstIntake,
      secondIntake: lerpGradient(secondIntake, other.secondIntake) ?? secondIntake,
      coachHeader: lerpGradient(coachHeader, other.coachHeader) ?? coachHeader,
      adminHeader: lerpGradient(adminHeader, other.adminHeader) ?? adminHeader,
      primaryCTA: lerpGradient(primaryCTA, other.primaryCTA) ?? primaryCTA,
    );
  }
}
