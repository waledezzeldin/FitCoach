import 'package:flutter/material.dart';

import '../../models/home_summary.dart';
import '../../models/quota_models.dart';
import '../../state/app_state.dart';
import '../../widgets/demo_banner.dart';
import '../../widgets/quota_usage_banner.dart';
import '../../widgets/subscription_manager_sheet.dart';

const HomeQuickActions _kDefaultQuickActions = HomeQuickActions(
  canBookVideoSession: true,
  canViewProgress: true,
  canAccessExerciseLibrary: true,
  hasInBodyData: false,
  canShopSupplements: true,
);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    final summary = app.homeSummary ?? (app.demoMode ? HomeSummary.fromLegacyStats(app.demoStats) : null);
    final quickStats = summary?.quickStats;
    final macros = summary?.macros ?? const HomeMacroSummary.placeholder();
    final weekly = summary?.weeklyProgress ?? const HomeWeeklyProgress(completionPct: 0, completedSessions: 0, targetSessions: 0);
    final todaysWorkout = summary?.todayWorkout;
    final quota = app.quotaSnapshot ?? summary?.quota;
    final quickActions = summary?.quickActions ?? _kDefaultQuickActions;
    final fallbackPlan = app.demoMode ? app.demoWorkoutPlan : app.workoutPlan;
    final displayName = _firstName((app.user?['name'] ?? app.demoProfile['name'])?.toString());
    final tierLabel = SubscriptionTierDisplay.parse(app.subscriptionType).label;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              app.refreshHomeSummary(force: true),
              app.refreshQuota(force: true),
            ]);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              _HomeHero(
                name: displayName,
                tierLabel: tierLabel,
                isDemo: app.demoMode,
                quickStats: quickStats,
                weekly: weekly,
                onComparePlans: () => _openSubscriptionManager(context),
                onToggleDemo: () => app.toggleDemoMode(),
                isLoading: app.homeSummaryLoading,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (app.homeSummaryError != null)
                      _ErrorBanner(
                        message: app.homeSummaryError!,
                        onRetry: () => app.refreshHomeSummary(force: true),
                      ),
                    if (quota != null)
                      QuotaUsageBanner(
                        snapshot: quota,
                        onUpgrade: () => _openSubscriptionManager(context),
                        margin: const EdgeInsets.only(bottom: 20),
                      ),
                    _TodayWorkoutCard(
                      summaryWorkout: todaysWorkout,
                      fallbackPlan: fallbackPlan,
                      onStartWorkout: () => _openWorkoutSession(context),
                    ),
                    const SizedBox(height: 20),
                    _QuickAccessCard(
                      actions: quickActions,
                      onBookVideo: () => _handleVideoBooking(context, quickActions),
                      onViewProgress: () => _openProgress(context),
                      onExerciseLibrary: () => _openExerciseLibrary(context),
                      onInBody: () => _showInBodyPrompt(context),
                      onSupplements: () => _openStore(context),
                    ),
                    const SizedBox(height: 20),
                    _MacroBreakdownCard(macros: macros),
                    const SizedBox(height: 20),
                    _WeeklyProgressCard(weekly: weekly),
                    if (summary?.upcomingSession != null) ...[
                      const SizedBox(height: 20),
                      _UpcomingSessionCard(session: summary!.upcomingSession!),
                    ],
                    const SizedBox(height: 20),
                    _CoachSupportCard(onContact: () => _showCoachDialog(context)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _firstName(String? value) {
    if (value == null || value.isEmpty) return 'Friend';
    return value.split(' ').first;
  }

  static void _openSubscriptionManager(BuildContext context) {
    SubscriptionManagerSheet.show(context);
  }

  static void _openWorkoutSession(BuildContext context) {
    Navigator.of(context).pushNamed('/workout_session');
  }

  static void _handleVideoBooking(BuildContext context, HomeQuickActions actions) {
    if (!actions.canBookVideoSession) {
      _openSubscriptionManager(context);
      return;
    }
    Navigator.of(context).pushNamed('/bookings');
  }

  static void _openProgress(BuildContext context) {
    Navigator.of(context).pushNamed('/workout_history');
  }

  static void _openExerciseLibrary(BuildContext context) {
    Navigator.of(context).pushNamed('/workout_plan');
  }

  static void _openStore(BuildContext context) {
    Navigator.of(context).pushNamed('/store');
  }

  static Future<void> _showInBodyPrompt(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('InBody Scan Data', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text('Log a new scan or import results from your last visit.', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI scan will be available soon.')));
                },
                icon: const Icon(Icons.auto_awesome),
                label: const Text('AI Scan (Coming Soon)'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Manual entry will be available soon.')));
                },
                icon: const Icon(Icons.edit_note_outlined),
                label: const Text('Manual Entry'),
              ),
            ],
          ),
        );
      },
    );
  }

  static void _showCoachDialog(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
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
              subtitle: const Text('Schedule a quick check-in'),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline),
              title: const Text('Chat with Coach'),
              subtitle: const Text('Send a progress update'),
              onTap: () => Navigator.pop(ctx),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _HomeHero extends StatelessWidget {
  const _HomeHero({
    required this.name,
    required this.tierLabel,
    required this.isDemo,
    required this.quickStats,
    required this.weekly,
    required this.onComparePlans,
    required this.onToggleDemo,
    required this.isLoading,
  });

  final String name;
  final String tierLabel;
  final bool isDemo;
  final HomeQuickStats? quickStats;
  final HomeWeeklyProgress weekly;
  final VoidCallback onComparePlans;
  final VoidCallback onToggleDemo;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final caloriesBurned = quickStats?.caloriesBurnedWeek ?? 0;
    final caloriesConsumed = quickStats?.caloriesConsumedToday ?? 0;
    final dailyGoal = quickStats?.targetCalories ?? 0;
    final adherence = quickStats?.nutritionAdherencePct ?? 0;
    final streak = quickStats?.streakDays ?? 0;
    final workoutsCompleted = weekly.completedSessions;
    final workoutTarget = weekly.targetSessions;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hello, $name! 👋', style: textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('Ready to crush today\'s plan?', style: textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.8))),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(tierLabel, style: textTheme.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                  if (isDemo) const SizedBox(height: 8),
                  if (isDemo) const DemoBanner(),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF2563EB)),
                onPressed: onComparePlans,
                icon: const Icon(Icons.workspace_premium_outlined),
                label: const Text('Compare Plans'),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: onToggleDemo,
                child: Text(isDemo ? 'Disable Demo' : 'Enable Demo', style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
          if (isLoading) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(minHeight: 4, backgroundColor: Colors.white.withValues(alpha: 0.2), valueColor: const AlwaysStoppedAnimation<Color>(Colors.white)),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              _HeroStatCard(
                icon: Icons.local_fire_department,
                title: 'Calories Burned',
                value: caloriesBurned.toString(),
                caption: 'This week',
              ),
              const SizedBox(width: 12),
              _HeroStatCard(
                icon: Icons.restaurant_menu,
                title: 'Calories Consumed',
                value: '$caloriesConsumed/$dailyGoal',
                caption: 'Today',
              ),
              const SizedBox(width: 12),
              _HeroStatCard(
                icon: Icons.flag_circle,
                title: 'Plan Adherence',
                value: '$adherence%',
                caption: streak > 0 ? '🔥 $streak day streak' : 'Stay consistent',
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Weekly Progress', style: textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text('$workoutsCompleted/$workoutTarget sessions', style: textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.8))),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (weekly.completionPct / 100).clamp(0.0, 1.0).toDouble(),
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 6,
                ),
                const SizedBox(height: 6),
                Text('${weekly.completionPct}% complete', style: textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.8))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStatCard extends StatelessWidget {
  const _HeroStatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.caption,
  });

  final IconData icon;
  final String title;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 8),
            Text(value, style: textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(title, style: textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.7))),
            Text(caption, style: textTheme.labelSmall?.copyWith(color: Colors.white.withValues(alpha: 0.6))),
          ],
        ),
      ),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  const _QuickAccessCard({
    required this.actions,
    required this.onBookVideo,
    required this.onViewProgress,
    required this.onExerciseLibrary,
    required this.onInBody,
    required this.onSupplements,
  });

  final HomeQuickActions actions;
  final VoidCallback onBookVideo;
  final VoidCallback onViewProgress;
  final VoidCallback onExerciseLibrary;
  final VoidCallback onInBody;
  final VoidCallback onSupplements;

  @override
  Widget build(BuildContext context) {
    final tiles = <_QuickActionButton>[
      _QuickActionButton(
        icon: Icons.videocam_outlined,
        title: 'Book Video Session',
        subtitle: 'Schedule time with your coach',
        background: const Color(0xFFF3E8FF),
        iconColor: const Color(0xFF7C3AED),
        borderColor: const Color(0xFFD9B8FF),
        textColor: const Color(0xFF4C1D95),
        enabled: actions.canBookVideoSession,
        onTap: onBookVideo,
      ),
      _QuickActionButton(
        icon: Icons.trending_up,
        title: 'View Progress',
        subtitle: 'Check recent workouts',
        onTap: onViewProgress,
      ),
      _QuickActionButton(
        icon: Icons.fitness_center,
        title: 'Exercise Library',
        subtitle: 'Browse your plan moves',
        onTap: onExerciseLibrary,
      ),
      _QuickActionButton(
        icon: Icons.monitor_heart,
        title: 'InBody Scan Data',
        subtitle: actions.hasInBodyData ? 'View latest stats' : 'Add your metrics',
        background: const Color(0xFFE0F2FE),
        iconColor: const Color(0xFF0369A1),
        borderColor: const Color(0xFF7DD3FC),
        textColor: const Color(0xFF0C4A6E),
        onTap: onInBody,
      ),
      _QuickActionButton(
        icon: Icons.shopping_bag_outlined,
        title: 'Supplements',
        subtitle: 'Shop curated products',
        onTap: onSupplements,
      ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick Access', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            for (final tile in tiles) ...[
              tile,
              if (tile != tiles.last) const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.background,
    this.borderColor,
    this.iconColor,
    this.textColor,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? background;
  final Color? borderColor;
  final Color? iconColor;
  final Color? textColor;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bg = background ?? scheme.surface;
    final border = borderColor ?? scheme.outlineVariant;
    final text = textColor ?? scheme.onSurface;

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        backgroundColor: bg,
        side: BorderSide(color: border),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      onPressed: enabled ? onTap : null,
      child: Row(
        children: [
          Icon(icon, color: enabled ? (iconColor ?? scheme.primary) : scheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall?.copyWith(color: enabled ? text : scheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: enabled ? text.withValues(alpha: 0.8) : scheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroBreakdownCard extends StatelessWidget {
  const _MacroBreakdownCard({required this.macros});

  final HomeMacroSummary macros;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = [
      {'label': 'Protein', 'entry': macros.protein, 'color': const Color(0xFF2563EB)},
      {'label': 'Carbs', 'entry': macros.carbs, 'color': const Color(0xFF10B981)},
      {'label': 'Fat', 'entry': macros.fats, 'color': const Color(0xFFF59E0B)},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nutrition Today', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            for (var i = 0; i < items.length; i++) ...[
              _MacroRow(
                label: items[i]['label'] as String,
                entry: items[i]['entry'] as MacroEntry,
                color: items[i]['color'] as Color,
              ),
              if (i < items.length - 1) const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  const _MacroRow({required this.label, required this.entry, required this.color});

  final String label;
  final MacroEntry entry;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final consumed = entry.consumed.toDouble();
    final target = entry.target.toDouble();
    final progress = target == 0 ? 0.0 : (consumed / target).clamp(0.0, 1.0).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            const Spacer(),
            Text('${consumed.toStringAsFixed(0)}g · ${target.toStringAsFixed(0)}g', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _TodayWorkoutCard extends StatelessWidget {
  const _TodayWorkoutCard({
    required this.summaryWorkout,
    required this.fallbackPlan,
    required this.onStartWorkout,
  });

  final HomeWorkoutPreview? summaryWorkout;
  final Map<String, dynamic>? fallbackPlan;
  final VoidCallback onStartWorkout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final planExercises = _extractPlanExercises(fallbackPlan);
    final hasContent = summaryWorkout != null || planExercises.isNotEmpty;
    if (!hasContent) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('No workout plan loaded yet.', style: theme.textTheme.bodyMedium),
        ),
      );
    }

    final title = summaryWorkout?.title ?? "Today's Workout";
    final duration = summaryWorkout?.durationMin;
    final exerciseCount = summaryWorkout?.exercisesLogged ?? planExercises.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text("Today's Workout", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text('Today', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Row(
              children: [
                if (duration != null && duration > 0) ...[
                  const Icon(Icons.timer_outlined, size: 16),
                  const SizedBox(width: 4),
                  Text('${duration.round()} min', style: theme.textTheme.bodySmall),
                  const SizedBox(width: 12),
                ],
                const Icon(Icons.fitness_center, size: 16),
                const SizedBox(width: 4),
                Text('$exerciseCount exercises', style: theme.textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 12),
            for (final block in planExercises.take(4)) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(child: Text(block['exercise']?.toString() ?? '', style: theme.textTheme.bodyMedium)),
                    Text('${block['sets'] ?? '-'}x${block['reps'] ?? '-'}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary)),
                  ],
                ),
              ),
            ],
            if (planExercises.length > 4)
              Text('+ ${planExercises.length - 4} more', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onStartWorkout,
              child: const Text('Start Workout'),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _extractPlanExercises(Map<String, dynamic>? plan) {
    if (plan == null) return const [];
    final days = plan['days'];
    if (days is! List || days.isEmpty) return const [];
    final todayIndex = (DateTime.now().weekday - 1).clamp(0, days.length - 1);
    final day = days[todayIndex];
    final blocks = day is Map ? day['blocks'] : null;
    if (blocks is! List) return const [];
    return blocks.whereType<Map>().map((e) => e.map((key, value) => MapEntry(key.toString(), value))).toList();
  }
}

class _WeeklyProgressCard extends StatelessWidget {
  const _WeeklyProgressCard({required this.weekly});

  final HomeWeeklyProgress weekly;

  @override
  Widget build(BuildContext context) {
    final pct = (weekly.completionPct / 100).clamp(0.0, 1.0).toDouble();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Weekly Completion', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                Text('${weekly.completedSessions}/${weekly.targetSessions} sessions', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: pct, minHeight: 10),
            const SizedBox(height: 8),
            Text('You\'re ${weekly.completionPct}% to your goal.', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _UpcomingSessionCard extends StatelessWidget {
  const _UpcomingSessionCard({required this.session});

  final HomeSessionSummary session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = MaterialLocalizations.of(context);
    final dateLabel = '${formatter.formatFullDate(session.scheduledAt)} · ${formatter.formatTimeOfDay(TimeOfDay.fromDateTime(session.scheduledAt))}';
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(Icons.video_camera_front_outlined, color: theme.colorScheme.primary),
        ),
        title: const Text('Upcoming Session'),
        subtitle: Text(session.coachName == null ? dateLabel : '${session.coachName} · $dateLabel'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).pushNamed('/bookings'),
      ),
    );
  }
}

class _CoachSupportCard extends StatelessWidget {
  const _CoachSupportCard({required this.onContact});

  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.support_agent, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(child: Text('Need help? Get in touch with your coach.', style: theme.textTheme.bodyMedium)),
            FilledButton(onPressed: onContact, child: const Text('Contact')),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: scheme.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Unable to refresh home data', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: scheme.onErrorContainer, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(message, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onErrorContainer)),
                TextButton(onPressed: onRetry, child: const Text('Retry')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
