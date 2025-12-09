import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'intake_state.dart';
import '../../l10n/app_localizations.dart';
// import '../../ui/button.dart'; // Unused import removed

class QuickStartStep3 extends StatefulWidget {
  const QuickStartStep3({super.key});
  @override
  State<QuickStartStep3> createState() => _QuickStartStep3State();
}

class _QuickStartStep3State extends State<QuickStartStep3> {
  String? _location;

  @override
  Widget build(BuildContext context) {
    // final t = AppLocalizations.of(context); // Unused variable removed
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/intake_bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(color: Colors.black.withOpacity(0.15)),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: 420,
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.bolt, size: 22),
                        const SizedBox(width: 8),
                        const Text('Quick Start', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const Spacer(),
                        Text('3/3', style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Let's get you started in under a minute!",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(value: 1.0, minHeight: 6, backgroundColor: Colors.grey[200], color: Colors.black),
                    const SizedBox(height: 32),
                    Icon(Icons.place, size: 56, color: Colors.black),
                    const SizedBox(height: 24),
                    Text(
                      'Where do you prefer to work out?',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Where will you train?',
                      style: TextStyle(color: Colors.grey[600], fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    _optionTile('gym', 'Gym', 'Full equipment access'),
                    const SizedBox(height: 12),
                    _optionTile('home', 'Home', 'Minimal equipment needed'),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Back'),
                            onPressed: () => context.go('/quickstart/2'),
                            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.rocket_launch),
                            label: const Text('Start My Journey'),
                            onPressed: _location == null
                                ? null
                                : () async {
                                    final intake = context.read<IntakeState>();
                                    await intake.saveQuickLocation(_location!);
                                    if (intake.first.goal != null) {
                                      await intake.markQuickCompleted();
                                    }
                                    if (!context.mounted) return;
                                    context.go('/home');
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _optionTile(String value, String title, String subtitle) {
    final selected = _location == value;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => setState(() => _location = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? Colors.black : Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? Colors.white : Colors.black54,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: selected ? Colors.white70 : Colors.grey[700],
                      fontSize: 13,
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
}
