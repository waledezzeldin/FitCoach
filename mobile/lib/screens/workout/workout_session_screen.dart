import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../localization/app_localizations.dart';
import '../../services/workout_service.dart';
import '../../state/app_state.dart';

enum _WorkoutView { overview, active }

class WorkoutSessionScreen extends StatefulWidget {
  WorkoutSessionScreen({super.key, WorkoutService? service, this.autoStartFirstExercise = false})
      : service = service ?? WorkoutService();

  final WorkoutService service;
  final bool autoStartFirstExercise;

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  late final WorkoutService svc;

  bool loading = true;
  String? error;

  Map<String, dynamic>? workout;
  String? workoutId;
  String? sessionId;

  int currentExercise = 0;
  final Map<int, List<Map<String, dynamic>>> recorded = {};

  Timer? _restTimer;
  int _restSeconds = 0;
  bool _restTimerRunning = false;

  _WorkoutView _view = _WorkoutView.overview;

  bool _showIntro = false;
  bool _introLoaded = false;
  bool _showFirstTimeOverlay = false;
  bool _intakeBannerDismissed = false;

  DateTime? _workoutStartedAt;
  int _totalCalories = 0;

  final TextEditingController _repsController = TextEditingController(text: '8');
  final TextEditingController _weightController = TextEditingController(text: '0');

  SharedPreferences? _prefs;

  static const List<String> _injuryAreas = ['shoulder', 'knee', 'lower_back', 'neck', 'ankle'];
  String? _lastSelectedInjury;
  bool _autoStartHandled = false;

  @override
  void initState() {
    super.initState();
    svc = widget.service;
    _initIntroPrefs();
  }

