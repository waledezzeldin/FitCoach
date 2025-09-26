import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import 'intake_state.dart';
import 'widgets/option_card.dart';
import 'plan_generation_screen.dart';

class IntakeFlow extends StatefulWidget {
  const IntakeFlow({super.key});
  @override
  State<IntakeFlow> createState() => _IntakeFlowState();
}

class _IntakeFlowState extends State<IntakeFlow> {
  final IntakeState intake = IntakeState();
  late final PageController _pc;

  final locations = const ['home', 'gym'];
  final goals = const ['fat_loss', 'muscle_gain', 'general_fitness'];
  final experiences = const ['beginner', 'intermediate', 'advanced'];
  final genders = const ['male', 'female'];
  final daysOptions = const [2, 3, 4, 5, 6];

  final _titles = const [
    'Your Age',
    'Gender',
    'Workout Location',
    'Primary Goal',
    'Experience',
    'Days / Week',
    'Injuries',
    'Body Metrics',
    'Summary',
  ];

  int index = 0;

  @override
  void initState() {
    super.initState();
    _pc = PageController();
    _prefetch();
  }

  Future<void> _prefetch() async {
    await intake.loadInjuryTable();
    await intake.loadTemplates();
    if (mounted) setState(() {});
  }

  void _next() {
    if (index < _titles.length - 1) {
      setState(() => index++);
      _pc.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      _finish();
    }
  }

  void _back() {
    if (index == 0) {
      Navigator.pop(context);
      return;
    }
    setState(() => index--);
    _pc.animateToPage(index, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  Future<void> _finish() async {
    await AppStateScope.of(context).signIn(
      user: {
        ...?AppStateScope.of(context).user,
        'intake': intake.toMap(),
      },
    );
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => PlanGenerationScreen(intake: intake)),
    );
  }

  bool get canContinue {
    switch (index) {
      case 0:
        return intake.ageYears != null && intake.ageRange != null;
      case 1:
        return intake.gender != null;
      case 2:
        return intake.workoutLocation != null;
      case 3:
        return intake.goal != null;
      case 4:
        return intake.experience != null;
      case 5:
        return intake.daysPerWeek != null;
      case 6:
        return true; // injuries optional
      case 7:
        return intake.weightKg != null && intake.heightCm != null;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final totalPages = _titles.length;
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[index]),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _back),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (index + 1) / totalPages,
            backgroundColor: cs.surfaceVariant,
          ),
          Expanded(
            child: PageView(
              controller: _pc,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _AgeInputPage(
                  age: intake.ageYears,
                  range: intake.ageRange,
                  onChanged: (v) {
                    intake.setAge(v);
                    setState(() {});
                  },
                ),
                _GenderPage(
                  genders: genders,
                  selected: intake.gender,
                  onSelect: (v) => setState(() => intake.gender = v),
                ),
                _LocationPage(
                  locations: locations,
                  selected: intake.workoutLocation,
                  onSelect: (v) => setState(() => intake.workoutLocation = v),
                ),
                _GoalPage(
                  goals: goals,
                  selected: intake.goal,
                  onSelect: (v) => setState(() => intake.goal = v),
                ),
                _ExperiencePage(
                  experiences: experiences,
                  selected: intake.experience,
                  onSelect: (v) => setState(() => intake.experience = v),
                ),
                _DaysPerWeekPage(
                  options: daysOptions,
                  selected: intake.daysPerWeek,
                  onSelect: (v) => setState(() => intake.daysPerWeek = v),
                ),
                _InjuryPage(intake: intake),
                _MetricsPage(
                  intake: intake,
                  onChanged: () => setState(() {}),
                ),
                _SummaryPage(intake: intake),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: canContinue ? _next : null,
                      child: Text(
                        index < totalPages - 1 ? 'Continue' : 'Generate',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Age input
class _AgeInputPage extends StatefulWidget {
  final int? age;
  final String? range;
  final ValueChanged<int?> onChanged;
  const _AgeInputPage({
    required this.age,
    required this.range,
    required this.onChanged,
  });

  @override
  State<_AgeInputPage> createState() => _AgeInputPageState();
}

class _AgeInputPageState extends State<_AgeInputPage> {
  late final TextEditingController controller =
      TextEditingController(text: widget.age?.toString() ?? '');
  String? error;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onInput(String v) {
    final val = int.tryParse(v);
    if (val == null || val < 10 || val > 90) {
      error = 'Enter age 10-90';
      widget.onChanged(null);
    } else {
      error = null;
      widget.onChanged(val);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Enter your age',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w600, color: cs.primary),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Age', errorText: error),
          onChanged: _onInput,
        ),
        const SizedBox(height: 12),
        if (widget.range != null)
          Text('Detected range: ${widget.range}',
              style: TextStyle(color: cs.onSurfaceVariant)),
      ],
    );
  }
}

