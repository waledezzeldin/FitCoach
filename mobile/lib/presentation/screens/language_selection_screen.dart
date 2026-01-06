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
    LanguageProvider languageProvider;
    try {
      languageProvider = context.watch<LanguageProvider>();
    } catch (_) {
      languageProvider = LanguageProvider();
    }

    Future<void> setLanguage(String code) async {
      try {
        await context.read<LanguageProvider>().setLanguage(code);
      } catch (_) {
        await LanguageProvider().setLanguage(code);
      }
    }

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
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xB3000000),
                    Color(0x99000000),
                    Color(0xCC000000),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/placeholders/branding_logo/a18300719941655fc0e724274fe3c0687ac10328.png',
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    languageProvider.t('language_title'),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    languageProvider.t('language_subtitle'),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  _LanguageCard(
                    flag: '\u{1F1FA}\u{1F1F8}',
                    language: languageProvider.t('english'),
                    isRtl: isArabic,
                    onTap: () async {
                      await setLanguage('en');
                      onLanguageSelected();
                    },
                  ),
                  const SizedBox(height: 16),
                  _LanguageCard(
                    flag: '\u{1F1F8}\u{1F1E6}',
                    language: languageProvider.t('arabic'),
                    isRtl: isArabic,
                    onTap: () async {
                      await setLanguage('ar');
                      onLanguageSelected();
                    },
                  ),
                  const Spacer(),
                  Text(
                    languageProvider.t('language_footer'),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String flag;
  final String language;
  final VoidCallback onTap;
  final bool isRtl;

  const _LanguageCard({
    required this.flag,
    required this.language,
    required this.onTap,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: (0.95 * 255)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: (0.3 * 255)),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: (0.15 * 255)),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(
                flag,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 16),
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
              Icon(
                isRtl ? Icons.arrow_back_ios_new : Icons.arrow_forward_ios,
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
