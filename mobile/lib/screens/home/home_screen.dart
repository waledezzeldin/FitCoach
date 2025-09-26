import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../widgets/demo_banner.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final demo = app.demoMode;
    final stats = app.effectiveStats;
    final workoutsDone = stats['workouts_completed_week'] ?? 0;
    final caloriesBurned = stats['calories_burned_week'] ?? 0;
    final consumedToday = stats['calories_consumed_today'] ?? 0;
    final targetCalories =
        stats['target_calories'] ?? (app.nutritionPlan?['calories'] ?? 2000);
    final nutritionProgress = targetCalories == 0
        ? 0.0
        : (consumedToday / targetCalories).clamp(0.0, 1.0);
    final workoutPlan = demo ? app.demoWorkoutPlan : app.workoutPlan;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            if (!app.demoMode) {
              // TODO real refresh
            }
            await Future.delayed(const Duration(milliseconds: 350));
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              Row(
                children: [
                  Text('Dashboard',
                      style: text.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  if (demo) ...[
                    const SizedBox(width: 8),
                    const DemoBanner(),
                  ],
                  const Spacer(),
                  TextButton(
                    onPressed: () => app.toggleDemoMode(),
                    child: Text(demo ? 'Disable Demo' : 'Enable Demo'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _StatsRow(
                workoutsDone: workoutsDone,
                caloriesBurned: caloriesBurned,
                nutritionProgress: nutritionProgress,
                targetCalories: targetCalories,
                consumedCalories: consumedToday,
              ),
              const SizedBox(height: 14),
              _ExtraMiniStats(stats: stats, demo: demo),
              const SizedBox(height: 20),
              _TodayWorkoutPreview(plan: workoutPlan),
              const SizedBox(height: 24),
              _ContactCoachCard(
                onContact: () => _showCoachDialog(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCoachDialog(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: cs.surface,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.call),
              title: const Text('Call Coach'),
              onTap: () {
                Navigator.pop(ctx);
                // TODO: integrate call (url_launcher)
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline),
              title: const Text('Chat with Coach'),
              onTap: () {
                Navigator.pop(ctx);
                // TODO: navigate to chat thread
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ExtraMiniStats extends StatelessWidget {
  final Map<String, dynamic> stats;
  final bool demo;
  const _ExtraMiniStats({required this.stats, required this.demo});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final streak = stats['streak_days'] ?? 0;
    final week = stats['program_week'] ?? 1;
    final delta = stats['weight_progress_kg'];
    final adherence = stats['nutrition_adherence_pct'];
    return Row(
      children: [
        Expanded(
          child: _MiniCard(
            icon: Icons.flash_on,
            label: 'Streak',
            value: '${streak}d',
            color: cs.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniCard(
            icon: Icons.calendar_today,
            label: 'Week',
            value: '$week',
            color: cs.tertiary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniCard(
            icon: Icons.monitor_weight,
            label: 'Weight',
            value: delta == null
                ? '--'
                : (delta > 0 ? '+${delta.toStringAsFixed(1)}kg' : '${delta.toStringAsFixed(1)}kg'),
            color: cs.secondary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniCard(
            icon: Icons.percent,
            label: 'Adherence',
            value: adherence == null ? '--' : '$adherence%',
            color: cs.primary,
          ),
        ),
      ],
    );
  }
}

class _MiniCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _MiniCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      height: 78,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const Spacer(),
          Text(value,
              style: text.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          Text(label,
              style: text.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int workoutsDone;
  final int caloriesBurned;
  final double nutritionProgress;
  final int targetCalories;
  final int consumedCalories;
  const _StatsRow({
    required this.workoutsDone,
    required this.caloriesBurned,
    required this.nutritionProgress,
    required this.targetCalories,
    required this.consumedCalories,
  });
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Workouts',
            value: '$workoutsDone',
            subtitle: 'This week',
            icon: Icons.check_circle,
            color: cs.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Burned',
            value: caloriesBurned.toString(),
            subtitle: 'kcal',
            icon: Icons.local_fire_department,
            color: cs.tertiary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _NutritionProgressCard(
            progress: nutritionProgress,
            consumed: consumedCalories,
            target: targetCalories,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final String? subtitle;
  final Color? color;
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: cs.primary),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(title, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _NutritionProgressCard extends StatelessWidget {
  final double progress;
  final int consumed;
  final int target;
  const _NutritionProgressCard({
    required this.progress,
    required this.consumed,
    required this.target,
  });
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 36,
            width: 36,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 5,
              backgroundColor: cs.outlineVariant,
              valueColor: AlwaysStoppedAnimation(cs.primary),
            ),
          ),
          const SizedBox(height: 6),
          Text('${(progress * 100).round()}%',
              style: text.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          Text('Nutrition',
              style: text.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _TodayWorkoutPreview extends StatelessWidget {
  final Map<String, dynamic>? plan;
  const _TodayWorkoutPreview({required this.plan});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    if (plan == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('No workout plan loaded yet.', style: text.bodyMedium),
        ),
      );
    }
    final days = (plan?['days'] as List?) ?? [];
    final today = DateTime.now().weekday; // 1 Mon
    final idx = days.isEmpty ? 0 : (today - 1) % days.length;
    final day = days.isEmpty ? null : days[idx] as Map?;
    final blocks = (day?['blocks'] as List?) ?? [];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Today\'s Workout',
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          if (day == null)
            Text('Plan missing day data', style: text.bodySmall)
          else
            for (final b in blocks.take(4))
              if (b is Map)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    '${b['exercise'] ?? b['name']}  ${b['sets'] ?? ''}x${b['reps'] ?? ''}',
                    style:
                        text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
          if (blocks.length > 4)
            Text('+ ${blocks.length - 4} more',
                style: text.labelSmall?.copyWith(color: cs.primary)),
        ]),
      ),
    );
  }
}

class _ContactCoachCard extends StatelessWidget {
  final VoidCallback onContact;
  const _ContactCoachCard({required this.onContact});
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.support_agent, color: cs.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Need help? Contact your coach',
                  style: text.bodyMedium),
            ),
            FilledButton(
              onPressed: onContact,
              child: const Text('Contact'),
            ),
          ],
        ),
      ),
    );
  }
}