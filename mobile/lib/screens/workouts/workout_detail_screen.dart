import 'package:flutter/material.dart';
import 'package:fitcoach/ui/button.dart';
import 'package:go_router/go_router.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final String id;
  const WorkoutDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Workout $id')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Plan for $id', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            const Text('This is a placeholder workout detail. Sessions, timers, and completion flow will be implemented in Phase 8.'),
            const Spacer(),
            PrimaryButton(
              label: 'Start Session',
              onPressed: () => context.push('/workouts/$id/session'),
            ),
          ],
        ),
      ),
    );
  }
}
