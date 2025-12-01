import 'dart:convert';

import 'package:flutter/material.dart';

import '../../localization/app_localizations.dart';
import '../../services/nutrition_service.dart';
import '../../state/app_state.dart';
import 'food_logging_dialog.dart';

class MealDetailScreen extends StatefulWidget {
  const MealDetailScreen({super.key, required this.meal, required this.planDate});

  final Map<String, dynamic> meal;
  final DateTime planDate;

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  final NutritionService _service = NutritionService();
  late Map<String, dynamic> _meal;
  late DateTime _planDate;
  String? _userId;
  bool _demoMode = false;
  bool _loadingLogs = true;
  String? _logsError;
  List<Map<String, dynamic>> _logs = const [];
  bool _hydrated = false;

  String get _mealName => (_meal['name'] ?? 'Meal').toString();
  String? get _mealId => _meal['id']?.toString();
  String get _mealKey => _mealId ?? _mealName;

  @override
  void initState() {
    super.initState();
    _meal = widget.meal;
    _planDate = widget.planDate;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final app = AppStateScope.of(context);
    final id = app.user?['id']?.toString();
    final changed = id != _userId || _demoMode != app.demoMode;
    _userId = id;
    _demoMode = app.demoMode;
    if (!_hydrated || changed) {
      _hydrated = true;
      _loadLogs();
    }
  }

  Future<void> _loadLogs() async {
    setState(() {
      _loadingLogs = true;
      _logsError = null;
    });
    try {
      if (_demoMode || _userId == null) {
        _logs = [
          {
            'id': 'demo_${DateTime.now().millisecondsSinceEpoch}',
            'meal': 'Berry Smoothie',
            'mealType': _mealKey,
            'calories': 190,
            'protein': 12,
            'carbs': 28,
            'fats': 4,
            'notes': jsonEncode({'serving': '350ml', 'mealLabel': _mealName}),
            'date': _planDate.toIso8601String(),
          },
        ];
      } else {
        final data = await _service.fetchLogs(_userId!, day: _planDate);
        _logs = data.where(_matchesMeal).toList();
      }
    } catch (error) {
      _logsError = _friendlyError(error);
    } finally {
      if (mounted) {
        setState(() {
          _loadingLogs = false;
        });
      }
    }
  }

  bool _matchesMeal(Map<String, dynamic> log) {
    final type = log['mealType']?.toString();
    return type == _mealKey || type == _mealName;
  }

  List<Map<String, dynamic>> get _mealItems =>
      (_meal['items'] as List?)?.cast<Map<String, dynamic>>() ?? const [];

