import 'package:flutter/material.dart';
import '../theme/fitcoach_theme.dart';

extension BuildContextBrand on BuildContext {
  FitCoachBrand get brand =>
      Theme.of(this).extension<FitCoachBrand>() ?? FitCoachBrand.light;
  ThemeData get theme => Theme.of(this);
}
