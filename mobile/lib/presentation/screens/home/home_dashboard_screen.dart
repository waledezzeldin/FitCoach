import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/config/demo_config.dart';
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
import '../coach/coach_dashboard_screen.dart';
import '../admin/admin_dashboard_screen.dart';

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
    return Stack(
      children: [
        Positioned.fill(
          child: Opacity(
            opacity: 0.18,
            child: Image.asset(
              'assets/placeholders/welcome_screens/workout_hero_image_1200x800.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            color: AppColors.background.withOpacity(0.88),
          ),
        ),
        SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroHeader(lang, isArabic),
                  const SizedBox(height: 20),
                  _buildNavigationGrid(lang, isArabic),
                  const SizedBox(height: 20),
                  if (DemoConfig.isDemo) _buildDemoModeSection(lang),
                  if (DemoConfig.isDemo) const SizedBox(height: 20),
                  _buildQuotaSection(lang, isArabic),
                  const SizedBox(height: 24),
                  _buildTodayWorkout(lang, isArabic),
                  const SizedBox(height: 16),
                  _buildTodayNutrition(lang, isArabic),
                  const SizedBox(height: 24),
                  _buildQuickActions(lang, isArabic),
                ],
              ),
            ),
          ),
        ),
      ],
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
                  color: Colors.white.withOpacity(0.2),
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
              color: Colors.white.withOpacity(0.12),
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
                    backgroundColor: Colors.white.withOpacity(0.2),
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
        color: Colors.white.withOpacity(0.12),
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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: item.color, size: 20),
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
                    color: AppColors.error.withOpacity(0.1),
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

class _HomeNavItem {
  final String label;
  final String description;
  final IconData icon;
  final Color color;
  final int index;
  final bool locked;
  final String lockedLabel;

  const _HomeNavItem({
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
    required this.index,
    this.locked = false,
    this.lockedLabel = 'Locked',
  });
}
