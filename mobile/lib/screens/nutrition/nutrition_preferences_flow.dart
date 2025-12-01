import 'package:flutter/material.dart';

import '../../design_system/design_tokens.dart';
import '../../localization/app_localizations.dart';
import '../../models/quota_models.dart';

class NutritionPreferencesFlow extends StatefulWidget {
  const NutritionPreferencesFlow({super.key, required this.initial});

  final NutritionPreferences initial;

  @override
  State<NutritionPreferencesFlow> createState() => _NutritionPreferencesFlowState();
}

class _NutritionPreferencesFlowState extends State<NutritionPreferencesFlow> {
  static const _totalSteps = 3;

  int _step = 0;
  late List<String> _proteinSources;
  late List<String> _proteinAllergies;
  late String _portionSize;
  late String _prepSpeed;
  late String _carbLevel;
  late List<String> _cuisines;
  late List<String> _avoid;
  late String _temperature;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _proteinSources = List<String>.from(widget.initial.proteinSources);
    _proteinAllergies = List<String>.from(widget.initial.proteinAllergies);
    final dinner = Map<String, dynamic>.from(widget.initial.dinnerPreferences ?? const {});
    _portionSize = (dinner['portionSize'] ?? 'moderate').toString();
    _prepSpeed = (dinner['prepSpeed'] ?? 'normal').toString();
    _carbLevel = (dinner['carbLevel'] ?? 'includes_carbs').toString();
    _cuisines = List<String>.from(dinner['cuisines'] as List? ?? const []);
    _avoid = List<String>.from(dinner['avoid'] as List? ?? const []);
    _temperature = (dinner['temperature'] ?? 'both').toString();
    _notesController = TextEditingController(text: widget.initial.additionalNotes ?? '');
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _toggle(List<String> target, String value) {
    setState(() {
      if (target.contains(value)) {
        target.remove(value);
      } else {
        target.add(value);
      }
    });
  }

  void _next() {
    if (_step < _totalSteps - 1) {
      setState(() => _step++);
      return;
    }
    final prefs = widget.initial.copyWith(
      proteinSources: List<String>.from(_proteinSources),
      proteinAllergies: List<String>.from(_proteinAllergies),
      dinnerPreferences: {
        'portionSize': _portionSize,
        'prepSpeed': _prepSpeed,
        'carbLevel': _carbLevel,
        'temperature': _temperature,
        'cuisines': _cuisines,
        'avoid': _avoid,
      },
      additionalNotes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );
    Navigator.of(context).pop(prefs);
  }

  void _prev() {
    if (_step == 0) {
      Navigator.of(context).maybePop();
    } else {
      setState(() => _step--);
    }
  }

