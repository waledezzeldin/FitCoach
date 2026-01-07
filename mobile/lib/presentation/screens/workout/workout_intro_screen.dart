import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../providers/language_provider.dart';
import '../../widgets/animated_reveal.dart';

class WorkoutIntroScreen extends StatelessWidget {
  final VoidCallback onGetStarted;

  const WorkoutIntroScreen({
    super.key,
    required this.onGetStarted,
  });

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final isArabic = languageProvider.isArabic;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.8,
              child: Image.asset(
                'assets/placeholders/splash_onboarding/workout_onboarding.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xB2000000),
                    Color(0x99000000),
                    Color(0xCC000000),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  AnimatedReveal(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: (0.35 * 255)),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AnimatedReveal(
                    delay: const Duration(milliseconds: 80),
                    child: Text(
                      languageProvider.t('workouts_intro_title'),
                      style: AppTextStyles.h2.copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedReveal(
                    delay: const Duration(milliseconds: 140),
                    child: Text(
                      languageProvider.t('workouts_intro_subtitle'),
                      style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        AnimatedReveal(
                          delay: const Duration(milliseconds: 220),
                          child: _FeatureCard(
                            icon: Icons.track_changes,
                            iconColor: const Color(0xFF7BA7FF),
                            title: languageProvider.t('workouts_intro_feature1_title'),
                            description: languageProvider.t('workouts_intro_feature1_desc'),
                            isArabic: isArabic,
                          ),
                        ),
                        const SizedBox(height: 12),
                        AnimatedReveal(
                          delay: const Duration(milliseconds: 300),
                          child: _FeatureCard(
                            icon: Icons.check_circle_outline,
                            iconColor: const Color(0xFF74E1A8),
                            title: languageProvider.t('workouts_intro_feature2_title'),
                            description: languageProvider.t('workouts_intro_feature2_desc'),
                            isArabic: isArabic,
                          ),
                        ),
                        const SizedBox(height: 12),
                        AnimatedReveal(
                          delay: const Duration(milliseconds: 380),
                          child: _FeatureCard(
                            icon: Icons.trending_up,
                            iconColor: const Color(0xFFC9A8FF),
                            title: languageProvider.t('workouts_intro_feature3_title'),
                            description: languageProvider.t('workouts_intro_feature3_desc'),
                            isArabic: isArabic,
                          ),
                        ),
                        const SizedBox(height: 12),
                        AnimatedReveal(
                          delay: const Duration(milliseconds: 460),
                          child: _FeatureCard(
                            icon: Icons.calendar_today,
                            iconColor: const Color(0xFFFFC48B),
                            title: languageProvider.t('workouts_intro_feature4_title'),
                            description: languageProvider.t('workouts_intro_feature4_desc'),
                            isArabic: isArabic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AnimatedReveal(
                    delay: const Duration(milliseconds: 520),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onGetStarted,
                        icon: Icon(
                          isArabic ? Icons.arrow_back : Icons.arrow_forward,
                          color: Colors.white,
                        ),
                        label: Text(languageProvider.t('workouts_get_started')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedReveal(
                    delay: const Duration(milliseconds: 600),
                    child: Text(
                      languageProvider.t('workouts_intro_note'),
                      style: AppTextStyles.small.copyWith(color: Colors.white60),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final bool isArabic;

  const _FeatureCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: (0.12 * 255)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: (0.2 * 255))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: isArabic
            ? [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: (0.2 * 255)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
              ]
            : [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: (0.2 * 255)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
      ),
    );
  }
}
