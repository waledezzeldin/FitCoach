import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../providers/language_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';

class FirstIntakeScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onSkip;
  
  const FirstIntakeScreen({
    super.key,
    required this.onComplete,
    required this.onSkip,
  });

  @override
  State<FirstIntakeScreen> createState() => _FirstIntakeScreenState();
}

class _FirstIntakeScreenState extends State<FirstIntakeScreen> {
  int _currentStep = 0;
  
  String? _selectedGender;
  String? _selectedGoal;
  String? _selectedLocation;
  int? _selectedFrequency;
  String? _selectedExperience;
  
  final List<int> _frequencies = [2, 3, 4, 5, 6, 7];

  Future<void> _submitIntake() async {
    if (_selectedGender == null || _selectedGoal == null || 
        _selectedLocation == null || _selectedFrequency == null ||
        _selectedExperience == null) {
      _showError('Please complete all questions');
      return;
    }
    
    final userProvider = context.read<UserProvider>();
    final authProvider = context.read<AuthProvider>();
    
    final success = await userProvider.submitFirstIntake({
      'gender': _selectedGender,
      'mainGoal': _selectedGoal,
      'workoutLocation': _selectedLocation,
      'workoutFrequency': _selectedFrequency,
      'experienceLevel': _selectedExperience,
    });
    
    if (success && mounted) {
      // Update auth provider with new user data
      if (userProvider.profile != null) {
        authProvider.updateUser(userProvider.profile!);
      }
      widget.onComplete();
    } else if (userProvider.error != null && mounted) {
      _showError(userProvider.error!);
    }
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final userProvider = context.watch<UserProvider>();
    final isArabic = languageProvider.isArabic;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.t('lets_know_you')),
        actions: [
          TextButton(
            onPressed: widget.onSkip,
            child: Text(languageProvider.t('skip')),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentStep + 1) / 5,
              backgroundColor: AppColors.surface,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: _buildCurrentStep(languageProvider, isArabic),
              ),
            ),
            
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _currentStep--;
                          });
                        },
                        child: Text(languageProvider.t('back')),
                      ),
                    ),
                  
                  if (_currentStep > 0) const SizedBox(width: 16),
                  
                  Expanded(
                    child: ElevatedButton(
                      onPressed: userProvider.isLoading ? null : () {
                        if (_currentStep < 4) {
                          // Validate current step
                          if (!_canProceedToNext()) {
                            _showError('Please select an option');
                            return;
                          }
                          setState(() {
                            _currentStep++;
                          });
                        } else {
                          _submitIntake();
                        }
                      },
                      child: userProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              _currentStep < 4
                                  ? languageProvider.t('next')
                                  : languageProvider.t('continue'),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  bool _canProceedToNext() {
    switch (_currentStep) {
      case 0:
        return _selectedGender != null;
      case 1:
        return _selectedGoal != null;
      case 2:
        return _selectedLocation != null;
      case 3:
        return _selectedFrequency != null;
      case 4:
        return _selectedExperience != null;
      default:
        return false;
    }
  }
  
  Widget _buildCurrentStep(LanguageProvider lang, bool isArabic) {
    switch (_currentStep) {
      case 0:
        return _buildGenderStep(lang, isArabic);
      case 1:
        return _buildGoalStep(lang, isArabic);
      case 2:
        return _buildLocationStep(lang, isArabic);
      case 3:
        return _buildFrequencyStep(lang, isArabic);
      case 4:
        return _buildExperienceStep(lang, isArabic);
      default:
        return const SizedBox();
    }
  }
  
  Widget _buildGenderStep(LanguageProvider lang, bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lang.t('gender'),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 32),
        _buildOptionCard(
          icon: Icons.male,
          title: lang.t('male'),
          isSelected: _selectedGender == 'male',
          onTap: () => setState(() => _selectedGender = 'male'),
        ),
        const SizedBox(height: 16),
        _buildOptionCard(
          icon: Icons.female,
          title: lang.t('female'),
          isSelected: _selectedGender == 'female',
          onTap: () => setState(() => _selectedGender = 'female'),
        ),
      ],
    );
  }
  
  Widget _buildGoalStep(LanguageProvider lang, bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lang.t('goal'),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 32),
        _buildOptionCard(
          icon: Icons.trending_down,
          title: lang.t('fat_loss'),
          isSelected: _selectedGoal == 'fat_loss',
          onTap: () => setState(() => _selectedGoal = 'fat_loss'),
        ),
        const SizedBox(height: 16),
        _buildOptionCard(
          icon: Icons.fitness_center,
          title: lang.t('muscle_gain'),
          isSelected: _selectedGoal == 'muscle_gain',
          onTap: () => setState(() => _selectedGoal = 'muscle_gain'),
        ),
        const SizedBox(height: 16),
        _buildOptionCard(
          icon: Icons.favorite,
          title: lang.t('general_fitness'),
          isSelected: _selectedGoal == 'general_fitness',
          onTap: () => setState(() => _selectedGoal = 'general_fitness'),
        ),
      ],
    );
  }
  
  Widget _buildLocationStep(LanguageProvider lang, bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lang.t('location'),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 32),
        _buildOptionCard(
          icon: Icons.home,
          title: lang.t('home'),
          isSelected: _selectedLocation == 'home',
          onTap: () => setState(() => _selectedLocation = 'home'),
        ),
        const SizedBox(height: 16),
        _buildOptionCard(
          icon: Icons.business,
          title: lang.t('gym'),
          isSelected: _selectedLocation == 'gym',
          onTap: () => setState(() => _selectedLocation = 'gym'),
        ),
      ],
    );
  }
  
  Widget _buildFrequencyStep(LanguageProvider lang, bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'كم يوم في الأسبوع؟' : 'How many days per week?',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _frequencies.map((freq) {
            final isSelected = _selectedFrequency == freq;
            return InkWell(
              onTap: () => setState(() => _selectedFrequency = freq),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$freq',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  Widget _buildExperienceStep(LanguageProvider lang, bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'ما مستوى خبرتك؟' : 'What\'s your experience level?',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 32),
        _buildOptionCard(
          icon: Icons.stars,
          title: isArabic ? 'مبتدئ' : 'Beginner',
          subtitle: isArabic ? '0-6 أشهر' : '0-6 months',
          isSelected: _selectedExperience == 'beginner',
          onTap: () => setState(() => _selectedExperience = 'beginner'),
        ),
        const SizedBox(height: 16),
        _buildOptionCard(
          icon: Icons.star_half,
          title: isArabic ? 'متوسط' : 'Intermediate',
          subtitle: isArabic ? '6-24 شهر' : '6-24 months',
          isSelected: _selectedExperience == 'intermediate',
          onTap: () => setState(() => _selectedExperience = 'intermediate'),
        ),
        const SizedBox(height: 16),
        _buildOptionCard(
          icon: Icons.emoji_events,
          title: isArabic ? 'متقدم' : 'Advanced',
          subtitle: isArabic ? 'أكثر من سنتين' : '2+ years',
          isSelected: _selectedExperience == 'advanced',
          onTap: () => setState(() => _selectedExperience = 'advanced'),
        ),
      ],
    );
  }
  
  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
