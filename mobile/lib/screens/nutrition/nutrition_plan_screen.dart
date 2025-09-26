import 'package:flutter/material.dart';
import '../../services/nutrition_service.dart';
import '../../state/app_state.dart';
import '../../widgets/demo_banner.dart';

class NutritionPlanScreen extends StatefulWidget {
  const NutritionPlanScreen({super.key, this.isFreemium = false});
  final bool isFreemium;

  @override
  State<NutritionPlanScreen> createState() => _NutritionPlanScreenState();
}

class _NutritionPlanScreenState extends State<NutritionPlanScreen> {
  bool loading = true;
  String? error;
  Map<String, dynamic> plan = {};
  final svc = NutritionService();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      plan = await svc.todayPlan();
    } catch (_) {
      error = 'Failed to load nutrition plan';
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Map<String, num> _macros() {
    final meals = (plan['meals'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    num cals = 0, p = 0, c = 0, f = 0;
    for (final m in meals) {
      final items = (m['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      for (final it in items) {
        final consumed = it['consumed'] == true;
        if (consumed) {
          cals += (it['calories'] as num?) ?? 0;
          p += (it['protein'] as num?) ?? 0;
          c += (it['carbs'] as num?) ?? 0;
          f += (it['fat'] as num?) ?? 0;
        }
      }
    }
    return {'calories': cals, 'protein': p, 'carbs': c, 'fat': f};
  }

  Future<void> _toggle(String mealId, Map<String, dynamic> item, bool val) async {
    setState(() => item['consumed'] = val);
    try {
      await svc.logToggle(mealId: mealId, itemId: (item['id'] ?? item['_id']).toString(), consumed: val);
    } catch (_) {
      setState(() => item['consumed'] = !val);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final app = AppStateScope.of(context);
    final demo = app.demoMode;
    final plan = demo ? app.demoNutritionPlan : this.plan; // use state 'plan'

    return Scaffold(
      appBar: AppBar(title: const Text('Today\'s Nutrition')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(error!, style: TextStyle(color: cs.error)),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: _load, child: const Text('Retry')),
                  ]),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Summary card (uses theme colors)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _metric('kcal', '${_m['calories']?.toInt() ?? 0}', cs),
                              _metric('P', '${_m['protein'] ?? 0}', cs),
                              _metric('C', '${_m['carbs'] ?? 0}', cs),
                              _metric('F', '${_m['fat'] ?? 0}', cs),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Show banner at top
                      if (demo) ...[
                        const SizedBox(height: 8),
                        const DemoBanner(),
                        const SizedBox(height: 12),
                      ],
                      // Meals
                      ..._meals.map((meal) {
                        final mealId = (meal['id'] ?? meal['_id'] ?? '').toString();
                        final items = (meal['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
                        return Card(
                          child: ExpansionTile(
                            title: Text(
                              (meal['name'] ?? 'Meal').toString(),
                              style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600),
                            ),
                            iconColor: cs.primary,
                            collapsedIconColor: cs.onSurfaceVariant,
                            children: items.map((it) {
                              final consumed = it['consumed'] == true;
                              final cal = (it['calories'] as num?)?.toInt() ?? 0;
                              return CheckboxListTile(
                                controlAffinity: ListTileControlAffinity.leading,
                                value: consumed,
                                onChanged: (v) => v == null ? null : _toggle(mealId, it, v),
                                title: Text((it['name'] ?? '').toString()),
                                subtitle: Text('$cal kcal', style: TextStyle(color: cs.onSurfaceVariant)),
                                activeColor: cs.primary,
                              );
                            }).toList(),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
    );
  }

  // Helpers expected in the file:
  List<Map<String, dynamic>> get _meals =>
      (plan['meals'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
  Map<String, num> get _m => _macros();

  Widget _metric(String label, String value, ColorScheme cs) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: cs.primary, fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: cs.onSurfaceVariant)),
      ],
    );
  }
}