// Days per week
class _DaysPerWeekPage extends StatelessWidget {
  final List<int> options;
  final int? selected;
  final ValueChanged<int> onSelect;
  const _DaysPerWeekPage(
      {required this.options, required this.selected, required this.onSelect});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final d in options)
            ChoiceChip(
              label: Text('$d'),
              selected: selected == d,
              onSelected: (_) => onSelect(d),
              selectedColor: cs.primary.withOpacity(.15),
              labelStyle: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected == d ? cs.primary : cs.onSurface,
              ),
            ),
        ],
      ),
    );
  }
}

// Gender
class _GenderPage extends StatelessWidget {
  final List<String> genders;
  final String? selected;
  final ValueChanged<String> onSelect;
  const _GenderPage(
      {required this.genders, required this.selected, required this.onSelect});
  @override
  Widget build(BuildContext context) {
    return _OptionsWrap(
      children: [
        for (final g in genders)
          OptionCard(
            label: g[0].toUpperCase() + g.substring(1),
            image: 'assets/images/intake/gender/$g.jpg',
            selected: selected == g,
            onTap: () => onSelect(g),
          ),
      ],
    );
  }
}

// Location
class _LocationPage extends StatelessWidget {
  final List<String> locations;
  final String? selected;
  final ValueChanged<String> onSelect;
  const _LocationPage(
      {required this.locations, required this.selected, required this.onSelect});
  @override
  Widget build(BuildContext context) {
    return _OptionsWrap(
      children: [
        for (final l in locations)
          OptionCard(
            label: l == 'home' ? 'Home' : 'Gym',
            image: 'assets/images/intake/location/$l.jpg',
            selected: selected == l,
            onTap: () => onSelect(l),
          ),
      ],
    );
  }
}

// Goal
class _GoalPage extends StatelessWidget {
  final List<String> goals;
  final String? selected;
  final ValueChanged<String> onSelect;
  const _GoalPage(
      {required this.goals, required this.selected, required this.onSelect});
  @override
  Widget build(BuildContext context) {
    return _OptionsWrap(
      children: [
        for (final g in goals)
          OptionCard(
            label: _pretty(g),
            image: 'assets/images/intake/goal/$g.jpg',
            selected: selected == g,
            onTap: () => onSelect(g),
          ),
      ],
    );
  }

  static String _pretty(String g) =>
      g.replaceAll('_', ' ').replaceFirst(g[0], g[0].toUpperCase());
}

// Experience
class _ExperiencePage extends StatelessWidget {
  final List<String> experiences;
  final String? selected;
  final ValueChanged<String> onSelect;
  const _ExperiencePage(
      {required this.experiences, required this.selected, required this.onSelect});
  @override
  Widget build(BuildContext context) {
    return _OptionsWrap(
      children: [
        for (final e in experiences)
          OptionCard(
            label: _cap(e),
            image: 'assets/images/intake/experience/$e.jpg',
            selected: selected == e,
            onTap: () => onSelect(e),
          ),
      ],
    );
  }
  static String _cap(String e) => e[0].toUpperCase() + e.substring(1);
}

