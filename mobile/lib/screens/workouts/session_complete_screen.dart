import 'package:flutter/material.dart';
import 'package:fitcoach/ui/button.dart';
import 'package:fitcoach/workouts/session_models.dart';

class SessionCompleteScreen extends StatelessWidget {
  final SessionResult result;
  const SessionCompleteScreen({super.key, required this.result});

  String _fmt(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('Workout ${result.workoutId}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Session Complete', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Great job! Here\'s your summary:', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 20),
            _SummaryRow(label: 'Duration', value: _fmt(result.elapsed)),
            const SizedBox(height: 8),
            _SummaryRow(label: 'Steps', value: '${result.completedSteps}/${result.totalSteps}'),
            const Spacer(),
            PrimaryButton(
              label: 'Done',
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst || route.settings.name == '/workouts');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(child: Text(label, style: theme.textTheme.titleMedium)),
        Text(value, style: theme.textTheme.titleMedium),
      ],
    );
  }
}