  Map<String, double> get _assignedTotals {
    double calories = 0, protein = 0, carbs = 0, fats = 0;
    for (final item in _mealItems) {
      calories += (item['calories'] as num?)?.toDouble() ?? 0;
      protein += (item['protein'] as num?)?.toDouble() ?? 0;
      carbs += (item['carbs'] as num?)?.toDouble() ?? 0;
      fats += (item['fat'] as num?)?.toDouble() ?? 0;
    }
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
    };
  }

  Map<String, double> get _loggedTotals {
    double calories = 0, protein = 0, carbs = 0, fats = 0;
    for (final log in _logs) {
      calories += (log['calories'] as num?)?.toDouble() ?? 0;
      protein += (log['protein'] as num?)?.toDouble() ?? 0;
      carbs += (log['carbs'] as num?)?.toDouble() ?? 0;
      fats += (log['fats'] as num?)?.toDouble() ?? 0;
    }
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
    };
  }

  Map<String, double> get _remainingTotals {
    final assigned = _assignedTotals;
    final logged = _loggedTotals;
    return {
      'calories': (assigned['calories'] ?? 0) - (logged['calories'] ?? 0),
      'protein': (assigned['protein'] ?? 0) - (logged['protein'] ?? 0),
      'carbs': (assigned['carbs'] ?? 0) - (logged['carbs'] ?? 0),
      'fats': (assigned['fats'] ?? 0) - (logged['fats'] ?? 0),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(_mealName)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _handleAddLog,
        icon: const Icon(Icons.add),
        label: Text(l10n.t('nutrition.logFood')),
      ),
      body: RefreshIndicator(
        onRefresh: _loadLogs,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            _buildSummaryCard(l10n),
            const SizedBox(height: 16),
            _buildAssignedFoods(l10n),
            const SizedBox(height: 16),
            _buildLoggedFoods(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(AppLocalizations l10n) {
    final cs = Theme.of(context).colorScheme;
    final assigned = _assignedTotals;
    final logged = _loggedTotals;
    final remaining = _remainingTotals;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.t('nutrition.mealSummary'), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _macroChip(l10n.t('nutrition.totalAssigned'), assigned, cs.primary),
                _macroChip(l10n.t('nutrition.totalLogged'), logged, cs.secondary),
                _macroChip(l10n.t('nutrition.remaining'), remaining, cs.tertiary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _macroChip(String label, Map<String, double> macros, Color color) {
    final textStyle = TextStyle(color: color, fontWeight: FontWeight.w600);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: textStyle),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              Text('${macros['calories']?.toStringAsFixed(0) ?? 0} kcal', style: textStyle),
              Text('${macros['protein']?.toStringAsFixed(0) ?? 0}P', style: textStyle),
              Text('${macros['carbs']?.toStringAsFixed(0) ?? 0}C', style: textStyle),
              Text('${macros['fats']?.toStringAsFixed(0) ?? 0}F', style: textStyle),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAssignedFoods(AppLocalizations l10n) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.t('nutrition.planFoods'), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (_mealItems.isEmpty)
              Text(l10n.t('nutrition.noPlanItems'), style: TextStyle(color: cs.onSurfaceVariant))
            else
              ..._mealItems.map((item) => _foodTile(item, cs)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _foodTile(Map<String, dynamic> item, ColorScheme cs) {
    final calories = (item['calories'] as num?)?.toInt() ?? 0;
    final protein = (item['protein'] as num?)?.toInt() ?? 0;
    final carbs = (item['carbs'] as num?)?.toInt() ?? 0;
    final fats = (item['fat'] as num?)?.toInt() ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name']?.toString() ?? 'Food', style: const TextStyle(fontWeight: FontWeight.w600)),
                if ((item['serving'] ?? '').toString().isNotEmpty)
                  Text(item['serving'].toString(), style: TextStyle(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          Text('$calories kcal', style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600)),
          const SizedBox(width: 12),
          Text('$protein P'),
          const SizedBox(width: 8),
          Text('$carbs C'),
          const SizedBox(width: 8),
          Text('$fats F'),
        ],
      ),
    );
  }

  Widget _buildLoggedFoods(AppLocalizations l10n) {
    final cs = Theme.of(context).colorScheme;
    if (_loadingLogs) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    if (_logsError != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(_logsError!, style: TextStyle(color: cs.error)),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _loadLogs, child: Text(l10n.t('common.retry'))),
            ],
          ),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.t('nutrition.loggedFoods'), style: Theme.of(context).textTheme.titleMedium),
                TextButton.icon(
                  onPressed: _handleAddLog,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.t('nutrition.logFood')),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_logs.isEmpty)
              Text(l10n.t('nutrition.emptyLogs'), style: TextStyle(color: cs.onSurfaceVariant))
            else
              ..._logs.map((log) => _logTile(log, l10n)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _logTile(Map<String, dynamic> log, AppLocalizations l10n) {
    final notes = _decodeNotes(log['notes']);
    final serving = notes['serving']?.toString();
    final customNotes = notes['notes']?.toString();
    final loggedAt = DateTime.tryParse(log['date']?.toString() ?? '');
    final timeLabel = loggedAt != null
        ? MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(loggedAt))
        : '';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(log['meal']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                      if (serving != null && serving.isNotEmpty)
                        Text(serving, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      if (timeLabel.isNotEmpty)
                        Text(l10n.t('nutrition.loggedAt').replaceAll('{time}', timeLabel),
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      tooltip: l10n.t('nutrition.editEntry'),
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _handleEditLog(log),
                    ),
                    IconButton(
                      tooltip: l10n.t('nutrition.deleteEntry'),
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _confirmDelete(log),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _logMacroPill('${(log['calories'] as num?)?.toInt() ?? 0} kcal'),
                _logMacroPill('${(log['protein'] as num?)?.toInt() ?? 0} P'),
                _logMacroPill('${(log['carbs'] as num?)?.toInt() ?? 0} C'),
                _logMacroPill('${(log['fats'] as num?)?.toInt() ?? 0} F'),
              ],
            ),
            if (customNotes != null && customNotes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(customNotes, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _logMacroPill(String text) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600)),
    );
  }

  Map<String, dynamic> _decodeNotes(dynamic raw) {
    if (raw is String && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          return decoded.map((key, value) => MapEntry(key.toString(), value));
        }
      } catch (_) {}
    }
    return const {};
  }

  Future<void> _handleAddLog() => _openLoggingDialog();

  Future<void> _handleEditLog(Map<String, dynamic> log) => _openLoggingDialog(existing: log);

  Future<void> _openLoggingDialog({Map<String, dynamic>? existing}) async {
    final l10n = context.l10n;
    final draft = existing == null ? null : _draftFromLog(existing);
    final result = await showDialog<FoodLogDraft>(
      context: context,
      builder: (_) => FoodLoggingDialog(initial: draft),
    );
    if (result == null) return;
    final meta = {
      'serving': result.serving,
      'notes': result.notes,
      'mealLabel': _mealName,
    }..removeWhere((key, value) => _isBlank(value));
    try {
      Map<String, dynamic> saved;
      if (_demoMode || _userId == null) {
        saved = _draftToLocalLog(result, id: existing?['id']?.toString());
      } else if (existing == null) {
        saved = await _service.createLog(
          userId: _userId!,
          foodName: result.name,
          calories: result.calories,
          protein: result.protein,
          carbs: result.carbs,
          fats: result.fats,
          date: _planDate,
          mealType: _mealKey,
          notes: meta.isEmpty ? null : meta,
        );
      } else {
        saved = await _service.updateLog(
          logId: existing['id'].toString(),
          foodName: result.name,
          calories: result.calories,
          protein: result.protein,
          carbs: result.carbs,
          fats: result.fats,
          date: _planDate,
          mealType: _mealKey,
          notes: meta.isEmpty ? null : meta,
        );
      }
      if (!mounted) return;
      setState(() {
        if (existing == null) {
          _logs = [saved, ..._logs];
        } else {
          _logs = _logs.map((log) => log['id'].toString() == saved['id'].toString() ? saved : log).toList();
        }
      });
      _showSnack(existing == null ? l10n.t('nutrition.foodLogged') : l10n.t('nutrition.foodUpdated'));
    } catch (error) {
      _showSnack(_friendlyError(error));
    }
  }

  FoodLogDraft _draftFromLog(Map<String, dynamic> log) {
    final notes = _decodeNotes(log['notes']);
    return FoodLogDraft(
      name: log['meal']?.toString() ?? '',
      serving: notes['serving']?.toString() ?? '',
      calories: (log['calories'] as num?)?.toDouble() ?? 0,
      protein: (log['protein'] as num?)?.toDouble() ?? 0,
      carbs: (log['carbs'] as num?)?.toDouble() ?? 0,
      fats: (log['fats'] as num?)?.toDouble() ?? 0,
      notes: notes['notes']?.toString() ?? log['notes']?.toString(),
    );
  }

  Map<String, dynamic> _draftToLocalLog(FoodLogDraft draft, {String? id}) {
    return {
      'id': id ?? 'local_${DateTime.now().millisecondsSinceEpoch}',
      'meal': draft.name,
      'mealType': _mealKey,
      'calories': draft.calories,
      'protein': draft.protein,
      'carbs': draft.carbs,
      'fats': draft.fats,
      'notes': jsonEncode({
        'serving': draft.serving,
        'notes': draft.notes,
        'mealLabel': _mealName,
      }..removeWhere((key, value) => _isBlank(value))),
      'date': _planDate.toIso8601String(),
    };
  }

  Future<void> _confirmDelete(Map<String, dynamic> log) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.t('nutrition.deleteEntry')),
        content: Text(l10n.t('nutrition.deleteEntryConfirm')),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.t('common.cancel'))),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.t('nutrition.deleteEntry'))),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      if (!_demoMode && _userId != null) {
        await _service.deleteLog(log['id'].toString());
      }
      if (!mounted) return;
      setState(() {
        _logs = _logs.where((entry) => entry['id'].toString() != log['id'].toString()).toList();
      });
      _showSnack(l10n.t('nutrition.foodDeleted'));
    } catch (error) {
      _showSnack(_friendlyError(error));
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _friendlyError(Object error) {
    final text = error.toString();
    return text.startsWith('Exception: ') ? text.substring(11) : text;
  }

  bool _isBlank(dynamic value) => value == null || (value is String && value.isEmpty);
}
