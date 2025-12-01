import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';

import '../../services/coach_service.dart';
import '../../state/app_state.dart';

class BookingConfirmScreen extends StatefulWidget {
  const BookingConfirmScreen({super.key});

  @override
  State<BookingConfirmScreen> createState() => _BookingConfirmScreenState();
}

class _BookingConfirmScreenState extends State<BookingConfirmScreen> {
  final _coachService = CoachService();
  bool _submitting = false;

  Map<String, dynamic>? get _args =>
      ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

  Map<String, dynamic>? get _coach => _args?['coach'] as Map<String, dynamic>?;
  Map<String, dynamic>? get _session => _args?['session'] as Map<String, dynamic>?;

  DateTime? _resolveStart(Map<String, dynamic> session) {
    final iso = session['iso']?.toString() ?? session['scheduledAt']?.toString();
    if (iso != null) {
      final parsed = DateTime.tryParse(iso);
      if (parsed != null) return parsed;
    }
    final date = session['date']?.toString();
    final time = session['time']?.toString();
    if (date != null && time != null) {
      return DateTime.tryParse('$date $time');
    }
    return null;
  }

  Future<void> _confirm() async {
    final coach = _coach;
    final session = _session;
    final app = AppStateScope.of(context);
    final userId = app.user?['id']?.toString() ?? app.user?['_id']?.toString();
    if (coach == null || session == null || userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing booking information.')),
      );
      return;
    }
    final start = _resolveStart(session);
    if (start == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to determine selected time.')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      final booked = await _coachService.bookSession(
        coachId: coach['id'].toString(),
        userId: userId,
        start: start,
      );
      await app.refreshQuota(force: true);
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/video_calls',
        arguments: {'newCall': booked},
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to confirm booking: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _addToCalendar() {
    final coach = _coach;
    final session = _session;
    if (coach == null || session == null) return;
    final start = _resolveStart(session) ??
        DateTime.tryParse('${session['date']} ${session['time']}') ??
        DateTime.now().add(const Duration(minutes: 10));
    final event = Event(
      title: 'Coaching with ${coach['name'] ?? ''}',
      description: 'FitCoach coaching session',
      startDate: start,
      endDate: start.add(const Duration(minutes: 45)),
      iosParams: const IOSParams(reminder: Duration(minutes: 5)),
      androidParams: const AndroidParams(),
    );
    Add2Calendar.addEvent2Cal(event);
  }

  @override
  Widget build(BuildContext context) {
    final green = Theme.of(context).colorScheme.primary;
    final coach = _coach;
    final session = _session;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Confirm Booking'),
        backgroundColor: Colors.black,
        foregroundColor: green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: (coach == null || session == null)
            ? const Center(child: Text('Missing booking info', style: TextStyle(color: Colors.white)))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Coach: ${coach['name']}', style: TextStyle(color: green, fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('Specialty: ${coach['specialty'] ?? ''}', style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 16),
                  Text('Date: ${session['date'] ?? session['label'] ?? ''}', style: const TextStyle(color: Colors.white)),
                  Text('Time: ${session['time'] ?? ''}', style: const TextStyle(color: Colors.white)),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _submitting ? null : _confirm,
                    child: _submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Confirm Booking'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _addToCalendar,
                    child: const Text('Add to Calendar'),
                  ),
                ],
              ),
      ),
    );
  }
}