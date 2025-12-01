import 'package:flutter/material.dart';
import '../../design_system/design_tokens.dart';
import '../../localization/app_localizations.dart';
import '../../models/quota_models.dart';
import '../../services/nutrition_service.dart';
import '../../services/nutrition_intake_flag_store.dart';
import '../../services/quota_service.dart';
import '../../state/app_state.dart';
import '../../widgets/demo_banner.dart';
import '../../widgets/nutrition_expiry_banner.dart';
import '../../widgets/quota_usage_banner.dart';
import '../../widgets/subscription_manager_sheet.dart';
import 'meal_detail_screen.dart';
import 'nutrition_preferences_flow.dart';

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
  final NutritionService svc = NutritionService();
  final QuotaService _quotaSvc = QuotaService();
  QuotaSnapshot? _quota;
  NutritionAccessSnapshot? _access;
  NutritionPreferences? _prefs;
  bool _savingPrefs = false;
  bool _launchingFlow = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final fetchedPlan = await svc.todayPlan();
      QuotaSnapshot? quota;
      NutritionAccessSnapshot? access;
      NutritionPreferences? prefs;
      final app = AppStateScope.of(context);
      final userId = app.user?['id']?.toString();
      if (userId != null) {
        final tier = SubscriptionTierDisplay.parse(app.subscriptionType);
        final combined = await Future.wait<dynamic>([
          _quotaSvc.fetchSnapshot(userId),
          svc.fetchAccess(userId, tier: tier),
          svc.fetchPreferences(userId),
        ]);
        quota = combined[0] as QuotaSnapshot;
        access = combined[1] as NutritionAccessSnapshot;
        prefs = combined[2] as NutritionPreferences?;
      }
      if (!mounted) return;
      setState(() {
        plan = fetchedPlan;
        _quota = quota;
        _access = access;
        _prefs = prefs;
        loading = false;
      });
      await _syncLocalIntakeState();
      await _maybeAutoLaunchIntake();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        error = 'Failed to load nutrition plan';
        loading = false;
      });
    }
  }

  Future<void> _syncLocalIntakeState() async {
    final app = AppStateScope.of(context);
    final phone = NutritionIntakeFlagStore.phoneFromProfile(app.user);
    if (phone == null) return;
    if (_prefs?.completedAt != null) {
      await NutritionIntakeFlagStore.markCompleted(phone);
      await NutritionIntakeFlagStore.clearPending(phone);
    }
  }

  Future<void> _maybeAutoLaunchIntake() async {
    if (!mounted) return;
    final app = AppStateScope.of(context);
    if (app.demoMode) {
      final phone = NutritionIntakeFlagStore.phoneFromProfile(app.user);
      await NutritionIntakeFlagStore.markCompleted(phone);
      await NutritionIntakeFlagStore.clearPending(phone);
      return;
    }
    final tier = SubscriptionTierDisplay.parse(app.subscriptionType);
    if (tier == SubscriptionTier.freemium) return;
    if (_prefs?.completedAt != null) return;
    final phone = NutritionIntakeFlagStore.phoneFromProfile(app.user);
    final pending = await NutritionIntakeFlagStore.hasPending(phone);
    if (!pending || _launchingFlow || _savingPrefs) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _openPreferencesSheet(autoLaunch: true);
    });
  }

  Map<String, num> _macrosFrom(List<Map<String, dynamic>> meals) {
    num cals = 0, p = 0, c = 0, f = 0;
    for (final meal in meals) {
      final items = (meal['items'] as List?)?.cast<Map<String, dynamic>>() ?? <Map<String, dynamic>>[];
      for (final item in items) {
        if (item['consumed'] == true) {
          cals += (item['calories'] as num?) ?? 0;
          p += (item['protein'] as num?) ?? 0;
          c += (item['carbs'] as num?) ?? 0;
          f += (item['fat'] as num?) ?? 0;
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
    final l10n = context.l10n;
    final app = AppStateScope.of(context);
    final tier = SubscriptionTierDisplay.parse(app.subscriptionType);
    final demo = app.demoMode;
    final plan = demo ? app.demoNutritionPlan : this.plan;
    final meals = (plan['meals'] as List?)?.cast<Map<String, dynamic>>() ?? <Map<String, dynamic>>[];
    final macros = _macrosFrom(meals);
    final locked = (_access?.status.isLocked ?? false) || (_access?.status.isExpired ?? false);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.t('nutrition.todayTitle'))),
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
                      if (_access != null)
                        NutritionExpiryBanner(
                          snapshot: _access!,
                          tier: tier,
                          onUpgrade: tier == SubscriptionTier.freemium ? _openUpgradeSheet : null,
                          onRegenerate: tier == SubscriptionTier.freemium ? () => _handleRegenerate(tier) : null,
                        ),
                      if (_quota != null)
                        QuotaUsageBanner(
                          snapshot: _quota!,
                          onUpgrade:
                              tier == SubscriptionTier.freemium ? _openUpgradeSheet : null,
                        ),
                      _PreferencesCard(
                        completed: _prefs?.completedAt != null,
                        saving: _savingPrefs,
                        onPressed: () => _openPreferencesSheet(),
                      ),
                      if (demo) const DemoBanner(),
                      const SizedBox(height: FitCoachSpacing.md),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _metric('kcal', '${macros['calories']?.toInt() ?? 0}', cs),
                              _metric('P', '${macros['protein'] ?? 0}', cs),
                              _metric('C', '${macros['carbs'] ?? 0}', cs),
                              _metric('F', '${macros['fat'] ?? 0}', cs),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: FitCoachSpacing.lg),
                      if (locked)
                        Card(
                          color: FitCoachColors.surfaceMuted,
                          child: Padding(
                            padding: const EdgeInsets.all(FitCoachSpacing.lg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Access locked', style: TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(height: FitCoachSpacing.sm),
                                const Text('Upgrade your plan to keep exploring personalized meals.'),
                                if (tier == SubscriptionTier.freemium) ...[
                                  const SizedBox(height: FitCoachSpacing.md),
                                  FilledButton(
                                    onPressed: _openUpgradeSheet,
                                    child: const Text('Upgrade now'),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        )
                      else
                        ...meals.map((meal) {
                          final mealId = (meal['id'] ?? meal['_id'] ?? '').toString();
                          final items = (meal['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
                          return Card(
                            child: Column(
                              children: [
                                ExpansionTile(
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
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed: () => _openMealDetail(meal),
                                    icon: const Icon(Icons.restaurant_menu),
                                    label: Text(l10n.t('nutrition.viewMeal')),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
    );
  }

  Widget _metric(String label, String value, ColorScheme cs) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: cs.primary, fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: cs.onSurfaceVariant)),
      ],
    );
  }

  Future<void> _openPreferencesSheet({bool autoLaunch = false}) async {
    if (_launchingFlow) return;
    final app = AppStateScope.of(context);
    final userId = app.user?['id']?.toString();
    if (userId == null) {
      if (!autoLaunch) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sign in to save preferences.')));
      }
      return;
    }
    final initial = _prefs ?? NutritionPreferences.empty();
    _launchingFlow = true;
    NutritionPreferences? updated;
    try {
      updated = await Navigator.of(context).push<NutritionPreferences>(
        MaterialPageRoute(builder: (_) => NutritionPreferencesFlow(initial: initial)),
      );
    } finally {
      _launchingFlow = false;
    }
    if (updated == null) return;
    setState(() => _savingPrefs = true);
    try {
      final saved = await svc.savePreferences(userId, updated);
      if (!mounted) return;
      setState(() {
        _prefs = saved;
        _savingPrefs = false;
      });
      final phone = NutritionIntakeFlagStore.phoneFromProfile(app.user);
      await NutritionIntakeFlagStore.clearPending(phone);
      await NutritionIntakeFlagStore.markCompleted(phone);
      await _syncLocalIntakeState();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Preferences saved.')));
    } catch (_) {
      if (!mounted) return;
      setState(() => _savingPrefs = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to save preferences.')));
    }
  }

  Future<void> _handleRegenerate(SubscriptionTier tier) async {
    final app = AppStateScope.of(context);
    final userId = app.user?['id']?.toString();
    if (userId == null) return;
    try {
      final snapshot = await svc.regeneratePlan(userId, tier);
      if (!mounted) return;
      setState(() => _access = snapshot);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Nutrition plan refreshed.')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Unable to regenerate plan right now.')));
    }
  }

  void _openMealDetail(Map<String, dynamic> meal) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MealDetailScreen(
          meal: meal,
          planDate: DateTime.now(),
        ),
      ),
    );
  }

  Future<void> _openUpgradeSheet() async {
    final before = AppStateScope.of(context).subscriptionType;
    await SubscriptionManagerSheet.show(context);
    final after = AppStateScope.of(context).subscriptionType;
    if (before != after) {
      await _load();
    }
  }
}

class _PreferencesCard extends StatelessWidget {
  const _PreferencesCard({required this.completed, required this.saving, required this.onPressed});

  final bool completed;
  final bool saving;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(completed ? Icons.check_circle : Icons.tune, color: completed ? Colors.green : null),
        title: Text(completed ? 'Preferences saved' : 'Complete nutrition preferences'),
        subtitle: Text(
          completed ? 'Your meals are tailored to your taste.' : 'Tell us your proteins and dinner style.',
        ),
        trailing: saving
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : TextButton(onPressed: onPressed, child: Text(completed ? 'Update' : 'Start')),
      ),
    );
  }
}
