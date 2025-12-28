import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../providers/language_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/workout_provider.dart';
import '../../providers/nutrition_provider.dart';
import '../../providers/quota_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_stat_info_card.dart';
import '../../widgets/quota_indicator.dart';
import '../workout/workout_screen.dart';
import '../nutrition/nutrition_screen.dart';
import '../messaging/coach_messaging_screen.dart';
import '../store/store_screen.dart';
import '../account/account_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  int _selectedIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    final userProvider = context.read<UserProvider>();
    final workoutProvider = context.read<WorkoutProvider>();
    final nutritionProvider = context.read<NutritionProvider>();
    final quotaProvider = context.read<QuotaProvider>();
    
    final futures = <Future<void>>[
      userProvider.loadProfile(),
      workoutProvider.loadActivePlan(),
      nutritionProvider.loadActivePlan(),
      nutritionProvider.checkTrialStatus(),
    ];
    final userId = userProvider.user?.id;
    if (userId != null && userId.isNotEmpty) {
      futures.add(quotaProvider.loadQuota(userId));
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
          _buildHomeTab(languageProvider, isArabic),
          _buildWorkoutTab(),
          _buildNutritionTab(),
          _buildCoachTab(),
          _buildStoreTab(),
          _buildAccountTab(),
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
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with greeting
              _buildHeader(lang, isArabic),
              
              const SizedBox(height: 24),
              
              // Subscription tier badge
              _buildSubscriptionBadge(lang, isArabic),
              
              const SizedBox(height: 24),
              
              // Quick stats
              _buildQuickStats(lang, isArabic),
              
              const SizedBox(height: 24),
              
              // Quota indicators
              _buildQuotaSection(lang, isArabic),
              
              const SizedBox(height: 24),
              
              // Today's workout
              _buildTodayWorkout(lang, isArabic),
              
              const SizedBox(height: 16),
              
              // Today's nutrition
              _buildTodayNutrition(lang, isArabic),
              
              const SizedBox(height: 24),
              
              // Quick actions
              _buildQuickActions(lang, isArabic),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader(LanguageProvider lang, bool isArabic) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = lang.t('good_morning');
    } else if (hour < 18) {
      greeting = lang.t('good_afternoon');
    } else {
      greeting = lang.t('good_evening');
    }
    
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Text(
            user?.name?.substring(0, 1).toUpperCase() ?? 'U',
            style: const TextStyle(
              fontSize: 24,
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
                greeting,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.name ?? lang.t('welcome'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            // Navigate to notifications
          },
        ),
      ],
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
                                workoutProvider.currentDay?.dayName ?? lang.t('chest_day'),
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
                        const Icon(Icons.chevron_right, color: AppColors.textDisabled),
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
                        const Icon(Icons.chevron_right, color: AppColors.textDisabled),
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
  
  Widget _buildWorkoutTab() {
    return const WorkoutScreen();
  }
  
  Widget _buildNutritionTab() {
    return const NutritionScreen();
  }
  
  Widget _buildCoachTab() {
    return const CoachMessagingScreen();
  }
  
  Widget _buildStoreTab() {
    return const StoreScreen();
  }
  
  Widget _buildAccountTab() {
    return const AccountScreen();
  }
}
