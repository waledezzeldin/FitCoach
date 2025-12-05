import 'package:flutter/material.dart';

import '../../services/coach_service.dart';
import '../../state/app_state.dart';

class CoachScheduleScreen extends StatefulWidget {
  const CoachScheduleScreen({super.key, this.coach, CoachService? coachService})
      : coachServiceOverride = coachService;

  final Map<String, dynamic>? coach;
  final CoachService? coachServiceOverride;
  @override
  State<CoachScheduleScreen> createState() => _CoachScheduleScreenState();
}

class _CoachScheduleScreenState extends State<CoachScheduleScreen> {
  late final CoachService _coachService;
  bool loading = true;
  String? error;
  List<Map<String, dynamic>> sessions = [];
  Map<String, dynamic>? coach;
  bool _booking = false;

  @override
  void initState() {
    super.initState();
    _coachService = widget.coachServiceOverride ?? CoachService();
    coach = widget.coach;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    coach ??= ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (coach != null && loading) _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final response = await _coachService.availability(coach!['id'].toString());
      sessions = (response['availability'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          const [];
    } catch (_) {
      error = 'Failed to load schedule';
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  bool get _quotaExceeded {
    final quota = AppStateScope.of(context).quotaSnapshot;
    final limit = quota?.limits.calls ?? 0;
    if (limit <= 0) return false;
    return (quota?.usage.callsUsed ?? 0) >= limit;
  }

  Future<void> _bookSlot(String iso) async {
    final app = AppStateScope.of(context);
    final userId = app.user?['id']?.toString() ?? app.user?['_id']?.toString();
    if (userId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please sign in first.')));
      return;
    }
    setState(() => _booking = true);
    try {
      await _coachService.bookSession(
        coachId: coach!['id'].toString(),
        userId: userId,
        start: DateTime.parse(iso),
      );
      await app.refreshQuota(force: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Session booked!')));
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Booking failed: $e')));
    } finally {
      if (mounted) setState(() => _booking = false);
    }
  }

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
                                color: Colors.red.withValues(alpha: 0.08),
                                border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'You have reached your video session quota. Upgrade to Smart Premium for more.',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: sessions.length,
                        itemBuilder: (context, index) {
                          final day = sessions[index];
                          final slots = (day['slots'] as List?) ?? const [];
                          return Card(
                            color: Colors.black,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(day['date']?.toString() ?? '',
                                      style: TextStyle(color: green, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 12),
                                  if (slots.isEmpty)
                                    const Text('No open slots', style: TextStyle(color: Colors.white70))
                                  else
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        for (final slot in slots)
                                          OutlinedButton(
                                            onPressed: _quotaExceeded || _booking
                                                ? null
                                                : () => _bookSlot(slot['iso'] as String),
                                            child: Text(slot['label']?.toString() ?? ''),
                                          ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      if (_booking)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
    );
  }
}