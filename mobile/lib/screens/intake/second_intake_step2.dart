import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'intake_state.dart';
import 'package:fitcoach/l10n/app_localizations.dart';

class SecondIntakeStep2 extends StatefulWidget {
  const SecondIntakeStep2({super.key});
  @override
  State<SecondIntakeStep2> createState() => _SecondIntakeStep2State();
}

class _SecondIntakeStep2State extends State<SecondIntakeStep2> {
  int? _days;
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
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Days per week'),
              items: [for (final d in List.generate(7, (i) => i + 1)) DropdownMenuItem(value: d, child: Text('$d days'))],
              value: _days,
              onChanged: (v) => setState(() => _days = v),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: (_days != null && _days! > 0)
                  ? () {
                      context.read<IntakeState>().saveSecond(SecondIntakeData(daysPerWeek: _days));
                      context.go('/intake/second/3');
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
