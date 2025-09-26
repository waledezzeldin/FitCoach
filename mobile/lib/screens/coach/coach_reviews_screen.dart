import 'package:flutter/material.dart';

class CoachReviewsScreen extends StatelessWidget {
  const CoachReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final green = Theme.of(context).colorScheme.primary;
    final coach = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    // TODO: Replace with actual reviews data from backend
    final reviews = [
      {'user': 'Alice', 'rating': 5, 'comment': 'Great coach! Helped me a lot.'},
      {'user': 'Bob', 'rating': 4, 'comment': 'Very knowledgeable and friendly.'},
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(coach != null ? '${coach['name']} Reviews' : 'Coach Reviews'),
        backgroundColor: Colors.black,
        foregroundColor: green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (coach != null)
              Text('Specialty: ${coach['specialty']}', style: TextStyle(color: green, fontSize: 16)),
            const SizedBox(height: 16),
            Text('User Reviews:', style: TextStyle(color: green, fontSize: 18)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  final review = reviews[index];
                  return Card(
                    color: Colors.black,
                    child: ListTile(
                      leading: Icon(Icons.person, color: green),
                      title: Text('${review['user']} (${review['rating']}/5)', style: TextStyle(color: green)),
                      subtitle: Text(review['comment'].toString(), style: const TextStyle(color: Colors.white)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to coach schedule screen
                  Navigator.pushNamed(context, '/coach_schedule', arguments: coach);
                },
                child: const Text('View Available Sessions'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}