  Future<void> _initIntroPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    _prefs = prefs;
    final seen = prefs.getBool('fc_workout_intro_seen') ?? false;
    setState(() {
      _showIntro = !seen;
      _introLoaded = true;
    });
  }

  Future<void> _dismissIntro() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setBool('fc_workout_intro_seen', true);
    if (!mounted) return;
    setState(() => _showIntro = false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final id = args?['workoutId']?.toString();
    if (id != null && id != workoutId) {
      workoutId = id;
      _load(id);
    } else if (args?['workout'] is Map<String, dynamic>) {
      workout = args!['workout'] as Map<String, dynamic>;
      workoutId = (workout!['id'] ?? workout!['_id']).toString();
      _start();
      loading = false;
      _scheduleAutoStartIfNeeded();
    }
  }

  Future<void> _load(String id) async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      workout = await svc.getWorkout(id);
      await _start();
      _scheduleAutoStartIfNeeded();
    } catch (_) {
      error = 'Failed to load workout';
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _scheduleAutoStartIfNeeded() {
    if (_autoStartHandled || !widget.autoStartFirstExercise) return;
    if (workout == null || _exercises.isEmpty) return;
    _autoStartHandled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startExercise(0);
      }
    });
  }

  Future<void> _start() async {
    try {
      final res = await svc.startSession(workoutId!);
      sessionId = (res['sessionId'] ?? res['id'] ?? '').toString();
    } catch (_) {
      sessionId ??= 'local-${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  List<Map<String, dynamic>> get _exercises =>
      (workout?['exercises'] as List?)?.cast<Map<String, dynamic>>() ?? const [];

  int _setCount(Map<String, dynamic> exercise) {
    final sets = exercise['sets'];
    if (sets is List && sets.isNotEmpty) return sets.length;
    return 3;
  }

  int _recordedCount(int index) => recorded[index]?.length ?? 0;

  bool _exerciseCompleted(int index) {
    if (index >= _exercises.length) return false;
    return _recordedCount(index) >= _setCount(_exercises[index]);
  }

  double get _workoutProgress {
    if (_exercises.isEmpty) return 0;
    final completed = List.generate(_exercises.length, (i) => _exerciseCompleted(i) ? 1 : 0).fold<int>(0, (sum, v) => sum + v);
    return completed / _exercises.length;
  }

  Future<void> _startExercise(int index) async {
    if (index < 0 || index >= _exercises.length) return;
    final exercise = _exercises[index];
    final reps = (exercise['sets'] is List && (exercise['sets'] as List).isNotEmpty)
        ? ((exercise['sets'] as List).first['reps']?.toString() ?? '8')
        : '8';
    final rest = (exercise['sets'] is List && (exercise['sets'] as List).isNotEmpty)
        ? ((exercise['sets'] as List).first['rest'] as num?)?.toInt()
        : 60;
    final id = (exercise['id'] ?? exercise['_id'] ?? 'ex_$index').toString();
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final seen = prefs.getBool('fc_workout_ex_seen_$id') ?? false;
    setState(() {
      currentExercise = index;
      _view = _WorkoutView.active;
      _repsController.text = reps;
      _weightController.text = '0';
      _restSeconds = rest ?? 60;
      _showFirstTimeOverlay = !seen;
      _workoutStartedAt ??= DateTime.now();
      _restTimerRunning = false;
    });
  }

  Future<void> _acknowledgeExerciseTutorial() async {
    final exercise = _exercises.isEmpty ? null : _exercises[currentExercise];
    if (exercise == null) return;
    final id = (exercise['id'] ?? exercise['_id'] ?? 'ex_$currentExercise').toString();
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setBool('fc_workout_ex_seen_$id', true);
    if (!mounted) return;
    setState(() => _showFirstTimeOverlay = false);
  }

  void _exitExerciseView() {
    _restTimer?.cancel();
    setState(() {
      _view = _WorkoutView.overview;
      _restTimerRunning = false;
    });
  }

  void _toggleRestTimer() {
    setState(() => _restTimerRunning = !_restTimerRunning);
  }

  void _resetRestTimer() {
    _restTimer?.cancel();
    setState(() {
      _restTimerRunning = false;
      _restSeconds = _currentRestTarget;
    });
  }

  int get _currentRestTarget {
    final exercise = _exercises.isEmpty ? null : _exercises[currentExercise];
    if (exercise == null) return 60;
    final sets = exercise['sets'];
    return (sets is List && sets.isNotEmpty ? (sets.first['rest'] as num?)?.toInt() : null) ?? 60;
  }

  void _startRestCountdown(int seconds) {
    _restTimer?.cancel();
    setState(() {
      _restSeconds = seconds;
      _restTimerRunning = true;
    });
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (!_restTimerRunning) return;
      if (_restSeconds <= 1) {
        timer.cancel();
        setState(() {
          _restSeconds = 0;
          _restTimerRunning = false;
        });
      } else {
        setState(() => _restSeconds -= 1);
      }
    });
  }

  Future<void> _saveSet({
    required int exerciseIndex,
    required int setIndex,
    required int reps,
    required double weight,
  }) async {
    recorded.putIfAbsent(exerciseIndex, () => []);
    recorded[exerciseIndex]!.add({'set': setIndex, 'reps': reps, 'weight': weight});
    setState(() {
      _totalCalories += _estimateCalories(reps, weight);
    });
    if (sessionId != null && workout != null) {
      final exId = (_exercises[exerciseIndex]['id'] ?? _exercises[exerciseIndex]['_id'] ?? '').toString();
      try {
        await svc.recordSet(
          sessionId: sessionId!,
          exerciseId: exId,
          setIndex: setIndex,
          reps: reps,
          weight: weight,
        );
      } catch (_) {}
    }
  }

  int _estimateCalories(int reps, double weight) {
    final base = reps * (weight > 0 ? weight * 0.08 : 1.2);
    return (base + 10).clamp(5, 120).round();
  }

  Future<void> _logActiveSet() async {
    final reps = int.tryParse(_repsController.text.trim()) ?? 0;
    final weight = double.tryParse(_weightController.text.trim()) ?? 0;
    final setIndex = _recordedCount(currentExercise);
    await _saveSet(exerciseIndex: currentExercise, setIndex: setIndex, reps: reps, weight: weight);
    final rest = _currentRestTarget;
    _startRestCountdown(rest.clamp(15, 180));
  }

  Future<void> _finish() async {
    _restTimer?.cancel();
    if (sessionId != null) {
      try {
        await svc.finishSession(sessionId!);
      } catch (_) {}
    }
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _refresh() async {
    if (workoutId == null) return;
    await _load(workoutId!);
  }

  void _showSnack(String message) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  String _friendlyError(Object error) {
    final text = error.toString();
    return text.startsWith('Exception: ') ? text.substring(11) : text;
  }

  String? _currentUserId() {
    final user = AppStateScope.of(context).user;
    final raw = user?['id'] ?? user?['_id'] ?? user?['userId'];
    final value = raw?.toString();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  String? _asString(dynamic value) => value?.toString();

  Future<T> _runWithLoader<T>(Future<T> Function() task) async {
    if (!mounted) return task();
    final navigator = Navigator.of(context, rootNavigator: true);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      return await task();
    } finally {
      if (mounted) navigator.pop();
    }
  }

  Future<void> _startInjuryFlow(int exerciseIndex) async {
    final exercises = _exercises;
    if (exerciseIndex < 0 || exerciseIndex >= exercises.length) return;
    final selection = await _selectInjuryArea(exercises[exerciseIndex]);
    if (selection == null || !mounted) return;
    List<Map<String, dynamic>> alternatives;
    try {
      final muscle = _asString(exercises[exerciseIndex]['muscleGroup']);
      alternatives = await _runWithLoader(() => svc.injuryAlternatives(
            injuryArea: selection,
            muscleGroup: muscle,
          ));
      if (!mounted) return;
    } catch (error) {
      _showSnack(_friendlyError(error));
      return;
    }
    if (!mounted) return;
    if (alternatives.isEmpty) {
      final l10n = context.l10n;
      _showSnack(l10n.t('workouts.noAlternatives'));
      return;
    }
    final choice = await _chooseAlternative(alternatives, selection);
    if (choice == null || !mounted) return;
    await _applyAlternative(exerciseIndex: exerciseIndex, alternative: choice, injuryArea: selection);
  }

  Future<String?> _selectInjuryArea(Map<String, dynamic> exercise) async {
    final l10n = context.l10n;
    final exerciseName = (exercise['name'] ?? 'Exercise').toString();
    final result = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetCtx) {
        String? selection = _lastSelectedInjury;
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final bottom = MediaQuery.of(ctx).viewPadding.bottom;
            return Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, bottom + 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.t('workouts.injuryDialog.title'), style: Theme.of(ctx).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    l10n.t('workouts.injuryDialog.description').replaceAll('{exercise}', exerciseName),
                    style: Theme.of(ctx).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(l10n.t('workouts.injuryDialog.selectArea'), style: Theme.of(ctx).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _injuryAreas
                        .map(
                          (area) => ChoiceChip(
                            label: Text(l10n.t('injuries.$area')),
                            selected: selection == area,
                            onSelected: (_) => setSheetState(() => selection = area),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Theme.of(ctx).colorScheme.primary, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.t('workouts.injuryDialog.impactNotice'),
                          style: Theme.of(ctx).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(sheetCtx).pop(),
                        child: Text(l10n.t('common.cancel')),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: selection == null ? null : () => Navigator.of(sheetCtx).pop(selection),
                        child: Text(l10n.t('workouts.findAlternative')),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    if (!mounted) return null;
    if (result != null) setState(() => _lastSelectedInjury = result);
    return result;
  }

  Future<Map<String, dynamic>?> _chooseAlternative(
    List<Map<String, dynamic>> alternatives,
    String injuryArea,
  ) async {
    final l10n = context.l10n;
    final injuryLabel = l10n.t('injuries.$injuryArea');
    final description = l10n.t('workouts.alternatives.description').replaceAll('{injury}', injuryLabel);
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        final bottom = MediaQuery.of(ctx).viewPadding.bottom;
        final height = MediaQuery.of(ctx).size.height * 0.6;
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, bottom + 16),
          child: SizedBox(
            height: height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.t('workouts.alternatives.title'), style: Theme.of(ctx).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(description, style: Theme.of(ctx).textTheme.bodyMedium),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    itemCount: alternatives.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, index) {
                      final alt = alternatives[index];
                      final muscle = _asString(alt['muscleGroup']);
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text((alt['name'] ?? 'Alternative').toString(), style: Theme.of(ctx).textTheme.titleSmall),
                              if (muscle != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(muscle, style: Theme.of(ctx).textTheme.bodySmall),
                                ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  children: [
                                    Icon(Icons.shield_moon_outlined, size: 16, color: Theme.of(ctx).colorScheme.primary),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        '${l10n.t('workouts.safeFor')} $injuryLabel',
                                        style: Theme.of(ctx).textTheme.bodySmall,
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.of(ctx).pop(alt),
                                      child: Text(l10n.t('workouts.useThis')),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(l10n.t('common.cancel')),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _applyAlternative({
    required int exerciseIndex,
    required Map<String, dynamic> alternative,
    required String injuryArea,
  }) async {
    final exercisesList = (workout?['exercises'] as List?)?.cast<Map<String, dynamic>>();
    if (exercisesList == null || exerciseIndex >= exercisesList.length) return;
    final original = Map<String, dynamic>.from(exercisesList[exerciseIndex]);
    final baseOriginalId = _asString(original['id'] ?? original['_id']) ?? 'exercise_$exerciseIndex';
    final altId = _asString(alternative['id'] ?? alternative['_id'] ?? alternative['exerciseId']) ?? 'alt_${DateTime.now().millisecondsSinceEpoch}';
    final updated = Map<String, dynamic>.from(original);
    updated['id'] = altId;
    updated['name'] = alternative['name'] ?? alternative['title'] ?? original['name'];
    updated['muscleGroup'] = alternative['muscleGroup'] ?? original['muscleGroup'];
    updated['isSwapped'] = true;
    updated['originalExerciseId'] = original['originalExerciseId'] ?? baseOriginalId;
    updated['originalExerciseName'] = original['originalExerciseName'] ?? original['name'];
    updated.removeWhere((key, value) => value == null);
    setState(() {
      exercisesList[exerciseIndex] = Map<String, dynamic>.from(updated);
    });
    final userId = _currentUserId();
    if (userId != null) {
      unawaited(
        svc
            .recordInjurySwap(
              userId: userId,
              sessionId: sessionId,
              originalExerciseId: baseOriginalId,
              alternativeExerciseId: altId,
              injuryArea: injuryArea,
            )
            .catchError((_) {}),
      );
    }
    _showSnack(context.l10n.t('workouts.swapSuccess'));
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    final cs = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    Widget body;
    if (loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (error != null) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(error!, style: TextStyle(color: cs.error)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: () => _refresh(), child: Text(l10n.t('common.retry'))),
          ],
        ),
      );
    } else if (_exercises.isEmpty) {
      body = Center(child: Text('No exercises', style: TextStyle(color: cs.onSurfaceVariant)));
    } else {
      body = _view == _WorkoutView.active ? _buildActiveView(app) : _buildOverview(app);
    }

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(child: body),
          if (_showIntro && _introLoaded) _WorkoutIntroOverlay(onDismiss: _dismissIntro),
          if (_showFirstTimeOverlay && _view == _WorkoutView.active)
            _ExerciseTutorialOverlay(
              onDismiss: _acknowledgeExerciseTutorial,
              exerciseName: (_exercises.isEmpty ? 'Exercise' : (_exercises[currentExercise]['name'] ?? 'Exercise')).toString(),
            ),
        ],
      ),
    );
  }

  Widget _buildOverview(AppState app) {
    final l10n = context.l10n;
    final exercises = _exercises;
    final completed = (_workoutProgress * exercises.length).round();
    final durationLabel = _formatDuration();

    return RefreshIndicator(
      onRefresh: _refresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _WorkoutHero(
                  name: (workout?['name'] ?? l10n.t('workouts.title')).toString(),
                  progress: _workoutProgress,
                  completed: completed,
                  total: exercises.length,
                  durationLabel: durationLabel,
                  calories: _totalCalories,
                ),
                if (app.needsSecondIntake && !_intakeBannerDismissed)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: _SecondIntakeBanner(
                      onComplete: () => Navigator.of(context).pushNamed('/intake'),
                      onBookCall: () => Navigator.of(context).pushNamed('/coach_list'),
                      onDismiss: () => setState(() => _intakeBannerDismissed = true),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _WorkoutOverviewCard(workout: workout, progress: _workoutProgress),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final exercise = exercises[index];
                  final completedSets = _recordedCount(index);
                  final totalSets = _setCount(exercise);
                  final isActive = index == currentExercise && _view == _WorkoutView.active;
                  final isCompleted = completedSets >= totalSets;
                  return Padding(
                    padding: EdgeInsets.only(bottom: index == exercises.length - 1 ? 0 : 12),
                    child: _ExerciseTimelineCard(
                      index: index,
                      exercise: exercise,
                      completedSets: completedSets,
                      totalSets: totalSets,
                      isActive: isActive,
                      isCompleted: isCompleted,
                      onView: () => _showExerciseDetails(exercise),
                      onStart: () => _startExercise(index),
                      onReportInjury: () => _startInjuryFlow(index),
                    ),
                  );
                },
                childCount: exercises.length,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pushNamed('/workout_history'),
                      child: Text(l10n.t('workouts.previousWorkout')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _workoutProgress >= 1 ? _finish : () => _startExercise(currentExercise),
                        child: Text(_workoutProgress >= 1
                          ? l10n.t('workouts.completed')
                          : l10n.t('workouts.continueWorkout')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveView(AppState app) {
    final l10n = context.l10n;
    final exercise = _exercises[currentExercise];
    final completedSets = _recordedCount(currentExercise);
    final totalSets = _setCount(exercise);
    final hasCompleted = completedSets >= totalSets;

    return Column(
      children: [
        _ActiveExerciseHeader(
          exercise: exercise,
          currentSet: completedSets + 1,
          totalSets: totalSets,
          onBack: _exitExerciseView,
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ExerciseStatsRow(exercise: exercise, completedSets: completedSets, totalSets: totalSets),
              const SizedBox(height: 16),
              _VideoPlaceholder(title: l10n.t('workouts.exerciseDemo')),
              const SizedBox(height: 16),
              if (_restSeconds > 0)
                _RestTimerCard(
                  seconds: _restSeconds,
                  isRunning: _restTimerRunning,
                  onToggle: _toggleRestTimer,
                  onReset: _resetRestTimer,
                ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                key: const Key('report_injury_button'),
                onPressed: () => _startInjuryFlow(currentExercise),
                icon: const Icon(Icons.health_and_safety_outlined),
                label: Text(l10n.t('workouts.reportInjury')),
              ),
              const SizedBox(height: 16),
              if (!hasCompleted)
                _LogSetCard(
                  repsController: _repsController,
                  weightController: _weightController,
                  units: app.units,
                  onLog: _logActiveSet,
                ),
              if (completedSets > 0) ...[
                const SizedBox(height: 16),
                _LoggedSetsList(recorded: recorded[currentExercise] ?? [], units: app.units),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: FilledButton(
            onPressed: hasCompleted
                ? () {
                    if (currentExercise < _exercises.length - 1) {
                      _startExercise(currentExercise + 1);
                    } else {
                      _exitExerciseView();
                    }
                  }
                : _logActiveSet,
            child: Text(hasCompleted
                ? (currentExercise < _exercises.length - 1
                    ? context.l10n.t('workouts.nextExercise')
                    : context.l10n.t('workouts.finishWorkout'))
                : context.l10n.t('workouts.logSet')),
          ),
        ),
      ],
    );
  }

  void _showExerciseDetails(Map<String, dynamic> exercise) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        final sets = exercise['sets'] as List? ?? const [];
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 12, 24, 12 + MediaQuery.of(ctx).viewPadding.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text((exercise['name'] ?? 'Exercise').toString(), style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text((exercise['description'] ?? context.l10n.t('workouts.exerciseDemo')).toString(),
                  style: Theme.of(ctx).textTheme.bodyMedium),
              const SizedBox(height: 16),
              ...sets.map((set) {
                final reps = set['reps'];
                final rest = set['rest'];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(child: Text('${context.l10n.t('workouts.reps')}: $reps')),
                      Text('${context.l10n.t('workouts.restTime')}: ${rest ?? 60}s'),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _startExercise(_exercises.indexOf(exercise));
                },
                child: Text(context.l10n.t('workouts.start')),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration() {
    if (_workoutStartedAt == null) return '0:00';
    final diff = DateTime.now().difference(_workoutStartedAt!);
    final minutes = diff.inMinutes;
    final seconds = diff.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class _WorkoutHero extends StatelessWidget {
  const _WorkoutHero({
    required this.name,
    required this.progress,
    required this.completed,
    required this.total,
    required this.durationLabel,
    required this.calories,
  });

  final String name;
  final double progress;
  final int completed;
  final int total;
  final String durationLabel;
  final int calories;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [cs.primary, cs.primary.withValues(alpha: 0.8)]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: cs.onPrimary)),
          const SizedBox(height: 8),
          Row(
            children: [
              Chip(
                label: Text('${(progress * 100).round()}% complete'),
                backgroundColor: cs.onPrimary.withValues(alpha: 0.1),
                labelStyle: TextStyle(color: cs.onPrimary),
              ),
              const SizedBox(width: 8),
              Chip(
                label: Text(durationLabel),
                backgroundColor: cs.onPrimary.withValues(alpha: 0.1),
                labelStyle: TextStyle(color: cs.onPrimary),
              ),
              if (calories > 0) ...[
                const SizedBox(width: 8),
                Chip(
                  label: Text('🔥 $calories cal'),
                  backgroundColor: cs.secondaryContainer.withValues(alpha: 0.3),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress.clamp(0, 1),
            color: cs.onPrimary,
            backgroundColor: cs.onPrimary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 8),
          Text('$completed of $total exercises complete', style: TextStyle(color: cs.onPrimary.withValues(alpha: 0.8))),
        ],
      ),
    );
  }
}

class _WorkoutOverviewCard extends StatelessWidget {
  const _WorkoutOverviewCard({required this.workout, required this.progress});

  final Map<String, dynamic>? workout;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _OverviewStat(label: l10n.t('workouts.exercises'), value: (workout?['exercises'] as List?)?.length.toString() ?? '0'),
            _OverviewStat(label: l10n.t('workouts.duration'), value: '${workout?['duration'] ?? '45'} min'),
            _OverviewStat(label: l10n.t('workouts.complete'), value: '${(progress * 100).round()}%'),
          ],
        ),
      ),
    );
  }
}

class _OverviewStat extends StatelessWidget {
  const _OverviewStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _ExerciseTimelineCard extends StatelessWidget {
  const _ExerciseTimelineCard({
    required this.index,
    required this.exercise,
    required this.completedSets,
    required this.totalSets,
    required this.isActive,
    required this.isCompleted,
    required this.onView,
    required this.onStart,
    required this.onReportInjury,
  });

  final int index;
  final Map<String, dynamic> exercise;
  final int completedSets;
  final int totalSets;
  final bool isActive;
  final bool isCompleted;
  final VoidCallback onView;
  final VoidCallback onStart;
  final VoidCallback onReportInjury;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final badgeColor = isCompleted ? cs.tertiaryContainer : (isActive ? cs.primaryContainer : cs.surfaceContainerHighest);
    return Card(
      elevation: isActive ? 4 : 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: badgeColor,
                  child: Text('${index + 1}', style: TextStyle(color: cs.onPrimaryContainer)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text((exercise['name'] ?? 'Exercise').toString(),
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                if (exercise['isSwapped'] == true)
                  Chip(
                    label: Text(l10n.t('workouts.swapped')),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text('$completedSets/$totalSets ${l10n.t('workouts.sets')} · ${exercise['muscleGroup'] ?? ''}',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(onPressed: onView, child: Text(l10n.t('common.details'))),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(onPressed: onStart, child: Text(isCompleted ? l10n.t('workouts.review') : l10n.t('workouts.start'))),
                ),
                IconButton(onPressed: onReportInjury, icon: const Icon(Icons.medical_information_outlined)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SecondIntakeBanner extends StatelessWidget {
  const _SecondIntakeBanner({required this.onComplete, required this.onBookCall, required this.onDismiss});

  final VoidCallback onComplete;
  final VoidCallback onBookCall;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(colors: [cs.secondaryContainer, cs.primaryContainer]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(l10n.t('intake.banner.title'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: cs.onPrimaryContainer)),
              ),
              IconButton(onPressed: onDismiss, icon: const Icon(Icons.close)),
            ],
          ),
          Text(l10n.t('intake.banner.description'), style: TextStyle(color: cs.onPrimaryContainer)),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: 0.3, backgroundColor: cs.onPrimaryContainer.withValues(alpha: 0.3)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: FilledButton(onPressed: onComplete, child: Text(l10n.t('intake.banner.completeNow'))),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(onPressed: onBookCall, child: Text(l10n.t('intake.banner.bookCall'))),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActiveExerciseHeader extends StatelessWidget {
  const _ActiveExerciseHeader({
    required this.exercise,
    required this.currentSet,
    required this.totalSets,
    required this.onBack,
  });

  final Map<String, dynamic> exercise;
  final int currentSet;
  final int totalSets;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final progress = (currentSet - 1) / totalSets;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(color: cs.primary, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back, color: Colors.white)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text((exercise['name'] ?? 'Exercise').toString(),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: cs.onPrimary)),
                    Text('${exercise['muscleGroup'] ?? ''} · Set $currentSet/$totalSets',
                      style: TextStyle(color: cs.onPrimary.withValues(alpha: 0.8))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: progress.clamp(0, 1), color: cs.onPrimary, backgroundColor: cs.onPrimary.withValues(alpha: 0.2)),
        ],
      ),
    );
  }
}

class _ExerciseStatsRow extends StatelessWidget {
  const _ExerciseStatsRow({required this.exercise, required this.completedSets, required this.totalSets});

  final Map<String, dynamic> exercise;
  final int completedSets;
  final int totalSets;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _OverviewStat(label: l10n.t('workouts.sets'), value: '$totalSets'),
            _OverviewStat(label: l10n.t('workouts.reps'), value: (exercise['sets'] is List && (exercise['sets'] as List).isNotEmpty)
                ? ((exercise['sets'] as List).first['reps'] ?? '8').toString()
                : '8'),
            _OverviewStat(label: l10n.t('workouts.logged'), value: '$completedSets/$totalSets'),
          ],
        ),
      ),
    );
  }
}

