import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'intake_state.dart';
import 'package:fitcoach/l10n/app_localizations.dart';

class SecondIntakeStep1 extends StatefulWidget {
  const SecondIntakeStep1({super.key});
  @override
  State<SecondIntakeStep1> createState() => _SecondIntakeStep1State();
}

class _SecondIntakeStep1State extends State<SecondIntakeStep1> {
  String? _experience;
  @override
  Widget build(BuildContext context) {
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
                DropdownMenuItem(value: 'intermediate', child: Text('Intermediate')),
                DropdownMenuItem(value: 'advanced', child: Text('Advanced')),
              ],
              value: _experience,
              onChanged: (v) => setState(() => _experience = v),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: (_experience != null && _experience!.isNotEmpty)
                  ? () {
                      context.read<IntakeState>().saveSecond(SecondIntakeData(experience: _experience));
                      context.go('/intake/second/2');
                    }
                  : null,
              child: Text(t.continueCta),
            )
          ],
        ),
      ),
    );
  }
}
