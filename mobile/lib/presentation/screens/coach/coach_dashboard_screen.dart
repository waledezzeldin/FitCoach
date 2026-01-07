import '../../widgets/error_banner.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../providers/language_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/coach_provider.dart';
import '../../providers/quota_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_stat_info_card.dart';
import '../../widgets/quota_indicator.dart';
import '../account/account_screen.dart';
import 'coach_clients_screen.dart';
import 'coach_calendar_screen.dart';
import 'workout_plan_builder_screen.dart';
import 'nutrition_plan_builder_screen.dart';

class CoachDashboardScreen extends StatefulWidget {
  const CoachDashboardScreen({super.key});

  @override
  State<CoachDashboardScreen> createState() => _CoachDashboardScreenState();
}

class _CoachDashboardScreenState extends State<CoachDashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAnalytics();
      _loadQuota();
    });
  }

  void _loadAnalytics() {
    final authProvider = context.read<AuthProvider>();
    final coachProvider = context.read<CoachProvider>();
    
    if (authProvider.user?.id != null) {
      coachProvider.loadAnalytics(authProvider.user!.id);
      // Also load today's appointments for the schedule
      coachProvider.loadAppointments(
        coachId: authProvider.user!.id,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 1)),
      );
    }
  }

  void _loadQuota() {
    final authProvider = context.read<AuthProvider>();
    final quotaProvider = context.read<QuotaProvider>();
    if (authProvider.user?.id != null) {
      quotaProvider.loadQuota(authProvider.user!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isArabic = languageProvider.isArabic;
    
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboardTab(languageProvider, authProvider, isArabic),
          const CoachClientsScreen(),
          const CoachCalendarScreen(),
          _buildMessagesTab(languageProvider),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textDisabled,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard),
            label: languageProvider.t('coach_tab_dashboard'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people),
            label: languageProvider.t('coach_tab_clients'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_month),
            label: languageProvider.t('coach_tab_calendar'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.chat),
            label: languageProvider.t('coach_tab_messages'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDashboardTab(
    LanguageProvider lang,
    AuthProvider auth,
    bool isArabic,
  ) {
    final coachProvider = context.watch<CoachProvider>();
    final analytics = coachProvider.analytics;
    final isLoading = coachProvider.isLoading;
    final todayAppointmentCount = coachProvider.appointments.length;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          _loadAnalytics();
          _loadQuota();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Error banners
              Builder(
                builder: (context) {
                  final quotaError = context.watch<QuotaProvider>().error;
                  final coachProvider = context.watch<CoachProvider>();
                  final analyticsError = coachProvider.error;
                  return Column(
                    children: [
                      if (quotaError != null && quotaError.isNotEmpty)
                        ErrorBanner(
                          message: quotaError,
                          onRetry: _loadQuota,
                        ),
                      if (analyticsError != null && analyticsError.isNotEmpty)
                        ErrorBanner(
                          message: analyticsError,
                          onRetry: _loadAnalytics,
                        ),
                    ],
                  );
                },
              ),
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lang.t(
                            'coach_greeting',
                            args: {'name': auth.user?.name ?? ''},
                          ),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lang.t('coach_dashboard_title'),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.account_circle),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const AccountScreen()),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () {
                          _loadAnalytics();
                          _loadQuota();
                        },
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),
              // Quota indicators
              Row(
                children: [
                  Expanded(child: QuotaIndicator(type: 'message')),
                  const SizedBox(width: 12),
                  Expanded(child: QuotaIndicator(type: 'videoCall')),
                ],
              ),
              const SizedBox(height: 24),
              
              // Quick stats
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (analytics != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: CustomStatCard(
                        title: lang.t('coach_metric_active_clients'),
                        value: '${analytics.activeClients}',
                        icon: Icons.people,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomStatCard(
                        title: lang.t('coach_metric_upcoming'),
                        value: '${analytics.upcomingAppointments}',
                        icon: Icons.video_call,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: CustomStatCard(
                        title: lang.t('coach_metric_new_messages'),
                        value: '${analytics.unreadMessages}',
                        icon: Icons.message,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomStatCard(
                        title: lang.t('coach_metric_today_sessions'),
                        value: '$todayAppointmentCount',
                        icon: Icons.today,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Today's schedule
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    lang.t('coach_schedule_today'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 2; // Calendar tab
                      });
                    },
                    child: Text(lang.t('coach_view_all')),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else
                _buildTodaySchedule(coachProvider, lang, isArabic),
              
              const SizedBox(height: 24),
              
              // Quick actions
              Text(
                lang.t('coach_quick_actions'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              CustomInfoCard(
                title: lang.t('coach_action_workout_plan'),
                subtitle: lang.t('coach_action_workout_plan_desc'),
                icon: Icons.fitness_center,
                iconColor: AppColors.primary,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => WorkoutPlanBuilderScreen(
                        clientId: 'demo-client',
                        clientName: lang.t('auth_demo_user'),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 12),
              
              CustomInfoCard(
                title: lang.t('coach_action_nutrition_plan'),
                subtitle: lang.t('coach_action_nutrition_plan_desc'),
                icon: Icons.restaurant,
                iconColor: AppColors.secondary,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => NutritionPlanBuilderScreen(
                        clientId: 'demo-client',
                        clientName: lang.t('auth_demo_user'),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 12),
              
              CustomInfoCard(
                title: lang.t('coach_action_schedule_session'),
                subtitle: lang.t('coach_action_schedule_session_desc'),
                icon: Icons.video_call,
                iconColor: AppColors.accent,
                onTap: () {
                  setState(() {
                    _selectedIndex = 2; // Calendar tab
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSessionItem({
    required String time,
    required String clientName,
    required String type,
    required bool isArabic,
    required LanguageProvider lang,
  }) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.person,
          color: AppColors.primary,
        ),
      ),
      title: Text(clientName),
      subtitle: Text('$time • $type'),
      trailing: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: Text(lang.t('coach_join')),
      ),
    );
  }
  
  Widget _buildTodaySchedule(
    CoachProvider coachProvider,
    LanguageProvider lang,
    bool isArabic,
  ) {
    final today = DateTime.now();
    final todayAppointments = coachProvider.appointments.where((appointment) {
      DateTime? scheduledDate;
      try {
        scheduledDate = DateTime.parse(appointment.scheduledAt);
      } catch (_) {
        return false;
      }
      return scheduledDate.year == today.year &&
             scheduledDate.month == today.month &&
             scheduledDate.day == today.day;
    }).toList();

    if (todayAppointments.isEmpty) {
      return CustomCard(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.event_busy,
                  size: 48,
                  color: AppColors.textDisabled,
                ),
                const SizedBox(height: 12),
                Text(
                  lang.t('coach_no_appointments'),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return CustomCard(
      child: Column(
        children: todayAppointments.asMap().entries.map((entry) {
          final index = entry.key;
          final appointment = entry.value;
          DateTime? scheduledDate;
          try {
            scheduledDate = DateTime.parse(appointment.scheduledAt);
          } catch (_) {
            scheduledDate = null;
          }
          final timeStr = scheduledDate != null
              ? '${scheduledDate.hour.toString().padLeft(2, '0')}:${scheduledDate.minute.toString().padLeft(2, '0')}'
              : '--:--';
          final clientName = appointment.userName ?? appointment.coachName ?? 'Unknown';
          final typeDisplay = _getTypeDisplayName(appointment.type, context.read<LanguageProvider>());
          return Column(
            children: [
              _buildSessionItem(
                time: timeStr,
                clientName: clientName,
                type: typeDisplay,
                isArabic: isArabic,
                lang: lang,
              ),
              if (index < todayAppointments.length - 1) const Divider(),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _getTypeDisplayName(String? type, LanguageProvider lang) {
    switch (type) {
      case 'video':
        return lang.t('video_call');
      case 'chat':
        return lang.t('chat');
      case 'assessment':
        return lang.t('assessment');
      default:
        return lang.t('unknown');
    }
  }
  
  Widget _buildMessagesTab(LanguageProvider lang) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.t('coach_messages')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: 24),
            Text(
              lang.t('coach_messages_coming_soon'),
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
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
}
