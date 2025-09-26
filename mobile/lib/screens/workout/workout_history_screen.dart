import 'package:flutter/material.dart';
import '../../services/workout_service.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  bool loading = true;
  String? error;
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      items = await WorkoutService().history();
    } catch (_) {
      error = 'Failed to load history';
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).colorScheme.primary;
    final errorColor = Theme.of(context).colorScheme.error;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout History'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(error!, style: TextStyle(color: errorColor)),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _load, child: const Text('Retry')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final it = items[i];
                      final name = (it['workoutName'] ?? it['name'] ?? 'Workout').toString();
                      final date = (it['date'] ?? it['finishedAt'] ?? '').toString();
                      final vol = (it['volume'] as num?)?.toDouble();
                      return ListTile(
                        title: Text(name, style: TextStyle(color: brand, fontWeight: FontWeight.w600)),
                        subtitle: Text(date),
                        trailing: vol == null
                            ? null
                            : Text('${vol.toStringAsFixed(1)} kg', style: TextStyle(color: brand, fontWeight: FontWeight.w600)),
                      );
                    },
                  ),
                ),
    );
  }
}