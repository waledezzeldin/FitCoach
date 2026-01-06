import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../../core/config/demo_config.dart';
import '../../../core/constants/colors.dart';
import '../../providers/language_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_button.dart';

class SubscriptionManagerScreen extends StatefulWidget {
  const SubscriptionManagerScreen({super.key});

  @override
  State<SubscriptionManagerScreen> createState() => _SubscriptionManagerScreenState();
}

class _SubscriptionManagerScreenState extends State<SubscriptionManagerScreen> {
  final List<Map<String, dynamic>> _plans = [
    {
      'tier': 'Freemium',
      'price': 0,
      'features': [
        'basic_workout',
        'nutrition_trial',
        'limited_messages',
        'one_video_call',
      ],
      'messagesLimit': 20,
      'videoCallsLimit': 1,
    },
    {
      'tier': 'Premium',
      'price': 199,
      'features': [
        'full_workout',
        'full_nutrition',
        'priority_messages',
        'two_video_calls',
        'progress_tracking',
      ],
      'messagesLimit': 200,
      'videoCallsLimit': 2,
    },
    {
      'tier': 'Smart Premium',
      'price': 399,
      'features': [
        'personalized_plans',
        'unlimited_messages',
        'four_video_calls',
        'inbody_analysis',
        'priority_support',
        'advanced_analytics',
      ],
      'messagesLimit': -1, // Unlimited
      'videoCallsLimit': 4,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isArabic = languageProvider.isArabic;
    final currentTier = authProvider.user?.subscriptionTier ?? 'Freemium';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'إدارة الاشتراك' : 'Manage Subscription'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current plan card
            CustomCard(
              color: AppColors.primary.withValues(alpha: 0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic ? 'خطتك الحالية' : 'Your Current Plan',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        currentTier,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      if (currentTier != 'Freemium')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isArabic ? 'نشط' : 'Active',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Plans
            Text(
              isArabic ? 'خطط الاشتراك' : 'Subscription Plans',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ..._plans.map((plan) => _buildPlanCard(
              plan,
              currentTier,
              isArabic,
            )).toList(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPlanCard(
    Map<String, dynamic> plan,
    String currentTier,
    bool isArabic,
  ) {
    final isCurrent = plan['tier'] == currentTier;
    final tier = plan['tier'] as String;
    final price = plan['price'] as int;
    final features = plan['features'] as List<String>;
    
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 16),
      border: isCurrent
          ? Border.all(color: AppColors.primary, width: 2)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tier,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        price == 0
                            ? isArabic ? 'مجاني' : 'Free'
                            : '$price ${isArabic ? 'ر.س' : 'SAR'}',
                        style: TextStyle(
                          fontSize: price == 0 ? 18 : 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      if (price > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4, left: 4, right: 4),
                          child: Text(
                            isArabic ? '/شهر' : '/month',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isArabic ? 'الحالية' : 'Current',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          
          // Features
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getFeatureLabel(feature, isArabic),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          )).toList(),
          
          const SizedBox(height: 16),
          
          // Action button
          if (!isCurrent)
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: _getButtonLabel(tier, currentTier, isArabic),
                onPressed: () => _handlePlanAction(tier, currentTier, isArabic),
                variant: _isUpgrade(tier, currentTier)
                    ? ButtonVariant.primary
                    : ButtonVariant.secondary,
                size: ButtonSize.large,
                fullWidth: true,
              ),
            ),
        ],
      ),
    );
  }
  
  bool _isUpgrade(String targetTier, String currentTier) {
    final tierOrder = ['Freemium', 'Premium', 'Smart Premium'];
    return tierOrder.indexOf(targetTier) > tierOrder.indexOf(currentTier);
  }
  
  String _getButtonLabel(String targetTier, String currentTier, bool isArabic) {
    if (_isUpgrade(targetTier, currentTier)) {
      return isArabic ? 'ترقية' : 'Upgrade';
    } else {
      return isArabic ? 'التبديل إلى هذه الخطة' : 'Switch to this plan';
    }
  }
  
