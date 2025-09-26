import 'package:flutter/material.dart';
import '../../services/coach_service.dart';

class CoachScheduleScreen extends StatefulWidget {
  const CoachScheduleScreen({super.key});
  @override
  State<CoachScheduleScreen> createState() => _CoachScheduleScreenState();
}

class _CoachScheduleScreenState extends State<CoachScheduleScreen> {
  bool loading = true;
  String? error;
  List<Map<String, dynamic>> sessions = [];
  Map<String, dynamic>? coach;

  // Quota
  int available = 0;
  int used = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    coach ??= ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (coach != null) _load();
  }

  Future<void> _load() async {
    setState(() { loading = true; error = null; });
    try {
      final svc = CoachService();
      final result = await Future.wait([
        svc.schedule(coach!['id'].toString()),
        svc.bookingSummary(),
      ]);
      sessions = (result[0] as List<Map<String, dynamic>>);
      final summary = (result[1] as Map<String, dynamic>);
      available = (summary['available'] as num?)?.toInt() ?? 0;
      used = (summary['used'] as num?)?.toInt() ?? 0;
    } catch (e) {
      error = 'Failed to load schedule';
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  bool get _quotaExceeded => available > 0 && used >= available;

  @override
  Widget build(BuildContext context) {
    final green = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(coach != null ? 'Schedule - ${coach!['name']}' : 'Schedule'),
        backgroundColor: Colors.black,
        foregroundColor: green,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    children: [
                      if (_quotaExceeded)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.08),
                              border: Border.all(color: Colors.red.withOpacity(0.4)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'You have used $used of $available sessions. Upgrade or wait to book more.',
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: sessions.length,
                        itemBuilder: (context, index) {
                          final s = sessions[index];
                          final availableSlot = s['available'] == true;
                          final disabled = !availableSlot || _quotaExceeded;
                          return Card(
                            color: Colors.black,
                            child: ListTile(
                              title: Text('${s['date']} • ${s['time']}', style: TextStyle(color: green)),
                              subtitle: Text(
                                availableSlot ? 'Available' : 'Unavailable',
                                style: TextStyle(color: availableSlot ? green : Colors.white70),
                              ),
                              trailing: ElevatedButton(
                                onPressed: disabled
                                    ? null
                                    : () {
                                        Navigator.pushNamed(
                                          context,
                                          '/booking_confirm',
                                          arguments: {'coach': coach, 'session': s},
                                        ).then((_) => _load());
                                      },
                                child: const Text('Book'),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
    );
  }
}