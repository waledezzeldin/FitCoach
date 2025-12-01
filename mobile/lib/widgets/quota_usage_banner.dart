import 'package:flutter/material.dart';

import '../design_system/design_tokens.dart';
import '../localization/app_localizations.dart';
import '../models/quota_models.dart';

class QuotaUsageBanner extends StatelessWidget {
  const QuotaUsageBanner({
    super.key,
    required this.snapshot,
    this.onUpgrade,
    this.margin,
  });

  final QuotaSnapshot snapshot;
  final VoidCallback? onUpgrade;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final usage = snapshot.usage;
    final limits = snapshot.limits;
    final messageLimit = limits.messages;
    final messageValue = messageLimit is num
        ? '${usage.messagesUsed}/${messageLimit.toInt()}'
        : '${usage.messagesUsed}/∞';
    final messagePercent = _percent(usage.messagesUsed, messageLimit);
    final callPercent = limits.calls > 0 ? _percent(usage.callsUsed, limits.calls) : null;
    final isLow = (messagePercent ?? 0) >= 0.8 || (callPercent ?? 0) >= 0.8;
    final resetLabel = MaterialLocalizations.of(context).formatMediumDate(usage.resetAt);

    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: FitCoachSpacing.lg),
      padding: const EdgeInsets.all(FitCoachSpacing.lg),
      decoration: BoxDecoration(
        gradient: FitCoachGradients.primaryCTA,
        borderRadius: BorderRadius.circular(FitCoachRadii.lg),
        boxShadow: const [FitCoachShadows.card],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subscription · ${snapshot.tier.label}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: FitCoachSpacing.sm),
          _UsageMeter(
            icon: Icons.chat_bubble_outline,
            label: l10n.t('quota.messages'),
            value: messageValue,
            percent: messagePercent,
          ),
          const SizedBox(height: FitCoachSpacing.md),
          _UsageMeter(
            icon: Icons.videocam_outlined,
            label: l10n.t('quota.calls'),
            value: '${usage.callsUsed}/${limits.calls}',
            percent: callPercent,
          ),
          const SizedBox(height: FitCoachSpacing.md),
          Wrap(
            spacing: FitCoachSpacing.sm,
            runSpacing: FitCoachSpacing.sm,
            children: [
              _pill(
                context,
                icon: Icons.attach_file,
                label: limits.chatAttachments
                    ? l10n.t('quota.attachments')
                    : l10n.t('quota.upgradePrompt'),
                muted: !limits.chatAttachments,
              ),
              if (limits.nutritionPersistent)
                _pill(
                  context,
                  icon: Icons.restaurant_menu,
                  label: l10n.t('nutrition.unlocked'),
                )
              else if (limits.nutritionWindowDays != null)
                _pill(
                  context,
                  icon: Icons.hourglass_bottom,
                  label: l10n
                      .t('nutrition.windowDays')
                      .replaceFirst('{days}', limits.nutritionWindowDays!.toString()),
                  muted: true,
                ),
            ],
          ),
          const SizedBox(height: FitCoachSpacing.sm),
          Text(
            '${l10n.t('quota.remaining')} · ${l10n.t('quota.resetsOn').replaceFirst('{date}', resetLabel)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
          ),
          if (isLow)
            Padding(
              padding: const EdgeInsets.only(top: FitCoachSpacing.sm),
              child: Text(
                l10n.t('quota.runningLow'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          if (onUpgrade != null)
            Padding(
              padding: const EdgeInsets.only(top: FitCoachSpacing.md),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: FitCoachColors.gradientCTAStart,
                ),
                onPressed: onUpgrade,
                child: Text(l10n.t('subscription.upgradeButton')),
              ),
            ),
        ],
      ),
    );
  }

  double? _percent(int used, dynamic limit) {
    if (limit is num && limit > 0) {
      return (used / limit).clamp(0, 1).toDouble();
    }
    return null;
  }

  Widget _pill(BuildContext context, {required IconData icon, required String label, bool muted = false}) {
    final bg = Colors.white.withValues(alpha: muted ? 0.12 : 0.2);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: FitCoachSpacing.md, vertical: FitCoachSpacing.sm),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(FitCoachRadii.pill),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white.withValues(alpha: muted ? 0.6 : 1)),
          const SizedBox(width: FitCoachSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white.withValues(alpha: muted ? 0.7 : 1),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _UsageMeter extends StatelessWidget {
  const _UsageMeter({
    required this.icon,
    required this.label,
    required this.value,
    this.percent,
  });

  final IconData icon;
  final String label;
  final String value;
  final double? percent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: FitCoachSpacing.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        if (percent != null)
          Padding(
            padding: const EdgeInsets.only(top: FitCoachSpacing.xs),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(FitCoachRadii.xs),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 6,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
