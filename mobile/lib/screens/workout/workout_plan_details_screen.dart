import 'package:flutter/material.dart';

class WorkoutPlanDetailsScreen extends StatelessWidget {
  const WorkoutPlanDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final workout = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (workout == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Workout Details')),
        body: Center(
          child: Text(
            'No workout details available.',
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
        ),
      );
    }

    final dayLabel = (workout['day'] ?? 'Workout').toString();
    final exercise = (workout['exercise'] ?? '').toString();
    final details = (workout['details'] ?? '').toString();

    return Scaffold(
      appBar: AppBar(title: Text('$dayLabel Details')),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Text(
            exercise,
            style: TextStyle(color: cs.primary, fontSize: 22, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Text(
            details,
            style: TextStyle(color: cs.onSurface, fontSize: 16),
          ),
          // TODO: Add more details, images, or video links if available
        ],
      ),
    );
  }
}