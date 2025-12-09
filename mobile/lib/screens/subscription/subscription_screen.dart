import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitcoach/subscription/subscription_state.dart';
import 'package:fitcoach/nutrition/nutrition_state.dart';
import 'package:fitcoach/l10n/app_localizations.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final sub = context.watch<SubscriptionState>();
    final nutrition = context.read<NutritionState>();
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.subscriptionTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('${t.subscriptionTitle}: ${sub.tier.name}'),
            const SizedBox(height: 8),
            Text(t.manageSubscription),
            const SizedBox(height: 12),
            Card(child: ListTile(title: Text(t.tierFreemium), subtitle: const Text('Free'), trailing: ElevatedButton(onPressed: () async {
              await sub.setTier(SubscriptionTier.freemium);
            }, child: Text(t.continueCta)))),
            const SizedBox(height: 8),
            Card(child: ListTile(title: Text(t.tierPremium), subtitle: const Text('\$9.99/mo'), trailing: ElevatedButton(onPressed: () async {
              await sub.setTier(SubscriptionTier.premium);
              await nutrition.unlockPermanentAccess();
              if (context.mounted) Navigator.of(context).pop();
            }, child: Text(t.continueCta)))),
            const SizedBox(height: 8),
            Card(child: ListTile(title: Text(t.tierSmartPremium), subtitle: const Text('\$29.99/mo'), trailing: ElevatedButton(onPressed: () async {
              await sub.setTier(SubscriptionTier.smartPremium);
              await nutrition.unlockPermanentAccess();
              if (context.mounted) Navigator.of(context).pop();
            }, child: Text(t.continueCta)))),
          ],
        ),
      ),
    );
  }
}
