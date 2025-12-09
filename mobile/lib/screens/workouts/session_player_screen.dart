import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitcoach/workouts/session_controller.dart';
import 'package:fitcoach/workouts/session_models.dart';
import 'package:fitcoach/ui/button.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:fitcoach/l10n/app_localizations.dart';

class SessionPlayerScreen extends StatelessWidget {
  final String id;
  final List<WorkoutStep>? initialSteps;
  const SessionPlayerScreen({super.key, required this.id, this.initialSteps});

  String _fmt(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return ChangeNotifierProvider(
      create: (_) => SessionController(initialSteps: initialSteps ?? [
        WorkoutStep(id: 's1', title: 'Warm-up', durationSeconds: 60),
        WorkoutStep(id: 's2', title: 'Set 1', durationSeconds: 120),
        WorkoutStep(id: 's3', title: 'Set 2', durationSeconds: 120),
        WorkoutStep(id: 's4', title: 'Cooldown', durationSeconds: 60),
      ]),
      child: Scaffold(
        appBar: AppBar(title: Text(t.sessionTitle(id))),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Consumer<SessionController>(
            builder: (context, c, _) {
              if (c.autoAdvanced) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Step completed, advancing'), duration: Duration(milliseconds: 1200)),
                  );
                  c.autoAdvanced = false;
                });
              }
              return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(t.elapsed, style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 8),
                Text(_fmt(c.elapsed), style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    itemCount: c.steps.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final s = c.steps[index];
                      return InkWell(
                        onTap: () => c.toggleComplete(index),
                        child: Row(
                          children: [
                            if (s.durationSeconds != null && index == c.currentIndex)
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  value: () {
                                    final total = s.durationSeconds!;
                                    final rem = c.currentStepRemainingSeconds ?? total;
                                    final done = (total - rem).clamp(0, total).toDouble();
                                    return total == 0 ? 0.0 : done / total.toDouble();
                                  }(),
                                ),
                              )
                            else
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    s.completed ? Icons.check_circle : Icons.radio_button_unchecked,
                                    color: s.completed ? Theme.of(context).colorScheme.primary : Theme.of(context).hintColor,
                                  ),
                                  if (s.completed)
                                    Positioned(
                                      right: -2,
                                      top: -2,
                                      child: Icon(Icons.check, size: 12, color: Theme.of(context).colorScheme.onPrimary),
                                    ),
                                ],
                              ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(s.title, style: Theme.of(context).textTheme.titleMedium)),
                            if (s.durationSeconds != null)
                              Builder(builder: (context) {
                                final isCurrent = index == c.currentIndex;
                                final remaining = isCurrent ? c.currentStepRemainingSeconds : s.durationSeconds;
                                final text = remaining == null ? '' : '${remaining}s';
                                return Text(text, style: Theme.of(context).textTheme.bodySmall);
                              }),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        label: c.running ? t.pause : t.start,
                        onPressed: c.running ? c.pause : c.start,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GhostButton(
                        label: t.reset,
                        onPressed: c.reset,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: GhostButton(key: const Key('sessionPrev'), label: t.prev, onPressed: c.prev)),
                    const SizedBox(width: 12),
                    Expanded(child: GhostButton(key: const Key('sessionSkip'), label: t.skip, onPressed: c.skipCurrent)),
                    const SizedBox(width: 12),
                    Expanded(child: GhostButton(key: const Key('sessionNext'), label: t.next, onPressed: c.next)),
                  ],
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: t.completeSession,
                  onPressed: c.allComplete
                      ? () {
                          final completed = c.steps.where((s) => s.completed).length;
                          final result = SessionResult(
                            workoutId: id,
                            elapsed: c.elapsed,
                            completedSteps: completed,
                            totalSteps: c.steps.length,
                          );
                          HapticFeedback.lightImpact();
                          context.push('/workouts/$id/session/complete', extra: result);
                        }
                      : null,
                ),
              ],
            );
            },
          ),
        ),
      ),
    );
  }
}
