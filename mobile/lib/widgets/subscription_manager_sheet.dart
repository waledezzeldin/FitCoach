import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../models/quota_models.dart';
import '../services/subscription_service.dart';
import '../state/app_state.dart';

class SubscriptionManagerSheet extends StatefulWidget {
  const SubscriptionManagerSheet({super.key});

  static Future<void> show(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: cs.surface,
      builder: (ctx) => const FractionallySizedBox(
        heightFactor: 0.95,
        child: SubscriptionManagerSheet(),
      ),
    );
  }

  @override
  State<SubscriptionManagerSheet> createState() => _SubscriptionManagerSheetState();
}

class _SubscriptionManagerSheetState extends State<SubscriptionManagerSheet> {
  final _service = SubscriptionService();
  SubscriptionTier? _loadingTier;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final app = AppStateScope.of(context);
    final currentTier = SubscriptionTierDisplay.parse(app.subscriptionType);
    final plans = _buildPlans(l10n, cs);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.t('subscription.title'),
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.t('subscription.compare'),
                      style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: l10n.t('common.cancel'),
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                for (final plan in plans)
                  _PlanCard(
                    definition: plan,
                    isCurrent: plan.tier == currentTier,
                    loading: _loadingTier == plan.tier,
                    onSelect: () => _handleUpgrade(plan.tier, l10n),
                  ),
                const SizedBox(height: 12),
                _FeatureComparison(l10n: l10n),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleUpgrade(SubscriptionTier tier, AppLocalizations l10n) async {
    final app = AppStateScope.of(context);
    final currentTier = SubscriptionTierDisplay.parse(app.subscriptionType);
    if (currentTier == tier) {
      return;
    }
    final user = app.user;
    final userId = user?['id']?.toString() ?? user?['_id']?.toString();
    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Missing user profile.')),
      );
      return;
    }
    setState(() => _loadingTier = tier);
    try {
      await _service.changeTier(userId, tier);
      await app.setSubscription(tier.apiValue);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('subscription.upgradeSuccess'))),
      );
      Navigator.of(context).maybePop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _loadingTier = null);
      }
    }
  }
}

class _PlanDefinition {
  const _PlanDefinition({
    required this.tier,
    required this.title,
    required this.price,
    required this.subtitle,
    required this.badge,
    required this.accent,
    required this.highlights,
  });

  final SubscriptionTier tier;
  final String title;
  final String price;
  final String subtitle;
  final String? badge;
  final Color accent;
  final List<String> highlights;
}

