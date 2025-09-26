import 'package:flutter/material.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import '../../services/coach_service.dart';

class BookingConfirmScreen extends StatelessWidget {
  const BookingConfirmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final green = Theme.of(context).colorScheme.primary;
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {};
    final coach = args['coach'] as Map<String, dynamic>?;
    final session = args['session'] as Map<String, dynamic>?;

    Future<void> _confirm() async {
      if (coach == null || session == null) return;
      try {
        final booked = await CoachService().book(
          coachId: coach['id'].toString(),
          sessionId: (session['id'] ?? session['sessionId']).toString(),
        );
        if (!context.mounted) return;
        Navigator.pushReplacementNamed(
          context,
          '/video_calls',
          arguments: {'newCall': booked},
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to confirm booking')),
        );
      }
    }

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
                  Text('Date: ${session['date']}', style: const TextStyle(color: Colors.white)),
                  Text('Time: ${session['time']}', style: const TextStyle(color: Colors.white)),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _confirm,
                    child: const Text('Confirm Booking'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      if (session == null) return;
                      final start = DateTime.tryParse('${session['date']} ${session['time']}') ?? DateTime.now().add(const Duration(minutes: 10));
                      final event = Event(
                        title: 'Coaching with ${coach?['name'] ?? ''}',
                        description: 'FitCoach coaching session',
                        startDate: start,
                        endDate: start.add(const Duration(minutes: 45)),
                        iosParams: const IOSParams(reminder: Duration(minutes: 5)),
                        androidParams: const AndroidParams(),
                      );
                      Add2Calendar.addEvent2Cal(event);
                    },
                    child: const Text('Add to Calendar'),
                  ),
                ],
              ),
      ),
    );
  }
}