import 'package:flutter/material.dart';
import '../../state/app_state.dart';

class WorkoutPlanScreen extends StatefulWidget {
  const WorkoutPlanScreen({super.key});
  @override
  State<WorkoutPlanScreen> createState() => _WorkoutPlanScreenState();
}

class _WorkoutPlanScreenState extends State<WorkoutPlanScreen> {
  Map<String, dynamic>? _plan;
  bool _loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_plan == null && _loading) {
      _load();
    }
  }

  Future<void> _load() async {
    final app = AppStateScope.of(context);
    if (app.demoMode) {
      setState(() {
        _plan = app.demoWorkoutPlan;
        _loading = false;
      });
      return;
    }
    try {
      // TODO: real fetch
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        _plan = app.workoutPlan; // may be null; UI handles
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_plan == null) {
      return Center(
        child: Text('No plan available', style: TextStyle(color: cs.onSurfaceVariant)),
      );
    }
    // ...render plan...
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(_plan?['name'] ?? 'Workout Plan', style: Theme.of(context).textTheme.titleLarge),
        // TODO: list days
      ],
    );
  }
}