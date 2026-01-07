import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../widgets/animated_reveal.dart';

class StoreIntroScreen extends StatelessWidget {
  final VoidCallback onGetStarted;

  const StoreIntroScreen({
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
                'assets/placeholders/splash_onboarding/store_onboarding.png',
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
                    Color(0x99000000),
                    Color(0x80000000),
                    Color(0xB3000000),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AnimatedReveal(
                          child: Text(
                            languageProvider.t('store_intro_title'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        AnimatedReveal(
                          delay: const Duration(milliseconds: 100),
                          child: Text(
                            languageProvider.t('store_intro_subtitle'),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: (0.9 * 255)),
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        AnimatedReveal(
                          delay: const Duration(milliseconds: 220),
                          child: _IntroFeatureCard(
                            icon: Icons.shopping_bag_outlined,
                            iconColor: const Color(0xFFF59E0B),
                            title: languageProvider.t('store_intro_feature1_title'),
                            description: languageProvider.t('store_intro_feature1_desc'),
                            isArabic: isArabic,
                          ),
                        ),
                        const SizedBox(height: 12),
                        AnimatedReveal(
                          delay: const Duration(milliseconds: 300),
                          child: _IntroFeatureCard(
                            icon: Icons.auto_awesome,
                            iconColor: const Color(0xFF3B82F6),
                            title: languageProvider.t('store_intro_feature2_title'),
                            description: languageProvider.t('store_intro_feature2_desc'),
                            isArabic: isArabic,
                          ),
                        ),
                        const SizedBox(height: 12),
                        AnimatedReveal(
                          delay: const Duration(milliseconds: 380),
                          child: _IntroFeatureCard(
                            icon: Icons.local_shipping_outlined,
                            iconColor: const Color(0xFF22C55E),
                            title: languageProvider.t('store_intro_feature3_title'),
                            description: languageProvider.t('store_intro_feature3_desc'),
                            isArabic: isArabic,
                          ),
                        ),
                        const SizedBox(height: 12),
                        AnimatedReveal(
                          delay: const Duration(milliseconds: 460),
                          child: _IntroFeatureCard(
                            icon: Icons.inventory_2_outlined,
                            iconColor: const Color(0xFF8B5CF6),
                            title: languageProvider.t('store_intro_feature4_title'),
                            description: languageProvider.t('store_intro_feature4_desc'),
                            isArabic: isArabic,
                          ),
                        ),
                        const SizedBox(height: 20),
                        AnimatedReveal(
                          delay: const Duration(milliseconds: 520),
                          child: SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: onGetStarted,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEA580C),
                                foregroundColor: Colors.white,
                                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                              child: Text(languageProvider.t('store_intro_start_shopping')),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IntroFeatureCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final bool isArabic;

  const _IntroFeatureCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: (0.1 * 255)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: (0.2 * 255))),
          ),
          child: Row(
            children: isArabic
                ? [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.right,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: (0.8 * 255)),
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _IntroIcon(icon: icon, color: iconColor),
                  ]
                : [
                    _IntroIcon(icon: icon, color: iconColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: (0.8 * 255)),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
          ),
        ),
      ),
    );
  }
}

class _IntroIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _IntroIcon({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: (0.2 * 255)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Icon(icon, color: color, size: 26),
    );
  }
}
