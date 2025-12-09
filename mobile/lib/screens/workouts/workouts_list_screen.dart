import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fitcoach/ui/surface_card.dart';
import 'package:provider/provider.dart';
import 'package:fitcoach/screens/intake/intake_state.dart';
// subscription_state is not used in the reminder variant (generic allowed)
import 'package:fitcoach/l10n/app_localizations.dart';

class WorkoutsListScreen extends StatelessWidget {
  const WorkoutsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = List.generate(5, (i) => ('w${i + 1}', 'Workout ${(i + 1)}'));
    final intake = context.watch<IntakeState>();
    final needsSecondIntake = !intake.second.isValid;
    int completedFields = 0;
    if ((intake.second.experience ?? '').isNotEmpty) completedFields++;
    if ((intake.second.daysPerWeek ?? 0) > 0) completedFields++;
    if (intake.second.injuries) completedFields++;
    final totalFields = 3;
    return Scaffold(
      appBar: AppBar(title: const Text('Workouts')),
      body: Column(
        children: [
          if (needsSecondIntake) _SecondIntakeReminder(
            completed: completedFields,
            total: totalFields,
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final (id, title) = items[index];
                return GestureDetector(
                  onTap: () {
                    // Always allow continue to generic plan; show reminder bar above.
                    context.push('/workouts/$id');
                  },
                  child: SurfaceCard(
                    child: Row(
                      children: [
                        const Icon(Icons.fitness_center),
                        const SizedBox(width: 12),
                        Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SecondIntakeReminder extends StatelessWidget {
  final int completed;
  final int total;
  const _SecondIntakeReminder({required this.completed, required this.total});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = total == 0 ? 0.0 : (completed / total).clamp(0.0, 1.0);
    final t = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.intakeReminderTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(t.intakeReminderDesc),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: progress, minHeight: 8),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ElevatedButton(
                onPressed: () => context.push('/intake/second/1'),
                child: Text(t.completeIntakeCta),
              ),
              OutlinedButton(
                onPressed: () => context.push('/coach'),
                child: Text(t.talkToCoachCta),
              ),
              TextButton(
                onPressed: () {},
                child: Text(t.continueGenericCta),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
