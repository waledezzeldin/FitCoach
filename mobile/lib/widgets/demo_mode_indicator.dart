import 'package:flutter/material.dart';

import '../demo/demo_launcher.dart';
import '../state/app_state.dart';

class DemoModeIndicatorOverlay extends StatelessWidget {
  const DemoModeIndicatorOverlay({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    return Stack(
      children: [
        child ?? const SizedBox.shrink(),
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !app.demoMode,
            child: AnimatedAlign(
              alignment: Alignment.topCenter,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              child: app.demoMode
                  ? SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                        child: _DemoBanner(
                          onSwitchPersona: () => _switchPersona(context),
                          onExitDemo: () => _exitDemo(context),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _switchPersona(BuildContext context) async {
    await DemoLauncher.showSheet(context);
  }

  Future<void> _exitDemo(BuildContext context) async {
    final app = AppStateScope.of(context);
    await app.signOut();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/phone_login', (_) => false);
  }
}

class _DemoBanner extends StatelessWidget {
  const _DemoBanner({required this.onSwitchPersona, required this.onExitDemo});

  final VoidCallback onSwitchPersona;
  final VoidCallback onExitDemo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: Colors.white.withValues(alpha: 0.1),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          boxShadow: const [
            BoxShadow(color: Color(0x44000000), blurRadius: 24, offset: Offset(0, 12)),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.visibility_outlined, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Demo mode active',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Explore safely · data is read-only',
                    style: theme.textTheme.labelSmall?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: onSwitchPersona,
              child: const Text('Switch persona', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: 8),
            FilledButton.tonal(
              onPressed: onExitDemo,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                minimumSize: const Size(0, 40),
              ),
              child: const Text('Exit'),
            ),
          ],
        ),
      ),
    );
  }
}