  bool get _canContinue {
    if (_step == 0) {
      return _proteinSources.isNotEmpty;
    }
    if (_step == 1) {
      return _cuisines.isNotEmpty;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _prev,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.t('nutritionPrefs.title')),
            const SizedBox(height: 2),
            Text(
              '${l10n.t('nutritionPrefs.step')} ${_step + 1} / $_totalSteps',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_step + 1) / _totalSteps,
            minHeight: 4,
            color: cs.primary,
            backgroundColor: cs.surfaceContainerHighest,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(FitCoachSpacing.lg),
          child: Column(
            children: [
              Expanded(child: _buildStep(l10n, cs)),
              const SizedBox(height: FitCoachSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _prev,
                      child: Text(_step == 0 ? l10n.t('common.cancel') : l10n.t('nutritionPrefs.previous')),
                    ),
                  ),
                  const SizedBox(width: FitCoachSpacing.md),
                  Expanded(
                    child: FilledButton(
                      onPressed: _canContinue ? _next : null,
                      child: Text(_step == _totalSteps - 1
                          ? l10n.t('nutritionPrefs.completeSetup')
                          : l10n.t('common.continue')),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(AppLocalizations l10n, ColorScheme cs) {
    switch (_step) {
      case 0:
        return _ProteinStep(
          l10n: l10n,
          proteinSources: _proteinSources,
          allergies: _proteinAllergies,
          onToggleProtein: (id) => _toggle(_proteinSources, id),
          onToggleAllergy: (id) => _toggle(_proteinAllergies, id),
        );
      case 1:
        return _DinnerStep(
          l10n: l10n,
          portionSize: _portionSize,
          prepSpeed: _prepSpeed,
          carbLevel: _carbLevel,
          temperature: _temperature,
          cuisines: _cuisines,
          onSelectPortion: (value) => setState(() => _portionSize = value),
          onSelectPrep: (value) => setState(() => _prepSpeed = value),
          onSelectCarb: (value) => setState(() => _carbLevel = value),
          onSelectTemp: (value) => setState(() => _temperature = value),
          onToggleCuisine: (value) => _toggle(_cuisines, value),
        );
      default:
        return _RestrictionsStep(
          l10n: l10n,
          avoid: _avoid,
          notesController: _notesController,
          onToggleAvoid: (value) => _toggle(_avoid, value),
        );
    }
  }
}

class _ProteinStep extends StatelessWidget {
  const _ProteinStep({
    required this.l10n,
    required this.proteinSources,
    required this.allergies,
    required this.onToggleProtein,
    required this.onToggleAllergy,
  });

  final AppLocalizations l10n;
  final List<String> proteinSources;
  final List<String> allergies;
  final ValueChanged<String> onToggleProtein;
  final ValueChanged<String> onToggleAllergy;

  static const _proteinOptions = [
    ['chicken', '🐔'],
    ['red_meat', '🥩'],
    ['tuna', '🐟'],
    ['shrimp', '🦐'],
    ['salmon', '🐟'],
    ['eggs', '🥚'],
    ['beans', '🫘'],
    ['tofu', '🥢'],
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: l10n.t('nutritionPrefs.protein.title'), subtitle: l10n.t('nutritionPrefs.protein.subtitle')),
          const SizedBox(height: FitCoachSpacing.md),
          _OptionGrid(
            options: _proteinOptions,
            translations: _proteinLabel(l10n),
            selected: proteinSources,
            onTap: onToggleProtein,
            highlightColor: Colors.greenAccent.withValues(alpha: 0.2),
          ),
          const SizedBox(height: FitCoachSpacing.xl),
          _SectionHeader(title: l10n.t('nutritionPrefs.allergies.title'), subtitle: l10n.t('nutritionPrefs.allergies.subtitle')),
          const SizedBox(height: FitCoachSpacing.md),
          _OptionGrid(
            options: _proteinOptions,
            translations: _proteinLabel(l10n),
            selected: allergies,
            onTap: onToggleAllergy,
            highlightColor: Colors.redAccent.withValues(alpha: 0.2),
          ),
        ],
      ),
    );
  }

  Map<String, String> _proteinLabel(AppLocalizations l10n) => {
        'chicken': l10n.t('foods.chicken'),
        'red_meat': l10n.t('foods.beef'),
        'tuna': l10n.t('foods.tuna'),
        'shrimp': l10n.t('foods.shrimp'),
        'salmon': l10n.t('foods.salmon'),
        'eggs': l10n.t('foods.eggs'),
        'beans': l10n.t('foods.beans'),
        'tofu': l10n.t('foods.tofu'),
      };
}

class _DinnerStep extends StatelessWidget {
  const _DinnerStep({
    required this.l10n,
    required this.portionSize,
    required this.prepSpeed,
    required this.carbLevel,
    required this.temperature,
    required this.cuisines,
    required this.onSelectPortion,
    required this.onSelectPrep,
    required this.onSelectCarb,
    required this.onSelectTemp,
    required this.onToggleCuisine,
  });

