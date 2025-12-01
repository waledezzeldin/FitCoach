import 'package:flutter/material.dart';

import '../../localization/app_localizations.dart';
import '../../models/quota_models.dart';
import '../../services/coach_service.dart';
import '../../state/app_state.dart';
import '../../widgets/subscription_manager_sheet.dart';

class CoachDashboardScreen extends StatefulWidget {
  const CoachDashboardScreen({super.key, required this.coachId});

  final String coachId;

  @override
  State<CoachDashboardScreen> createState() => _CoachDashboardScreenState();
}

class _CoachDashboardScreenState extends State<CoachDashboardScreen> {
  final _coachService = CoachService();
  final TextEditingController _messageCtrl = TextEditingController();
  final TextEditingController _attachmentCtrl = TextEditingController();
  final GlobalKey _bookingSectionKey = GlobalKey();

  bool _loading = true;
  bool _booking = false;
  bool _sending = false;
  String? _error;
  String? _userId;

  Map<String, dynamic>? _dashboard;
  List<dynamic> _availability = const [];
  List<Map<String, dynamic>> _messages = const [];
  QuotaSnapshot? _quota;
  Map<String, dynamic>? _stats;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final app = AppStateScope.of(context);
    final userId = app.user?['id']?.toString() ?? app.user?['_id']?.toString();
    if (userId != _userId) {
      _userId = userId;
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
      final availability = await _coachService.availability(widget.coachId);
      final messages =
          await _coachService.fetchMessages(widget.coachId, userId: _userId);
      if (!mounted) return;
      setState(() {
        _dashboard = dashboard;
        _availability = (availability['availability'] as List?) ?? const [];
        _messages = messages;
        _quota = dashboard['quota'] is Map
            ? QuotaSnapshot.fromJson(
                Map<String, dynamic>.from(dashboard['quota'] as Map),
              )
            : null;
        _stats = dashboard['stats'] is Map
            ? Map<String, dynamic>.from(dashboard['stats'] as Map)
            : null;
        _loading = false;
      });
      _maybePromptRating();
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = err.toString();
      });
    }
  }

  void _maybePromptRating() {
    final pending =
        _dashboard?['pendingRatingSession'] as Map<String, dynamic>?;
    if (pending == null) return;
    Future.microtask(() => _showRatingDialog(pending['id'] as String));
  }

  Future<void> _showRatingDialog(String sessionId) async {
    int rating = 5;
    final noteCtrl = TextEditingController();
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rate your last session'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StatefulBuilder(
                builder: (context, setModalState) => Column(
                  children: [
                    Slider(
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: rating.toString(),
                      value: rating.toDouble(),
                      onChanged: (value) =>
                          setModalState(() => rating = value.toInt()),
                    ),
                    TextField(
                      controller: noteCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Optional feedback'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Later')),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _submitRating(sessionId, rating, noteCtrl.text.trim());
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitRating(String sessionId, int rating, String note) async {
    if (_userId == null) return;
    try {
      await _coachService.rateSession(
          sessionId: sessionId,
          userId: _userId!,
          rating: rating,
          note: note.isEmpty ? null : note);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thanks for your feedback!')));
      await _load();
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Rating failed: $err')));
    }
  }

  Future<void> _bookSlot(String isoString) async {
    if (_userId == null) return;
    setState(() => _booking = true);
    try {
      await _coachService.bookSession(
        coachId: widget.coachId,
        userId: _userId!,
        start: DateTime.parse(isoString),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Session booked!')));
      await _load();
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Booking failed: $err')));
    } finally {
      if (mounted) setState(() => _booking = false);
    }
  }

  Future<void> _sendMessage() async {
    if (_userId == null ||
        (_messageCtrl.text.isEmpty && _attachmentCtrl.text.isEmpty)) {
      return;
    }
    setState(() => _sending = true);
    try {
      await _coachService.sendMessage(
        coachId: widget.coachId,
        userId: _userId!,
        sender: 'user',
        body:
            _messageCtrl.text.trim().isEmpty ? null : _messageCtrl.text.trim(),
        attachment: _attachmentCtrl.text.trim().isEmpty
            ? null
            : {
                'attachmentUrl': _attachmentCtrl.text.trim(),
                'attachmentName': 'upload',
              },
      );
      _messageCtrl.clear();
      _attachmentCtrl.clear();
      await _load();
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
    final attachmentsAllowed = _dashboard?['attachmentsAllowed'] == true;
    final tier = SubscriptionTierDisplay.parse(app.subscriptionType);
    final upgradeAction = tier == SubscriptionTier.freemium
      ? () => SubscriptionManagerSheet.show(context)
      : null;
    final coach = _dashboard?['coach'] as Map<String, dynamic>?;
    final rating = _dashboard?['rating'] as Map<String, dynamic>?;

    Widget body;
    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      body = Center(child: Text(_error!));
    } else {
      body = RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            _CoachHeroCard(
              coach: coach,
              stats: _stats,
              rating: rating,
              onViewProfile: _openCoachProfile,
              onBook: _scrollToBookingSection,
              onMessage: () => _openMessagingScreen(),
            ),
            if (_quota != null) ...[
              const SizedBox(height: 16),
              _MessageUsageBanner(snapshot: _quota!, onUpgrade: upgradeAction),
            ],
            if (tier == SubscriptionTier.freemium || _quota?.limits.chatAttachments == false) ...[
              const SizedBox(height: 12),
              _UpgradeTipCard(onUpgrade: upgradeAction),
            ],
            const SizedBox(height: 24),
            _clientsSection(l10n),
            const SizedBox(height: 24),
            KeyedSubtree(key: _bookingSectionKey, child: _bookingSection(attachmentsAllowed)),
            const SizedBox(height: 24),
            _messagesSection(attachmentsAllowed),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coach'),
        actions: [
          IconButton(onPressed: _openCoachProfile, icon: const Icon(Icons.verified_user_outlined)),
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: body,
    );
  }

  Widget _clientsSection(AppLocalizations l10n) {
    final sessions = (_dashboard?['upcomingSessions'] as List?)
            ?.cast<Map<String, dynamic>>() ??
        const [];
    if (sessions.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(Icons.calendar_today_outlined, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(l10n.t('coach.noData'), textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.event_available_outlined, color: Colors.teal),
            const SizedBox(width: 8),
            Text(l10n.t('coach.sessions'), style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 12),
        ...sessions.take(5).map((session) => _UpcomingSessionCard(
              session: session,
              onViewClient: () => _openClientDetail(session),
            )),
      ],
    );
  }

  void _openClientDetail(Map<String, dynamic> session) {
    final user = session['user'] as Map<String, dynamic>?;
    final clientId = user?['id']?.toString();
    if (clientId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Client unavailable')));
      return;
    }
    Navigator.of(context).pushNamed(
      '/coach_client_detail',
      arguments: {
        'coachId': widget.coachId,
        'clientId': clientId,
        'clientName': user?['name']?.toString(),
      },
    );
  }

  void _scrollToBookingSection() {
    final ctx = _bookingSectionKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _openCoachProfile() {
    Navigator.of(context).pushNamed('/coach_profile', arguments: {'coachId': widget.coachId});
  }

  Widget _bookingSection(bool _) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.video_call, color: Colors.deepPurple),
            const SizedBox(width: 8),
            Text(l10n.t('coach.bookVideo'), style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            if (_booking)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_availability.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('No open slots this week. Please check back later.',
                  style: Theme.of(context).textTheme.bodyMedium),
            ),
          )
        else
          SizedBox(
            height: 190,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, index) {
                final day = _availability[index] as Map<String, dynamic>;
                final slots = (day['slots'] as List).cast<Map<String, dynamic>>();
                return _BookingDayCard(
                  dateLabel: day['date'] as String,
                  slots: slots,
                  onBook: _booking ? null : (iso) => _bookSlot(iso),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemCount: _availability.length,
            ),
          ),
      ],
    );
  }

  Widget _messagesSection(bool attachmentsAllowed) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.chat_bubble_outline, color: Colors.blue),
            const SizedBox(width: 8),
            Text(l10n.t('coach.messagesTitle'), style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            TextButton(
              onPressed: () => _openMessagingScreen(),
              child: Text(l10n.t('coach.openMessaging')),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.surfaceContainerHighest,
                Theme.of(context).colorScheme.surfaceTint.withValues(alpha: 0.08),
              ],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: _messages.isEmpty
              ? Text(l10n.t('coach.messagesEmpty'))
              : Column(
                  children: [
                    for (final message in _messages)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: _ChatBubble(message: message),
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.t('coach.message'), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
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
                  decoration: InputDecoration(
                    labelText: attachmentsAllowed
                        ? l10n.t('coach.attachmentHint')
                        : l10n.t('coach.attachmentLocked'),
                    border: const OutlineInputBorder(),
                    enabled: attachmentsAllowed,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: _sending ? null : _sendMessage,
                    icon: _sending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                    label: Text(l10n.t('coach.sendMessage')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _openMessagingScreen({String? clientId, String? clientName}) {
    Navigator.of(context).pushNamed(
      '/coach_messaging',
      arguments: {
        'coachId': widget.coachId,
        if (clientId != null) 'clientId': clientId,
        if (clientName != null) 'clientName': clientName,
      },
    );
  }
}

class _CoachHeroCard extends StatelessWidget {
  const _CoachHeroCard({
    required this.coach,
    required this.stats,
    required this.rating,
    required this.onViewProfile,
    required this.onBook,
    required this.onMessage,
  });

  final Map<String, dynamic>? coach;
  final Map<String, dynamic>? stats;
  final Map<String, dynamic>? rating;
  final VoidCallback onViewProfile;
  final VoidCallback onBook;
  final VoidCallback onMessage;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final user = coach?['user'] as Map<String, dynamic>?;
    final name = user?['name']?.toString() ?? 'Coach';
    final initials = _initial(name);
    final verified = coach?['verified'] == true;
    final headline = coach?['headline']?.toString();
    final experienceYears = coach?['experienceYears'];
    final specializations = (coach?['specializations'] as List?)?.cast<String>() ?? const [];
    final averageRating = stats?['averageRating'] as num?;
    final ratingCount = stats?['ratingCount'] as int? ?? rating?['count'] as int? ?? 0;
    final totalClients = stats?['totalClients'];
    final successRate = stats?['successRate'];
    final monthlyRevenue = stats?['monthlyRevenue'] as num?;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [cs.primary, cs.primaryContainer]),
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: cs.onPrimary.withValues(alpha: 0.1),
                child: Text(initials, style: TextStyle(color: cs.onPrimary, fontSize: 20)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(color: cs.onPrimary, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (verified)
                          Row(
                            children: [
                              const Icon(Icons.verified, color: Colors.amber, size: 20),
                              const SizedBox(width: 4),
                              Text(l10n.t('coach.verified'), style: TextStyle(color: cs.onPrimary)),
                            ],
                          ),
                      ],
                    ),
                    if (headline != null)
                      Text(headline, style: TextStyle(color: cs.onPrimary.withValues(alpha: 0.8))),
                    if (averageRating != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 18),
                            const SizedBox(width: 4),
                            Text('${averageRating.toStringAsFixed(1)} · $ratingCount ${l10n.t('coach.reviews')}',
                                style: TextStyle(color: cs.onPrimary)),
                          ],
                        ),
                      ),
                    if (experienceYears != null)
                      Text('${experienceYears.toString()} ${l10n.t('coach.yearsExp')}',
                          style: TextStyle(color: cs.onPrimary.withValues(alpha: 0.8))),
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
              _HeroStatChip(label: l10n.t('coach.totalClients'), value: '$totalClients'),
              _HeroStatChip(label: l10n.t('coach.successRate'), value: successRate != null ? '$successRate%' : '—'),
              _HeroStatChip(
                label: l10n.t('coach.monthlyRevenue'),
                value: monthlyRevenue != null ? _formatCurrency(monthlyRevenue) : '—',
              ),
            ],
          ),
          if (specializations.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: specializations
                  .map((tag) => Chip(
                        label: Text(tag),
                        backgroundColor: cs.onPrimary.withValues(alpha: 0.15),
                        labelStyle: TextStyle(color: cs.onPrimary),
                        visualDensity: VisualDensity.compact,
                      ))
                  .toList(),
            ),
          ],
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final shouldStack = constraints.maxWidth < 600;
              final children = [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onBook,
                    style: FilledButton.styleFrom(
                      backgroundColor: cs.onPrimary,
                      foregroundColor: cs.primary,
                    ),
                    icon: const Icon(Icons.video_call),
                    label: Text(l10n.t('coach.bookVideo')),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onViewProfile,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: cs.onPrimary,
                      side: BorderSide(color: cs.onPrimary.withValues(alpha: 0.4)),
                    ),
                    icon: const Icon(Icons.badge_outlined),
                    label: Text(l10n.t('coach.viewProfile')),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onMessage,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: cs.onPrimary,
                      side: BorderSide(color: cs.onPrimary.withValues(alpha: 0.4)),
                    ),
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: Text(l10n.t('coach.messageCoach')),
                  ),
                ),
              ];
              if (shouldStack) {
                return Column(
                  children: [
                    children[0],
                    const SizedBox(height: 8),
                    children[2],
                    const SizedBox(height: 8),
                    children[4],
                  ],
                );
              }
              return Row(children: children);
            },
          ),
        ],
      ),
    );
  }
}

