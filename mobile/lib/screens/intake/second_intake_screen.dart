import 'package:flutter/material.dart';

import '../../design_system/design_tokens.dart';
import '../../design_system/theme_extensions.dart';
import '../../models/intake_models.dart';
import 'intake_state.dart';

class SecondIntakeScreen extends StatefulWidget {
  const SecondIntakeScreen({
    super.key,
    required this.intake,
    required this.onComplete,
    required this.onSkip,
  });

  static const finishButtonKey = ValueKey<String>('second-intake-finish');
  static const skipButtonKey = ValueKey<String>('second-intake-skip');
  static ValueKey<String> experienceChipKey(String level) =>
      ValueKey<String>('second-intake-experience-$level');
  static ValueKey<String> daysChipKey(int day) =>
      ValueKey<String>('second-intake-days-$day');

  final IntakeState intake;
  final Future<void> Function(SecondIntakeData data) onComplete;
  final Future<void> Function() onSkip;

  @override
  State<SecondIntakeScreen> createState() => _SecondIntakeScreenState();
}

class _SecondIntakeScreenState extends State<SecondIntakeScreen> {
  static const List<String> _experienceLevels = ['beginner', 'intermediate', 'advanced'];
  static const List<int> _daysPerWeekOptions = [2, 3, 4, 5, 6];

