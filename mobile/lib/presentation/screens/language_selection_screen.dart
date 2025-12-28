import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../providers/language_provider.dart';

class LanguageSelectionScreen extends StatelessWidget {
  final VoidCallback onLanguageSelected;
  
  const LanguageSelectionScreen({
    super.key,
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context) {
    Future<void> setLanguage(String code) async {
      try {
        await context.read<LanguageProvider>().setLanguage(code);
      } catch (_) {
        await LanguageProvider().setLanguage(code);
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text(
                    'عاش',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Title
              const Text(
                'Welcome to FitCoach+',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              // Subtitle
              const Text(
                'Select your language',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              // English Option
              _LanguageCard(
                flag: '🇬🇧',
                language: 'English',
                onTap: () async {
                  await setLanguage('en');
                  onLanguageSelected();
                },
              ),
              
              const SizedBox(height: 16),
              
              // Arabic Option
              _LanguageCard(
                flag: '🇸🇦',
                language: 'العربية',
                onTap: () async {
                  await setLanguage('ar');
                  onLanguageSelected();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String flag;
  final String language;
  final VoidCallback onTap;
  
  const _LanguageCard({
    required this.flag,
    required this.language,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Flag
              Text(
                flag,
                style: const TextStyle(fontSize: 32),
              ),
              
              const SizedBox(width: 16),
              
              // Language Name
              Expanded(
                child: Text(
                  language,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              
              // Arrow
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
