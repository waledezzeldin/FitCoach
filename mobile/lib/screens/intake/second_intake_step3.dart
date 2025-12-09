import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'intake_state.dart';
import 'package:fitcoach/l10n/app_localizations.dart';

class SecondIntakeStep3 extends StatefulWidget {
  const SecondIntakeStep3({super.key});
  @override
  State<SecondIntakeStep3> createState() => _SecondIntakeStep3State();
}

class _SecondIntakeStep3State extends State<SecondIntakeStep3> {
  final List<String> _injuryOptions = const ['Back', 'Knee', 'Shoulder', 'Neck', 'Ankle'];
  final Set<String> _selectedInjuries = <String>{};
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final intake = context.read<IntakeState>();
    return Scaffold(
      appBar: AppBar(title: Text(t.intakeStep2Title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Any injuries we should know about?'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final opt in _injuryOptions)
                  FilterChip(
                    label: Text(opt),
                    selected: _selectedInjuries.contains(opt),
                    onSelected: (sel) => setState(() {
                      if (sel) {
                        _selectedInjuries.add(opt);
                      } else {
                        _selectedInjuries.remove(opt);
                      }
                    }),
                  ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                await intake.saveSecond(SecondIntakeData(injuries: _selectedInjuries.isNotEmpty));
                await intake.markCompleted();
                if (!context.mounted) return;
                context.go('/home');
              },
              child: Text(t.completeIntake),
            )
          ],
        ),
      ),
    );
  }
}