class _HeroStatChip extends StatelessWidget {
  const _HeroStatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cs.onPrimary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: cs.onPrimary)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: cs.onPrimary.withValues(alpha: 0.8))),
        ],
      ),
    );
  }
}

class _MessageUsageBanner extends StatelessWidget {
  const _MessageUsageBanner({required this.snapshot, this.onUpgrade});

  final QuotaSnapshot snapshot;
  final VoidCallback? onUpgrade;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final limitValue = snapshot.limits.messages;
    final isUnlimited = limitValue == null || (limitValue is String && limitValue.toLowerCase() == 'unlimited');
    final used = snapshot.usage.messagesUsed;
    final limit = isUnlimited
        ? null
        : (limitValue is num
            ? limitValue.toInt()
            : int.tryParse(limitValue.toString()));
    final percent = limit == null || limit == 0 ? 0.0 : (used / limit).clamp(0, 1).toDouble();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_graph, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Text(l10n.t('coach.messagesTitle'), style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                Text(snapshot.tier.label),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: limit == null ? null : percent, minHeight: 8),
            const SizedBox(height: 8),
            Text(
                isUnlimited
                  ? l10n.t('quota.unlimited')
                  : '$used/${limit ?? 0} ${l10n.t('quota.messages')}',
            ),
            if (onUpgrade != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onUpgrade,
                  icon: const Icon(Icons.workspace_premium_outlined),
                  label: Text(l10n.t('quota.upgradeForMore')),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _UpgradeTipCard extends StatelessWidget {
  const _UpgradeTipCard({this.onUpgrade});

  final VoidCallback? onUpgrade;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.lock_open, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(l10n.t('coach.attachmentLocked')),
            ),
            FilledButton(
              onPressed: onUpgrade,
              child: Text(l10n.t('subscription.upgradeButton')), // fallback text
            ),
          ],
        ),
      ),
    );
  }
}

