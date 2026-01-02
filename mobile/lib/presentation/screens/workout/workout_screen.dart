import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/config/demo_config.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/workout_plan.dart';
import '../../providers/language_provider.dart';
import '../../providers/workout_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_button.dart';
import '../intake/second_intake_screen.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  bool _promptedSecondIntake = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<WorkoutProvider>().loadActivePlan();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowSecondIntake();
    });
  }

  void _maybeShowSecondIntake() {
    if (_promptedSecondIntake) return;
    if (!DemoConfig.isDemo) return;
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;
    if (user == null || user.hasCompletedSecondIntake) return;
    _promptedSecondIntake = true;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SecondIntakeScreen(
          onComplete: () {
            if (mounted) {
              Navigator.of(context).pop();
              context.read<WorkoutProvider>().loadActivePlan();
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final workoutProvider = context.watch<WorkoutProvider>();
    final isArabic = languageProvider.isArabic;
    
    if (workoutProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (workoutProvider.activePlan == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(languageProvider.t('workout')),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.fitness_center_outlined,
                size: 80,
                color: AppColors.textDisabled,
              ),
              const SizedBox(height: 24),
              Text(
                languageProvider.t('no_active_workout_plan'),
                style: const TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                languageProvider.t('workout_plan_coming_soon'),
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
    
    return Scaffold(
      appBar: AppBar(
        title: Text(workoutProvider.activePlan!.name ?? ''),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Show workout history
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildWorkoutOverviewHeader(workoutProvider, languageProvider),

          // Weekly calendar
          _buildWeeklyCalendar(workoutProvider, languageProvider, isArabic),
          
          // Exercise list
          Expanded(
            child: _buildExerciseList(workoutProvider, languageProvider, isArabic),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutOverviewHeader(
    WorkoutProvider provider,
    LanguageProvider lang,
  ) {
    final plan = provider.activePlan!;
    final currentDay = provider.currentDay;

    final totalExercises = currentDay?.exercises.length ?? 0;
    final completedExercises = currentDay == null
        ? 0
        : currentDay.exercises.where((e) => provider.isExerciseCompleted(e.id)).length;
    final progress = totalExercises == 0 ? 0.0 : completedExercises / totalExercises;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.headerGradientStart, AppColors.headerGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lang.t('workout_overview'),
            style: AppTextStyles.small.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 6),
          Text(
            plan.name ?? lang.t('workout'),
            style: AppTextStyles.h3.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildHeaderPill(
                icon: Icons.fitness_center,
                label: '$totalExercises ${lang.t('exercises')}',
              ),
              const SizedBox(width: 8),
              _buildHeaderPill(
                icon: Icons.check_circle_outline,
                label: '$completedExercises ${lang.t('completed')}',
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: (0.2 * 255)),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            lang.t('workout_progress', args: {
              'completed': '$completedExercises',
              'total': '$totalExercises',
            }),
            style: AppTextStyles.small.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderPill({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: (0.14 * 255)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: (0.12 * 255))),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.small.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWeeklyCalendar(
    WorkoutProvider provider,
    LanguageProvider lang,
    bool isArabic,
  ) {
    final plan = provider.activePlan!;
    final currentDayIndex = provider.currentDayIndex ?? 0;
    
    return Container(
      height: 100,
      color: AppColors.surface,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(8),
        itemCount: plan.days!.length,
        itemBuilder: (context, index) {
          final day = plan.days![index];
          final isSelected = index == currentDayIndex;
          
          return GestureDetector(
            onTap: () {
              provider.setCurrentDay(index);
            },
            child: Container(
              width: 80,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    lang.t('workout_day', args: {'number': '${day.dayNumber}'}),
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    day.dayName.length > 8 
                        ? '${day.dayName.substring(0, 8)}...'
                        : day.dayName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${day.exercises.length} ${lang.t('exercises')}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white.withValues(alpha: (0.8 * 255)) : AppColors.textDisabled,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildExerciseList(
    WorkoutProvider provider,
    LanguageProvider lang,
    bool isArabic,
  ) {
    final currentDay = provider.currentDay;
    
    if (currentDay == null) {
      return Center(
        child: Text(lang.t('workout_select_day')),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: currentDay.exercises.length,
      itemBuilder: (context, index) {
        final exercise = currentDay.exercises[index];
        return _buildExerciseCard(exercise, provider, lang, isArabic, index);
      },
    );
  }
  
  Widget _buildExerciseCard(
    Exercise exercise,
    WorkoutProvider provider,
    LanguageProvider lang,
    bool isArabic,
    int index,
  ) {
    final authProvider = context.watch<AuthProvider>();
    final userInjuries = authProvider.user?.injuries ?? [];
    final hasConflict = exercise.hasInjuryConflict(userInjuries);
    final isCompleted = provider.isExerciseCompleted(exercise.id);
    
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.zero,
      border: hasConflict 
          ? Border.all(color: AppColors.warning, width: 2)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Exercise number
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCompleted 
                        ? AppColors.success
                        : AppColors.primary.withValues(alpha: (0.1 * 255)),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Exercise name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? exercise.nameAr : exercise.nameEn,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (exercise.muscleGroup != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          exercise.muscleGroup!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Video button
                if (exercise.videoUrl != null)
                  IconButton(
                    icon: const Icon(Icons.play_circle_outline),
                    color: AppColors.primary,
                    onPressed: () {
                      _showExerciseDetail(exercise, lang, isArabic);
                    },
                  ),
              ],
            ),
          ),
          
          // Video thumbnail
          if (exercise.thumbnailUrl != null)
            GestureDetector(
              onTap: () => _showExerciseDetail(exercise, lang, isArabic),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  image: DecorationImage(
                    image: NetworkImage(exercise.thumbnailUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: (0.6 * 255)),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
          
          // Exercise details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sets x Reps
                Row(
                  children: [
                    _buildInfoChip(
                      icon: Icons.repeat,
                      label: '${exercise.sets} ${lang.t('sets')}',
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      icon: Icons.fitness_center,
                      label: '${exercise.reps} ${lang.t('reps')}',
                    ),
                    if (exercise.restTime != null) ...[
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        icon: Icons.timer,
                        label: exercise.restTime!,
                      ),
                    ],
                  ],
                ),
                
                // Injury warning
                if (hasConflict) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: (0.1 * 255)),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.warning.withValues(alpha: (0.3 * 255))),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.warning,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            lang.t('workout_injury_conflict'),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                // Notes
                if (exercise.notes != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    exercise.notes!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                
                const SizedBox(height: 16),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: isCompleted
                            ? lang.t('completed')
                            : lang.t('complete'),
                        onPressed: isCompleted
                            ? null
                            : () {
                                provider.completeExercise(exercise.id);
                              },
                        variant: isCompleted
                            ? ButtonVariant.outline
                            : ButtonVariant.primary,
                        icon: isCompleted ? Icons.check : null,
                        fullWidth: true,
                      ),
                    ),
                    if (hasConflict) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          text: lang.t('substitute'),
                          onPressed: () {
                            _showSubstituteDialog(exercise, provider, lang, isArabic);
                          },
                          variant: ButtonVariant.secondary,
                          icon: Icons.swap_horiz,
                          fullWidth: true,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  void _showExerciseDetail(Exercise exercise, LanguageProvider lang, bool isArabic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
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
                
                // Exercise name
                Text(
                  isArabic ? exercise.nameAr : exercise.nameEn,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Video player placeholder
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.play_circle_outline,
                      size: 60,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Instructions
                if (exercise.instructions != null) ...[
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
                        ? (exercise.instructionsAr ?? exercise.instructions!)
                        : (exercise.instructionsEn ?? exercise.instructions!),
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
  
  Future<void> _showSubstituteDialog(
    Exercise exercise,
    WorkoutProvider provider,
    LanguageProvider lang,
    bool isArabic,
  ) async {
    final authProvider = context.read<AuthProvider>();
    final userInjuries = authProvider.user?.injuries ?? [];
    
      showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang.t('substitute_exercise')),
        content: FutureBuilder<List<Exercise>>(
          future: provider.getExerciseAlternatives(exercise.id, userInjuries),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return Text(
                lang.t('no_alternatives_available'),
              );
            }
            
            final alternatives = snapshot.data!;
            
            return SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: alternatives.length,
                itemBuilder: (context, index) {
                  final alt = alternatives[index];
                  return ListTile(
                    title: Text(isArabic ? alt.nameAr : alt.nameEn),
                    subtitle: Text(alt.muscleGroup ?? ''),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      Navigator.pop(context);
                      final success = await provider.substituteExercise(
                        exercise.id,
                        alt.id,
                      );
                      
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              lang.t('exercise_substituted_successfully'),
                            ),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(lang.t('cancel')),
          ),
        ],
      ),
    );
  }
}