List<_PlanDefinition> _buildPlans(AppLocalizations l10n, ColorScheme cs) {
  return [
    _PlanDefinition(
      tier: SubscriptionTier.freemium,
      title: l10n.t('subscription.freemium'),
        price: r'$0',
      subtitle: l10n.t('subscription.basicReports'),
      badge: null,
      accent: cs.outline,
      highlights: [
        l10n.t('subscription.basicPreferences'),
        '${l10n.t('subscription.coachMessages')} - 3 ${l10n.t('subscription.perMonth')}',
        l10n.t('subscription.store'),
      ],
    ),
    _PlanDefinition(
      tier: SubscriptionTier.premium,
      title: l10n.t('subscription.premium'),
        price: r'$19',
      subtitle: l10n.t('subscription.adaptiveAI'),
      badge: l10n.t('subscription.mostPopular'),
      accent: cs.primary,
      highlights: [
        '${l10n.t('subscription.workoutPlans')} - 4 ${l10n.t('subscription.weekCycle')}',
        l10n.t('subscription.mealPersonalization'),
        '${l10n.t('subscription.coachMessages')} - ${l10n.t('subscription.unlimited')}',
      ],
    ),
    _PlanDefinition(
      tier: SubscriptionTier.smartPremium,
      title: l10n.t('subscription.smartPremium'),
        price: r'$49',
      subtitle: l10n.t('subscription.detailedInsights'),
      badge: l10n.t('subscription.bestValue'),
      accent: cs.tertiary,
      highlights: [
        l10n.t('subscription.aiPowered'),
        l10n.t('subscription.videoSessions'),
          '${l10n.t('subscription.storeDiscounts')} - 15% ${l10n.t('subscription.off')}',
      ],
    ),
  ];
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.definition,
    required this.isCurrent,
    required this.loading,
    required this.onSelect,
  });

  final _PlanDefinition definition;
  final bool isCurrent;
  final bool loading;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: cs.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  definition.title,
                  style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 8),
                if (definition.badge != null)
                  _Badge(label: definition.badge!, color: definition.accent),
                if (isCurrent)
                  _Badge(label: l10n.t('subscription.currentPlan'), color: cs.primary),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${definition.price} / ${l10n.t('subscription.perMonth')}',
              style: text.headlineSmall?.copyWith(color: definition.accent, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              definition.subtitle,
              style: text.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            for (final feature in definition.highlights)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 18, color: definition.accent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: text.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            if (isCurrent)
              OutlinedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.check),
                label: Text(l10n.t('subscription.currentPlan')),
              )
            else
              FilledButton(
                onPressed: loading ? null : onSelect,
                style: FilledButton.styleFrom(
                  backgroundColor: definition.accent,
                  minimumSize: const Size.fromHeight(44),
                ),
                child: loading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onPrimary),
                        ),
                      )
                    : Text('${l10n.t('subscription.upgradeButton')} ${definition.title}'),
              ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: text.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _FeatureComparison extends StatelessWidget {
  const _FeatureComparison({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final rows = _comparisonRows();
    return Card(
      elevation: 0,
      color: cs.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.t('subscription.features'),
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(row.label(l10n), style: text.bodyMedium),
                    ),
                    _FeaturePill(label: row.freemium(l10n), color: cs.outline),
                    const SizedBox(width: 8),
                    _FeaturePill(label: row.premium(l10n), color: cs.primary),
                    const SizedBox(width: 8),
                    _FeaturePill(label: row.smart(l10n), color: cs.tertiary),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<_ComparisonRow> _comparisonRows() {
    return [
      _ComparisonRow(
        label: (l10n) => l10n.t('subscription.workoutPlans'),
        freemium: (l10n) => '1',
        premium: (l10n) => '4',
        smart: (l10n) => l10n.t('subscription.unlimited'),
      ),
      _ComparisonRow(
        label: (l10n) => l10n.t('subscription.mealPersonalization'),
        freemium: (l10n) => l10n.t('subscription.basicPreferences'),
        premium: (l10n) => l10n.t('subscription.included'),
        smart: (l10n) => l10n.t('subscription.aiPowered'),
      ),
      _ComparisonRow(
        label: (l10n) => l10n.t('subscription.coachMessages'),
        freemium: (l10n) => '3 ${l10n.t('subscription.perMonth')}',
         premium: (l10n) => l10n.t('subscription.unlimited'),
        smart: (l10n) => l10n.t('subscription.unlimited'),
      ),
      _ComparisonRow(
        label: (l10n) => l10n.t('subscription.videoSessions'),
        freemium: (l10n) => l10n.t('subscription.notIncluded'),
          premium: (l10n) => '1 ${l10n.t('subscription.perMonth')}',
          smart: (l10n) => '4 ${l10n.t('subscription.perMonth')}',
      ),
      _ComparisonRow(
        label: (l10n) => l10n.t('subscription.storeDiscounts'),
        freemium: (l10n) => l10n.t('subscription.notIncluded'),
          premium: (l10n) => '5%',
          smart: (l10n) => '15%',
      ),
      _ComparisonRow(
        label: (l10n) => l10n.t('subscription.advancedAnalytics'),
        freemium: (l10n) => l10n.t('subscription.basicReports'),
        premium: (l10n) => l10n.t('subscription.included'),
        smart: (l10n) => l10n.t('subscription.detailedInsights'),
      ),
    ];
  }
}

class _ComparisonRow {
  const _ComparisonRow({
    required this.label,
    required this.freemium,
    required this.premium,
    required this.smart,
  });

  final String Function(AppLocalizations) label;
  final String Function(AppLocalizations) freemium;
  final String Function(AppLocalizations) premium;
  final String Function(AppLocalizations) smart;
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.6)),
        color: color.withValues(alpha: 0.08),
      ),
      child: Text(
        label,
        style: text.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
