import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../providers/language_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_stat_info_card.dart';
import '../subscription/subscription_upgrade_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isArabic = languageProvider.isArabic;
    final user = authProvider.user;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.t('account')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header
            CustomCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      user?.name?.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? languageProvider.t('user'),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.phoneNumber ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getTierColor(user?.subscriptionTier ?? 'Freemium')
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getTierColor(user?.subscriptionTier ?? 'Freemium')
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            user?.subscriptionTier ?? 'Freemium',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _getTierColor(user?.subscriptionTier ?? 'Freemium'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      // Navigate to edit profile
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Subscription section
            Text(
              isArabic ? 'الاشتراك' : 'Subscription',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            CustomInfoCard(
              title: isArabic ? 'إدارة الاشتراك' : 'Manage Subscription',
              subtitle: isArabic 
                  ? 'ترقية أو إلغاء اشتراكك'
                  : 'Upgrade or cancel your subscription',
              icon: Icons.card_membership,
              onTap: () {
                // Navigate to subscription management
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SubscriptionUpgradeScreen(),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 12),
            
            CustomInfoCard(
              title: isArabic ? 'سجل الدفع' : 'Payment History',
              subtitle: isArabic 
                  ? 'عرض المدفوعات السابقة'
                  : 'View past payments',
              icon: Icons.payment,
              iconColor: AppColors.secondary,
              onTap: () {
                // Navigate to payment history
                // TODO: Create payment history screen
              },
            ),
            
            const SizedBox(height: 24),
            
            // Settings section
            Text(
              isArabic ? 'الإعدادات' : 'Settings',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            CustomCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.language, color: AppColors.primary),
                    title: Text(isArabic ? 'اللغة' : 'Language'),
                    subtitle: Text(isArabic ? 'العربية' : 'English'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showLanguageDialog(context, languageProvider, isArabic),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.dark_mode, color: AppColors.accent),
                    title: Text(isArabic ? 'الوضع الداكن' : 'Dark Mode'),
                    subtitle: Text(
                      isArabic 
                          ? 'تفعيل الوضع الداكن'
                          : 'Enable dark theme',
                    ),
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme();
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.notifications, color: AppColors.warning),
                    title: Text(isArabic ? 'الإشعارات' : 'Notifications'),
                    subtitle: Text(
                      isArabic 
                          ? 'إدارة تفضيلات الإشعارات'
                          : 'Manage notification preferences',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to notification settings
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Profile section
            Text(
              isArabic ? 'الملف الشخصي' : 'Profile',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            CustomInfoCard(
              title: isArabic ? 'المعلومات الشخصية' : 'Personal Information',
              subtitle: isArabic 
                  ? 'العمر، الوزن، الطول'
                  : 'Age, Weight, Height',
              icon: Icons.person,
              iconColor: AppColors.primary,
              onTap: () {
                // Navigate to personal info
              },
            ),
            
            const SizedBox(height: 12),
            
            CustomInfoCard(
              title: isArabic ? 'الأهداف الصحية' : 'Fitness Goals',
              subtitle: isArabic 
                  ? 'تحديث أهدافك'
                  : 'Update your goals',
              icon: Icons.flag,
              iconColor: AppColors.secondary,
              onTap: () {
                // Navigate to goals
              },
            ),
            
            const SizedBox(height: 12),
            
            CustomInfoCard(
              title: isArabic ? 'الإصابات' : 'Injuries',
              subtitle: isArabic 
                  ? 'إدارة الإصابات الحالية'
                  : 'Manage current injuries',
              icon: Icons.healing,
              iconColor: AppColors.warning,
              onTap: () {
                // Navigate to injuries
              },
            ),
            
            const SizedBox(height: 24),
            
            // Support section
            Text(
              isArabic ? 'الدعم' : 'Support',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            CustomInfoCard(
              title: isArabic ? 'مركز المساعدة' : 'Help Center',
              subtitle: isArabic 
                  ? 'الأسئلة الشائعة والدعم'
                  : 'FAQs and support',
              icon: Icons.help_outline,
              iconColor: AppColors.primary,
              onTap: () {
                // Navigate to help center
              },
            ),
            
            const SizedBox(height: 12),
            
            CustomInfoCard(
              title: isArabic ? 'تواصل معنا' : 'Contact Us',
              subtitle: isArabic 
                  ? 'تواصل مع فريق الدعم'
                  : 'Get in touch with support',
              icon: Icons.email,
              iconColor: AppColors.secondary,
              onTap: () {
                // Navigate to contact
              },
            ),
            
            const SizedBox(height: 12),
            
            CustomInfoCard(
              title: isArabic ? 'حول التطبيق' : 'About App',
              subtitle: 'عاش v2.0.0',
              icon: Icons.info_outline,
              iconColor: AppColors.accent,
              onTap: () {
                _showAboutDialog(context, isArabic);
              },
            ),
            
            const SizedBox(height: 24),
            
            // Legal section
            Text(
              isArabic ? 'القانونية' : 'Legal',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            CustomInfoCard(
              title: isArabic ? 'الشروط والأحكام' : 'Terms & Conditions',
              icon: Icons.article,
              iconColor: AppColors.textSecondary,
              onTap: () {
                // Navigate to terms
              },
            ),
            
            const SizedBox(height: 12),
            
            CustomInfoCard(
              title: isArabic ? 'سياسة الخصوصية' : 'Privacy Policy',
              icon: Icons.privacy_tip,
              iconColor: AppColors.textSecondary,
              onTap: () {
                // Navigate to privacy policy
              },
            ),
            
            const SizedBox(height: 32),
            
            // Logout button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _logout(context, authProvider, isArabic),
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: Text(
                  isArabic ? 'تسجيل الخروج' : 'Logout',
                  style: const TextStyle(color: AppColors.error),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
  
  Color _getTierColor(String tier) {
    switch (tier) {
      case 'Smart Premium':
        return AppColors.accent;
      case 'Premium':
        return AppColors.secondary;
      default:
        return AppColors.textDisabled;
    }
  }
  
  void _showLanguageDialog(
    BuildContext context,
    LanguageProvider provider,
    bool isArabic,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isArabic ? 'اختر اللغة' : 'Choose Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: provider.currentLanguage,
              onChanged: (value) {
                provider.setLanguage('en');
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('العربية'),
              value: 'ar',
              groupValue: provider.currentLanguage,
              onChanged: (value) {
                provider.setLanguage('ar');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _showAboutDialog(BuildContext context, bool isArabic) {
    showAboutDialog(
      context: context,
      applicationName: 'عاش',
      applicationVersion: '2.0.0',
      applicationLegalese: isArabic
          ? '© 2024 عاش. جميع الحقوق محفوظة.'
          : '© 2024 Aash. All rights reserved.',
      children: [
        const SizedBox(height: 16),
        Text(
          isArabic
              ? 'تطبيق شامل للياقة البدنية مع تدريب شخصي'
              : 'Comprehensive fitness app with personal coaching',
        ),
      ],
    );
  }
  
  Future<void> _logout(
    BuildContext context,
    AuthProvider authProvider,
    bool isArabic,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isArabic ? 'تسجيل الخروج' : 'Logout'),
        content: Text(
          isArabic
              ? 'هل أنت متأكد من تسجيل الخروج؟'
              : 'Are you sure you want to logout?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              isArabic ? 'تسجيل الخروج' : 'Logout',
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    
    if (confirmed == true && context.mounted) {
      await authProvider.logout();
      // Navigation will be handled by app.dart listening to auth state
    }
  }
}