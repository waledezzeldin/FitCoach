import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../localization/app_localizations.dart';
import '../../state/app_state.dart';

class WorkoutPlanScreen extends StatefulWidget {
  const WorkoutPlanScreen({super.key});

  @override
  State<WorkoutPlanScreen> createState() => _WorkoutPlanScreenState();
}

class _WorkoutPlanScreenState extends State<WorkoutPlanScreen> {
  static const _kTutorialPref = 'fc_workout_plan_intro_seen';

  Map<String, dynamic>? _plan;
  List<_WorkoutDay> _days = const <_WorkoutDay>[];
  List<List<_WorkoutDay>> _weeks = const <List<_WorkoutDay>>[];
  bool _loading = true;
  bool _showTutorial = false;
  bool _didLoad = false;
  String? _error;
  int _weekIndex = 0;

  @override
  void initState() {
    super.initState();
    _hydrateTutorialPref();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoad) {
      _didLoad = true;
      _loadPlan();
    }
  }

  Future<void> _hydrateTutorialPref() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool(_kTutorialPref) ?? false;
    if (!mounted) return;
    setState(() => _showTutorial = !seen);
  }

  Future<void> _dismissTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kTutorialPref, true);
    if (!mounted) return;
    setState(() => _showTutorial = false);
  }

  Future<void> _loadPlan({bool refresh = false}) async {
    final app = AppStateScope.of(context);
    if (!refresh) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final Map<String, dynamic>? plan = app.demoMode ? app.demoWorkoutPlan : app.workoutPlan;
      final parsedDays = _serializeDays(plan);
      setState(() {
        _plan = plan;
        _days = parsedDays;
        _weeks = _chunkWeeks(parsedDays);
        _weekIndex = (_weeks.isEmpty ? 0 : math.min(_weekIndex, _weeks.length - 1));
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: TextStyle(color: cs.error)),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => _loadPlan(),
              child: Text(l10n.t('common.retry')),
            ),
          ],
        ),
      );
    }

    if (_plan == null || _days.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.t('workouts.planEmptyTitle'),
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.t('workouts.planEmptySubtitle'),
                style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => _loadPlan(refresh: true),
                child: Text(l10n.t('common.retry')),
              ),
            ],
          ),
        ),
      );
    }

    final weeks = _weeks.isEmpty ? <List<_WorkoutDay>>[_days] : _weeks;
    final selectedWeek = weeks.isEmpty ? _days : weeks[_weekIndex];
    final currentDay = _currentDay;
    final completedCount = _days.where((day) => day.status == _WorkoutStatus.completed).length;
    final remainingCount = _days.length - completedCount;
    final weekCount = weeks.length;

    return RefreshIndicator(
      onRefresh: () => _loadPlan(refresh: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        children: [
          _PlanHeroCard(
            planName: (_plan?['name'] ?? l10n.t('subscription.workoutPlans')).toString(),
            subtitle: l10n.t('workouts.planHeroSubtitle').replaceFirst('{weeks}', weekCount.toString()),
            completedCount: completedCount,
            remainingCount: remainingCount,
            weekCount: weekCount,
            onStart: currentDay == null ? null : () => _startDay(currentDay),
            startLabel: l10n.t('workouts.planStartToday'),
            l10n: l10n,
          ),
          const SizedBox(height: 16),
          if (_showTutorial)
            _TutorialCard(
              title: l10n.t('workouts.planTutorialTitle'),
              body: l10n.t('workouts.planTutorialBody'),
              dismissLabel: l10n.t('workouts.planDismiss'),
              onDismiss: _dismissTutorial,
            ),
          if (weekCount > 1) ...[
            _WeekSelector(
              weekCount: weekCount,
              activeIndex: _weekIndex,
              onChanged: (index) => setState(() => _weekIndex = index),
              l10n: l10n,
            ),
            const SizedBox(height: 12),
          ],
          for (final day in selectedWeek) ...[
            _WorkoutDayCard(
              day: day,
              onStart: day.status == _WorkoutStatus.rest ? null : () => _startDay(day),
              onDetails: () => _openDetails(day),
              l10n: l10n,
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  List<_WorkoutDay> _serializeDays(Map<String, dynamic>? plan) {
    final rawDays = plan?['days'];
    if (rawDays is! List) return const <_WorkoutDay>[];
    final mapped = rawDays.whereType<Map>().toList();
    final hasExplicitToday = mapped.any((day) => _statusFromString(day['status']) == _WorkoutStatus.today);
    var markedActive = hasExplicitToday;
    final List<_WorkoutDay> result = [];
    for (var i = 0; i < mapped.length; i++) {
      final day = mapped[i];
      final blocks = _parseBlocks(day['blocks']);
      final isRest = day['rest'] == true || blocks.isEmpty;
      var status = _statusFromString(day['status']);
      if (isRest) {
        status = _WorkoutStatus.rest;
      } else if (status == _WorkoutStatus.upcoming && day['completed'] == true) {
        status = _WorkoutStatus.completed;
      } else if (status == _WorkoutStatus.upcoming && !markedActive) {
        status = _WorkoutStatus.today;
        markedActive = true;
      }
      if (status == _WorkoutStatus.today) {
        markedActive = true;
      }
      result.add(
        _WorkoutDay(
          id: (day['id'] ?? 'day_${i + 1}').toString(),
          label: day['day']?.toString() ?? 'Day ${i + 1}',
          focus: day['focus']?.toString() ?? (blocks.isNotEmpty ? blocks.first.title : 'Workout'),
          blocks: blocks,
          status: status,
        ),
      );
    }
    return result;
  }

  List<_WorkoutBlock> _parseBlocks(dynamic value) {
    if (value is! List) return const <_WorkoutBlock>[];
    return value
        .whereType<Map>()
        .map(
          (block) => _WorkoutBlock(
            title: block['exercise']?.toString() ?? block['name']?.toString() ?? 'Exercise',
            sets: (block['sets'] as num?)?.toInt(),
            reps: block['reps']?.toString(),
            rest: (block['rest'] as num?)?.toInt(),
            muscleGroup: block['muscleGroup']?.toString(),
          ),
        )
        .toList();
  }

  List<List<_WorkoutDay>> _chunkWeeks(List<_WorkoutDay> days) {
    if (days.isEmpty) return const <List<_WorkoutDay>>[];
    final List<List<_WorkoutDay>> chunks = [];
    for (var i = 0; i < days.length; i += 7) {
      chunks.add(days.sublist(i, math.min(i + 7, days.length)));
    }
    return chunks;
  }

  _WorkoutDay? get _currentDay {
    if (_days.isEmpty) return null;
    return _days.firstWhere(
      (day) => day.status == _WorkoutStatus.today,
      orElse: () => _days.firstWhere(
        (day) => day.status == _WorkoutStatus.upcoming,
        orElse: () => _days.first,
      ),
    );
  }

  void _startDay(_WorkoutDay day) {
    final exercises = day.blocks
        .asMap()
        .entries
        .map(
          (entry) => {
            'id': '${day.id}_${entry.key}',
            'name': entry.value.title,
            'muscleGroup': entry.value.muscleGroup,
            'sets': List.generate(
              entry.value.sets ?? 3,
              (_) => {
                'reps': entry.value.reps,
                'rest': entry.value.rest ?? 60,
              },
            ),
          },
        )
        .toList();

    Navigator.of(context).pushNamed(
      '/workout_session',
      arguments: {
        'workout': {
          'id': day.id,
          'name': '${_plan?['name'] ?? 'Workout'} · ${day.label}',
          'duration': exercises.length * 10,
          'exercises': exercises,
        },
      },
    );
  }

  void _openDetails(_WorkoutDay day) {
    final details = day.blocks
        .map((block) => '${block.title} · ${block.sets ?? 3} x ${block.reps ?? '10'}')
        .join('\n');
    Navigator.of(context).pushNamed(
      '/workout_plan_details',
      arguments: {
        'day': day.label,
        'exercise': day.focus,
        'details': details,
        'blocks': day.blocks
            .map((block) => {
                  'title': block.title,
                  'sets': block.sets,
                  'reps': block.reps,
                })
            .toList(),
      },
    );
  }

  _WorkoutStatus _statusFromString(dynamic value) {
    final text = value?.toString().toLowerCase();
    switch (text) {
      case 'completed':
      case 'done':
        return _WorkoutStatus.completed;
      case 'today':
      case 'current':
      case 'active':
        return _WorkoutStatus.today;
      case 'rest':
        return _WorkoutStatus.rest;
      default:
        return _WorkoutStatus.upcoming;
    }
  }
}

class _PlanHeroCard extends StatelessWidget {
  const _PlanHeroCard({
    required this.planName,
    required this.subtitle,
    required this.completedCount,
    required this.remainingCount,
    required this.weekCount,
    required this.onStart,
    required this.startLabel,
    required this.l10n,
  });

  final String planName;
  final String subtitle;
  final int completedCount;
  final int remainingCount;
  final int weekCount;
  final VoidCallback? onStart;
  final String startLabel;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [cs.primary, cs.primaryContainer]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 18, offset: Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(planName, style: theme.textTheme.headlineSmall?.copyWith(color: cs.onPrimary, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(subtitle, style: theme.textTheme.bodyMedium?.copyWith(color: cs.onPrimary.withValues(alpha: 0.8))),
          const SizedBox(height: 16),
          Row(
            children: [
              _HeroStat(value: completedCount.toString(), label: l10n.t('workouts.planCompletedLabel'), color: cs.onPrimary),
              const SizedBox(width: 12),
              _HeroStat(value: remainingCount.toString(), label: l10n.t('workouts.planUpcomingLabel'), color: cs.onPrimary),
              const SizedBox(width: 12),
              _HeroStat(value: weekCount.toString(), label: l10n.t('workouts.planWeeksLabel'), color: cs.onPrimary),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onStart,
            style: FilledButton.styleFrom(backgroundColor: cs.onPrimary, foregroundColor: cs.primary),
            child: Text(startLabel),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.value, required this.label, required this.color});

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: theme.textTheme.headlineSmall?.copyWith(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: theme.textTheme.labelLarge?.copyWith(color: color.withValues(alpha: 0.8))),
        ],
      ),
    );
  }
}

class _TutorialCard extends StatelessWidget {
  const _TutorialCard({required this.title, required this.body, required this.dismissLabel, required this.onDismiss});

  final String title;
  final String body;
  final String dismissLabel;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(body, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: onDismiss, child: Text(dismissLabel)),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekSelector extends StatelessWidget {
  const _WeekSelector({required this.weekCount, required this.activeIndex, required this.onChanged, required this.l10n});

  final int weekCount;
  final int activeIndex;
  final ValueChanged<int> onChanged;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        weekCount,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ChoiceChip(
            label: Text(l10n.t('workouts.planWeek').replaceFirst('{index}', '${index + 1}')),
            selected: index == activeIndex,
            onSelected: (_) => onChanged(index),
          ),
        ),
      ),
    );
  }
}