class _UpcomingSessionCard extends StatelessWidget {
  const _UpcomingSessionCard({required this.session, required this.onViewClient});

  final Map<String, dynamic> session;
  final VoidCallback onViewClient;

  @override
  Widget build(BuildContext context) {
    final user = session['user'] as Map<String, dynamic>?;
    final scheduledAt = DateTime.tryParse(session['scheduledAt']?.toString() ?? '');
    final loc = MaterialLocalizations.of(context);
    final label = scheduledAt != null
        ? '${loc.formatMediumDate(scheduledAt)} · ${loc.formatTimeOfDay(TimeOfDay.fromDateTime(scheduledAt))}'
        : '';
    final status = session['status']?.toString();
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(child: Text(_initial(user?['name']?.toString()))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?['name']?.toString() ?? 'Client',
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(label, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                if (status != null)
                  Chip(label: Text(status), visualDensity: VisualDensity.compact),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: onViewClient,
                  icon: const Icon(Icons.remove_red_eye_outlined),
                  label: Text(context.l10n.t('coach.viewClient')),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed('/coach_messaging', arguments: {
                    'coachId': session['coachId'],
                    'clientId': user?['id']?.toString(),
                    'clientName': user?['name']?.toString(),
                  }),
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: Text(context.l10n.t('coach.message')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingDayCard extends StatelessWidget {
  const _BookingDayCard({
    required this.dateLabel,
    required this.slots,
    required this.onBook,
  });

  final String dateLabel;
  final List<Map<String, dynamic>> slots;
  final ValueChanged<String>? onBook;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dateLabel, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemBuilder: (_, index) {
                    final slot = slots[index];
                    return OutlinedButton(
                      onPressed: onBook == null ? null : () => onBook!(slot['iso'] as String),
                      child: Text(slot['label'] as String),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemCount: slots.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final Map<String, dynamic> message;

  @override
  Widget build(BuildContext context) {
    final isUser = message['sender'] == 'user';
    final body = message['body']?.toString() ??
      (message['attachmentUrl'] != null ? 'Attachment' : '');
    final ts = DateTime.tryParse(message['createdAt']?.toString() ?? '')?.toLocal();
    final loc = MaterialLocalizations.of(context);
    final timestamp = ts != null
      ? '${loc.formatShortDate(ts)} · ${loc.formatTimeOfDay(TimeOfDay.fromDateTime(ts))}'
      : '';
    final bubbleColor = isUser
        ? Theme.of(context).colorScheme.primaryContainer
        : Theme.of(context).colorScheme.surfaceContainerHighest;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(body, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(timestamp, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

String _initial(String? value) {
  if (value == null || value.isEmpty) return '?';
  final first = value.runes.isNotEmpty ? value.runes.first : '?'.codeUnitAt(0);
  return String.fromCharCode(first).toUpperCase();
}

String _formatCurrency(num value) {
  final absValue = value.abs();
  num scaled = absValue;
  var suffix = '';
  if (absValue >= 1000000000) {
    scaled = absValue / 1000000000;
    suffix = 'B';
  } else if (absValue >= 1000000) {
    scaled = absValue / 1000000;
    suffix = 'M';
  } else if (absValue >= 1000) {
    scaled = absValue / 1000;
    suffix = 'K';
  }
  final decimals = scaled >= 100 || scaled % 1 == 0 ? 0 : 1;
  final formatted = scaled.toStringAsFixed(decimals);
  final sign = value < 0 ? '-' : '';
  return '$sign\$$formatted$suffix';
}

