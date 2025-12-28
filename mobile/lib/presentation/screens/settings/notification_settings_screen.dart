import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../data/repositories/user_repository.dart';
import '../../providers/language_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_card.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  
  // User notifications
  bool _workoutReminders = true;
  bool _coachMessages = true;
  bool _nutritionTracking = false;
  bool _promotions = true;
  
  // Coach notifications
  bool _newClientAssignments = true;
  bool _clientMessages = true;
  bool _sessionReminders = true;
  bool _paymentAlerts = true;
  
  // Admin notifications
  bool _systemAlerts = true;
  bool _userReports = true;
  bool _coachApplications = true;
  bool _paymentIssues = true;
  bool _securityAlerts = true;
  
  // Notification channels
  bool _pushEnabled = true;
  bool _emailEnabled = true;
  bool _smsEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final repository = UserRepository();
      final settings = await repository.getNotificationSettings();
      
      if (mounted) {
        setState(() {
          _workoutReminders = settings['workout_reminders'] ?? true;
          _coachMessages = settings['coach_messages_notifications'] ?? true;
          _nutritionTracking = settings['nutrition_tracking_notifications'] ?? false;
          _promotions = settings['promotions_notifications'] ?? true;
          
          _newClientAssignments = settings['new_client_assignments'] ?? true;
          _clientMessages = settings['client_messages_notifications'] ?? true;
          _sessionReminders = settings['session_reminders'] ?? true;
          _paymentAlerts = settings['payment_alerts'] ?? true;
          
          _systemAlerts = settings['system_alerts'] ?? true;
          _userReports = settings['user_reports_notifications'] ?? true;
          _coachApplications = settings['coach_applications_notifications'] ?? true;
          _paymentIssues = settings['payment_issues_notifications'] ?? true;
          _securityAlerts = settings['security_alerts'] ?? true;
          
          _pushEnabled = settings['push_enabled'] ?? true;
          _emailEnabled = settings['email_enabled'] ?? true;
          _smsEnabled = settings['sms_enabled'] ?? false;
          
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isArabic = languageProvider.isArabic;
    final userRole = authProvider.user?.role ?? 'user';

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'إعدادات الإشعارات' : 'Notification Settings'),
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Notification channels
          Text(
            isArabic ? 'قنوات الإشعارات' : 'Notification Channels',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          CustomCard(
            child: Column(
              children: [
                _buildSwitchTile(
                  title: isArabic ? 'إشعارات الدفع' : 'Push Notifications',
                  subtitle: isArabic ? 'إشعارات على جهازك' : 'Notifications on your device',
                  icon: Icons.notifications_active,
                  value: _pushEnabled,
                  onChanged: (value) {
                    setState(() {
                      _pushEnabled = value;
                    });
                    _saveSettings(isArabic);
                  },
                ),
                const Divider(height: 1),
                _buildSwitchTile(
                  title: isArabic ? 'البريد الإلكتروني' : 'Email',
                  subtitle: isArabic ? 'إشعارات عبر البريد' : 'Notifications via email',
                  icon: Icons.email,
                  value: _emailEnabled,
                  onChanged: (value) {
                    setState(() {
                      _emailEnabled = value;
                    });
                    _saveSettings(isArabic);
                  },
                ),
                const Divider(height: 1),
                _buildSwitchTile(
                  title: isArabic ? 'رسائل SMS' : 'SMS',
                  subtitle: isArabic ? 'إشعارات نصية' : 'Text message notifications',
                  icon: Icons.sms,
                  value: _smsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _smsEnabled = value;
                    });
                    _saveSettings(isArabic);
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // User notifications
          if (userRole == 'user') ...[
            Text(
              isArabic ? 'إشعارات المستخدم' : 'User Notifications',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            CustomCard(
              child: Column(
                children: [
                  _buildSwitchTile(
                    title: isArabic ? 'تذكيرات التمارين' : 'Workout Reminders',
                    subtitle: isArabic ? 'إشعار بموعد التمرين' : 'Remind you about workouts',
                    icon: Icons.fitness_center,
                    value: _workoutReminders,
                    onChanged: (value) {
                      setState(() {
                        _workoutReminders = value;
                      });
                      _saveSettings(isArabic);
                    },
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    title: isArabic ? 'رسائل المدرب' : 'Coach Messages',
                    subtitle: isArabic ? 'إشعار بالرسائل الجديدة' : 'New messages from coach',
                    icon: Icons.chat_bubble,
                    value: _coachMessages,
                    onChanged: (value) {
                      setState(() {
                        _coachMessages = value;
                      });
                      _saveSettings(isArabic);
                    },
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    title: isArabic ? 'تتبع التغذية' : 'Nutrition Tracking',
                    subtitle: isArabic ? 'تذكيرات الوجبات' : 'Meal reminders',
                    icon: Icons.restaurant,
                    value: _nutritionTracking,
                    onChanged: (value) {
                      setState(() {
                        _nutritionTracking = value;
                      });
                      _saveSettings(isArabic);
                    },
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    title: isArabic ? 'العروض الترويجية' : 'Promotions',
                    subtitle: isArabic ? 'عروض وخصومات خاصة' : 'Special offers and discounts',
                    icon: Icons.local_offer,
                    value: _promotions,
                    onChanged: (value) {
                      setState(() {
                        _promotions = value;
                      });
                      _saveSettings(isArabic);
                    },
                  ),
                ],
              ),
            ),
          ],
          
          // Coach notifications
          if (userRole == 'coach') ...[
            Text(
              isArabic ? 'إشعارات المدرب' : 'Coach Notifications',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            CustomCard(
              child: Column(
                children: [
                  _buildSwitchTile(
                    title: isArabic ? 'عملاء جدد' : 'New Client Assignments',
                    subtitle: isArabic ? 'إشعار بالعملاء الجدد' : 'When new clients are assigned',
                    icon: Icons.person_add,
                    value: _newClientAssignments,
                    onChanged: (value) {
                      setState(() {
                        _newClientAssignments = value;
                      });
                      _saveSettings(isArabic);
                    },
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    title: isArabic ? 'رسائل العملاء' : 'Client Messages',
                    subtitle: isArabic ? 'رسائل من العملاء' : 'Messages from clients',
                    icon: Icons.message,
                    value: _clientMessages,
                    onChanged: (value) {
                      setState(() {
                        _clientMessages = value;
                      });
                      _saveSettings(isArabic);
                    },
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    title: isArabic ? 'تذكيرات الجلسات' : 'Session Reminders',
                    subtitle: isArabic ? 'جلسات الفيديو القادمة' : 'Upcoming video sessions',
                    icon: Icons.videocam,
                    value: _sessionReminders,
                    onChanged: (value) {
                      setState(() {
                        _sessionReminders = value;
                      });
                      _saveSettings(isArabic);
                    },
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    title: isArabic ? 'تنبيهات الدفع' : 'Payment Alerts',
                    subtitle: isArabic ? 'تنبيهات الأرباح' : 'Earnings notifications',
                    icon: Icons.account_balance_wallet,
                    value: _paymentAlerts,
                    onChanged: (value) {
                      setState(() {
                        _paymentAlerts = value;
                      });
                      _saveSettings(isArabic);
                    },
                  ),
                ],
              ),
            ),
          ],
          
          // Admin notifications
          if (userRole == 'admin') ...[
            Text(
              isArabic ? 'إشعارات المسؤول' : 'Admin Notifications',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            CustomCard(
              child: Column(
                children: [
                  _buildSwitchTile(
                    title: isArabic ? 'تنبيهات النظام' : 'System Alerts',
                    subtitle: isArabic ? 'مشاكل فنية' : 'Technical issues',
                    icon: Icons.warning,
                    value: _systemAlerts,
                    onChanged: (value) {
                      setState(() {
                        _systemAlerts = value;
                      });
                      _saveSettings(isArabic);
                    },
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    title: isArabic ? 'تقارير المستخدمين' : 'User Reports',
                    subtitle: isArabic ? 'محتوى مبلغ عنه' : 'Reported content',
                    icon: Icons.flag,
                    value: _userReports,
                    onChanged: (value) {
                      setState(() {
                        _userReports = value;
                      });
                      _saveSettings(isArabic);
                    },
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    title: isArabic ? 'طلبات المدربين' : 'Coach Applications',
                    subtitle: isArabic ? 'مدربون جدد' : 'New coach applications',
                    icon: Icons.how_to_reg,
                    value: _coachApplications,
                    onChanged: (value) {
                      setState(() {
                        _coachApplications = value;
                      });
                      _saveSettings(isArabic);
                    },
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    title: isArabic ? 'مشاكل الدفع' : 'Payment Issues',
                    subtitle: isArabic ? 'فشل المعاملات' : 'Failed transactions',
                    icon: Icons.payment,
                    value: _paymentIssues,
                    onChanged: (value) {
                      setState(() {
                        _paymentIssues = value;
                      });
                      _saveSettings(isArabic);
                    },
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    title: isArabic ? 'تنبيهات الأمان' : 'Security Alerts',
                    subtitle: isArabic ? 'نشاط مشبوه' : 'Suspicious activity',
                    icon: Icons.security,
                    value: _securityAlerts,
                    onChanged: (value) {
                      setState(() {
                        _securityAlerts = value;
                      });
                      _saveSettings(isArabic);
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(title),
      subtitle: Text(subtitle),
      secondary: Icon(icon, color: AppColors.primary),
      activeColor: AppColors.primary,
    );
  }
  
  Future<void> _saveSettings(bool isArabic) async {
    setState(() {
      _isSaving = true;
    });
    
    try {
      final repository = UserRepository();
      
      await repository.updateNotificationSettings({
        'workoutReminders': _workoutReminders,
        'coachMessagesNotifications': _coachMessages,
        'nutritionTrackingNotifications': _nutritionTracking,
        'promotionsNotifications': _promotions,
        'newClientAssignments': _newClientAssignments,
        'clientMessagesNotifications': _clientMessages,
        'sessionReminders': _sessionReminders,
        'paymentAlerts': _paymentAlerts,
        'systemAlerts': _systemAlerts,
        'userReportsNotifications': _userReports,
        'coachApplicationsNotifications': _coachApplications,
        'paymentIssuesNotifications': _paymentIssues,
        'securityAlerts': _securityAlerts,
        'pushEnabled': _pushEnabled,
        'emailEnabled': _emailEnabled,
        'smsEnabled': _smsEnabled,
      });
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isArabic 
                  ? 'فشل في حفظ الإعدادات' 
                  : 'Failed to save settings',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
