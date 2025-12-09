import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'language_selection_screen.dart'; // Unused import removed

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    // Start onboarding directly with the welcome screen, then go to login
    return Scaffold(
      body: SafeArea(
        child: _WelcomeOnboardingScreen(
          onNext: () {
            WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/login'));
          },
        ),
      ),
    );
  }
}

class _WelcomeOnboardingScreen extends StatelessWidget {
  final VoidCallback onNext;
  const _WelcomeOnboardingScreen({required this.onNext});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEAF1FB), Color(0xFFF8FAFF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          // App Icon and Version
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.fitness_center, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 8),
          Text('Version 1.0', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 16),
          // Welcome Title
          Text(
            'Welcome to FitCoach',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Your Personal Fitness Journey Starts Here',
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Get personalized workout plans, nutrition guidance, and direct coach support to achieve your fitness goals.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          // Feature Cards
          _FeatureCard(
            icon: Icons.fitness_center,
            color: Color(0xFF2D8CFF),
            title: 'Custom Workouts',
            subtitle: 'Tailored to your fitness level and goals',
          ),
          const SizedBox(height: 12),
          _FeatureCard(
            icon: Icons.restaurant,
            color: Color(0xFF22C55E),
            title: 'Nutrition Plans',
            subtitle: 'Personalized meal planning and macro tracking',
          ),
          const SizedBox(height: 12),
          _FeatureCard(
            icon: Icons.person,
            color: Color(0xFF8B5CF6),
            title: 'Expert Coaches',
            subtitle: 'Direct access to certified fitness professionals',
          ),
          const SizedBox(height: 24),
          // Get Started Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onNext,
                child: const Text('Get Started', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Transform your fitness journey with personalized guidance',
            style: TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  const _FeatureCard({required this.icon, required this.color, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
