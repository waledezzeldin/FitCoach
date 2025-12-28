import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../providers/language_provider.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  
  const OnboardingScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    LanguageProvider languageProvider;
    try {
      languageProvider = context.watch<LanguageProvider>();
    } catch (_) {
      languageProvider = LanguageProvider();
    }
    final isArabic = languageProvider.isArabic;
    
    final slides = _getSlides(isArabic);
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: isArabic ? Alignment.topLeft : Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: widget.onComplete,
                  child: Text(
                    languageProvider.t('skip'),
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
            
            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: slides.length,
                itemBuilder: (context, index) {
                  return _OnboardingSlide(
                    slide: slides[index],
                    isArabic: isArabic,
                  );
                },
              ),
            ),
            
            // Page indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                slides.length,
                (index) => _PageIndicator(
                  isActive: index == _currentPage,
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Next/Get Started button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < slides.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      widget.onComplete();
                    }
                  },
                  child: Text(
                    _currentPage < slides.length - 1
                        ? languageProvider.t('next')
                        : languageProvider.t('get_started'),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
  
  List<OnboardingSlideData> _getSlides(bool isArabic) {
    return [
      OnboardingSlideData(
        title: isArabic ? 'مرحباً بك في عاش' : 'Welcome to FitCoach+',
        description: isArabic
            ? 'رحلتك نحو اللياقة البدنية تبدأ هنا مع مدربين محترفين'
            : 'Your fitness journey starts here with professional coaches',
        icon: Icons.fitness_center,
        color: AppColors.primary,
      ),
      OnboardingSlideData(
        title: isArabic ? 'خطط تمرين مخصصة' : 'Personalized Workout Plans',
        description: isArabic
            ? 'احصل على خطط تمرين مصممة خصيصاً لأهدافك وحالتك'
            : 'Get workout plans tailored to your goals and condition',
        icon: Icons.calendar_today,
        color: AppColors.secondary,
      ),
      OnboardingSlideData(
        title: isArabic ? 'تواصل مع مدربك' : 'Connect with Your Coach',
        description: isArabic
            ? 'تواصل مباشر مع مدربك للحصول على الإرشادات والدعم'
            : 'Direct communication with your coach for guidance and support',
        icon: Icons.chat_bubble_outline,
        color: AppColors.accent,
      ),
    ];
  }
}

class OnboardingSlideData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  
  OnboardingSlideData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class _OnboardingSlide extends StatelessWidget {
  final OnboardingSlideData slide;
  final bool isArabic;
  
  const _OnboardingSlide({
    required this.slide,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: slide.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              slide.icon,
              size: 60,
              color: slide.color,
            ),
          ),
          
          const SizedBox(height: 48),
          
          // Title
          Text(
            slide.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // Description
          Text(
            slide.description,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final bool isActive;
  
  const _PageIndicator({
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.border,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
