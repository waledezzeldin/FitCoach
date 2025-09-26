import 'package:flutter/material.dart';

class CoachSessionScreen extends StatelessWidget {
  final int availableSessions; // Pass from backend/user state
  final int usedSessions;      // Pass from backend/user state

  const CoachSessionScreen({
    super.key,
    required this.availableSessions,
    required this.usedSessions,
  });

  @override
  Widget build(BuildContext context) {
    final green = Theme.of(context).colorScheme.primary;
    final remaining = availableSessions - usedSessions;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Coach Sessions'),
        backgroundColor: Colors.black,
        foregroundColor: green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Sessions This Month: $availableSessions',
              style: TextStyle(color: green, fontSize: 18),
            ),
            Text(
              'Used Sessions: $usedSessions',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              'Remaining: $remaining',
              style: TextStyle(
                color: remaining > 0 ? green : Colors.red,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            remaining > 0
                ? ElevatedButton(
                    onPressed: () {
                      // TODO: Navigate to booking screen or show available slots
                      Navigator.pushNamed(context, '/coach_list');
                    },
                    child: const Text('Book a Session'),
                  )
                : Text(
                    'You have reached your session limit for this month.',
                    style: TextStyle(color: Colors.redAccent, fontSize: 16),
                  ),
          ],
        ),
      ),
    );
  }
}