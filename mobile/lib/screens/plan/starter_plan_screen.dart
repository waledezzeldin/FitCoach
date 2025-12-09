import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitcoach/l10n/app_localizations.dart';
import 'package:fitcoach/screens/intake/intake_state.dart';
import 'package:fitcoach/ui/surface_card.dart';

class StarterPlanScreen extends StatelessWidget {
  const StarterPlanScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final intake = context.watch<IntakeState>();
    final exp = intake.second.experience ?? 'beginner';
    final days = intake.second.daysPerWeek ?? 3;
    final hasInjuries = intake.second.injuries;

    // Simple mapping: experience and injuries affect plan type
    String planType;
    if (exp == 'beginner') {
      planType = hasInjuries ? 'Low Impact' : 'General Fitness';
    } else if (exp == 'intermediate') {
      planType = hasInjuries ? 'Adaptive Strength' : 'Strength & Cardio';
    } else {
      planType = hasInjuries ? 'Performance + Rehab' : 'Advanced Performance';
    }
    return Scaffold(
      appBar: AppBar(title: Text(t.starterPlanTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${t.planExperience}: $exp', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Text('${t.planDaysPerWeek}: $days', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Text('Plan Type: $planType', style: theme.textTheme.bodyMedium),
                  if (hasInjuries)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text('Injuries: Yes', style: theme.textTheme.bodySmall),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: days,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) => SurfaceCard(
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 8),
                      Text('Day ${i + 1}: ${planType}'),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