  late final TextEditingController _ageCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _heightCtrl;
  String? _experience;
  int? _daysPerWeek;
  final Set<String> _selectedInjuries = {};
  final List<_InjuryOption> _injuryOptions = [];
  String _injuryQuery = '';
  bool _loadingInjuries = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final intake = widget.intake;
    _ageCtrl = TextEditingController(text: intake.ageYears?.toString() ?? '');
    _weightCtrl = TextEditingController(text: intake.weightKg?.toString() ?? '');
    _heightCtrl = TextEditingController(text: intake.heightCm?.toString() ?? '');
    _experience = intake.experience;
    _daysPerWeek = intake.daysPerWeek;
    _selectedInjuries.addAll(intake.injuries);
    _loadInjuries();
  }

  Future<void> _loadInjuries() async {
    await widget.intake.loadInjuryTable();
    final table = widget.intake.injuryTable ?? {};
    final entries = table.entries
        .map(
          (entry) => _InjuryOption(
            id: entry.key,
            label: _resolveInjuryLabel(entry.key, entry.value),
          ),
        )
        .toList()
      ..sort((a, b) => a.label.compareTo(b.label));
    if (!mounted) return;
    setState(() {
      _injuryOptions
        ..clear()
        ..addAll(entries);
      _loadingInjuries = false;
    });
  }

  @override
  void dispose() {
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  String? _validate() {
    final age = int.tryParse(_ageCtrl.text.trim());
    if (age == null || age < 10 || age > 90) {
      return 'Age must be between 10 and 90.';
    }
    final weight = double.tryParse(_weightCtrl.text.trim());
    if (weight == null || weight < 30) {
      return 'Enter a valid weight (kg).';
    }
    final height = double.tryParse(_heightCtrl.text.trim());
    if (height == null || height < 100) {
      return 'Enter a valid height (cm).';
    }
    if (_experience == null) {
      return 'Select your experience level.';
    }
    if (_daysPerWeek == null) {
      return 'Choose how many days you can train.';
    }
    return null;
  }

  Future<void> _submit() async {
    final error = _validate();
    if (error != null) {
      assert(() {
        debugPrint('SecondIntakeScreen validation failed: $error');
        return true;
      }());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    assert(() {
      debugPrint('SecondIntakeScreen submitting payload');
      return true;
    }());
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      final age = int.parse(_ageCtrl.text.trim());
      final weight = double.parse(_weightCtrl.text.trim());
      final height = double.parse(_heightCtrl.text.trim());
      widget.intake
        ..setAge(age)
        ..weightKg = weight
        ..heightCm = height
        ..experience = _experience
        ..daysPerWeek = _daysPerWeek;
      widget.intake.injuries
        ..clear()
        ..addAll(_selectedInjuries);
      final payload = SecondIntakeData(
        age: age,
        weight: weight,
        height: height,
        experienceLevel: _experience!,
        workoutFrequency: _daysPerWeek!,
        injuries: _selectedInjuries.toList(),
      );
      await widget.onComplete(payload);
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _skip() async {
    if (_submitting) return;
    await widget.onSkip();
  }

  Iterable<_InjuryOption> get _filteredInjuries {
    if (_injuryQuery.isEmpty) return _injuryOptions;
    final query = _injuryQuery.toLowerCase();
    return _injuryOptions.where((opt) => opt.label.toLowerCase().contains(query));
  }

  @override
  Widget build(BuildContext context) {
    final surfaces = Theme.of(context).extension<FitCoachSurfaces>();
    final bottomPad = MediaQuery.of(context).viewPadding.bottom;
    return Container(
      decoration: BoxDecoration(gradient: surfaces?.secondIntake ?? FitCoachGradients.secondIntake),
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('Great, a few more details'),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomPad),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _CardSurface(
                      title: 'Body metrics',
                      subtitle: 'We use these to estimate caloric needs and select loads.',
                      child: Column(
                        children: [
                          TextField(
                            controller: _ageCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Age (years)'),
                          ),
                          const SizedBox(height: FitCoachSpacing.lg),
                          TextField(
                            controller: _weightCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(labelText: 'Weight (kg)'),
                          ),
                          const SizedBox(height: FitCoachSpacing.lg),
                          TextField(
                            controller: _heightCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(labelText: 'Height (cm)'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: FitCoachSpacing.xxl),
                    _CardSurface(
                      title: 'Experience & availability',
                      subtitle: 'Help us match the right program difficulty.',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            children: [
                              for (final level in _experienceLevels)
                                ChoiceChip(
                                  key: SecondIntakeScreen.experienceChipKey(level),
                                  label: Text(_formatLabel(level)),
                                  selected: _experience == level,
                                  onSelected: (_) => setState(() => _experience = level),
                                ),
                            ],
                          ),
                          const SizedBox(height: FitCoachSpacing.lg),
                          Text('Days per week', style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: FitCoachSpacing.sm),
                          Wrap(
                            spacing: 8,
                            children: [
                              for (final day in _daysPerWeekOptions)
                                ChoiceChip(
                                  key: SecondIntakeScreen.daysChipKey(day),
                                  label: Text('$day'),
                                  selected: _daysPerWeek == day,
                                  onSelected: (_) => setState(() => _daysPerWeek = day),
                                ),
                            ],
                          ),
                        ],
                      ),
                      ),
                    const SizedBox(height: FitCoachSpacing.xxl),
                    _CardSurface(
                      title: 'Injuries or considerations',
                      subtitle: 'Optional but recommended so we can avoid aggravations.',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.search),
                              labelText: 'Search injuries',
                            ),
                            onChanged: (value) => setState(() => _injuryQuery = value),
                          ),
                          const SizedBox(height: FitCoachSpacing.lg),
                          if (_loadingInjuries)
                            const Center(child: CircularProgressIndicator())
                          else if (_injuryOptions.isEmpty)
                            const Text('No injuries catalog available right now.')
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final injury in _filteredInjuries)
                                  FilterChip(
                                    label: Text(injury.label),
                                    selected: _selectedInjuries.contains(injury.id),
                                    onSelected: (_) => setState(() {
                                      if (_selectedInjuries.contains(injury.id)) {
                                        _selectedInjuries.remove(injury.id);
                                      } else {
                                        _selectedInjuries.add(injury.id);
                                      }
                                    }),
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: FitCoachSpacing.xxxl),
                    FilledButton.icon(
                      key: SecondIntakeScreen.finishButtonKey,
                      onPressed: _submitting ? null : _submit,
                      icon: _submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check_rounded),
                      label: Text(_submitting ? 'Generating plan...' : 'Finish intake'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: FitCoachSpacing.md),
                    TextButton(
                      key: SecondIntakeScreen.skipButtonKey,
                      onPressed: _submitting ? null : _skip,
                      child: const Text('Skip for now'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _formatLabel(String value) {
    return value.replaceAll('_', ' ').split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  static String _resolveInjuryLabel(String key, dynamic value) {
    if (value is Map<String, dynamic>) {
      return value['short']?.toString() ?? value['description']?.toString() ?? key;
    }
    return value?.toString() ?? key;
  }
}

class _CardSurface extends StatelessWidget {
  const _CardSurface({
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.95),
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
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: FitCoachSpacing.lg),
            child,
          ],
        ),
      ),
    );
  }
}

class _InjuryOption {
  const _InjuryOption({required this.id, required this.label});

  final String id;
  final String label;
}
