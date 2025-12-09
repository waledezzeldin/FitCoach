import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/surface_card.dart';
import '../../subscription/subscription_state.dart';
import '../../nutrition/nutrition_state.dart';
import '../home/home_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    // Example: get real state from providers
    final nutrition = context.watch<NutritionState>();
    final sub = context.watch<SubscriptionState>();

    // Use macroSummary and calorieTarget for demo; replace with dynamic values if available
    final burned = nutrition.caloriesBurnedToday.toString();
    final consumed = nutrition.caloriesConsumedToday.toString();
    final burnedDelta = nutrition.caloriesDeltaToday != 0
      ? (nutrition.caloriesDeltaToday > 0 ? '+${nutrition.caloriesDeltaToday}' : nutrition.caloriesDeltaToday.toString())
      : null;
    final protein = nutrition.proteinToday;
    final carbs = nutrition.carbsToday;
    final fats = nutrition.fatsToday;
    final weeklyProgress = nutrition.weeklyProgress;

    final intake = Provider.of<IntakeState>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.today),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Starter Plan Card
            SurfaceCard(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.fitness_center, color: Theme.of(context).colorScheme.primary, size: 28),
                      const SizedBox(width: 12),
                      Text('Starter Plan', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Goal: ${intake.first.goal ?? "-"}', style: Theme.of(context).textTheme.bodyMedium),
                  Text('Location: ${intake.trainingLocation ?? "-"}', style: Theme.of(context).textTheme.bodyMedium),
                  Text('Gender: ${intake.gender ?? "-"}', style: Theme.of(context).textTheme.bodyMedium),
                  // Add more plan details as needed
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Reminders Section (Intake, Plan Expiry, Notifications)
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/intake');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t.intakeReminderTitle)),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                color: Theme.of(context).colorScheme.errorContainer,
                child: SurfaceCard(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  child: Row(
                    children: [
                      Icon(Icons.notifications_active, color: Theme.of(context).colorScheme.error, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(t.intakeReminderDesc,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Banner Section (Promo, Trial, Upgrade)
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/subscription');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t.tapToUpgradeBadge)),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: SurfaceCard(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  child: Row(
                    children: [
                      Icon(Icons.star, color: Theme.of(context).colorScheme.secondary, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(t.tapToUpgradeBadge,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            // Coach Tips Section (Dynamic)
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(t.coachTitle),
                    content: Text('Stay hydrated and keep moving!'), // TODO: Localize coach tips if needed
                    actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.ok))],
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: SurfaceCard(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text('${t.coachTitle}: Stay hydrated and keep moving!',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Advanced Progress Chart (Placeholder)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              color: Theme.of(context).colorScheme.tertiaryContainer,
              child: SurfaceCard(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: Row(
                  children: [
                    Icon(Icons.show_chart, color: Theme.of(context).colorScheme.tertiary, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(t.elapsed, // Using a localized label for demo
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.info_outline),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(t.completeSession)),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Reminders/Banners (example placeholder)
            if (sub.tier == SubscriptionTier.freemium)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(t.tapToUpgradeBadge, style: Theme.of(context).textTheme.bodyMedium),
              ),
            // Coach tip (example placeholder)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('💡 ${t.coachTitle}: Stay hydrated and keep moving!', style: Theme.of(context).textTheme.bodyMedium),
            ),
            QuickStatsRow(
              burnedTitle: t.caloriesBurned,
              consumedTitle: t.caloriesConsumed,
              burned: burned,
              consumed: consumed,
              burnedDelta: burnedDelta,
            ),
            const SizedBox(height: 16),
            MacroSummary(protein: protein, carbs: carbs, fats: fats),
            const SizedBox(height: 16),
            WeeklyProgress(daily: weeklyProgress),
            const SizedBox(height: 16),
            Text(t.navigation, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            QuickActionsGrid(
              onTap: (key) {
                // Implement navigation for each action
                switch (key) {
                  case 'workouts':
                    Navigator.pushNamed(context, '/workouts');
                    break;
                  case 'nutrition':
                    Navigator.pushNamed(context, '/nutrition');
                    break;
                  case 'coach':
                    Navigator.pushNamed(context, '/coach');
                    break;
                  case 'store':
                    Navigator.pushNamed(context, '/store');
                    break;
                  case 'subscription':
                    Navigator.pushNamed(context, '/subscription');
                    break;
                  default:
                    break;
                }
              },
            ),
            // TODO: Add more sections as in UI/UX React code if needed
          ],
        ),
      ),
    );
  }
}
