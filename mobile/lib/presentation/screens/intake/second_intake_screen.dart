import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../providers/language_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';

class SecondIntakeScreen extends StatefulWidget {
  final VoidCallback onComplete;
  
  const SecondIntakeScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<SecondIntakeScreen> createState() => _SecondIntakeScreenState();
}

class _SecondIntakeScreenState extends State<SecondIntakeScreen> {
  int _currentStep = 0;
  
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _bodyFatController = TextEditingController();
  final TextEditingController _medicalController = TextEditingController();
  
  final List<String> _selectedInjuries = [];
  
  final List<String> _commonInjuries = [
    'Lower Back',
    'Knee',
    'Shoulder',
    'Wrist',
    'Ankle',
    'Neck',
    'Elbow',
    'Hip',
  ];
  
  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _bodyFatController.dispose();
    _medicalController.dispose();
    super.dispose();
  }
  
  Future<void> _submitIntake() async {
    // Validate required fields
    if (_ageController.text.isEmpty || 
        _weightController.text.isEmpty || 
        _heightController.text.isEmpty) {
      _showError('Please complete all required fields');
      return;
    }
    
    final userProvider = context.read<UserProvider>();
    final authProvider = context.read<AuthProvider>();
    
    final success = await userProvider.submitSecondIntake({
      'age': int.parse(_ageController.text),
      'weight': double.parse(_weightController.text),
      'height': double.parse(_heightController.text),
      'bodyFat': _bodyFatController.text.isNotEmpty 
          ? double.parse(_bodyFatController.text) 
          : null,
      'injuries': _selectedInjuries,
      'medicalConditions': _medicalController.text.isNotEmpty 
          ? _medicalController.text 
          : null,
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
        title: Text(languageProvider.t('additional_info')),
        leading: IconButton(
          icon: Icon(isArabic ? Icons.arrow_forward : Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentStep + 1) / 6,
              backgroundColor: AppColors.surface,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            
            // Premium badge
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.primary.withValues(alpha: 0.1),
              child: Row(
                children: [
                  const Icon(Icons.star, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    isArabic 
                        ? 'ميزة البريميوم - معلومات متقدمة لخطة أفضل'
                        : 'Premium Feature - Advanced info for better plans',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
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
                        if (_currentStep < 5) {
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
                              _currentStep < 5
                                  ? languageProvider.t('next')
                                  : languageProvider.t('complete'),
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
  
  Widget _buildCurrentStep(LanguageProvider lang, bool isArabic) {
    switch (_currentStep) {
      case 0:
        return _buildAgeStep(lang, isArabic);
      case 1:
        return _buildWeightStep(lang, isArabic);
      case 2:
        return _buildHeightStep(lang, isArabic);
      case 3:
        return _buildBodyFatStep(lang, isArabic);
      case 4:
        return _buildInjuriesStep(lang, isArabic);
      case 5:
        return _buildMedicalStep(lang, isArabic);
      default:
        return const SizedBox();
    }
  }
  
  Widget _buildAgeStep(LanguageProvider lang, bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'كم عمرك؟' : 'What\'s your age?',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _ageController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(3),
          ],
          decoration: InputDecoration(
            labelText: isArabic ? 'العمر' : 'Age',
            hintText: '25',
            suffixText: isArabic ? 'سنة' : 'years',
            prefixIcon: const Icon(Icons.cake),
          ),
        ),
      ],
    );
  }
  
  Widget _buildWeightStep(LanguageProvider lang, bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'كم وزنك؟' : 'What\'s your weight?',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _weightController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
          ],
          decoration: InputDecoration(
            labelText: isArabic ? 'الوزن' : 'Weight',
            hintText: '75.0',
            suffixText: isArabic ? 'كجم' : 'kg',
            prefixIcon: const Icon(Icons.monitor_weight),
          ),
        ),
      ],
    );
  }
  
  Widget _buildHeightStep(LanguageProvider lang, bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'كم طولك؟' : 'What\'s your height?',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _heightController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(3),
          ],
          decoration: InputDecoration(
            labelText: isArabic ? 'الطول' : 'Height',
            hintText: '175',
            suffixText: isArabic ? 'سم' : 'cm',
            prefixIcon: const Icon(Icons.height),
          ),
        ),
      ],
    );
  }
  
  Widget _buildBodyFatStep(LanguageProvider lang, bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'نسبة الدهون (اختياري)' : 'Body Fat % (Optional)',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isArabic 
              ? 'إذا كنت تعرف نسبة الدهون في جسمك'
              : 'If you know your body fat percentage',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _bodyFatController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
          ],
          decoration: InputDecoration(
            labelText: isArabic ? 'نسبة الدهون' : 'Body Fat %',
            hintText: '15.0',
            suffixText: '%',
            prefixIcon: const Icon(Icons.insights),
          ),
        ),
      ],
    );
  }
  
  Widget _buildInjuriesStep(LanguageProvider lang, bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'هل لديك أي إصابات؟' : 'Do you have any injuries?',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isArabic 
              ? 'سنقوم بتعديل خطة التمرين لتجنب الإصابات'
              : 'We\'ll adjust your workout plan to avoid injuries',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _commonInjuries.map((injury) {
            final isSelected = _selectedInjuries.contains(injury);
            return FilterChip(
              label: Text(injury),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedInjuries.add(injury);
                  } else {
                    _selectedInjuries.remove(injury);
                  }
                });
              },
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              checkmarkColor: AppColors.primary,
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Text(
          isArabic 
              ? 'لا إصابات؟ رائع! تابع للأمام'
              : 'No injuries? Great! Just continue',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
  
  Widget _buildMedicalStep(LanguageProvider lang, bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'أي حالات طبية؟ (اختياري)' : 'Any medical conditions? (Optional)',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isArabic 
              ? 'مثل: السكري، ضغط الدم، الربو، إلخ'
              : 'e.g., Diabetes, High blood pressure, Asthma, etc.',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _medicalController,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: isArabic ? 'الحالات الطبية' : 'Medical Conditions',
            hintText: isArabic 
                ? 'اكتب هنا أي حالات طبية...'
                : 'Enter any medical conditions...',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.warning, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isArabic
                      ? 'استشر طبيبك قبل البدء بأي برنامج تمرين'
                      : 'Consult your doctor before starting any exercise program',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
