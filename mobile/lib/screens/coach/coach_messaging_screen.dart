import 'package:flutter/material.dart';

import '../../localization/app_localizations.dart';
import '../../models/quota_models.dart';
import '../../services/coach_service.dart';
import '../../state/app_state.dart';
import '../../widgets/quota_usage_banner.dart';
import '../../widgets/subscription_manager_sheet.dart';

class CoachMessagingScreen extends StatefulWidget {
  const CoachMessagingScreen(
      {super.key,
      required this.coachId,
      this.initialClientId,
      this.initialClientName});

  final String coachId;
  final String? initialClientId;
  final String? initialClientName;

  @override
  State<CoachMessagingScreen> createState() => _CoachMessagingScreenState();
}

class _CoachMessagingScreenState extends State<CoachMessagingScreen> {
  final _coachService = CoachService();
  final _messageCtrl = TextEditingController();
  final _attachmentCtrl = TextEditingController();

  bool _loading = true;
  bool _sending = false;
  bool _attachmentsAllowed = false;
  String? _userId;
  String? _error;
  String? _selectedClientId;
  String? _selectedClientName;

  QuotaSnapshot? _quota;
  List<Map<String, dynamic>> _messages = const [];
  final Map<String, _ClientOption> _knownClients = {};

  @override
  void initState() {
    super.initState();
    _selectedClientId = widget.initialClientId;
    _selectedClientName = widget.initialClientName;
    if (widget.initialClientId != null) {
      _knownClients[widget.initialClientId!] = _ClientOption(
          id: widget.initialClientId!,
          name: widget.initialClientName ?? 'Client');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final app = AppStateScope.of(context);
    final nextUserId =
        app.user?['id']?.toString() ?? app.user?['_id']?.toString();
    if (nextUserId != null && nextUserId != _userId) {
      _userId = nextUserId;
      _load();
    }
  }

  Future<void> _load() async {
    if (_userId == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final dashboard =
          await _coachService.dashboard(widget.coachId, userId: _userId!);
      final messages = await _coachService.fetchMessages(widget.coachId);
      if (!mounted) return;
      setState(() {
        _quota = dashboard['quota'] is Map
            ? QuotaSnapshot.fromJson(
                Map<String, dynamic>.from(dashboard['quota'] as Map),
              )
            : null;
        _attachmentsAllowed = dashboard['attachmentsAllowed'] == true;
        _messages = messages;
        for (final msg in messages) {
          final user = msg['user'] as Map<String, dynamic>?;
          final clientId = user?['id']?.toString();
          if (clientId == null) continue;
          _knownClients[clientId] = _ClientOption(
            id: clientId,
            name: user?['name']?.toString() ?? 'Client',
            email: user?['email']?.toString(),
          );
        }
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

  List<Map<String, dynamic>> get _visibleMessages {
    if (_selectedClientId == null) return _messages;
    return _messages
        .where((message) => message['userId']?.toString() == _selectedClientId)
        .toList();
  }

  Future<void> _sendMessage() async {
    if (_selectedClientId == null) {
      final l10n = context.l10n;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.t('coach.selectClientFirst'))));
      return;
    }
    if (_messageCtrl.text.trim().isEmpty &&
        _attachmentCtrl.text.trim().isEmpty) {
      return;
    }
    setState(() => _sending = true);
    try {
      await _coachService.sendMessage(
        coachId: widget.coachId,
        userId: _selectedClientId!,
        sender: 'coach',
        body:
            _messageCtrl.text.trim().isEmpty ? null : _messageCtrl.text.trim(),
        attachment: _attachmentCtrl.text.trim().isEmpty
            ? null
            : {
                'attachmentUrl': _attachmentCtrl.text.trim(),
                'attachmentName': 'coach_upload',
              },
      );
      _messageCtrl.clear();
      _attachmentCtrl.clear();
      await _load();
      if (_selectedClientId != null &&
          _knownClients.containsKey(_selectedClientId)) {
        _selectedClientName = _knownClients[_selectedClientId!]!.name;
      }
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Message failed: $err')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    _attachmentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final app = AppStateScope.of(context);
    final tier = SubscriptionTierDisplay.parse(app.subscriptionType);
    final upgradeAction = tier == SubscriptionTier.freemium
        ? () => SubscriptionManagerSheet.show(context)
        : null;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('coach.messagesTitle')),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh))
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (_quota != null)
                        QuotaUsageBanner(
                          snapshot: _quota!,
                          onUpgrade: upgradeAction,
                        ),
                      if (_knownClients.isNotEmpty ||
                          _selectedClientId != null) ...[
                        Text(l10n.t('coach.contactClient'),
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        _ClientPicker(
                          options: _knownClients.values.toList(),
                          selectedId: _selectedClientId,
                          fallbackName: _selectedClientName,
                          onSelect: (opt) => setState(() {
                            _selectedClientId = opt?.id;
                            _selectedClientName = opt?.name;
                          }),
                        ),
                        const SizedBox(height: 16),
                      ],
                      _buildMessageList(l10n),
                      const SizedBox(height: 16),
                      _buildComposer(l10n),
                    ],
                  ),
                ),
    );
  }

  Widget _buildMessageList(AppLocalizations l10n) {
    if (_visibleMessages.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Text(l10n.t('coach.messagesEmpty')),
      );
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: _visibleMessages.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final message = _visibleMessages[index];
          final isCoach = message['sender'] == 'coach';
          final ts = DateTime.tryParse(message['createdAt']?.toString() ?? '');
          final subtitle = ts != null
              ? '${MaterialLocalizations.of(context).formatMediumDate(ts)} · ${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(ts))}'
              : '';
          return ListTile(
            leading: CircleAvatar(
                child: Icon(
                    isCoach ? Icons.fitness_center : Icons.person_outline)),
            title: Text(message['body']?.toString() ??
                (message['attachmentUrl'] != null ? 'Attachment' : '')),
            subtitle: Text(subtitle),
            trailing: message['attachmentUrl'] != null
                ? const Icon(Icons.attach_file)
                : null,
          );
        },
      ),
    );
  }

  Widget _buildComposer(AppLocalizations l10n) {
    final quota = _quota;
    final messageLimit = quota?.limits.messages;
    final messagesUsed = quota?.usage.messagesUsed ?? 0;
    double? percent;
    var quotaExceeded = false;
    if (quota != null && messageLimit is num && messageLimit > 0) {
      percent = (messagesUsed / messageLimit).clamp(0, 1).toDouble();
      quotaExceeded = messagesUsed >= messageLimit;
    }
    final tier = SubscriptionTierDisplay.parse(AppStateScope.of(context).subscriptionType);
    final upgradeAction = tier == SubscriptionTier.freemium
        ? () => SubscriptionManagerSheet.show(context)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (percent != null && percent >= 0.8)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(l10n.t('coach.quotaWarning').replaceFirst(
                  '{percent}', ((percent * 100).toInt()).toString())),
            ),
          ),
        if (quotaExceeded)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.t('quota.exceeded'),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Theme.of(context).colorScheme.onErrorContainer),
                  ),
                  if (upgradeAction != null)
                    TextButton(
                      onPressed: upgradeAction,
                      child: Text(l10n.t('quota.upgradePrompt')),
                    ),
                ],
              ),
            ),
          ),
        TextField(
          controller: _messageCtrl,
          minLines: 2,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: l10n.t('coach.messagePlaceholder'),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _attachmentCtrl,
          enabled: _attachmentsAllowed,
          decoration: InputDecoration(
            labelText: _attachmentsAllowed
                ? l10n.t('coach.attachmentHint')
                : l10n.t('coach.attachmentLocked'),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: _sending || quotaExceeded ? null : _sendMessage,
            icon: _sending
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.send),
            label: Text(l10n.t('coach.sendMessage')),
          ),
        ),
      ],
    );
  }
}

class _ClientPicker extends StatelessWidget {
  const _ClientPicker(
      {required this.options,
      required this.selectedId,
      required this.onSelect,
      this.fallbackName});

  final List<_ClientOption> options;
  final String? selectedId;
  final String? fallbackName;
  final ValueChanged<_ClientOption?> onSelect;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty && fallbackName != null) {
      return Chip(label: Text(fallbackName!));
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          label: Text(AppLocalizations.of(context).t('coach.filterAllClients')),
          selected: selectedId == null,
          onSelected: (_) => onSelect(null),
        ),
        for (final option in options)
          ChoiceChip(
            label: Text(option.displayLabel),
            selected: option.id == selectedId,
            onSelected: (_) => onSelect(option),
          ),
      ],
    );
  }
}

class _ClientOption {
  _ClientOption({required this.id, required this.name, this.email});

  final String id;
  final String name;
  final String? email;

  String get displayLabel => email == null ? name : '$name · $email';
}
