import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/config/demo_config.dart';
import '../../../core/constants/colors.dart';
import '../../providers/language_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/workout_provider.dart';
import '../../providers/nutrition_provider.dart';
import '../../providers/quota_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/video_call_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/animated_reveal.dart';
import '../../widgets/custom_stat_info_card.dart';
import '../../widgets/quota_indicator.dart';
import '../../widgets/custom_button.dart';
import '../workout/workout_screen.dart';
import '../nutrition/nutrition_screen.dart';
import '../messaging/coach_messaging_screen.dart';
import '../store/store_screen.dart';
import '../account/account_screen.dart';
import '../coach/coach_dashboard_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../booking/video_booking_screen.dart';
import '../booking/appointment_detail_screen.dart';
import '../video_call/video_call_screen.dart';
import '../exercise/exercise_library_screen.dart';
import '../progress/progress_screen.dart';
import '../inbody/inbody_input_screen.dart';
import '../subscription/subscription_manager_screen.dart';
import '../../../data/models/appointment.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  int _selectedIndex = 0;
  bool _quickAccessExpanded = false;
  String? _joiningAppointmentId;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadData();
      }
    });
  }
  
  Future<void> _loadData() async {
    final userProvider = context.read<UserProvider>();
    final workoutProvider = context.read<WorkoutProvider>();
    final nutritionProvider = context.read<NutritionProvider>();
    final quotaProvider = context.read<QuotaProvider>();
    final appointmentProvider = context.read<AppointmentProvider>();
    final authProvider = context.read<AuthProvider>();
    
    final futures = <Future<void>>[
      userProvider.loadProfile(),
      workoutProvider.loadActivePlan(),
      nutritionProvider.loadActivePlan(),
      nutritionProvider.checkTrialStatus(),
    ];
    final userId = authProvider.user?.id ?? userProvider.user?.id;
    if (userId != null && userId.isNotEmpty) {
      futures.add(quotaProvider.loadQuota(userId));
      futures.add(appointmentProvider.loadUserAppointments(userId: userId, refresh: true));
    }
    await Future.wait(futures);
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final isArabic = languageProvider.isArabic;
    
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          TickerMode(
            enabled: _selectedIndex == 0,
            child: _buildHomeTab(languageProvider, isArabic),
          ),
          TickerMode(
            enabled: _selectedIndex == 1,
            child: _buildWorkoutTab(),
          ),
          TickerMode(
            enabled: _selectedIndex == 2,
            child: _buildNutritionTab(),
          ),
          TickerMode(
            enabled: _selectedIndex == 3,
            child: _buildCoachTab(),
          ),
          TickerMode(
            enabled: _selectedIndex == 4,
            child: _buildStoreTab(),
          ),
          TickerMode(
            enabled: _selectedIndex == 5,
            child: _buildAccountTab(),
          ),
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
            icon: const Icon(Icons.home),
            label: languageProvider.t('home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.fitness_center),
            label: languageProvider.t('workout'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.restaurant),
            label: languageProvider.t('nutrition'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.chat),
            label: languageProvider.t('coach'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.shopping_bag),
            label: languageProvider.t('store'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: languageProvider.t('account'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHomeTab(LanguageProvider lang, bool isArabic) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final tier = user?.subscriptionTier ?? 'Freemium';
    final firstName = (user?.name ?? lang.t('welcome')).split(' ').first;
    final fitnessScore = user?.fitnessScore ?? (DemoConfig.isDemo ? 72 : 0);
    final fitnessUpdatedBy = user?.fitnessScoreUpdatedBy;
    final appointmentProvider = context.watch<AppointmentProvider>();
    final nextSession = appointmentProvider.nextVideoCall;
    final isAppointmentsLoading = appointmentProvider.isLoading && !appointmentProvider.hasLoaded;

    final stats = DemoConfig.isDemo
        ? {
            'caloriesBurned': 2850,
            'caloriesConsumed': 1950,
            'planAdherence': 85,
            'weeklyProgress': 78,
            'workoutsCompleted': 12,
            'totalWorkouts': 14,
          }
        : {
            'caloriesBurned': 0,
            'caloriesConsumed': 0,
            'planAdherence': 0,
            'weeklyProgress': 0,
            'workoutsCompleted': 0,
            'totalWorkouts': 0,
          };

    final todayWorkout = DemoConfig.isDemo
        ? {
            'name': 'Upper Body Strength',
            'duration': '45 min',
            'exercises': 6,
          }
        : null;

    return Stack(
      children: [
        Positioned.fill(
          child: Opacity(
            opacity: 0.8,
            child: Image.network(
              'https://images.unsplash.com/photo-1671970922029-0430d2ae122c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ),
        SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedReveal(
                    offset: Offset(isArabic ? 0.14 : -0.14, 0),
                    initialScale: 0.95,
                    child: _buildHomeHeader(
                      lang,
                      isArabic,
                      firstName,
                      tier,
                      fitnessScore,
                      fitnessUpdatedBy,
                      stats,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isAppointmentsLoading) ...[
                          AnimatedReveal(
                            delay: const Duration(milliseconds: 120),
                            offset: const Offset(0, 0.16),
                            initialScale: 0.94,
                            child: _buildNextSessionLoadingCard(),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (nextSession != null) ...[
                          AnimatedReveal(
                            delay: const Duration(milliseconds: 180),
                            offset: Offset(isArabic ? 0.18 : -0.18, 0),
                            initialScale: 0.94,
                            child: _buildNextSessionCardHome(
                              lang,
                              isArabic,
                              nextSession,
                              appointmentProvider,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (tier != 'Smart Premium') ...[
                          AnimatedReveal(
                            delay: const Duration(milliseconds: 240),
                            offset: const Offset(0, 0.14),
                            initialScale: 0.95,
                            child: _buildQuotaSection(lang, isArabic),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (todayWorkout != null) ...[
                          AnimatedReveal(
                            delay: const Duration(milliseconds: 300),
                            offset: const Offset(0, 0.12),
                            initialScale: 0.96,
                            child: _buildTodayWorkoutCard(lang, isArabic, todayWorkout),
                          ),
                          const SizedBox(height: 16),
                        ],
                        AnimatedReveal(
                          delay: const Duration(milliseconds: 360),
                          offset: const Offset(0, 0.12),
                          initialScale: 0.95,
                          child: _buildNavigationGridCompact(lang, isArabic, tier),
                        ),
                        const SizedBox(height: 16),
                        AnimatedReveal(
                          delay: const Duration(milliseconds: 420),
                          offset: const Offset(0, 0.16),
                          initialScale: 0.95,
                          child: _buildQuickAccessCard(lang, isArabic, tier),
                        ),
                        if (DemoConfig.isDemo) const SizedBox(height: 16),
                        if (DemoConfig.isDemo)
                          AnimatedReveal(
                            delay: const Duration(milliseconds: 480),
                            offset: const Offset(0, 0.18),
                            initialScale: 0.95,
                            child: _buildRecentActivityCard(lang, isArabic),
                          ),
                        if (tier == 'Freemium') const SizedBox(height: 16),
                        if (tier == 'Freemium')
                          AnimatedReveal(
                            delay: const Duration(milliseconds: 540),
                            offset: const Offset(0, 0.2),
                            initialScale: 0.94,
                            child: _buildUpgradeCard(lang, isArabic),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHomeHeader(
    LanguageProvider lang,
    bool isArabic,
    String firstName,
    String tier,
    int fitnessScore,
    String? fitnessUpdatedBy,
    Map<String, int> stats,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.headerGradientStart, AppColors.headerGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${lang.t('home_hello')}, $firstName!',
                      style: AppTextStyles.h3.copyWith(color: Colors.white),
                      textAlign: isArabic ? TextAlign.right : TextAlign.left,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lang.t('home_ready'),
                      style: AppTextStyles.small.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tier,
                  style: AppTextStyles.smallMedium.copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.person, color: Colors.white, size: 20),
                onPressed: () => setState(() => _selectedIndex = 5),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Text(
                            lang.t('home_fitness_score'),
                            style: AppTextStyles.small.copyWith(color: Colors.white70),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            fitnessUpdatedBy == 'coach'
                                ? lang.t('home_updated_by_coach')
                                : lang.t('home_auto_updated'),
                            style: AppTextStyles.small.copyWith(color: Colors.white54),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          '$fitnessScore',
                          style: AppTextStyles.h2.copyWith(color: Colors.white),
                        ),
                        Text(
                          '/100',
                          style: AppTextStyles.small.copyWith(color: Colors.white54),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: fitnessScore / 100,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildHeaderStat(
                  icon: Icons.local_fire_department,
                  value: stats['caloriesBurned']?.toString() ?? '0',
                  label: lang.t('home_calories_burned'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildHeaderStat(
                  icon: Icons.local_dining,
                  value: stats['caloriesConsumed']?.toString() ?? '0',
                  label: lang.t('home_calories_consumed'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildHeaderStat(
                  icon: Icons.track_changes,
                  value: '${stats['planAdherence'] ?? 0}%',
                  label: lang.t('home_adherence'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      lang.t('home_weekly_progress'),
                      style: AppTextStyles.small.copyWith(color: Colors.white70),
                    ),
                    Text(
                      '${stats['weeklyProgress'] ?? 0}%',
                      style: AppTextStyles.small.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (stats['weeklyProgress'] ?? 0) / 100,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${stats['workoutsCompleted'] ?? 0}/${stats['totalWorkouts'] ?? 0}',
                      style: AppTextStyles.small.copyWith(color: Colors.white54),
                    ),
                    Text(
                      lang.t('home_this_week'),
                      style: AppTextStyles.small.copyWith(color: Colors.white54),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextSessionLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // Light surface so text/icons stay clearly visible
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: const [
          CircularProgressIndicator(strokeWidth: 2),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              'Loading your upcoming sessions...',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextSessionCardHome(
    LanguageProvider lang,
    bool isArabic,
    Appointment appointment,
    AppointmentProvider provider,
  ) {
    final dateLabel = _formatHomeSessionDate(appointment, isArabic);
    final countdown = _formatHomeCountdown(appointment, isArabic);
    final canJoin = provider.canJoin(appointment);
    final isVideo = _homeIsVideoSession(appointment);
    final isJoining = _joiningAppointmentId == appointment.id;
    final joinHint = isArabic
        ? 'يمكنك الانضمام قبل 10 دقائق من الموعد'
        : 'Join becomes available 10 minutes before start';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // Keep strong gradient but soften a bit for readability
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isArabic ? 'جلستك القادمة' : 'Your next session',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            appointment.coachName ?? lang.t('coach'),
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            dateLabel,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
          ),
          if (countdown != null) ...[
            const SizedBox(height: 4),
            Text(
              countdown,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: lang.t('join_video_call'),
                  onPressed: (isVideo && canJoin && !isJoining) ? () => _joinAppointmentFromHome(appointment) : null,
                  isLoading: isJoining,
                  size: ButtonSize.medium,
                  fullWidth: true,
                  variant: ButtonVariant.secondary,
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                onPressed: () => _openAppointmentDetailsFromHome(appointment),
                child: Text(isArabic ? 'التفاصيل' : 'Details'),
              ),
            ],
          ),
          if (!canJoin && isVideo)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                joinHint,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  String _formatHomeSessionDate(Appointment appointment, bool isArabic) {
    final locale = isArabic ? 'ar' : 'en';
    try {
      final date = DateTime.parse(appointment.scheduledAt);
      return DateFormat('EEE, MMM d • h:mm a', locale).format(date);
    } catch (_) {
      return appointment.scheduledAt;
    }
  }

  String? _formatHomeCountdown(Appointment appointment, bool isArabic) {
    try {
      final date = DateTime.parse(appointment.scheduledAt);
      final diff = date.difference(DateTime.now());
      if (diff.isNegative) return null;
      final hours = diff.inHours;
      final minutes = diff.inMinutes.remainder(60);
      if (hours <= 0 && minutes <= 0) {
        return isArabic ? 'يبدأ الآن' : 'Starting now';
      }
      if (hours <= 0) {
        return isArabic ? 'يبدأ بعد $minutes دقيقة' : 'Starts in $minutes min';
      }
      final minutesLabel = minutes > 0
          ? (isArabic ? ' و $minutes دقيقة' : ' ${minutes}m')
          : '';
      return isArabic
          ? 'يبدأ بعد $hours ساعة$minutesLabel'
          : 'Starts in ${hours}h$minutesLabel';
    } catch (_) {
      return null;
    }
  }

  bool _homeIsVideoSession(Appointment appointment) {
    final type = (appointment.type ?? 'video').toLowerCase();
    return type == 'video';
  }

  Widget _buildHeaderStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 2),
          Text(
            label.split(' ').first,
            style: AppTextStyles.small.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTodayWorkoutCard(
    LanguageProvider lang,
    bool isArabic,
    Map<String, dynamic> workout,
  ) {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                lang.t('home_todays_workout'),
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      lang.t('home_today'),
                      style: AppTextStyles.small.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            workout['name'] as String,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                workout['duration'] as String,
                style: AppTextStyles.small.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(width: 8),
              Text(
                '\u2022',
                style: AppTextStyles.small.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(width: 8),
              Text(
                '${workout['exercises']} ${lang.t('home_exercises')}',
                style: AppTextStyles.small.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => setState(() => _selectedIndex = 1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.fitness_center, size: 16, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        lang.t('home_start_workout'),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationGridCompact(LanguageProvider lang, bool isArabic, String tier) {
    final isFreemium = tier == 'Freemium';
    final items = [
      _HomeNavItem(
        label: lang.t('home_workouts'),
        description: lang.t('home_workouts_desc'),
        icon: Icons.fitness_center,
        color: const Color(0xFF3B82F6),
        index: 1,
        background: const Color(0xFFEFF6FF),
      ),
      _HomeNavItem(
        label: lang.t('home_nutrition'),
        description: lang.t('home_nutrition_desc'),
        icon: Icons.restaurant,
        color: const Color(0xFF22C55E),
        index: 2,
        locked: isFreemium,
        lockedLabel: lang.t('home_tap_to_upgrade'),
        background: const Color(0xFFF0FDF4),
      ),
      _HomeNavItem(
        label: lang.t('home_coach'),
        description: lang.t('home_coach_desc'),
        icon: Icons.chat_bubble_outline,
        color: const Color(0xFFF59E0B),
        index: 3,
        badge: DemoConfig.isDemo ? '1' : null,
        background: const Color(0xFFFFFBEB),
      ),
      _HomeNavItem(
        label: lang.t('home_store'),
        description: lang.t('home_store_desc'),
        icon: Icons.shopping_bag_outlined,
        color: const Color(0xFF06B6D4),
        index: 4,
        background: const Color(0xFFECFEFF),
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: items.map(_buildNavigationCardCompact).toList(),
    );
  }

  Widget _buildNavigationCardCompact(_HomeNavItem item) {
    return InkWell(
      onTap: () {
        if (item.locked) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SubscriptionManagerScreen()),
          );
        } else {
          setState(() => _selectedIndex = item.index);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: item.locked ? const Color(0xFFFFF7ED) : item.background ?? Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: item.locked ? const Color(0xFFFED7AA) : AppColors.border,
            width: item.locked ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: item.color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(item.icon, color: Colors.white, size: 22),
                ),
                if (item.locked)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF97316), Color(0xFFEC4899)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.workspace_premium, color: Colors.white, size: 22),
                    ),
                  ),
                if (item.badge != null)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        item.badge!,
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              item.description,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (item.locked) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE4C7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.lockedLabel,
                  style: AppTextStyles.small.copyWith(
                    color: const Color(0xFF9A3412),
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessCard(LanguageProvider lang, bool isArabic, String tier) {
    final canAccessInbody = tier != 'Freemium';
    return CustomCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _quickAccessExpanded = !_quickAccessExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.fitness_center, size: 18, color: AppColors.textPrimary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      lang.t('home_quick_access'),
                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Icon(
                    _quickAccessExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (_quickAccessExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  _buildQuickAccessButton(
                    lang.t('home_book_video_session'),
                    Icons.videocam,
                    const Color(0xFF9333EA),
                    isArabic,
                    () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const VideoBookingScreen()),
                    ),
                    background: const Color(0xFFF3E8FF),
                    borderColor: const Color(0xFFE9D5FF),
                  ),
                  const SizedBox(height: 8),
                  _buildQuickAccessButton(
                    lang.t('home_manage_subscription'),
                    Icons.workspace_premium,
                    const Color(0xFF7C3AED),
                    isArabic,
                    () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SubscriptionManagerScreen()),
                    ),
                    background: const Color(0xFFF3E8FF),
                    borderColor: const Color(0xFFE9D5FF),
                  ),
                  const SizedBox(height: 8),
                  _buildQuickAccessButton(
                    lang.t('home_view_progress'),
                    Icons.trending_up,
                    AppColors.textPrimary,
                    isArabic,
                    () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProgressScreen()),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildQuickAccessButton(
                    lang.t('home_exercise_library'),
                    Icons.fitness_center,
                    AppColors.textPrimary,
                    isArabic,
                    () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ExerciseLibraryScreen()),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildQuickAccessButton(
                    lang.t('inbody_title'),
                    Icons.monitor_heart,
                    const Color(0xFF2563EB),
                    isArabic,
                    () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => canAccessInbody
                            ? const InBodyInputScreen()
                            : const SubscriptionManagerScreen(),
                      ),
                    ),
                    background: const Color(0xFFDBEAFE),
                    borderColor: const Color(0xFFBFDBFE),
                  ),
                  const SizedBox(height: 8),
                  _buildQuickAccessButton(
                    lang.t('home_supplements'),
                    Icons.shopping_bag,
                    AppColors.textPrimary,
                    isArabic,
                    () => setState(() => _selectedIndex = 4),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessButton(
    String label,
    IconData icon,
    Color iconColor,
    bool isArabic,
    VoidCallback onPressed,
    {
    Color? background,
    Color? borderColor,
    }
  ) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: iconColor),
      label: Text(
        label,
        style: AppTextStyles.smallMedium.copyWith(color: iconColor == AppColors.textPrimary ? null : iconColor),
      ),
      style: OutlinedButton.styleFrom(
        alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        backgroundColor: background,
        side: borderColor == null ? null : BorderSide(color: borderColor),
      ),
    );
  }

  Widget _buildRecentActivityCard(LanguageProvider lang, bool isArabic) {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, size: 18, color: AppColors.textPrimary),
              const SizedBox(width: 8),
              Text(
                lang.t('home_recent_activity'),
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildActivityRow(
            title: lang.t('home_completed_push_day'),
            subtitle: lang.t('home_hours_ago'),
            badge: '+250 cal',
            color: const Color(0xFF22C55E),
          ),
          const SizedBox(height: 8),
          _buildActivityRow(
            title: lang.t('home_message_from_coach'),
            subtitle: lang.t('home_day_ago'),
            badge: lang.t('home_new'),
            color: const Color(0xFF3B82F6),
          ),
          const SizedBox(height: 8),
          _buildActivityRow(
            title: lang.t('home_weekly_progress_updated'),
            subtitle: lang.t('home_days_ago'),
            color: const Color(0xFF7C3AED),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityRow({
    required String title,
    required String subtitle,
    String? badge,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.smallMedium),
              Text(subtitle, style: AppTextStyles.small.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
        if (badge != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.surface,
            ),
            child: Text(badge, style: AppTextStyles.small.copyWith(color: AppColors.textSecondary)),
          ),
      ],
    );
  }

  Widget _buildUpgradeCard(LanguageProvider lang, bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF3E8FF), Color(0xFFE0F2FE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9D5FF)),
      ),
      child: Column(
        children: [
          const Icon(Icons.workspace_premium, color: Color(0xFF7C3AED), size: 26),
          const SizedBox(height: 8),
          Text(
            lang.t('home_unlock_premium'),
            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF4C1D95)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            lang.t('home_premium_desc'),
            style: AppTextStyles.small.copyWith(color: const Color(0xFF6D28D9)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SubscriptionManagerScreen()),
              ),
              icon: const Icon(Icons.star, size: 14),
              label: Text(lang.t('home_upgrade_now')),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(LanguageProvider lang, bool isArabic) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    final name = user?.name ?? lang.t('welcome');
    final firstName = name.split(' ').first;
    final tier = user?.subscriptionTier ?? 'Freemium';
    final fitnessScore = user?.fitnessScore ?? (DemoConfig.isDemo ? 72 : 0);
    final fitnessUpdatedBy = user?.fitnessScoreUpdatedBy;
    final caloriesBurned = DemoConfig.isDemo ? 2850 : 0;
    final caloriesConsumed = DemoConfig.isDemo ? 1950 : 0;
    final workoutsCompleted = DemoConfig.isDemo ? 12 : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.headerGradientStart, AppColors.headerGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${lang.t('home_hello')}, $firstName!',
                      style: AppTextStyles.h3.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lang.t('home_ready'),
                      style: AppTextStyles.small.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tier,
                  style: AppTextStyles.smallMedium.copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.person_outline, color: Colors.white),
                onPressed: () => setState(() => _selectedIndex = 5),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lang.t('home_fitness_score'),
                            style: AppTextStyles.small.copyWith(color: Colors.white70),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            fitnessUpdatedBy == 'coach'
                                ? lang.t('home_updated_by_coach')
                                : lang.t('home_auto_updated'),
                            style: AppTextStyles.small.copyWith(color: Colors.white54),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          '$fitnessScore',
                          style: AppTextStyles.h2.copyWith(color: Colors.white),
                        ),
                        Text(
                          '/100',
                          style: AppTextStyles.small.copyWith(color: Colors.white54),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: fitnessScore / 100,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildHeroStat(
                  icon: Icons.local_fire_department,
                  value: '$caloriesBurned',
                  label: lang.t('home_calories_burned'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildHeroStat(
                  icon: Icons.fitness_center,
                  value: '$workoutsCompleted',
                  label: lang.t('home_workouts_completed'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildHeroStat(
                  icon: Icons.local_dining,
                  value: '$caloriesConsumed',
                  label: lang.t('home_calories_consumed'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.small.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationGrid(LanguageProvider lang, bool isArabic) {
    final authProvider = context.watch<AuthProvider>();
    final tier = authProvider.user?.subscriptionTier ?? 'Freemium';
    final isFreemium = tier == 'Freemium';

    final items = [
      _HomeNavItem(
        label: lang.t('home_workouts'),
        description: lang.t('home_workouts_desc'),
        icon: Icons.fitness_center,
        color: AppColors.primary,
        index: 1,
      ),
      _HomeNavItem(
        label: lang.t('home_nutrition'),
        description: lang.t('home_nutrition_desc'),
        icon: Icons.restaurant,
        color: AppColors.accent,
        index: 2,
        locked: isFreemium,
        lockedLabel: lang.t('home_locked'),
      ),
      _HomeNavItem(
        label: lang.t('home_coach'),
        description: lang.t('home_coach_desc'),
        icon: Icons.chat_bubble_outline,
        color: AppColors.secondaryForeground,
        index: 3,
      ),
      _HomeNavItem(
        label: lang.t('home_store'),
        description: lang.t('home_store_desc'),
        icon: Icons.shopping_bag_outlined,
        color: AppColors.accent,
        index: 4,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lang.t('home_quick_access'),
          style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: items.map(_buildNavigationCard).toList(),
        ),
      ],
    );
  }

  Widget _buildNavigationCard(_HomeNavItem item) {
    return InkWell(
      onTap: item.locked ? null : () => setState(() => _selectedIndex = item.index),
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: item.color, size: 18),
                ),
                const SizedBox(height: 12),
                Text(
                  item.label,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: AppTextStyles.small.copyWith(color: AppColors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            if (item.locked)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.lockedLabel,
                    style: AppTextStyles.small.copyWith(color: AppColors.error),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  
  Widget _buildSubscriptionBadge(LanguageProvider lang, bool isArabic) {
    final authProvider = context.watch<AuthProvider>();
    final tier = authProvider.user?.subscriptionTier ?? 'Freemium';
    
    Color getColor() {
      switch (tier) {
        case 'Premium':
          return AppColors.secondary;
        case 'Smart Premium':
          return AppColors.accent;
        default:
          return AppColors.textDisabled;
      }
    }
    
    IconData getIcon() {
      switch (tier) {
        case 'Smart Premium':
          return Icons.auto_awesome;
        case 'Premium':
          return Icons.star;
        default:
          return Icons.person;
      }
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [getColor(), getColor().withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(getIcon(), color: Colors.white, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tier,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lang.t('current_plan'),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          if (tier != 'Smart Premium')
            OutlinedButton(
              onPressed: () {
                // Navigate to upgrade
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white),
              ),
              child: Text(lang.t('upgrade')),
            ),
        ],
      ),
    );
  }
  
  Widget _buildQuickStats(LanguageProvider lang, bool isArabic) {
    return Row(
      children: [
        Expanded(
          child: CustomStatCard(
            title: lang.t('day_streak'),
            value: '7',
            icon: Icons.local_fire_department,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomStatCard(
            title: lang.t('workouts'),
            value: '24',
            icon: Icons.fitness_center,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomStatCard(
            title: lang.t('calories'),
            value: '1.8k',
            icon: Icons.local_fire_department_outlined,
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }
  
  Widget _buildQuotaSection(LanguageProvider lang, bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lang.t('monthly_quota'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        const Row(
          children: [
            Expanded(
              child: QuotaIndicator(
                type: 'message',
                showDetails: true,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: QuotaIndicator(
                type: 'videoCall',
                showDetails: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildTodayWorkout(LanguageProvider lang, bool isArabic) {
    final workoutProvider = context.watch<WorkoutProvider>();
    final currentDay = workoutProvider.currentDay;
    final dayLabel = isArabic
        ? currentDay?.dayNameAr ?? currentDay?.dayName ?? lang.t('chest_day')
        : currentDay?.dayName ?? lang.t('chest_day');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lang.t('todays_workout'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        CustomCard(
          onTap: () {
            setState(() => _selectedIndex = 1);
          },
          child: workoutProvider.activePlan != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.fitness_center,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dayLabel,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${workoutProvider.currentDay?.exercises.length ?? 8} ${lang.t('exercises')}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          isArabic ? Icons.chevron_left : Icons.chevron_right,
                          color: AppColors.textDisabled,
                        ),
                      ],
                    ),
                  ],
                )
              : Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.fitness_center_outlined,
                        size: 48,
                        color: AppColors.textDisabled,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        lang.t('no_active_workout_plan'),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
  
  Widget _buildTodayNutrition(LanguageProvider lang, bool isArabic) {
    final nutritionProvider = context.watch<NutritionProvider>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lang.t('todays_nutrition'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        CustomCard(
          onTap: () {
            setState(() => _selectedIndex = 2);
          },
          child: nutritionProvider.activePlan != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.restaurant,
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${nutritionProvider.activePlan?.dailyCalories ?? 2000} ${lang.t('calories')}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '4 ${lang.t('meals')}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          isArabic ? Icons.chevron_left : Icons.chevron_right,
                          color: AppColors.textDisabled,
                        ),
                      ],
                    ),
                  ],
                )
              : Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.restaurant_outlined,
                        size: 48,
                        color: AppColors.textDisabled,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        lang.t('no_active_nutrition_plan'),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
  
  Widget _buildQuickActions(LanguageProvider lang, bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lang.t('quick_actions'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        CustomInfoCard(
          title: lang.t('message_coach'),
          subtitle: lang.t('connect_with_coach'),
          icon: Icons.chat_bubble_outline,
          iconColor: AppColors.primary,
          onTap: () {
            setState(() => _selectedIndex = 3);
          },
        ),
        const SizedBox(height: 12),
        CustomInfoCard(
          title: lang.t('your_progress'),
          subtitle: lang.t('view_achievements'),
          icon: Icons.trending_up,
          iconColor: AppColors.secondary,
          onTap: () {
            // Navigate to progress
          },
        ),
        const SizedBox(height: 12),
        CustomInfoCard(
          title: lang.t('store'),
          subtitle: lang.t('shop_products'),
          icon: Icons.shopping_bag_outlined,
          iconColor: AppColors.accent,
          onTap: () {
            setState(() => _selectedIndex = 4);
          },
        ),
      ],
    );
  }

  Widget _buildDemoModeSection(LanguageProvider lang) {
    final authProvider = context.watch<AuthProvider>();
    final role = authProvider.user?.role ?? 'user';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Demo Mode',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Switch role and open dashboards',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('User'),
                    selected: role == 'user',
                    onSelected: (_) => authProvider.setDemoRole('user'),
                  ),
                  ChoiceChip(
                    label: const Text('Coach'),
                    selected: role == 'coach',
                    onSelected: (_) => authProvider.setDemoRole('coach'),
                  ),
                  ChoiceChip(
                    label: const Text('Admin'),
                    selected: role == 'admin',
                    onSelected: (_) => authProvider.setDemoRole('admin'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CoachDashboardScreen(),
                          ),
                        );
                      },
                      child: const Text('Coach Dashboard'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AdminDashboardScreen(),
                          ),
                        );
                      },
                      child: const Text('Admin Dashboard'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openAppointmentDetailsFromHome(Appointment appointment) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AppointmentDetailScreen(appointment: appointment),
      ),
    );
  }

  Future<void> _joinAppointmentFromHome(Appointment appointment) async {
    final videoCallProvider = context.read<VideoCallProvider>();
    final languageProvider = context.read<LanguageProvider>();

    setState(() => _joiningAppointmentId = appointment.id);

    try {
      final result = await videoCallProvider.canJoinCall(appointment.id);
      if (result == null || result['canJoin'] != true) {
        final message = result?['reason'] ?? languageProvider.t('cannot_join_call');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
        return;
      }

      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VideoCallScreen(
            appointmentId: appointment.id,
            coachId: appointment.coachId,
            coachName: appointment.coachName ?? languageProvider.t('coach'),
            isCoach: false,
          ),
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(languageProvider.t('error'))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _joiningAppointmentId = null);
      }
    }
  }
  
  Widget _buildWorkoutTab() {
    return WorkoutScreen(isActive: _selectedIndex == 1);
  }
  
  Widget _buildNutritionTab() {
    return NutritionScreen(
      onBack: () => setState(() => _selectedIndex = 0),
    );
  }
  
  Widget _buildCoachTab() {
    return const CoachMessagingScreen();
  }
  
  Widget _buildStoreTab() {
    return StoreScreen(
      onBack: () => setState(() => _selectedIndex = 0),
    );
  }
  
  Widget _buildAccountTab() {
    return AccountScreen(
      onBack: () => setState(() => _selectedIndex = 0),
    );
  }
}

class _HomeNavItem {
  final String label;
  final String description;
  final IconData icon;
  final Color color;
  final Color? background;
  final int index;
  final bool locked;
  final String lockedLabel;
  final String? badge;

  const _HomeNavItem({
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
    this.background,
    required this.index,
    this.locked = false,
    this.lockedLabel = 'Locked',
    this.badge,
  });
}
