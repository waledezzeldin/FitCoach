import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitcoach/nutrition/nutrition_state.dart';
import 'package:fitcoach/ui/surface_card.dart';
import 'package:fitcoach/ui/button.dart';
import 'package:fitcoach/l10n/app_localizations.dart';

class NutritionPlanScreen extends StatelessWidget {
  const NutritionPlanScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<NutritionState>();
      final t = AppLocalizations.of(context);
    if (s.isLocked) {
      return Scaffold(
          appBar: AppBar(title: Text(t.nutritionPlan)),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(t.nutritionExpired),
                  ),
              ),
              const SizedBox(height: 12),
                PrimaryButton(label: t.upgrade, onPressed: () => Navigator.of(context).pushNamed('/subscription')),
            ],
          ),
        ),
      );
    }
    const meals = <String>[
      'Breakfast: Oats & berries',
      'Lunch: Grilled chicken & salad',
      'Dinner: Salmon & veggies',
    ];
    final theme = Theme.of(context);
    final DateTime? expiresAt = s.expiresAt; // use real expiry from state
    final int? remainingDays = expiresAt != null ? expiresAt.difference(DateTime.now()).inDays : null;
    return Scaffold(
      appBar: AppBar(title: Text(t.nutritionTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (remainingDays != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('${t.expiresIn} $remainingDays ${t.days}', style: theme.textTheme.bodyMedium),
              ),
            const SizedBox(height: 12),
            if (_showRefreshBanner(s))
              Card(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(child: Text(_bannerText(s))),
                      TextButton(onPressed: () => s.refreshPlan(), child: const Text('Refresh')),
                    ],
                  ),
                ),
              ),
            Text('Diet: ${s.prefs.dietType}'),
            Text('Target: ${s.prefs.calorieTarget} kcal'),
            const SizedBox(height: 8),
            _macroSummaryRow(summary: s.macroSummary()),
            const SizedBox(height: 16),
            const Text('Today\'s Meals'),
            const SizedBox(height: 8),
            for (final m in meals)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SurfaceCard(child: Padding(padding: const EdgeInsets.all(12), child: Text(m))),
              ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Edit Preferences',
              onPressed: () => Navigator.of(context).pushNamed('/nutrition/preferences'),
            ),
            const SizedBox(height: 8),
            if (s.expiresAt != null)
              Text('Access until: ${s.expiresAt}'),
          ],
        ),
      ),
    );
  }

  bool _showRefreshBanner(NutritionState s) {
    final last = s.lastUpdated;
    if (last == null) return true; // show until first refresh/save
    final days = DateTime.now().difference(last).inDays;
    return days >= 2; // threshold: 2 days stale
  }

  String _bannerText(NutritionState s) {
    final last = s.lastUpdated;
    final days = last == null ? 'never' : '${DateTime.now().difference(last).inDays}d';
    return 'Plan updated $days ago — refresh?';
  }

  Widget _macroSummaryRow({required Map<String, int> summary}) {
    return Row(
      children: [
        Expanded(child: _MacroTile(label: 'Protein', value: '${summary['protein']}g')),
        const SizedBox(width: 8),
        Expanded(child: _MacroTile(label: 'Carbs', value: '${summary['carbs']}g')),
        const SizedBox(width: 8),
        Expanded(child: _MacroTile(label: 'Fats', value: '${summary['fats']}g')),
      ],
    );
  }
}

class _MacroTile extends StatelessWidget {
  final String label;
  final String value;
  const _MacroTile({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
      Text(label, style: Theme.of(context).textTheme.labelMedium),
      const SizedBox(height: 4),
      Text(value, style: Theme.of(context).textTheme.titleMedium),
    ])));
  }
}
