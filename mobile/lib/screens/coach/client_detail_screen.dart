import 'package:flutter/material.dart';

import '../../localization/app_localizations.dart';
import '../../models/quota_models.dart';
import '../../services/coach_service.dart';
import '../../widgets/quota_usage_banner.dart';

class CoachClientDetailScreen extends StatefulWidget {
  const CoachClientDetailScreen(
      {super.key,
      required this.coachId,
      required this.clientId,
      this.clientName});

  final String coachId;
  final String clientId;
  final String? clientName;

  @override
  State<CoachClientDetailScreen> createState() =>
      _CoachClientDetailScreenState();
}

class _CoachClientDetailScreenState extends State<CoachClientDetailScreen> {
  final CoachService _service = CoachService();
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _payload;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _service.clientDetail(widget.coachId, widget.clientId);
      if (!mounted) return;
      setState(() {
        _payload = data;
        _loading = false;
      });
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = err.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.clientName ?? l10n.t('coach.clientDetails')),
          actions: [
            IconButton(onPressed: _load, icon: const Icon(Icons.refresh))
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.t('coach.overview')),
              Tab(text: l10n.t('coach.sessions')),
              Tab(text: l10n.t('coach.nutrition')),
            ],
          ),
        ),
        body: _buildBody(l10n),
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    return TabBarView(
      children: [
        _overviewTab(l10n),
        _sessionsTab(l10n),
        _nutritionTab(l10n),
      ],
    );
  }

  Widget _overviewTab(AppLocalizations l10n) {
    final user = _payload?['user'] as Map<String, dynamic>?;
    final quota = _payload?['quota'] is Map
        ? QuotaSnapshot.fromJson(
            Map<String, dynamic>.from(_payload?['quota'] as Map),
          )
        : null;
    final intake = _payload?['intake'] as Map<String, dynamic>?;
    final milestones = _asList(_payload?['milestones']);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ClientHeader(user: user, intake: intake, quota: quota),
        const SizedBox(height: 16),
        if (quota != null)
          QuotaUsageBanner(
            snapshot: quota,
          ),
        if (quota != null) const SizedBox(height: 16),
        _QuickActions(
          onMessage: _openMessaging,
          onCall: _notImplemented(l10n.t('coach.callComingSoon')),
          onAssign: _notImplemented(l10n.t('coach.assignComingSoon')),
        ),
        const SizedBox(height: 16),
        if (milestones.isNotEmpty)
          _MilestonesCard(milestones: milestones, l10n: l10n),
        if (milestones.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.t('coach.noData')),
            ),
          ),
      ],
    );
  }

  Widget _sessionsTab(AppLocalizations l10n) {
    final sessions = _asList(_payload?['sessions']);
    if (sessions.isEmpty) {
      return Center(child: Text(l10n.t('coach.noData')));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (_, index) {
        final session = sessions[index];
        final scheduledAt =
            DateTime.tryParse(session['scheduledAt']?.toString() ?? '');
        final loc = MaterialLocalizations.of(context);
        final dateLabel = scheduledAt != null
            ? '${loc.formatFullDate(scheduledAt)} · ${loc.formatTimeOfDay(TimeOfDay.fromDateTime(scheduledAt))}'
            : '';
        return Card(
          child: ListTile(
            leading: const Icon(Icons.video_call),
            title:
                Text(dateLabel.isEmpty ? l10n.t('coach.sessions') : dateLabel),
            subtitle: Text((session['status'] ?? '').toString()),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: sessions.length,
    );
  }

  Widget _nutritionTab(AppLocalizations l10n) {
    final logs = _asList(_payload?['nutritionLogs']);
    if (logs.isEmpty) {
      return Center(child: Text(l10n.t('coach.noData')));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (_, index) {
        final log = logs[index];
        final date = DateTime.tryParse(log['date']?.toString() ?? '');
        final loc = MaterialLocalizations.of(context);
        final label = date != null ? loc.formatFullDate(date) : '';
        return Card(
          child: ListTile(
            leading: const Icon(Icons.restaurant_menu),
            title: Text(log['meal']?.toString() ?? ''),
            subtitle:
                Text(label.isEmpty ? l10n.t('coach.nutritionLogs') : label),
            trailing: Text('${(log['calories'] as num?)?.toInt() ?? 0} kcal'),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: logs.length,
    );
  }

  VoidCallback _notImplemented(String message) {
    return () {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    };
  }

  List<Map<String, dynamic>> _asList(dynamic source) {
    if (source is List) {
      return source.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return const [];
  }

  void _openMessaging() {
    final user = _payload?['user'] as Map<String, dynamic>?;
    final fallbackName = widget.clientName ?? user?['name']?.toString();
    Navigator.of(context).pushNamed(
      '/coach_messaging',
      arguments: {
        'coachId': widget.coachId,
        'clientId': widget.clientId,
        if (fallbackName != null) 'clientName': fallbackName,
      },
    );
  }
}

class _ClientHeader extends StatelessWidget {
  const _ClientHeader(
      {required this.user, required this.intake, required this.quota});

  final Map<String, dynamic>? user;
  final Map<String, dynamic>? intake;
  final QuotaSnapshot? quota;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const SizedBox.shrink();
    }
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final name = user?['name']?.toString() ?? '';
    final email = user?['email']?.toString() ?? '';
    final goal = intake?['mainGoal']?.toString();
    final tierLabel = quota?.tier.label;
    final lastActive = (user?['lastActiveAt'] as String?);
    final lastActiveDt =
        lastActive != null ? DateTime.tryParse(lastActive) : null;
    final dateText = lastActiveDt != null
        ? MaterialLocalizations.of(context).formatShortDate(lastActiveDt)
        : l10n.t('coach.noData');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(email, style: Theme.of(context).textTheme.bodySmall),
                      if (tierLabel != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                              '${l10n.t('coach.subscription')}: ${tierLabel.toUpperCase()}',
                              style: TextStyle(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _chip(l10n.t('coach.goal'), goal ?? l10n.t('coach.noData'), cs),
                _chip(l10n.t('coach.lastActive').replaceAll('{date}', dateText),
                    '', cs),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, String value, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(color: cs.onSurfaceVariant)),
          if (value.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(value,
                  style: TextStyle(
                      color: cs.primary, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions(
      {required this.onMessage, required this.onCall, required this.onAssign});

  final VoidCallback onMessage;
  final VoidCallback onCall;
  final VoidCallback onAssign;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.t('coach.quickActions'),
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.tonal(
                onPressed: onMessage, child: Text(l10n.t('coach.message'))),
            FilledButton.tonal(
                onPressed: onCall, child: Text(l10n.t('coach.call'))),
            OutlinedButton(
                onPressed: onAssign, child: Text(l10n.t('coach.assignPlan'))),
          ],
        ),
      ],
    );
  }
}

class _MilestonesCard extends StatelessWidget {
  const _MilestonesCard({required this.milestones, required this.l10n});

  final List<Map<String, dynamic>> milestones;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.t('coach.milestones'),
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...milestones.map((milestone) {
              final date =
                  DateTime.tryParse(milestone['achievedAt']?.toString() ?? '');
              final loc = MaterialLocalizations.of(context);
              final label = date != null ? loc.formatFullDate(date) : '';
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.emoji_events_outlined),
                title: Text(milestone['title']?.toString() ?? ''),
                subtitle: Text(label),
              );
            }),
          ],
        ),
      ),
    );
  }
}