// Injuries
class _InjuryPage extends StatefulWidget {
  final IntakeState intake;
  const _InjuryPage({required this.intake});
  @override
  State<_InjuryPage> createState() => _InjuryPageState();
}

class _InjuryPageState extends State<_InjuryPage> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final map = widget.intake.injuryTable ?? {};
    final entries = map.entries
        .where((e) =>
            query.isEmpty ||
            e.key.toLowerCase().contains(query.toLowerCase()) ||
            (e.value is Map &&
                ((e.value as Map)['description'] ?? '')
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase())))
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    if (map.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          decoration: const InputDecoration(
              labelText: 'Search injuries', prefixIcon: Icon(Icons.search)),
          onChanged: (v) => setState(() => query = v),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final e in entries)
              _InjuryChip(
                id: e.key,
                label: (e.value is Map
                        ? ((e.value as Map)['short'] ??
                            (e.value as Map)['description'] ??
                            e.key)
                        : e.key)
                    .toString(),
                selected: widget.intake.injuries.contains(e.key),
                onToggle: () {
                  setState(() {
                    if (widget.intake.injuries.contains(e.key)) {
                      widget.intake.injuries.remove(e.key);
                    } else {
                      widget.intake.injuries.add(e.key);
                    }
                  });
                },
              ),
          ],
        ),
        if (widget.intake.injuries.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            'Selected (${widget.intake.injuries.length}): ${widget.intake.injuries.join(', ')}',
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
        ],
        const SizedBox(height: 80),
      ],
    );
  }
}

class _InjuryChip extends StatelessWidget {
  final String id;
  final String label;
  final bool selected;
  final VoidCallback onToggle;
  const _InjuryChip(
      {required this.id,
      required this.label,
      required this.selected,
      required this.onToggle});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ChoiceChip(
      label: Text(label, overflow: TextOverflow.ellipsis),
      selected: selected,
      onSelected: (_) => onToggle(),
      selectedColor: cs.primary.withOpacity(.18),
      labelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        color: selected ? cs.primary : cs.onSurface,
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

// Metrics
class _MetricsPage extends StatefulWidget {
  final IntakeState intake;
  final VoidCallback onChanged;
  const _MetricsPage({required this.intake, required this.onChanged});
  @override
  State<_MetricsPage> createState() => _MetricsPageState();
}

class _MetricsPageState extends State<_MetricsPage> {
  late final TextEditingController weightCtrl =
      TextEditingController(text: widget.intake.weightKg?.toString() ?? '');
  late final TextEditingController heightCtrl =
      TextEditingController(text: widget.intake.heightCm?.toString() ?? '');

  @override
  void dispose() {
    weightCtrl.dispose();
    heightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        TextField(
          controller: weightCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Weight (kg)'),
          onChanged: (v) {
            widget.intake.weightKg = double.tryParse(v.trim());
            widget.onChanged();
          },
        ),
        const SizedBox(height: 16),
        TextField(
          controller: heightCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Height (cm)'),
          onChanged: (v) {
            widget.intake.heightCm = double.tryParse(v.trim());
            widget.onChanged();
          },
        ),
      ],
    );
  }
}

// Summary
class _SummaryPage extends StatelessWidget {
  final IntakeState intake;
  const _SummaryPage({required this.intake});
  @override
  Widget build(BuildContext context) {
    final map = intake.toMap();
    final cs = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Review',
                      style: TextStyle(
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 18)),
                  const SizedBox(height: 12),
                  for (final e in map.entries)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text('${e.key}: ${e.value}'),
                    ),
                  const SizedBox(height: 12),
                  const Text('You can go back to edit any step.'),
                ]),
          ),
        ),
      ],
    );
  }
}

// Shared layout wrap
class _OptionsWrap extends StatelessWidget {
  final List<Widget> children;
  const _OptionsWrap({required this.children});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        final wide = c.maxWidth > 500;
        if (wide) {
          return Center(
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: children,
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: children,
            ),
          ],
        );
      },
    );
  }
}