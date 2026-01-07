import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../providers/language_provider.dart';
import '../../widgets/custom_card.dart';

class SubscriptionManagementScreen extends StatelessWidget {
  const SubscriptionManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final isArabic = languageProvider.isArabic;
    final tiers = [
      _SubscriptionTier(
        id: 'freemium',
        name: 'Freemium',
        price: 0,
        features: [
          'Basic workout plans',
          '50 coach messages/month',
          '1 video call/month',
        ],
      ),
      _SubscriptionTier(
        id: 'premium',
        name: 'Premium',
        price: 29.99,
        features: [
          'Custom plans',
          '200 messages/month',
          '4 video calls/month',
          'Nutrition access',
        ],
      ),
      _SubscriptionTier(
        id: 'smart_premium',
        name: 'Smart Premium',
        price: 49.99,
        features: [
          'All Premium features',
          'Unlimited messaging',
          '8 video calls/month',
          'File attachments',
        ],
      ),
    ];

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: Icon(
                      isArabic ? Icons.arrow_forward : Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          languageProvider.t('admin_subscription_management'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          languageProvider.t('admin_manage_plans'),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(languageProvider.t('admin_saved'))),
                      );
                    },
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: Text(
                      languageProvider.t('save'),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tiers.length,
              itemBuilder: (context, index) {
                final tier = tiers[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              tier.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '\$${tier.price.toStringAsFixed(2)}/mo',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _LabeledInput(
                                label: languageProvider.t('admin_price'),
                                value: tier.price.toStringAsFixed(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _LabeledInput(
                                label: languageProvider.t('admin_billing_cycle'),
                                value: languageProvider.t('admin_billing_monthly'),
                                enabled: false,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          languageProvider.t('admin_features'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...tier.features.map(
                          (feature) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.background.withValues(alpha: (0.6 * 255)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                feature,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LabeledInput extends StatelessWidget {
  final String label;
  final String value;
  final bool enabled;

  const _LabeledInput({
    required this.label,
    required this.value,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          enabled: enabled,
          controller: TextEditingController(text: value),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}

class _SubscriptionTier {
  final String id;
  final String name;
  final double price;
  final List<String> features;

  _SubscriptionTier({
    required this.id,
    required this.name,
    required this.price,
    required this.features,
  });
}