class _WorkoutDayCard extends StatelessWidget {
  const _WorkoutDayCard({required this.day, required this.onStart, required this.onDetails, required this.l10n});

  final _WorkoutDay day;
  final VoidCallback? onStart;
  final VoidCallback onDetails;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final status = _statusMeta(day.status, l10n, cs);
    final exerciseCountLabel = l10n.t('workouts.planExercisesCount').replaceFirst('{count}', day.blocks.length.toString());

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(day.label, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(day.focus, style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: status.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(999), border: Border.all(color: status.color.withValues(alpha: 0.4))),
                  child: Text(status.label, style: theme.textTheme.labelLarge?.copyWith(color: status.color, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(exerciseCountLabel, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: onStart,
                    child: Text(l10n.t('workouts.planStart')),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(onPressed: onDetails, child: Text(l10n.t('workouts.planViewDetails'))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _StatusMeta _statusMeta(_WorkoutStatus status, AppLocalizations l10n, ColorScheme cs) {
    switch (status) {
      case _WorkoutStatus.completed:
        return _StatusMeta(l10n.t('workouts.planCompletedLabel'), cs.primary);
      case _WorkoutStatus.today:
        return _StatusMeta(l10n.t('workouts.planTodayLabel'), cs.secondary);
      case _WorkoutStatus.rest:
        return _StatusMeta(l10n.t('workouts.planRestLabel'), cs.tertiary);
      case _WorkoutStatus.upcoming:
      default:
        return _StatusMeta(l10n.t('workouts.planUpcomingLabel'), cs.outline);
    }
  }
}

class _StatusMeta {
  const _StatusMeta(this.label, this.color);
  final String label;
  final Color color;
}

class _WorkoutDay {
  const _WorkoutDay({
    required this.id,
    required this.label,
    required this.focus,
    required this.blocks,
    required this.status,
  });

  final String id;
  final String label;
  final String focus;
  final List<_WorkoutBlock> blocks;
  final _WorkoutStatus status;
}

class _WorkoutBlock {
  const _WorkoutBlock({
    required this.title,
    this.sets,
    this.reps,
    this.rest,
    this.muscleGroup,
  });

  final String title;
  final int? sets;
  final String? reps;
  final int? rest;
  final String? muscleGroup;
}

enum _WorkoutStatus { completed, today, upcoming, rest }