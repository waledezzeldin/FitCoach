import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../../core/constants/colors.dart';
import '../../../data/models/nutrition_plan.dart';
import '../../providers/language_provider.dart';
import '../../providers/nutrition_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_card.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = context.read<NutritionProvider>();
      provider.loadActivePlan();
      provider.checkTrialStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final nutritionProvider = context.watch<NutritionProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isArabic = languageProvider.isArabic;
    final subscriptionTier = authProvider.user?.subscriptionTier ?? 'Freemium';
    
    // Check access
    final canAccess = nutritionProvider.canAccessNutrition(subscriptionTier);
    
    if (nutritionProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Show trial expired message for Freemium users
    if (!canAccess && subscriptionTier == 'Freemium') {
      return _buildTrialExpired(languageProvider, isArabic);
    }
    
    if (nutritionProvider.activePlan == null) {
      return _buildNoPlan(languageProvider, isArabic);
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(nutritionProvider.activePlan!.name ?? ''),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Show nutrition history
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await nutritionProvider.loadActivePlan();
          await nutritionProvider.checkTrialStatus();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trial banner for Freemium users
              if (subscriptionTier == 'Freemium' && !nutritionProvider.hasTrialExpired)
                _buildTrialBanner(nutritionProvider, languageProvider, isArabic),
              
              if (subscriptionTier == 'Freemium' && !nutritionProvider.hasTrialExpired)
                const SizedBox(height: 16),
              
              // Macro progress
              _buildMacroProgress(
                nutritionProvider.activePlan!,
                languageProvider,
                isArabic,
              ),
              
              const SizedBox(height: 24),
              
              // Calorie counter
              _buildCalorieCounter(
                nutritionProvider.activePlan!,
                languageProvider,
                isArabic,
              ),
              
              const SizedBox(height: 24),
              
              // Meals
              Text(
                languageProvider.t('todays_meals'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              _buildMealsList(
                nutritionProvider.activePlan!,
                languageProvider,
                isArabic,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTrialBanner(
    NutritionProvider provider,
    LanguageProvider lang,
    bool isArabic,
  ) {
    final daysRemaining = provider.trialDaysRemaining;
    final isExpiringSoon = daysRemaining <= 3;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isExpiringSoon
              ? [AppColors.warning, AppColors.warning.withValues(alpha: (0.7 * 255))]
              : [AppColors.primary, AppColors.primary.withValues(alpha: (0.7 * 255))],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isExpiringSoon ? Icons.warning_amber : Icons.info_outline,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  lang.t('trial_period'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            lang.t(
              'trial_expiring',
              args: {'days': daysRemaining.toString()},
            ),
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: (0.9 * 255)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to upgrade
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: isExpiringSoon ? AppColors.warning : AppColors.primary,
              ),
              child: Text(lang.t('upgrade_to_premium')),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTrialExpired(LanguageProvider lang, bool isArabic) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.t('nutrition')),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 80,
                color: AppColors.warning,
              ),
              const SizedBox(height: 24),
              Text(
                lang.t('trial_expired'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                lang.t('upgrade_prompt'),
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to upgrade
                  },
                  child: Text(lang.t('upgrade_to_premium')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildNoPlan(LanguageProvider lang, bool isArabic) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.t('nutrition')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_outlined,
              size: 80,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: 24),
            Text(
              lang.t('no_active_nutrition_plan'),
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              lang.t('nutrition_plan_coming_soon'),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textDisabled,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMacroProgress(
    NutritionPlan plan,
    LanguageProvider lang,
    bool isArabic,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildMacroRing(
            label: lang.t('protein'),
            value: 120,
            target: plan.macros?['protein'] ?? 0,
            color: AppColors.primary,
          ),
        ),
        Expanded(
          child: _buildMacroRing(
            label: lang.t('carbs'),
            value: 200,
            target: plan.macros?['carbs'] ?? 0,
            color: AppColors.secondary,
          ),
        ),
        Expanded(
          child: _buildMacroRing(
            label: lang.t('fats'),
            value: 50,
            target: plan.macros?['fats'] ?? 0,
            color: AppColors.accent,
          ),
        ),
      ],
    );
  }
  
  Widget _buildMacroRing({
    required String label,
    required double value,
    required double target,
    required Color color,
  }) {
    final percentage = (value / target).clamp(0.0, 1.0);
    
    return Column(
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(100, 100),
                painter: _MacroRingPainter(
                  percentage: percentage,
                  color: color,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${value.toInt()}g',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    '/ ${target.toInt()}g',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
  
  Widget _buildCalorieCounter(
    NutritionPlan plan,
    LanguageProvider lang,
    bool isArabic,
  ) {
    final consumed = 1200; // Mock data
    final target = plan.dailyCalories ?? 0;
    final remaining = target - consumed;
    final percentage = target > 0 ? (consumed / target).clamp(0.0, 1.0) : 0.0;
    
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lang.t('calories'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$consumed',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    lang.t('consumed'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$remaining',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                  Text(
                    lang.t('remaining'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: AppColors.surface,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 12,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMealsList(
    NutritionPlan plan,
    LanguageProvider lang,
    bool isArabic,
  ) {
    // Get today's meals (simplified - use day index in real app)
    final todayMeals = (plan.days != null && plan.days!.isNotEmpty) ? plan.days![0].meals : <Meal>[];
    
    return Column(
      children: todayMeals.map((meal) {
        return _buildMealCard(meal, lang, isArabic);
      }).toList(),
    );
  }
  
  Widget _buildMealCard(Meal meal, LanguageProvider lang, bool isArabic) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meal header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getMealColor(meal.type).withValues(alpha: (0.1 * 255)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getMealIcon(meal.type),
                  color: _getMealColor(meal.type),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? meal.nameAr : meal.nameEn,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${meal.time} • ${meal.calories} ${lang.t('cal_unit')}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  _showMealDetail(meal, lang, isArabic);
                },
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Food items
          ...meal.foods.take(3).map((food) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.circle,
                    size: 6,
                    color: AppColors.textDisabled,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${isArabic ? food.nameAr : food.nameEn} (${food.quantity}${food.unit})',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          
          if (meal.foods.length > 3) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                lang.t(
                  'more_items',
                  args: {'count': (meal.foods.length - 3).toString()},
                ),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textDisabled,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Color _getMealColor(String type) {
    switch (type.toLowerCase()) {
      case 'breakfast':
        return AppColors.warning;
      case 'lunch':
        return AppColors.secondary;
      case 'dinner':
        return AppColors.primary;
      case 'snack':
        return AppColors.accent;
      default:
        return AppColors.textDisabled;
    }
  }
  
  IconData _getMealIcon(String type) {
    switch (type.toLowerCase()) {
      case 'breakfast':
        return Icons.free_breakfast;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      case 'snack':
        return Icons.cookie;
      default:
        return Icons.restaurant;
    }
  }
  
  void _showMealDetail(Meal meal, LanguageProvider lang, bool isArabic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Meal name
                Text(
                  isArabic ? meal.nameAr : meal.nameEn,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // All food items
                ...meal.foods.map((food) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isArabic ? food.nameAr : food.nameEn,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${food.quantity}${food.unit} • ${food.calories} ${lang.t('cal_unit')}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                
                const SizedBox(height: 24),
                
                // Instructions if available
                if (meal.instructions != null) ...[
                  Text(
                    lang.t('instructions'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isArabic 
                        ? (meal.instructionsAr ?? meal.instructions!)
                        : (meal.instructionsEn ?? meal.instructions!),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom painter for macro rings
class _MacroRingPainter extends CustomPainter {
  final double percentage;
  final Color color;
  
  _MacroRingPainter({
    required this.percentage,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 8.0;
    
    // Background circle
    final bgPaint = Paint()
      ..color = AppColors.surface
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    
    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);
    
    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -math.pi / 2,
      2 * math.pi * percentage,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_MacroRingPainter oldDelegate) {
    return oldDelegate.percentage != percentage;
  }
}