class _VideoPlaceholder extends StatelessWidget {
  const _VideoPlaceholder({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.play_circle_outline, size: 48),
              const SizedBox(height: 8),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}

class _RestTimerCard extends StatelessWidget {
  const _RestTimerCard({required this.seconds, required this.isRunning, required this.onToggle, required this.onReset});

  final int seconds;
  final bool isRunning;
  final VoidCallback onToggle;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('$minutes:$secs', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.blue.shade700)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(onPressed: onToggle, icon: Icon(isRunning ? Icons.pause : Icons.play_arrow), label: Text(isRunning ? 'Pause' : 'Start')),
                const SizedBox(width: 12),
                OutlinedButton.icon(onPressed: onReset, icon: const Icon(Icons.refresh), label: const Text('Reset')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LogSetCard extends StatelessWidget {
  const _LogSetCard({required this.repsController, required this.weightController, required this.units, required this.onLog});

  final TextEditingController repsController;
  final TextEditingController weightController;
  final String units;
  final VoidCallback onLog;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.t('workouts.logSet'), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: repsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: l10n.t('workouts.reps')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: '${l10n.t('workouts.weight')} ($units)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton(onPressed: onLog, child: Text(l10n.t('workouts.logSet'))),
          ],
        ),
      ),
    );
  }
}

class _LoggedSetsList extends StatelessWidget {
  const _LoggedSetsList({required this.recorded, required this.units});

  final List<Map<String, dynamic>> recorded;
  final String units;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.t('workouts.completedSets'), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...recorded.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Set ${entry.key + 1}'),
                    Text('${entry.value['reps']} reps · ${entry.value['weight']} $units'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutIntroOverlay extends StatelessWidget {
  const _WorkoutIntroOverlay({required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.7),
        child: Center(
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.fitness_center, size: 48),
                  const SizedBox(height: 12),
                  Text('Welcome to your session', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('Track sets, rest with timers, and swap exercises safely. Ready to begin?', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton(onPressed: onDismiss, child: const Text('Let’s go')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExerciseTutorialOverlay extends StatelessWidget {
  const _ExerciseTutorialOverlay({required this.onDismiss, required this.exerciseName});

  final VoidCallback onDismiss;
  final String exerciseName;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.6),
        child: Center(
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('First time with $exerciseName?', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  const Text('Use the video demo, adjust reps/weight, and save after each set.'),
                  const SizedBox(height: 16),
                  FilledButton(onPressed: onDismiss, child: const Text('Got it')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}