  final AppLocalizations l10n;
  final String portionSize;
  final String prepSpeed;
  final String carbLevel;
  final String temperature;
  final List<String> cuisines;
  final ValueChanged<String> onSelectPortion;
  final ValueChanged<String> onSelectPrep;
  final ValueChanged<String> onSelectCarb;
  final ValueChanged<String> onSelectTemp;
  final ValueChanged<String> onToggleCuisine;

  static const _cuisineOptions = [
    ['egyptian', '🇪🇬'],
    ['arabic', '🥙'],
    ['mediterranean', '🫒'],
    ['asian', '🍜'],
    ['western', '🍽️'],
    ['indian', '🍛'],
  ];

  @override
  Widget build(BuildContext context) {
    final controlPadding = EdgeInsets.symmetric(vertical: FitCoachSpacing.sm);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: l10n.t('nutritionPrefs.dinner.title'), subtitle: l10n.t('nutritionPrefs.dinner.subtitle')),
          const SizedBox(height: FitCoachSpacing.md),
          _LabeledChoiceRow(
            label: l10n.t('nutritionPrefs.portionSize'),
            value: portionSize,
            options: [
              ['light', l10n.t('nutritionPrefs.portionSize.light')],
              ['moderate', l10n.t('nutritionPrefs.portionSize.moderate')],
              ['filling', l10n.t('nutritionPrefs.portionSize.filling')],
            ],
            onSelect: onSelectPortion,
            padding: controlPadding,
          ),
          _LabeledChoiceRow(
            label: l10n.t('nutritionPrefs.prepTime'),
            value: prepSpeed,
            options: [
              ['quick', l10n.t('nutritionPrefs.prepTime.quick')],
              ['normal', l10n.t('nutritionPrefs.prepTime.normal')],
              ['prep_ahead', l10n.t('nutritionPrefs.prepTime.prepAhead')],
            ],
            onSelect: onSelectPrep,
            padding: controlPadding,
          ),
          _LabeledChoiceRow(
            label: l10n.t('nutritionPrefs.carbs'),
            value: carbLevel,
            options: [
              ['no_carb', l10n.t('nutritionPrefs.carbs.noCarb')],
              ['low_carb', l10n.t('nutritionPrefs.carbs.lowCarb')],
              ['includes_carbs', l10n.t('nutritionPrefs.carbs.includesCarbs')],
            ],
            onSelect: onSelectCarb,
            padding: controlPadding,
          ),
          _LabeledChoiceRow(
            label: l10n.t('nutritionPrefs.temperature'),
            value: temperature,
            options: [
              ['hot', l10n.t('nutritionPrefs.temperature.hot')],
              ['cold', l10n.t('nutritionPrefs.temperature.cold')],
              ['both', l10n.t('nutritionPrefs.temperature.both')],
            ],
            onSelect: onSelectTemp,
            padding: controlPadding,
          ),
          const SizedBox(height: FitCoachSpacing.lg),
          _SectionHeader(title: l10n.t('nutritionPrefs.cuisines'), subtitle: l10n.t('nutritionPrefs.cuisines.subtitle')),
          const SizedBox(height: FitCoachSpacing.sm),
          _OptionGrid(
            options: _cuisineOptions,
            translations: _cuisineLabels(l10n),
            selected: cuisines,
            onTap: onToggleCuisine,
            highlightColor: Colors.orangeAccent.withValues(alpha: 0.15),
          ),
        ],
      ),
    );
  }

  Map<String, String> _cuisineLabels(AppLocalizations l10n) => {
        'egyptian': l10n.t('cuisines.egyptian'),
        'arabic': l10n.t('cuisines.middle_eastern'),
        'mediterranean': l10n.t('cuisines.mediterranean'),
        'asian': l10n.t('cuisines.asian'),
        'western': l10n.t('cuisines.american'),
        'indian': l10n.t('cuisines.indian'),
      };
}

class _RestrictionsStep extends StatelessWidget {
  const _RestrictionsStep({
    required this.l10n,
    required this.avoid,
    required this.notesController,
    required this.onToggleAvoid,
  });

