import 'package:flutter/material.dart';

import '../../demo/demo_launcher.dart';
import '../../state/app_state.dart';
import '../../localization/app_localizations.dart';
import '../../widgets/primary_cta.dart';

class AppIntroScreen extends StatefulWidget {
  const AppIntroScreen({super.key});

  @override
  State<AppIntroScreen> createState() => _AppIntroScreenState();
}

class _AppIntroScreenState extends State<AppIntroScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  List<_IntroSlide> _slides(BuildContext context) {
    final l10n = context.l10n;
    return [
      _IntroSlide(
        icon: Icons.fitness_center,
        title: l10n.t('intro.slide1Title'),
        body: l10n.t('intro.slide1Body'),
      ),
      _IntroSlide(
        icon: Icons.chat_bubble_outline,
        title: l10n.t('intro.slide2Title'),
        body: l10n.t('intro.slide2Body'),
      ),
      _IntroSlide(
        icon: Icons.storefront_outlined,
        title: l10n.t('intro.slide3Title'),
        body: l10n.t('intro.slide3Body'),
      ),
    ];
  }

  Future<void> _finish(BuildContext context) async {
    final app = AppStateScope.of(context);
    await app.markIntroSeen();
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, app.resolveLandingRoute());
  }

  void _next(BuildContext context, List<_IntroSlide> slides) {
    if (_index >= slides.length - 1) {
      _finish(context);
    } else {
      _controller.animateToPage(
        _index + 1,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _showDemoSheet() async {
    if (!mounted) return;
    await DemoLauncher.showSheet(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slides = _slides(context);
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF050417), Color(0xFF090A1F), Color(0xFF050208)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _finish(context),
                    child: Text(l10n.t('intro.skip')),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: slides.length,
                    onPageChanged: (value) => setState(() => _index = value),
                    itemBuilder: (context, i) {
                      final slide = slides[i];
                      return _IntroCard(slide: slide);
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    slides.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: i == _index ? 28 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
                      decoration: BoxDecoration(
                        color: i == _index ? Colors.white : Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
                PrimaryCTA(
                  label: _index == slides.length - 1 ? l10n.t('intro.getStarted') : l10n.t('intro.next'),
                  onPressed: () => _next(context, slides),
                  icon: _index == slides.length - 1 ? Icons.bolt : Icons.arrow_forward,
                ),
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  icon: const Icon(Icons.visibility_outlined),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                  ),
                  onPressed: _showDemoSheet,
                  label: Text(l10n.t('auth.demoCta')),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.t('auth.demoHint'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.slide});

  final _IntroSlide slide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final app = AppStateScope.of(context);
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onLongPress: () {
          app.toggleDemoMode();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(app.demoMode ? l10n.t('demo.enabled') : l10n.t('demo.disabled'))),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            gradient: const LinearGradient(
              colors: [Color(0x660C0B33), Color(0x337C3AED)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: const [
              BoxShadow(color: Color(0x33000000), blurRadius: 30, offset: Offset(0, 18)),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 56,
                backgroundColor: Colors.white.withValues(alpha: 0.08),
                child: Icon(slide.icon, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 32),
              Text(
                slide.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                slide.body,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntroSlide {
  const _IntroSlide({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;
}
