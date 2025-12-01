import 'dart:async';
import 'package:flutter/material.dart';
import '../../design_system/design_tokens.dart';
import '../../design_system/theme_extensions.dart';
import '../../services/plan_generator.dart';
import '../../state/app_state.dart';
import 'intake_state.dart';

class PlanGenerationScreen extends StatefulWidget {
  final IntakeState intake;
  const PlanGenerationScreen({super.key, required this.intake});

  @override
  State<PlanGenerationScreen> createState() => _PlanGenerationScreenState();
}

class _PlanGenerationScreenState extends State<PlanGenerationScreen> {
  int progress = 1;
  String step = 'Starting...';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _simulate();
  }

  Future<void> _simulate() async {
    final gen = PlanGenerator();

    void updateStep(String s) {
      if (!mounted) return;
      setState(() => step = s);
      // bump progress a bit per step
      if (progress < 90) {
        progress += 5;
      }
    }

    _timer = Timer.periodic(const Duration(milliseconds: 120), (t) {
      if (!mounted) return;
      setState(() {
        if (progress < 95) progress += 1;
      });
    });

    final workoutFuture = gen.generateWorkout(widget.intake, onStep: updateStep);
    final nutritionFuture = gen.generateNutrition(widget.intake, onStep: updateStep);

    final workoutPlan = await workoutFuture;
    final nutritionPlan = await nutritionFuture;

    if (!mounted) return;
    setState(() {
      step = 'Finalizing';
      progress = 100;
    });

    await AppStateScope.of(context).updatePlans(workout: workoutPlan, nutrition: nutritionPlan);
    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final gradient = theme.extension<FitCoachSurfaces>()?.primaryCTA ?? FitCoachGradients.primaryCTA;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: CircularProgressIndicator(
                        value: progress / 100,
                        strokeWidth: 10,
                      ),
                    ),
                    Text(
                      '$progress%',
                      style: theme.textTheme.headlineSmall?.copyWith(color: cs.onPrimary) ??
                          TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: cs.onPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  step,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(color: cs.onPrimary.withValues(alpha: 0.9)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}