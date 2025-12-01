import 'package:flutter/material.dart';

import '../../models/intake_models.dart';
import '../../state/app_state.dart';
import 'first_intake_screen.dart';
import 'intake_state.dart';
import 'plan_generation_screen.dart';
import 'second_intake_screen.dart';

class IntakeFlow extends StatefulWidget {
  const IntakeFlow({super.key});

  @override
  State<IntakeFlow> createState() => _IntakeFlowState();
}

class _IntakeFlowState extends State<IntakeFlow> {
  final IntakeState intake = IntakeState();
  bool _hydrated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hydrated) return;
    final app = AppStateScope.of(context);
    final first = app.intakeProgress.first;
    final second = app.intakeProgress.second;
    if (first != null) {
      intake.gender = first.gender;
      intake.goal = first.mainGoal;
      intake.workoutLocation = first.workoutLocation;
    }
    if (second != null) {
      intake.setAge(second.age);
      intake.weightKg = second.weight;
      intake.heightCm = second.height;
      intake.experience = second.experienceLevel;
      intake.daysPerWeek = second.workoutFrequency;
      intake.injuries
        ..clear()
        ..addAll(second.injuries);
    }
    _hydrated = true;
  }

  Future<void> _handleFirstComplete(FirstIntakeData data) async {
    intake.gender = data.gender;
    intake.goal = data.mainGoal;
    intake.workoutLocation = data.workoutLocation;

    final app = AppStateScope.of(context);
    await app.saveFirstIntake(data);
    if (!mounted) return;
    if (!app.needsSecondIntake) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      setState(() {});
    }
  }

  Future<void> _handleSecondComplete(SecondIntakeData data) async {
    intake.setAge(data.age);
    intake.weightKg = data.weight;
    intake.heightCm = data.height;
    intake.experience = data.experienceLevel;
    intake.daysPerWeek = data.workoutFrequency;
    intake.injuries
      ..clear()
      ..addAll(data.injuries);

    final app = AppStateScope.of(context);
    await app.saveSecondIntake(data);
    if (!mounted) return;
    await AppStateScope.of(context).completeIntake();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => PlanGenerationScreen(intake: intake)),
    );
  }

  Future<void> _handleSkipSecond() async {
    final app = AppStateScope.of(context);
    await app.skipSecondIntake();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    if (app.needsSecondIntake) {
      return SecondIntakeScreen(
        intake: intake,
        onComplete: _handleSecondComplete,
        onSkip: _handleSkipSecond,
      );
    }
    return FirstIntakeScreen(
      intake: intake,
      onComplete: _handleFirstComplete,
    );
  }
}