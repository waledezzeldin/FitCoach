import 'package:flutter/material.dart';
import 'package:fitcoach/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../app.dart';

class LanguageSelectionScreen extends StatelessWidget {
  final void Function(Locale)? onSelected;
  const LanguageSelectionScreen({super.key, this.onSelected});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7F4EFF), Color(0xFF4F8CFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: _LanguageSelectionContent(onSelected: onSelected, t: t),
          ),
        ),
      ),
    );
  }
}

class _LanguageSelectionContent extends StatefulWidget {
  final void Function(Locale)? onSelected;
  final AppLocalizations t;
  const _LanguageSelectionContent({Key? key, this.onSelected, required this.t}) : super(key: key);
  @override
  State<_LanguageSelectionContent> createState() => _LanguageSelectionContentState();
}

class _LanguageSelectionContentState extends State<_LanguageSelectionContent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.language, size: 56, color: Colors.white),
        const SizedBox(height: 24),
        Text(
          widget.t.selectLanguage,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          widget.t.selectLanguage,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        _LanguageOption(
          code: 'US',
          title: 'English',
          subtitle: 'English',
          selected: false,
          onTap: () {
            Provider.of<AppState>(context, listen: false).setLocale(const Locale('en'));
            if (widget.onSelected != null) widget.onSelected!(const Locale('en'));
            Navigator.pushReplacementNamed(context, '/onboarding');
          },
        ),
        const SizedBox(height: 16),
        _LanguageOption(
          code: 'SA',
          title: 'Arabic',
          subtitle: 'العربية',
          selected: false,
          onTap: () {
            Provider.of<AppState>(context, listen: false).setLocale(const Locale('ar'));
            if (widget.onSelected != null) widget.onSelected!(const Locale('ar'));
            Navigator.pushReplacementNamed(context, '/onboarding');
          },
        ),
        const SizedBox(height: 32),
        Text(
          widget.t.changeLater,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String code;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.code,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? Colors.black : Colors.transparent, width: 2),
        ),
        child: Row(
          children: [
            Text(
              code,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: Colors.black, size: 22)
            else
              const Icon(Icons.arrow_forward_ios, color: Colors.black26, size: 20),
          ],
        ),
      ),
    );
  }
}
