import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fitcoach/app.dart';
import 'package:fitcoach/screens/intake/intake_state.dart';
import 'package:fitcoach/screens/home/home_screen.dart';

void main() {
  testWidgets('Language → Onboarding → Login → Intake1 → Intake2 → Intake3 → Home flow', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => IntakeState()),
        ],
        child: FitCoachApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Language selection
    final englishOption = find.byWidgetPredicate((widget) {
      return widget is InkWell &&
        widget.child is Container &&
        (widget.child as Container).child is Row &&
        ((widget.child as Container).child as Row).children.any((c) =>
          c is Column &&
          c.children.any((t) => t is Text && t.data == 'English')
        );
    });
    expect(englishOption, findsOneWidget);
    await tester.tap(englishOption);
    await tester.pumpAndSettle();

    // Onboarding
    expect(find.textContaining('Welcome'), findsOneWidget);
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // Login
    expect(find.text('Continue with Email'), findsOneWidget);
    await tester.tap(find.text('Continue with Email'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'user@example.com');
    await tester.enterText(find.byType(TextFormField).last, 'password123');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    // Intake Step 1
    expect(find.text('What is your gender?'), findsOneWidget);
    await tester.tap(find.text('Male'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Intake Step 2
    expect(find.text("What's your main goal?"), findsOneWidget);
    await tester.tap(find.text('Fat Loss'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Intake Step 3
    expect(find.text('Where do you prefer to work out?'), findsOneWidget);
    await tester.tap(find.text('Gym'));
    await tester.tap(find.text('Start My Journey'));
    await tester.pumpAndSettle();

    // Home
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
