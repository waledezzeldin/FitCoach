import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitapp/presentation/screens/onboarding_screen.dart';
import 'package:fitapp/presentation/screens/splash_screen.dart';
import 'package:fitapp/presentation/screens/language_selection_screen.dart';

void main() {
  group('Screen Widget Tests', () {
    testWidgets('SplashScreen renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(onStart: () {}),
        ),
      );
      await tester.pump(const Duration(milliseconds: 150));

      // Splash screen should render
      expect(find.byType(SplashScreen), findsOneWidget);
    });

    testWidgets('OnboardingScreen renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OnboardingScreen(onComplete: () {}),
        ),
      );

      // Onboarding screen should render
      expect(find.byType(OnboardingScreen), findsOneWidget);
    });

    testWidgets('LanguageSelectionScreen renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LanguageSelectionScreen(
            onLanguageSelected: () {},
          ),
        ),
      );

      // Language selection screen should render
      expect(find.byType(LanguageSelectionScreen), findsOneWidget);
    });
  });
}
