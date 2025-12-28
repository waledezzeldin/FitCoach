import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/colors.dart';
import '../../../data/repositories/payment_repository.dart';
import '../../providers/language_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_button.dart';

class SubscriptionUpgradeScreen extends StatefulWidget {
  final String? requiredTier; // 'premium' or 'smart_premium'
  final String? featureName; // Feature that triggered upgrade
  
  const SubscriptionUpgradeScreen({
    super.key,
    this.requiredTier,
    this.featureName,
  });

  @override
  State<SubscriptionUpgradeScreen> createState() => _SubscriptionUpgradeScreenState();
}

class _SubscriptionUpgradeScreenState extends State<SubscriptionUpgradeScreen> {
  String _selectedTier = 'premium';
  String _selectedCycle = 'monthly'; // 'monthly' or 'yearly'
  String _selectedPaymentMethod = 'stripe'; // 'stripe' or 'tap'
  bool _isProcessing = false;
  
  final Map<String, Map<String, double>> _prices = {
    'premium': {
      'monthly': 99.00,
      'yearly': 999.00, // ~83/month
    },
    'smart_premium': {
      'monthly': 199.00,
      'yearly': 1999.00, // ~166/month
    },
  };

  @override
  void initState() {
    super.initState();
    if (widget.requiredTier != null) {
      _selectedTier = widget.requiredTier!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isArabic = languageProvider.isArabic;
    final currentTier = authProvider.user?.subscriptionTier ?? 'freemium';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'ترقية الاشتراك' : 'Upgrade Subscription'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            if (widget.featureName != null) ...[
              CustomCard(
                color: AppColors.warning.withValues(alpha: 0.1),
                child: Row(
                  children: [
                    const Icon(Icons.lock, color: AppColors.warning),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isArabic
                            ? 'يتطلب ${widget.featureName} اشتراك Premium'
                            : '${widget.featureName} requires Premium subscription',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            Text(
              isArabic ? 'اختر خطتك' : 'Choose Your Plan',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isArabic
                  ? 'قم بالترقية للحصول على ميزات حصرية'
                  : 'Upgrade to unlock exclusive features',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            
            // Billing cycle toggle
            _buildBillingCycleToggle(isArabic),
            const SizedBox(height: 24),
            
            // Subscription plans
            _buildPlanCard(
              tier: 'premium',
              nameEn: 'Premium',
              nameAr: 'بريميوم',
              isArabic: isArabic,
              currentTier: currentTier,
            ),
            const SizedBox(height: 16),
            _buildPlanCard(
              tier: 'smart_premium',
              nameEn: 'Smart Premium',
              nameAr: 'سمارت بريميوم',
              isArabic: isArabic,
              currentTier: currentTier,
            ),
            
            const SizedBox(height: 32),
            
            // Payment method
            Text(
              isArabic ? 'طريقة الدفع' : 'Payment Method',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildPaymentMethodSelector(isArabic),
            
            const SizedBox(height: 32),
            
            // Purchase button
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: _isProcessing
                    ? (isArabic ? 'جاري المعالجة...' : 'Processing...')
                    : isArabic
                        ? 'متابعة للدفع'
                        : 'Continue to Payment',
                onPressed: _isProcessing ? null : () => _handlePayment(isArabic),
                variant: ButtonVariant.primary,
                size: ButtonSize.large,
                fullWidth: true,
                icon: Icons.payment,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Terms
            Text(
              isArabic
                  ? 'بالمتابعة، أنت توافق على شروط الخدمة وسياسة الخصوصية'
                  : 'By continuing, you agree to our Terms of Service and Privacy Policy',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textDisabled,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBillingCycleToggle(bool isArabic) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _buildCycleOption(
              'monthly',
              isArabic ? 'شهري' : 'Monthly',
              isArabic,
            ),
          ),
          Expanded(
            child: _buildCycleOption(
              'yearly',
              isArabic ? 'سنوي' : 'Yearly',
              isArabic,
              badge: isArabic ? 'وفّر 17%' : 'Save 17%',
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCycleOption(String cycle, String label, bool isArabic, {String? badge}) {
    final isSelected = _selectedCycle == cycle;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCycle = cycle;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : AppColors.success,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.primary : Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildPlanCard({
    required String tier,
    required String nameEn,
    required String nameAr,
    required bool isArabic,
    required String currentTier,
  }) {
    final isSelected = _selectedTier == tier;
    final isCurrent = currentTier == tier;
    final price = _prices[tier]![_selectedCycle]!;
    final monthlyPrice = _selectedCycle == 'yearly' ? price / 12 : price;
    
    final features = tier == 'premium'
        ? [
            {'en': 'Unlimited messages', 'ar': 'رسائل غير محدودة'},
            {'en': '4 video calls/month', 'ar': '4 مكالمات فيديو شهرياً'},
            {'en': 'InBody AI analysis', 'ar': 'تحليل InBody بالذكاء الاصطناعي'},
            {'en': 'Advanced analytics', 'ar': 'تحليلات متقدمة'},
            {'en': 'Priority support', 'ar': 'دعم أولوية'},
          ]
        : [
            {'en': 'Everything in Premium', 'ar': 'كل ميزات بريميوم'},
            {'en': 'Unlimited video calls', 'ar': 'مكالمات فيديو غير محدودة'},
            {'en': 'Chat file attachments', 'ar': 'مرفقات الملفات في الدردشة'},
            {'en': 'Injury substitution engine', 'ar': 'محرك استبدال الإصابات'},
            {'en': 'Personalized coaching', 'ar': 'تدريب شخصي'},
          ];
    
    return GestureDetector(
      onTap: isCurrent ? null : () {
        setState(() {
          _selectedTier = tier;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          color: isCurrent ? AppColors.surface : Colors.white,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      isArabic ? nameAr : nameEn,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isCurrent) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isArabic ? 'حالي' : 'Current',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (!isCurrent)
                  Radio<String>(
                    value: tier,
                    groupValue: _selectedTier,
                    onChanged: (value) {
                      setState(() {
                        _selectedTier = value!;
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '/${isArabic ? (_selectedCycle == 'monthly' ? 'شهر' : 'سنة') : _selectedCycle.substring(0, _selectedCycle.length - 2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            if (_selectedCycle == 'yearly') ...[
              const SizedBox(height: 4),
              Text(
                '\$${monthlyPrice.toStringAsFixed(0)}/${isArabic ? 'شهر' : 'month'}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textDisabled,
                ),
              ),
            ],
            const SizedBox(height: 16),
            ...features.map((feature) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
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
                        isArabic ? feature['ar']! : feature['en']!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPaymentMethodSelector(bool isArabic) {
    return Row(
      children: [
        Expanded(
          child: _buildPaymentMethodCard(
            'stripe',
            isArabic ? 'بطاقة ائتمان' : 'Credit Card',
            Icons.credit_card,
            isArabic,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildPaymentMethodCard(
            'tap',
            isArabic ? 'Tap Payments' : 'Tap Payments',
            Icons.payment,
            isArabic,
          ),
        ),
      ],
    );
  }
  
  Widget _buildPaymentMethodCard(
    String method,
    String label,
    IconData icon,
    bool isArabic,
  ) {
    final isSelected = _selectedPaymentMethod == method;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textDisabled,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _handlePayment(bool isArabic) async {
    setState(() {
      _isProcessing = true;
    });
    
    try {
      final repository = PaymentRepository();
      
      Map<String, dynamic> paymentResult;
      
      if (_selectedPaymentMethod == 'stripe') {
        // Create Stripe payment
        paymentResult = await repository.createStripePayment(
          tier: _selectedTier,
          billingCycle: _selectedCycle,
        );
        
        // Launch Stripe checkout URL
        final checkoutUrl = paymentResult['checkoutUrl'] as String;
        await _launchPaymentUrl(checkoutUrl);
        
      } else {
        // Create Tap payment
        paymentResult = await repository.createTapPayment(
          tier: _selectedTier,
          billingCycle: _selectedCycle,
        );
        
        // Launch Tap payment URL
        final paymentUrl = paymentResult['paymentUrl'] as String;
        await _launchPaymentUrl(paymentUrl);
      }
      
      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isArabic
                  ? 'سيتم توجيهك إلى صفحة الدفع'
                  : 'Redirecting to payment page',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        
        // After payment completes (webhook will update backend)
        // User needs to restart app or pull to refresh
      }
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isArabic
                  ? 'فشل في إنشاء الدفع: ${e.toString()}'
                  : 'Payment failed: ${e.toString()}',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
  
  Future<void> _launchPaymentUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch payment URL');
    }
  }
}
