import 'package:flutter/material.dart';
import 'package:fitcoach/ui/surface_card.dart';
import 'package:fitcoach/ui/badge.dart';
import 'package:fitcoach/theme/fitcoach_theme.dart';
import 'package:provider/provider.dart';
import 'package:fitcoach/subscription/subscription_state.dart';
import 'package:fitcoach/l10n/app_localizations.dart';

class QuickStatsRow extends StatelessWidget {
  final String burnedTitle;
  final String consumedTitle;
  final String burned;
  final String consumed;
  final String? burnedDelta;
  const QuickStatsRow({super.key, required this.burnedTitle, required this.consumedTitle, required this.burned, required this.consumed, this.burnedDelta});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: SurfaceCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(burnedTitle, style: t.textTheme.labelMedium),
              const SizedBox(height: 6),
              Text(burned, style: t.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
              if (burnedDelta != null) ...[
                const SizedBox(height: 4),
                Text(burnedDelta!, style: t.textTheme.bodySmall?.copyWith(color: t.hintColor)),
              ]
            ]),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SurfaceCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(consumedTitle, style: t.textTheme.labelMedium),
              const SizedBox(height: 6),
              Text(consumed, style: t.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      ],
    );
  }
}

class MacroSummary extends StatelessWidget {
  final int protein;
  final int carbs;
  final int fats;
  const MacroSummary({super.key, required this.protein, required this.carbs, required this.fats});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return SurfaceCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Macros', style: t.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          FCBadge(text: 'Protein: $protein g', variant: BadgeVariant.info),
          FCBadge(text: 'Carbs: $carbs g', variant: BadgeVariant.success),
          FCBadge(text: 'Fats: $fats g', variant: BadgeVariant.warn),
        ]),
      ]),
    );
  }
}

class WeeklyProgress extends StatelessWidget {
  final List<double> daily; // 7 values 0..1
  const WeeklyProgress({super.key, required this.daily});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return SurfaceCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Weekly Progress', style: t.textTheme.titleMedium),
        const SizedBox(height: 12),
        SizedBox(
          height: 64,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final v in daily) ...[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: v.clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: t.colorScheme.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ]),
    );
  }
}

class QuickActionsGrid extends StatelessWidget {
  final void Function(String key) onTap;
  const QuickActionsGrid({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final sub = context.watch<SubscriptionState>();
    final isFreemium = sub.tier == SubscriptionTier.freemium;
    final t = AppLocalizations.of(context);
    final upgradeText = t.tapToUpgradeBadge;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _tile(context, 'Workouts', const Color(0xFF3B82F6), () => onTap('workouts')),
        _tile(context, t.nutritionTitle, const Color(0xFF10B981), () => onTap('nutrition'),
          badge: isFreemium ? _UpgradeBadge(text: upgradeText) : null),
        _tile(context, t.coachTitle, const Color(0xFFA855F7), () => onTap('coach')),
        _tile(context, 'Store', const Color(0xFFF59E0B), () => onTap('store')),
        _tile(context, 'Subscription', const Color(0xFFEF4444), () => onTap('subscription')),
      ],
    );
  }

  Widget _tile(BuildContext context, String label, Color color, VoidCallback onTap, {Widget? badge}) {
    final brand = Theme.of(context).extension<FitCoachBrand>()!;
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 16 * 2 - 12) / 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: brand.radius as BorderRadius,
        child: Ink(
          decoration: BoxDecoration(
            color: color.withValues(alpha: .12),
            borderRadius: brand.radius as BorderRadius,
            border: Border.all(color: brand.border),
            boxShadow: [
              BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.05), blurRadius: 8, offset: const Offset(0, 4)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color)),
                if (badge != null) ...[
                  const SizedBox(height: 8),
                  badge,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UpgradeBadge extends StatefulWidget {
  final String text;
  const _UpgradeBadge({required this.text});
  @override
  State<_UpgradeBadge> createState() => _UpgradeBadgeState();
}

class _UpgradeBadgeState extends State<_UpgradeBadge> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  late final Animation<double> _pulse = Tween<double>(begin: .95, end: 1.05).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return ScaleTransition(
      scale: _pulse,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            t.colorScheme.secondaryContainer,
            t.colorScheme.primaryContainer,
          ]),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(widget.text, style: t.textTheme.labelMedium),
      ),
    );
  }
}
