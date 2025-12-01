import 'package:flutter/material.dart';

import '../../localization/app_localizations.dart';

class FoodLogDraft {
  FoodLogDraft({
    required this.name,
    required this.serving,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.notes,
  });

  final String name;
  final String serving;
  final double calories;
  final double protein;
  final double carbs;
  final double fats;
  final String? notes;

  FoodLogDraft copyWith({
    String? name,
    String? serving,
    double? calories,
    double? protein,
    double? carbs,
    double? fats,
    String? notes,
  }) {
    return FoodLogDraft(
      name: name ?? this.name,
      serving: serving ?? this.serving,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fats: fats ?? this.fats,
      notes: notes ?? this.notes,
    );
  }
}

class FoodLoggingDialog extends StatefulWidget {
  const FoodLoggingDialog({super.key, this.initial});

  final FoodLogDraft? initial;

  @override
  State<FoodLoggingDialog> createState() => _FoodLoggingDialogState();
}

class _FoodLoggingDialogState extends State<FoodLoggingDialog> with SingleTickerProviderStateMixin {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _servingCtrl;
  late final TextEditingController _calCtrl;
  late final TextEditingController _proteinCtrl;
  late final TextEditingController _carbCtrl;
  late final TextEditingController _fatCtrl;
  late final TextEditingController _notesCtrl;
  late final TabController _tabController;
  String? _error;
  String _search = '';

  final List<Map<String, dynamic>> _suggestedFoods = const [
    {
      'name': 'Greek Yogurt',
      'serving': '170g cup',
      'calories': 120,
      'protein': 17,
      'carbs': 9,
      'fats': 0,
    },
    {
      'name': 'Grilled Chicken',
      'serving': '100g',
      'calories': 165,
      'protein': 31,
      'carbs': 0,
      'fats': 4,
    },
    {
      'name': 'Avocado Toast',
      'serving': '1 slice',
      'calories': 210,
      'protein': 6,
      'carbs': 24,
      'fats': 10,
    },
  ];

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _nameCtrl = TextEditingController(text: initial?.name ?? '');
    _servingCtrl = TextEditingController(text: initial?.serving ?? '');
    _calCtrl = TextEditingController(text: initial?.calories.toString() ?? '');
    _proteinCtrl = TextEditingController(text: initial?.protein.toString() ?? '');
    _carbCtrl = TextEditingController(text: initial?.carbs.toString() ?? '');
    _fatCtrl = TextEditingController(text: initial?.fats.toString() ?? '');
    _notesCtrl = TextEditingController(text: initial?.notes ?? '');
    _tabController = TabController(length: 2, vsync: this, initialIndex: initial == null ? 0 : 1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameCtrl.dispose();
    _servingCtrl.dispose();
    _calCtrl.dispose();
    _proteinCtrl.dispose();
    _carbCtrl.dispose();
    _fatCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(widget.initial == null ? l10n.t('nutrition.addFood') : l10n.t('nutrition.editEntry')),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: l10n.t('nutrition.searchFood')),
                Tab(text: l10n.t('nutrition.customFood')),
              ],
            ),
            SizedBox(
              height: 360,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSearchTab(l10n),
                  _buildForm(l10n),
                ],
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.t('common.cancel')),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(widget.initial == null ? l10n.t('nutrition.addToMeal') : l10n.t('common.save')),
        ),
      ],
    );
  }

  Widget _buildSearchTab(AppLocalizations l10n) {
    final filtered = _suggestedFoods
        .where((food) => food['name']
            .toString()
            .toLowerCase()
            .contains(_search.trim().toLowerCase()))
        .toList();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: l10n.t('nutrition.searchPlaceholder'),
            ),
            onChanged: (value) => setState(() => _search = value),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, index) {
                final food = filtered[index];
                final tileColor = Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.3);
                return ListTile(
                  tileColor: tileColor,
                  title: Text(food['name'].toString()),
                  subtitle: Text('${food['serving']} • ${food['calories']} kcal'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _applySuggestion(food),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(labelText: l10n.t('nutrition.foodName')),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _servingCtrl,
            decoration: InputDecoration(labelText: l10n.t('nutrition.servingSize')),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _macroField(controller: _calCtrl, label: l10n.t('nutrition.calories'))),
              const SizedBox(width: 12),
              Expanded(child: _macroField(controller: _proteinCtrl, label: '${l10n.t('nutrition.protein')} (g)')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _macroField(controller: _carbCtrl, label: '${l10n.t('nutrition.carbs')} (g)')),
              const SizedBox(width: 12),
              Expanded(child: _macroField(controller: _fatCtrl, label: '${l10n.t('nutrition.fats')} (g)')),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesCtrl,
            maxLines: 3,
            decoration: InputDecoration(labelText: l10n.t('nutrition.notes')),
          ),
        ],
      ),
    );
  }

  Widget _macroField({required TextEditingController controller, required String label}) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label),
    );
  }

  void _applySuggestion(Map<String, dynamic> food) {
    _nameCtrl.text = food['name'].toString();
    _servingCtrl.text = food['serving'].toString();
    _calCtrl.text = food['calories'].toString();
    _proteinCtrl.text = food['protein'].toString();
    _carbCtrl.text = food['carbs'].toString();
    _fatCtrl.text = food['fats'].toString();
    _tabController.index = 1;
  }

  void _submit() {
    final l10n = context.l10n;
    final name = _nameCtrl.text.trim();
    final serving = _servingCtrl.text.trim();
    final calories = double.tryParse(_calCtrl.text.trim());
    final protein = double.tryParse(_proteinCtrl.text.trim()) ?? 0;
    final carbs = double.tryParse(_carbCtrl.text.trim()) ?? 0;
    final fats = double.tryParse(_fatCtrl.text.trim()) ?? 0;
    if (name.isEmpty || calories == null) {
      setState(() => _error = l10n.t('nutrition.validationFoodRequired'));
      return;
    }
    setState(() => _error = null);
    Navigator.of(context).pop(
      FoodLogDraft(
        name: name,
        serving: serving,
        calories: calories,
        protein: protein,
        carbs: carbs,
        fats: fats,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      ),
    );
  }
}
