import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:fitcoach_plus/design_system/theme_extensions.dart';
import 'package:fitcoach_plus/models/intake_models.dart';
import 'package:fitcoach_plus/screens/intake/first_intake_screen.dart';
import 'package:fitcoach_plus/screens/intake/intake_state.dart';
import 'package:fitcoach_plus/screens/intake/second_intake_screen.dart';
import 'package:fitcoach_plus/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _transparent1x1PngBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAAWgmWQ0AAAAASUVORK5CYII=';

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    fail('Could not locate widget for finder: $finder');
  }
  final target = finder.first;
  await tester.ensureVisible(target);
  await tester.pump();
  await tester.tap(target, warnIfMissed: false);
  await tester.pump();
}

Future<void> _waitForSignal(WidgetTester tester, Completer<void> signal) async {
  const step = Duration(milliseconds: 25);
  const timeout = Duration(seconds: 2);
  var elapsed = Duration.zero;
  while (!signal.isCompleted && elapsed < timeout) {
    await tester.pump(step);
    elapsed += step;
  }
  if (!signal.isCompleted) {
    fail('Timed out waiting for async callback to complete within $timeout.');
  }
}

Future<void> _installAssetHandler() async {
  final binding = TestDefaultBinaryMessengerBinding.instance;
  final messenger = binding.defaultBinaryMessenger;
  final pngBytes = base64Decode(_transparent1x1PngBase64);
  final pngByteData = pngBytes.buffer.asByteData();
  final jsonByteData = Uint8List.fromList(utf8.encode('{}')).buffer.asByteData();

  messenger.setMockMessageHandler('flutter/assets', (ByteData? message) async {
    final keyBytes = message?.buffer.asUint8List();
    final key = keyBytes == null ? '' : utf8.decode(keyBytes);
    if (key.endsWith('.json')) {
      return jsonByteData;
    }
    return pngByteData;
  });
}

Widget _wrapWithApp(Widget child, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme ?? AppTheme.light,
    home: child,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await _installAssetHandler();
  });

  group('FirstIntakeScreen', () {
    testWidgets('blocks submission until selections are complete', (tester) async {
      final submittedSignal = Completer<void>();
      FirstIntakeData? submitted;
      await tester.pumpWidget(
        _wrapWithApp(
          FirstIntakeScreen(
            intake: IntakeState(),
            onComplete: (data) async {
              submitted = data;
              if (!submittedSignal.isCompleted) {
                submittedSignal.complete();
              }
            },
          ),
        ),
      );

      final continueButtonFinder = find.byKey(FirstIntakeScreen.continueButtonKey);
      expect(continueButtonFinder, findsOneWidget);
      await _tapVisible(tester, continueButtonFinder);
      expect(find.text('Please complete every section.'), findsOneWidget);
      expect(submittedSignal.isCompleted, isFalse);

      await _tapVisible(tester, find.text('Female'));
      await _tapVisible(tester, find.text('Lose weight'));
      await _tapVisible(tester, find.text('Home workouts'));

      await _tapVisible(tester, continueButtonFinder);
      await _waitForSignal(tester, submittedSignal);
      expect(submitted, isNotNull);
      expect(submitted!.gender, 'female');
      expect(submitted!.mainGoal, 'lose_weight');
      expect(submitted!.workoutLocation, 'home');
    });

    testWidgets('honors custom FitCoach surface gradients', (tester) async {
      const customGradient = LinearGradient(
        colors: [Colors.orange, Colors.pink],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
      final theme = AppTheme.light.copyWith(
        extensions: <ThemeExtension<dynamic>>[
          FitCoachSurfaces.light().copyWith(firstIntake: customGradient),
        ],
      );

      await tester.pumpWidget(
        _wrapWithApp(
          FirstIntakeScreen(
            intake: IntakeState(),
            onComplete: (_) async {},
          ),
          theme: theme,
        ),
      );

      final decoratedContainer = tester.widgetList<Container>(find.byType(Container)).firstWhere((container) {
        final decoration = container.decoration;
        return decoration is BoxDecoration && identical(decoration.gradient, customGradient);
      });
      final decoration = decoratedContainer.decoration as BoxDecoration;
      expect(identical(decoration.gradient, customGradient), isTrue);
    });
  });

  group('SecondIntakeScreen', () {
    testWidgets('collects metrics and calls onComplete', (tester) async {
      final submissionSignal = Completer<void>();
      SecondIntakeData? submission;
      final intake = IntakeState();

      await tester.pumpWidget(
        _wrapWithApp(
          SecondIntakeScreen(
            intake: intake,
            onComplete: (data) async {
              submission = data;
              if (!submissionSignal.isCompleted) {
                submissionSignal.complete();
              }
            },
            onSkip: () async {},
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.enterText(find.widgetWithText(TextField, 'Age (years)'), '29');
      await tester.enterText(find.widgetWithText(TextField, 'Weight (kg)'), '71.5');
      await tester.enterText(find.widgetWithText(TextField, 'Height (cm)'), '168');
      await tester.pump();
      final experienceChipFinder = find.byKey(SecondIntakeScreen.experienceChipKey('beginner'));
      final daysChipFinder = find.byKey(SecondIntakeScreen.daysChipKey(4));
      expect(experienceChipFinder, findsOneWidget);
      expect(daysChipFinder, findsOneWidget);
      await _tapVisible(tester, experienceChipFinder);
      await _tapVisible(tester, daysChipFinder);
      expect(tester.widget<ChoiceChip>(experienceChipFinder).selected, isTrue);
      expect(tester.widget<ChoiceChip>(daysChipFinder).selected, isTrue);

      final finishButtonFinder = find.byKey(SecondIntakeScreen.finishButtonKey);
      expect(finishButtonFinder, findsOneWidget);
      await _tapVisible(tester, finishButtonFinder);
      await _waitForSignal(tester, submissionSignal);
      expect(submission, isNotNull);
      expect(submission!.age, 29);
      expect(submission!.experienceLevel, 'beginner');
      expect(submission!.workoutFrequency, 4);
      expect(intake.ageYears, 29);
      expect(intake.daysPerWeek, 4);
      expect(intake.weightKg, 71.5);
      expect(intake.heightCm, 168);
    });

    testWidgets('allows users to skip the second stage', (tester) async {
      final skippedSignal = Completer<void>();
      await tester.pumpWidget(
        _wrapWithApp(
          SecondIntakeScreen(
            intake: IntakeState(),
            onComplete: (_) async {},
            onSkip: () async {
              if (!skippedSignal.isCompleted) {
                skippedSignal.complete();
              }
            },
          ),
        ),
      );

      final skipButtonFinder = find.byKey(SecondIntakeScreen.skipButtonKey);
      expect(skipButtonFinder, findsOneWidget);
      await _tapVisible(tester, skipButtonFinder);
      await _waitForSignal(tester, skippedSignal);
    });
  });
}
