import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/workout_service.dart';
import '../../state/app_state.dart';

class WorkoutSessionScreen extends StatefulWidget {
  const WorkoutSessionScreen({super.key});

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  bool loading = true;
  String? error;

  Map<String, dynamic>? workout;
  String? workoutId;
  String? sessionId;

  int currentExercise = 0;
  final Map<int, List<Map<String, dynamic>>> recorded = {}; // exerciseIndex -> sets

  // Rest timer
  Timer? _restTimer;
  int restSeconds = 0;

  final svc = WorkoutService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final id = args?['workoutId']?.toString();
    if (id != null && id != workoutId) {
      workoutId = id;
      _load(id);
    } else if (args?['workout'] is Map<String, dynamic>) {
      workout = args!['workout'] as Map<String, dynamic>;
      workoutId = (workout!['id'] ?? workout!['_id']).toString();
      _start();
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
    } catch (_) {
      error = 'Failed to load workout';
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _start() async {
    try {
      final res = await svc.startSession(workoutId!);
      sessionId = (res['sessionId'] ?? res['id'] ?? '').toString();
    } catch (_) {
      // allow offline tracking
      sessionId ??= 'local-${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  List<Map<String, dynamic>> get _exercises =>
      (workout?['exercises'] as List?)?.cast<Map<String, dynamic>>() ?? const [];

  void _startRest(int seconds) {
    _restTimer?.cancel();
    setState(() => restSeconds = seconds);
    _restTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (restSeconds <= 1) {
        t.cancel();
        if (mounted) setState(() => restSeconds = 0);
      } else {
        if (mounted) setState(() => restSeconds -= 1);
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
    setState(() {});
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
      } catch (_) {
        // keep local only
      }
    }
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

  @override
  void dispose() {
    _restTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final units = AppStateScope.of(context).units;

    return Scaffold(
      appBar: AppBar(
        title: Text((workout?['name'] ?? 'Workout').toString()),
        actions: [
          TextButton(
            // use theme primary
            style: TextButton.styleFrom(foregroundColor: cs.primary),
            onPressed: _finish,
            child: const Text('Finish'),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!, style: TextStyle(color: cs.error)))
              : (_exercises.isEmpty
                  ? Center(child: Text('No exercises', style: TextStyle(color: cs.onSurfaceVariant)))
                  : Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (restSeconds > 0)
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: cs.primary.withOpacity(0.6)),
                                  color: cs.primary.withOpacity(0.08),
                                ),
                                child: Text('Rest: ${restSeconds}s', style: TextStyle(color: cs.primary, fontSize: 16)),
                              ),
                            ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _exercises.length,
                              itemBuilder: (_, i) {
                                final e = _exercises[i];
                                final sets = (e['sets'] as List?)?.cast<Map<String, dynamic>>() ?? [];
                                return Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          (e['name'] ?? 'Exercise').toString(),
                                          style: TextStyle(color: cs.primary, fontSize: 16, fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(height: 8),
                                        ...List.generate(sets.isEmpty ? 3 : sets.length, (sIdx) {
                                          final targetReps = (sets.isNotEmpty ? sets[sIdx]['reps'] : null) as num?;
                                          final rest = (sets.isNotEmpty ? sets[sIdx]['rest'] : null) as num?;
                                          final repsCtrl = TextEditingController(text: targetReps?.toString() ?? '');
                                          final weightCtrl = TextEditingController();
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 6),
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: 36,
                                                  child: Text('#${sIdx + 1}', style: TextStyle(color: cs.onSurfaceVariant)),
                                                ),
                                                Expanded(
                                                  child: TextField(
                                                    controller: repsCtrl,
                                                    keyboardType: TextInputType.number,
                                                    decoration: const InputDecoration(labelText: 'Reps'),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: TextField(
                                                    controller: weightCtrl,
                                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                    decoration: InputDecoration(labelText: 'Weight ($units)'),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    final reps = int.tryParse(repsCtrl.text.trim()) ?? (targetReps?.toInt() ?? 0);
                                                    final weight = double.tryParse(weightCtrl.text.trim()) ?? 0.0;
                                                    _saveSet(exerciseIndex: i, setIndex: sIdx, reps: reps, weight: weight);
                                                    final restS = (rest?.toInt() ?? 60).clamp(10, 300);
                                                    _startRest(restS);
                                                  },
                                                  child: const Text('Save'),
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                        if ((recorded[i] ?? []).isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 8),
                                            child: Text(
                                              'Recorded: ${recorded[i]!.map((s) => '${s['reps']}x@${s['weight']}$units').join(', ')}',
                                              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    )),
    );
  }
}