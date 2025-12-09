import 'package:flutter/material.dart';
import 'package:fitcoach/l10n/app_localizations.dart';

class CoachScreen extends StatelessWidget {
  const CoachScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.coachTitle)),
      body: const Center(child: Text('Coach Screen')), // Replace with actual coach UI
    );
  }
}
