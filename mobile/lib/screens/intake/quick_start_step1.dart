import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
// import 'package:fitcoach/l10n/app_localizations.dart'; // Unused import removed
import 'package:fitcoach/screens/intake/intake_state.dart';

class QuickStartStep1 extends StatefulWidget {
  const QuickStartStep1({super.key});
  @override
  State<QuickStartStep1> createState() => _QuickStartStep1State();
}

class _QuickStartStep1State extends State<QuickStartStep1> {
  String? _gender;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Blurred background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/intake_bg.jpg'), // Replace with your background asset
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(color: Color.fromRGBO(0, 0, 0, 0.15)),
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
                      color: Color.fromRGBO(0, 0, 0, 0.10),
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
                        Text('1/3', style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Let's get you started in under a minute!",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(value: 1/3, minHeight: 6, backgroundColor: Colors.grey[200], color: Colors.black),
                    const SizedBox(height: 32),
                    Icon(Icons.person, size: 56, color: Colors.black),
                    const SizedBox(height: 24),
                    Text(
                      'What is your gender?',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Help us personalize your experience',
                      style: TextStyle(color: Colors.grey[600], fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    _optionTile('Male'),
                    const SizedBox(height: 12),
                    _optionTile('Female'),
                    const SizedBox(height: 12),
                    _optionTile('Other'),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Back'),
                            onPressed: () => context.pop(),
                            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Continue'),
                            onPressed: _gender == null
                                ? null
                                : () async {
                                    await context.read<IntakeState>().saveQuickGender(_gender!);
                                    if (!context.mounted) return;
                                    context.go('/quickstart/2');
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

  Widget _optionTile(String value) {
    final selected = _gender == value;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => setState(() => _gender = value),
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
              child: Text(
                value,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