  final AppLocalizations l10n;
  final List<String> avoid;
  final TextEditingController notesController;
  final ValueChanged<String> onToggleAvoid;

  static const _avoidOptions = [
    ['spicy', '🌶️'],
    ['fried', '🍟'],
    ['dairy', '🥛'],
    ['gluten', '🌾'],
    ['seafood', '🐟'],
    ['nuts', '🥜'],
    ['shellfish', '🦐'],
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: l10n.t('nutritionPrefs.avoid.title'), subtitle: l10n.t('nutritionPrefs.avoid.subtitle')),
          const SizedBox(height: FitCoachSpacing.md),
          _OptionGrid(
            options: _avoidOptions,
            translations: _avoidLabels(l10n),
            selected: avoid,
            onTap: onToggleAvoid,
            highlightColor: Colors.redAccent.withValues(alpha: 0.18),
          ),
          const SizedBox(height: FitCoachSpacing.lg),
          _SectionHeader(title: l10n.t('nutritionPrefs.notes.title'), subtitle: l10n.t('nutritionPrefs.notes.subtitle')),
          const SizedBox(height: FitCoachSpacing.sm),
          TextField(
            controller: notesController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: l10n.t('nutritionPrefs.notes.placeholder'),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(FitCoachRadii.md)),
            ),
          ),
          const SizedBox(height: FitCoachSpacing.xl),
          ListTile(
            leading: const Icon(Icons.check_circle, color: Colors.green),
            title: Text(l10n.t('nutritionPrefs.complete')),
            subtitle: Text(l10n.t('nutritionPrefs.completeDesc')),
          ),
        ],
      ),
    );
  }

  Map<String, String> _avoidLabels(AppLocalizations l10n) => {
        'spicy': l10n.t('foods.spicy'),
        'fried': l10n.t('foods.fried'),
        'dairy': l10n.t('foods.dairy'),
        'gluten': l10n.t('foods.gluten'),
        'seafood': l10n.t('foods.seafood'),
        'nuts': l10n.t('foods.nuts'),
        'shellfish': l10n.t('foods.shellfish'),
      };
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(subtitle, style: text.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

class _OptionGrid extends StatelessWidget {
  const _OptionGrid({
    required this.options,
    required this.translations,
    required this.selected,
    required this.onTap,
    required this.highlightColor,
  });

  final List<List<String>> options;
  final Map<String, String> translations;
  final List<String> selected;
  final ValueChanged<String> onTap;
  final Color highlightColor;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: FitCoachSpacing.sm,
      runSpacing: FitCoachSpacing.sm,
      children: [
        for (final option in options)
          GestureDetector(
            onTap: () => onTap(option.first),
            child: Container(
              width: 150,
              padding: const EdgeInsets.symmetric(horizontal: FitCoachSpacing.md, vertical: FitCoachSpacing.sm),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(FitCoachRadii.lg),
                border: Border.all(color: selected.contains(option.first) ? highlightColor : Theme.of(context).dividerColor),
                color: selected.contains(option.first) ? highlightColor : Theme.of(context).colorScheme.surfaceContainerLowest,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(option.last, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: FitCoachSpacing.sm),
                  Flexible(
                    child: Text(
                      translations[option.first] ?? option.first,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _LabeledChoiceRow extends StatelessWidget {
  const _LabeledChoiceRow({
    required this.label,
    required this.value,
    required this.options,
    required this.onSelect,
    required this.padding,
  });

  final String label;
  final String value;
  final List<List<String>> options;
  final ValueChanged<String> onSelect;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: text.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: FitCoachSpacing.sm),
          Wrap(
            spacing: FitCoachSpacing.sm,
            children: options
                .map(
                  (entry) => ChoiceChip(
                    label: Text(entry.last),
                    selected: value == entry.first,
                    onSelected: (_) => onSelect(entry.first),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
