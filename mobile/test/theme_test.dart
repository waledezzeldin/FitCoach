import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitcoach/theme/fitcoach_theme.dart';

void main() {
  group('FitCoachTheme', () {
    test('light scheme basics', () {
      final t = FitCoachTheme.light();
      expect(t.colorScheme.brightness, Brightness.light);
      expect(t.colorScheme.surface, const Color(0xFFFFFFFF));
    });

    test('dark scheme basics', () {
      final t = FitCoachTheme.dark();
      expect(t.colorScheme.brightness, Brightness.dark);
      expect(t.colorScheme.surface, const Color(0xFF242428));
    });
  });
}
