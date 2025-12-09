import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../ui/input.dart';
import '../../ui/button.dart';
import 'intake_state.dart';
import '../../l10n/app_localizations.dart';

class FirstIntakeScreen extends StatefulWidget {
  final VoidCallback? onNext;
  const FirstIntakeScreen({super.key, this.onNext});
  @override
  State<FirstIntakeScreen> createState() => _FirstIntakeScreenState();
}

class _FirstIntakeScreenState extends State<FirstIntakeScreen> {
  final TextEditingController _height = TextEditingController();
  final TextEditingController _weight = TextEditingController();
  String? _goal;

  bool get _valid {
    final h = double.tryParse(_height.text);
    final w = double.tryParse(_weight.text);
    return (_goal != null && _goal!.isNotEmpty) && (h != null && h > 0) && (w != null && w > 0);
  }

  @override
  void initState() {
    super.initState();
    void onChanged() => setState(() {});
    _height.addListener(onChanged);
    _weight.addListener(onChanged);
  }

  @override
  void dispose() {
    _height.dispose();
    _weight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final intake = context.read<IntakeState>();
    return Scaffold(
      appBar: AppBar(title: Text(t.intakeStep1Title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Goal'),
              items: const [
                DropdownMenuItem(value: 'lose_weight', child: Text('Lose Weight')),
                DropdownMenuItem(value: 'build_muscle', child: Text('Build Muscle')),
                DropdownMenuItem(value: 'stay_fit', child: Text('Stay Fit')),
              ],
              value: _goal,
              onChanged: (v) => setState(() => _goal = v),
            ),
            const SizedBox(height: 12),
            FitTextField(controller: _height, label: 'Height (cm)', keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            FitTextField(controller: _weight, label: 'Weight (kg)', keyboardType: TextInputType.number),
            const SizedBox(height: 24),
            PrimaryButton(
              key: const Key('firstIntakeNext'),
              label: t.continueCta,
              onPressed: _valid
                  ? () async {
                      final d = FirstIntakeData(
                        goal: _goal,
                        heightCm: double.tryParse(_height.text),
                        weightKg: double.tryParse(_weight.text),
                      );
                      await intake.saveFirst(d);
                      if (!context.mounted) return;
                      if (widget.onNext != null) {
                        widget.onNext!();
                        return;
                      }
                      context.go('/intake/second');
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
