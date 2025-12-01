import 'package:flutter/material.dart';

const _featuredCoaches = [
  {
    'name': 'Mira Soliman',
    'specialty': 'Functional strength · Cairo',
  },
  {
    'name': 'Adel Nour',
    'specialty': 'Endurance & conditioning',
  },
  {
    'name': 'Yasmeen Kamal',
    'specialty': 'Mobility & Pilates',
  },
];

class CoachListScreen extends StatelessWidget {
  const CoachListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Coaches')),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'We\'re curating verified FitCoach pros. Tap a profile to learn more once the directory launches.',
              style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            ..._featuredCoaches.map((coach) => Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text(coach['name']![0])),
                    title: Text(coach['name']!),
                    subtitle: Text(coach['specialty']!),
                    trailing: const Icon(Icons.lock_outline),
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coach directory is coming soon.')),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}