  String _getFeatureLabel(String feature, bool isArabic) {
    final labels = {
      'basic_workout': isArabic ? 'خطط تمرين أساسية' : 'Basic workout plans',
      'full_workout': isArabic ? 'خطط تمرين كاملة' : 'Full workout plans',
      'personalized_plans': isArabic ? 'خطط شخصية مخصصة' : 'Personalized plans',
      'nutrition_trial': isArabic ? 'تجربة تغذية 14 يوم' : '14-day nutrition trial',
      'full_nutrition': isArabic ? 'خطط تغذية كاملة' : 'Full nutrition plans',
      'limited_messages': isArabic ? '20 رسالة شهرياً' : '20 messages/month',
      'priority_messages': isArabic ? '200 رسالة شهرياً' : '200 messages/month',
      'unlimited_messages': isArabic ? 'رسائل غير محدودة' : 'Unlimited messages',
      'one_video_call': isArabic ? 'مكالمة فيديو واحدة شهرياً' : '1 video call/month',
      'two_video_calls': isArabic ? 'مكالمتان فيديو شهرياً' : '2 video calls/month',
      'four_video_calls': isArabic ? '4 مكالمات فيديو شهرياً' : '4 video calls/month',
      'progress_tracking': isArabic ? 'تتبع التقدم' : 'Progress tracking',
      'inbody_analysis': isArabic ? 'تحليل InBody' : 'InBody analysis',
      'priority_support': isArabic ? 'دعم أولوية' : 'Priority support',
      'advanced_analytics': isArabic ? 'تحليلات متقدمة' : 'Advanced analytics',
    };
    return labels[feature] ?? feature;
  }
  
  void _handlePlanAction(String targetTier, String currentTier, bool isArabic) {
    final isUpgrade = _isUpgrade(targetTier, currentTier);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isUpgrade
              ? (isArabic ? 'تأكيد الترقية' : 'Confirm Upgrade')
              : (isArabic ? 'تأكيد التبديل' : 'Confirm Switch'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isUpgrade
                  ? (isArabic
                      ? 'هل تريد الترقية إلى $targetTier؟'
                      : 'Do you want to upgrade to $targetTier?')
                  : (isArabic
                      ? 'هل تريد التبديل إلى $targetTier؟'
                      : 'Do you want to switch to $targetTier?'),
            ),
            if (isUpgrade) ...[
              const SizedBox(height: 16),
              Text(
                isArabic
                    ? 'سيتم تطبيق الترقية فوراً'
                    : 'Upgrade will be applied immediately',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _processPlanChange(targetTier, currentTier, isArabic);
            },
            child: Text(isArabic ? 'تأكيد' : 'Confirm'),
          ),
        ],
      ),
    );
  }
  
  void _processPlanChange(String targetTier, String currentTier, bool isArabic) async {
    // Simulate API call
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isArabic
              ? '?? ????? ???????? ?????'
              : 'Subscription changed successfully',
        ),
        backgroundColor: AppColors.success,
      ),
    );

    // Update user tier (would be done through provider in real app)
    final authProvider = context.read<AuthProvider>();
    if (DemoConfig.isDemo) {
      final userProvider = context.read<UserProvider>();
      await userProvider.updateSubscription(targetTier);
      if (userProvider.profile != null) {
        authProvider.updateUser(userProvider.profile!);
      }
    }

    final isUpgradeFromFreemium = currentTier == 'Freemium' &&
        (targetTier == 'Premium' || targetTier == 'Smart Premium');
    if (isUpgradeFromFreemium) {
      final userId = authProvider.user?.id ?? 'demo-user';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('pending_nutrition_intake_$userId', true);
      await prefs.setBool('nutrition_preferences_completed_$userId', false);
    }
  }
}
