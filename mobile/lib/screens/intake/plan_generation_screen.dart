import 'dart:async';
import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import 'intake_state.dart';
import '../../services/plan_generator.dart';

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
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
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
                  Text('$progress%', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: cs.primary)),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                step,
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}