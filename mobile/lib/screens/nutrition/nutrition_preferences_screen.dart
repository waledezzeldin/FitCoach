import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitcoach/nutrition/nutrition_state.dart';
import 'package:fitcoach/ui/button.dart';
import 'package:fitcoach/ui/surface_card.dart';
import 'package:fitcoach/l10n/app_localizations.dart';

class NutritionPreferencesScreen extends StatefulWidget {
  const NutritionPreferencesScreen({super.key});
  @override
  State<NutritionPreferencesScreen> createState() => _NutritionPreferencesScreenState();
}

class _NutritionPreferencesScreenState extends State<NutritionPreferencesScreen> {
  late TextEditingController _calController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatsController;
  String _diet = 'balanced';
  final Set<String> _allergies = {};

  @override
  void initState() {
    super.initState();
    final s = context.read<NutritionState>();
    _diet = s.prefs.dietType;
    _calController = TextEditingController(text: s.prefs.calorieTarget.toString());
    _proteinController = TextEditingController(text: s.prefs.proteinTarget.toString());
    _carbsController = TextEditingController(text: s.prefs.carbsTarget.toString());
    _fatsController = TextEditingController(text: s.prefs.fatsTarget.toString());
    _allergies.addAll(s.prefs.allergies);
  }

  @override
  void dispose() {
    _calController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<NutritionState>();
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.nutritionTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Diet Type'),
            const SizedBox(height: 8),
            SurfaceCard(
              child: DropdownButtonFormField<String>(
              value: _diet,
              items: const [
                DropdownMenuItem(value: 'balanced', child: Text('Balanced')),
                DropdownMenuItem(value: 'keto', child: Text('Keto')),
                DropdownMenuItem(value: 'vegan', child: Text('Vegan')),
              ],
              onChanged: (v) => setState(() => _diet = v ?? 'balanced'),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Calorie Target (kcal)'),
            const SizedBox(height: 8),
            SurfaceCard(child: Padding(padding: const EdgeInsets.all(8), child: TextField(
              controller: _calController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'e.g., 2200'),
            ))),
            const SizedBox(height: 16),
            const Text('Macro Targets (g)'),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: SurfaceCard(child: Padding(padding: const EdgeInsets.all(8), child: TextField(controller: _proteinController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Protein'))))),
              const SizedBox(width: 8),
              Expanded(child: SurfaceCard(child: Padding(padding: const EdgeInsets.all(8), child: TextField(controller: _carbsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Carbs'))))),
              const SizedBox(width: 8),
              Expanded(child: SurfaceCard(child: Padding(padding: const EdgeInsets.all(8), child: TextField(controller: _fatsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Fats'))))),
            ]),
            const SizedBox(height: 16),
            const Text('Allergies'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['gluten', 'nuts', 'dairy', 'eggs'].map((a) {
                final selected = _allergies.contains(a);
                return FilterChip(
                  label: Text(a),
                  selected: selected,
                  onSelected: (v) => setState(() => v ? _allergies.add(a) : _allergies.remove(a)),
                );
              }).toList(),
            ),
            const Spacer(),
            PrimaryButton(
              label: 'Save',
              onPressed: () async {
                final cal = int.tryParse(_calController.text) ?? s.prefs.calorieTarget;
                final protein = int.tryParse(_proteinController.text) ?? s.prefs.proteinTarget;
                final carbs = int.tryParse(_carbsController.text) ?? s.prefs.carbsTarget;
                final fats = int.tryParse(_fatsController.text) ?? s.prefs.fatsTarget;
                await s.save(NutritionPrefs(
                  dietType: _diet,
                  calorieTarget: cal,
                  allergies: _allergies.toList(),
                  proteinTarget: protein,
                  carbsTarget: carbs,
                  fatsTarget: fats,
                ));
                if (!context.mounted) return;
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
