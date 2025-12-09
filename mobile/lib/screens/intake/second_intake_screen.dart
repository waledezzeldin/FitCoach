import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../ui/button.dart';
import 'intake_state.dart';
import 'package:fitcoach/l10n/app_localizations.dart';

class SecondIntakeScreen extends StatefulWidget {
  final VoidCallback? onComplete;
  const SecondIntakeScreen({super.key, this.onComplete});
  @override
  State<SecondIntakeScreen> createState() => _SecondIntakeScreenState();
}

class _SecondIntakeScreenState extends State<SecondIntakeScreen> {
  String? _experience;
  int? _days;
  final List<String> _injuryOptions = const [
    'Back',
    'Knee',
    'Shoulder',
    'Neck',
    'Ankle',
  ];
  final Set<String> _selectedInjuries = <String>{};

  bool get _valid =>
      (_experience != null && _experience!.isNotEmpty) &&
      (_days != null && _days! > 0);

  @override
  Widget build(BuildContext context) {
    final intake = context.read<IntakeState>();
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.intakeStep2Title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: t.intakeStep2Title),
              items: const [
                DropdownMenuItem(value: 'beginner', child: Text('Beginner')),
                DropdownMenuItem(
                  value: 'intermediate',
                  child: Text('Intermediate'),
                ),
                DropdownMenuItem(value: 'advanced', child: Text('Advanced')),
              ],
              value: _experience,
              onChanged: (v) => setState(() => _experience = v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Days per week'),
              items: [
                for (final d in List.generate(7, (i) => i + 1))
                  DropdownMenuItem(value: d, child: Text('$d days')),
              ],
              value: _days,
              onChanged: (v) => setState(() => _days = v),
            ),
            const SizedBox(height: 12),
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
            PrimaryButton(
              label: t.completeIntake,
              onPressed: _valid
                  ? () async {
                      await intake.saveSecond(
                        SecondIntakeData(
                          experience: _experience,
                          daysPerWeek: _days,
                          injuries: _selectedInjuries.isNotEmpty,
                        ),
                      );
                      await intake.markCompleted();
                      if (!context.mounted) return;
                      if (widget.onComplete != null) {
                        widget.onComplete!();
                        return;
                      }
                      context.go('/home');
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
