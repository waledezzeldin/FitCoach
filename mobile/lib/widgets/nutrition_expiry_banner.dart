import 'package:flutter/material.dart';
import '../design_system/design_tokens.dart';
import '../models/quota_models.dart';

class NutritionExpiryBanner extends StatelessWidget {
  const NutritionExpiryBanner({
    super.key,
    required this.snapshot,
    required this.tier,
    this.onUpgrade,
    this.onRegenerate,
  });

  final NutritionAccessSnapshot snapshot;
  final SubscriptionTier tier;
  final VoidCallback? onUpgrade;
  final VoidCallback? onRegenerate;

  bool get _isFreemium => tier == SubscriptionTier.freemium;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final status = snapshot.status;
    final locked = status.isLocked || status.isExpired;
    final gradient = const LinearGradient(
      colors: [FitCoachColors.gradientCTAStart, FitCoachColors.gradientCTAEnd],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
    final borderRadius = BorderRadius.circular(FitCoachRadii.md);

    return Container(
      margin: const EdgeInsets.only(bottom: FitCoachSpacing.lg),
      padding: const EdgeInsets.all(FitCoachSpacing.lg),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: borderRadius,
        boxShadow: const [FitCoachShadows.card],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(locked ? Icons.lock_outline : Icons.bolt, color: Colors.white),
              const SizedBox(width: FitCoachSpacing.sm),
              Text(
                locked ? 'Nutrition Locked' : 'Nutrition Access',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              if (!locked && _isFreemium && onRegenerate != null)
                TextButton(
                  onPressed: onRegenerate,
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  child: const Text('Regenerate'),
                ),
            ],
          ),
          const SizedBox(height: FitCoachSpacing.sm),
          Text(
            _statusLine(status),
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
          ),
          if (locked && onUpgrade != null)
            Padding(
              padding: const EdgeInsets.only(top: FitCoachSpacing.md),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: cs.primary,
                ),
                onPressed: onUpgrade,
                child: const Text('Upgrade to unlock'),
              ),
            ),
        ],
      ),
    );
  }

  String _statusLine(NutritionExpiryStatus status) {
    if (!status.canAccess && status.expiryMessage != null) {
      return status.expiryMessage!;
    }
    if (status.daysRemaining != null) {
      final days = status.daysRemaining!;
      return days > 0 ? 'Expires in $days day${days == 1 ? '' : 's'}' : 'Expires today';
    }
    return 'Unlimited nutrition access';
  }
}
