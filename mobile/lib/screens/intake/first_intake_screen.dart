import 'package:flutter/material.dart';

import '../../design_system/design_tokens.dart';
import '../../design_system/theme_extensions.dart';
import '../../models/intake_models.dart';
import 'intake_state.dart';
import 'widgets/option_card.dart';

class FirstIntakeScreen extends StatefulWidget {
  const FirstIntakeScreen({
    super.key,
    required this.intake,
    required this.onComplete,
  });

  static const continueButtonKey = ValueKey<String>('first-intake-continue');

  final IntakeState intake;
  final Future<void> Function(FirstIntakeData data) onComplete;

  @override
  State<FirstIntakeScreen> createState() => _FirstIntakeScreenState();
}

class _FirstIntakeScreenState extends State<FirstIntakeScreen> {
  static const List<_IntakeOption> _genderOptions = [
    _IntakeOption('female', 'Female', '${FitCoachAssets.intakeGender}/female.jpg'),
    _IntakeOption('male', 'Male', '${FitCoachAssets.intakeGender}/male.jpg'),
    _IntakeOption('non_binary', 'Non-binary', '${FitCoachAssets.intakeGender}/non_binary.jpg'),
  ];

  static const List<_IntakeOption> _goalOptions = [
    _IntakeOption('lose_weight', 'Lose weight', '${FitCoachAssets.intakeGoal}/lose_weight.jpg'),
    _IntakeOption('build_muscle', 'Build muscle', '${FitCoachAssets.intakeGoal}/build_muscle.jpg'),
    _IntakeOption('increase_stamina', 'Increase stamina', '${FitCoachAssets.intakeGoal}/increase_stamina.jpg'),
    _IntakeOption('general_fitness', 'General fitness', '${FitCoachAssets.intakeGoal}/general_fitness.jpg'),
  ];

  static const List<_IntakeOption> _locationOptions = [
    _IntakeOption('home', 'Home workouts', '${FitCoachAssets.intakeLocation}/home.jpg'),
    _IntakeOption('gym', 'Gym workouts', '${FitCoachAssets.intakeLocation}/gym.jpg'),
    _IntakeOption('hybrid', 'Hybrid', '${FitCoachAssets.intakeLocation}/hybrid.jpg'),
  ];

  String? _gender;
  String? _goal;
  String? _location;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _gender = widget.intake.gender;
    _goal = widget.intake.goal;
    _location = widget.intake.workoutLocation;
  }

  bool get _isValid => _gender != null && _goal != null && _location != null;

  Future<void> _submit() async {
    if (!_isValid || _submitting) {
      if (!_isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please complete every section.')),
        );
      }
      return;
    }
    setState(() => _submitting = true);
    try {
      final data = FirstIntakeData(
        gender: _gender!,
        mainGoal: _goal!,
        workoutLocation: _location!,
      );
      await widget.onComplete(data);
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final surfaces = Theme.of(context).extension<FitCoachSurfaces>();
    return Container(
      decoration: BoxDecoration(gradient: surfaces?.firstIntake ?? FitCoachGradients.firstIntake),
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('Let\'s personalize your plan'),
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final bottomInset = MediaQuery.of(context).viewPadding.bottom;
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  24,
                  24,
                  24,
                  24 + bottomInset,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _SectionCard(
                          title: 'Who should we coach?',
                          subtitle: 'Select the gender that best represents you.',
                          child: _OptionGrid(
                            options: _genderOptions,
                            selectedValue: _gender,
                            onTap: (value) => setState(() => _gender = value),
                          ),
                        ),
                        const SizedBox(height: FitCoachSpacing.xxl),
                        _SectionCard(
                          title: 'What\'s your main goal?',
                          subtitle: 'We\'ll tailor the program to the result you need.',
                          child: _OptionGrid(
                            options: _goalOptions,
                            selectedValue: _goal,
                            onTap: (value) => setState(() => _goal = value),
                          ),
                        ),
                        const SizedBox(height: FitCoachSpacing.xxl),
                        _SectionCard(
                          title: 'Where do you want to train?',
                          subtitle: 'Pick a location so the workouts match your equipment.',
                          child: _OptionGrid(
                            options: _locationOptions,
                            selectedValue: _location,
                            onTap: (value) => setState(() => _location = value),
                          ),
                        ),
                        const SizedBox(height: FitCoachSpacing.xxxl),
                        FilledButton.icon(
                          key: FirstIntakeScreen.continueButtonKey,
                          onPressed: _submitting ? null : _submit,
                          icon: _submitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.arrow_forward_rounded),
                          label: Text(_submitting ? 'Saving...' : 'Continue'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cardColor = cs.surface.withValues(alpha: 0.95);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(FitCoachRadii.md),
        boxShadow: const [FitCoachShadows.card],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: FitCoachSpacing.sm),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54)),
            const SizedBox(height: FitCoachSpacing.lg),
            child,
          ],
        ),
      ),
    );
  }
}

class _OptionGrid extends StatelessWidget {
  const _OptionGrid({
    required this.options,
    required this.selectedValue,
    required this.onTap,
  });

  final List<_IntakeOption> options;
  final String? selectedValue;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: options
          .map(
            (option) => OptionCard(
              label: option.label,
              image: option.asset,
              selected: selectedValue == option.value,
              onTap: () => onTap(option.value),
            ),
          )
          .toList(),
    );
  }
}

class _IntakeOption {
  const _IntakeOption(this.value, this.label, this.asset);

  final String value;
  final String label;
  final String asset;
}
