import 'package:flutter/material.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import '../../services/coach_service.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});
  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  bool loading = true;
  String? error;
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { loading = true; error = null; });
    try {
      items = await CoachService().listBookings();
    } catch (e) {
      error = 'Failed to load bookings';
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _cancel(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel booking?'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes, cancel')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await CoachService().cancelBooking(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking canceled')));
      _load();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to cancel')));
    }
  }

  Future<void> _addToCalendar(Map<String, dynamic> it) async {
    final title = 'Coaching with ${(it['coachName'] ?? it['coach'] ?? '')}';
    final date = DateTime.tryParse((it['startAt'] ?? it['dateTime'] ?? '').toString()) ??
        DateTime.tryParse('${it['date']} ${it['time']}') ??
        DateTime.now().add(const Duration(minutes: 10));
    final end = date.add(const Duration(minutes: 45));
    final event = Event(
      title: title,
      description: 'FitCoach coaching session',
      location: (it['location'] ?? it['meetingUrl'] ?? '').toString(),
      startDate: date,
      endDate: end,
      iosParams: const IOSParams(reminder: Duration(minutes: 5)),
      androidParams: const AndroidParams(),
    );
    await Add2Calendar.addEvent2Cal(event);
  }

  Future<void> _reschedule(Map<String, dynamic> it) async {
    final coachId = it['coachId']?.toString() ?? '';
    if (coachId.isEmpty) return;
    // Load available sessions for that coach
    List<Map<String, dynamic>> sessions = [];
    try {
      sessions = await CoachService().schedule(coachId);
    } catch (_) {}
    if (!mounted) return;

    String? selectedId;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Pick a new time', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 12),
              SizedBox(
                height: 240,
                child: ListView.builder(
                  itemCount: sessions.length,
                  itemBuilder: (_, i) {
                    final s = sessions[i];
                    final avail = s['available'] == true;
                    final sid = (s['id'] ?? s['sessionId']).toString();
                    return ListTile(
                      title: Text('${s['date']} • ${s['time']}', style: const TextStyle(color: Colors.white)),
                      subtitle: Text(avail ? 'Available' : 'Unavailable', style: TextStyle(color: avail ? Colors.greenAccent : Colors.white70)),
                      trailing: Radio<String>(
                        value: sid,
                        groupValue: selectedId,
                        onChanged: avail ? (v) => setSheet(() => selectedId = v) : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: selectedId == null
                    ? null
                    : () async {
                        Navigator.pop(ctx);
                        try {
                          await CoachService().rescheduleBooking(bookingId: it['id'].toString(), newSessionId: selectedId!);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rescheduled')));
                          _load();
                        } catch (_) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to reschedule')));
                        }
                      },
                child: const Text('Confirm'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final green = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('My Bookings'), backgroundColor: Colors.black, foregroundColor: green),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _load, child: const Text('Retry')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(color: Colors.white12, height: 1),
                    itemBuilder: (_, i) {
                      final it = items[i];
                      final id = (it['id'] ?? '').toString();
                      final coachName = (it['coachName'] ?? it['coach'] ?? '').toString();
                      final date = (it['date'] ?? '').toString();
                      final time = (it['time'] ?? '').toString();
                      final status = (it['status'] ?? 'Scheduled').toString();
                      return ListTile(
                        leading: Icon(Icons.event, color: green),
                        title: Text(coachName, style: TextStyle(color: green)),
                        subtitle: Text('$date • $time • $status', style: const TextStyle(color: Colors.white70)),
                        trailing: PopupMenuButton<String>(
                          color: Colors.grey[900],
                          iconColor: Colors.white70,
                          onSelected: (v) {
                            if (v == 'calendar') _addToCalendar(it);
                            if (v == 'cancel') _cancel(id);
                            if (v == 'reschedule') _reschedule(it);
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(value: 'calendar', child: Text('Add to Calendar')),
                            const PopupMenuItem(value: 'reschedule', child: Text('Reschedule')),
                            const PopupMenuItem(value: 'cancel', child: Text('Cancel')),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}