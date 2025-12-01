import 'dart:async';
import 'package:flutter/material.dart';
import '../../localization/app_localizations.dart';
import '../../models/quota_models.dart';
import '../../services/chat_socket_service.dart';
import '../../services/chat_service.dart';
import '../../state/app_state.dart';
import '../../widgets/quota_usage_banner.dart';
import '../../widgets/subscription_manager_sheet.dart';

class ChatThreadScreen extends StatefulWidget {
  const ChatThreadScreen({super.key, required this.conversation});
  final Map<String, dynamic> conversation;

  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends State<ChatThreadScreen> {
  final _svc = ChatService();
  final _scroll = ScrollController();
  final _input = TextEditingController();
  final _socket = ChatSocketService();

  bool loading = true;
  String? error;
  List<Map<String, dynamic>> messages = [];
  String? beforeCursor;
  Timer? _poll;
  bool _loadingOlder = false;
  bool _requestedQuotaRefresh = false;

  bool peerTyping = false;
  Timer? _typingDebounce;

  String get convoId => (widget.conversation['id'] ?? widget.conversation['_id']).toString();
  String get title => (widget.conversation['peerName'] ?? widget.conversation['userName'] ?? widget.conversation['coachName'] ?? 'Chat').toString();
  String? get _currentUserId {
    final user = AppStateScope.of(context).user;
    final dynamic id = user?['id'] ?? user?['_id'] ?? user?['userId'];
    return id?.toString();
  }

  bool get _isMessageQuotaExceeded {
    final snapshot = AppStateScope.of(context).quotaSnapshot;
    final limit = snapshot?.limits.messages;
    if (snapshot != null && limit is num && limit > 0) {
      return snapshot.usage.messagesUsed >= limit;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_handleScroll);
    _initSocket();
    _load();
    // Simple polling; replace with WebSocket if available
    _poll = Timer.periodic(const Duration(seconds: 30), (_) => _refreshNew());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_requestedQuotaRefresh) {
      _requestedQuotaRefresh = true;
      unawaited(AppStateScope.of(context).refreshQuota());
    }
  }

  Future<void> _initSocket() async {
    try {
      await _socket.connect();
      _socket.joinConversation(convoId);

      _socket.onMessage.listen((m) {
        if (m['conversationId']?.toString() != convoId) return;
        messages.add(m.cast<String, dynamic>());
        if (mounted) setState(() {});
        _jumpToBottom();
        final id = (m['id'] ?? m['_id'] ?? '').toString();
        if (id.isNotEmpty) {
          ChatService().markRead(convoId, lastMessageId: id);
          _socket.emitRead(convoId, id);
        }
      });

      _socket.onTyping.listen((e) {
        if (e['conversationId']?.toString() != convoId) return;
        final isTyping = e['typing'] == true;
        if (!mounted) return;
        setState(() => peerTyping = isTyping);
        _typingDebounce?.cancel();
        if (isTyping) {
          _typingDebounce = Timer(const Duration(seconds: 3), () {
            if (mounted) setState(() => peerTyping = false);
          });
        }
      });
    } catch (_) {
      // fallback to polling only
    }
  }

  @override
  void dispose() {
    _typingDebounce?.cancel();
    _poll?.cancel();
    _scroll.removeListener(_handleScroll);
    _socket.leaveConversation(convoId);
    // do not disconnect globally (other screens may use it)
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { loading = true; error = null; messages.clear(); beforeCursor = null; });
    try {
      final id = convoId;
      if (id.isEmpty) throw Exception('Missing conversation');
      final batch = await _svc.messages(id);
      messages = batch;
      if (batch.isNotEmpty) {
        // Expecting server to sort desc by createdAt; our "older" cursor uses the last item
        beforeCursor = batch.last['createdAt']?.toString();
      }
    } catch (e) {
      error = 'Failed to load messages';
    } finally {
      if (mounted) setState(() => loading = false);
      _jumpToBottom();
    }
  }

  void _handleScroll() {
    if (!_scroll.hasClients) return;
    final threshold = _scroll.position.minScrollExtent + 48;
    if (_scroll.position.pixels <= threshold) {
      _loadOlder();
    }
  }

  Future<void> _loadOlder() async {
    if (beforeCursor == null || _loadingOlder) return;
    _loadingOlder = true;
    try {
      final older = await _svc.messages(convoId, before: beforeCursor);
      if (older.isEmpty) {
        beforeCursor = null;
      } else {
        messages.addAll(older);
        beforeCursor = older.last['createdAt']?.toString();
        if (mounted) setState(() {});
      }
    } catch (_) {
    } finally {
      _loadingOlder = false;
    }
  }

  Future<void> _refreshNew() async {
    if (messages.isEmpty) return _load();
    try {
      // Fetch since last message time if backend supports; else reload
      await _load();
    } catch (_) {}
  }

  void _jumpToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }

  void _emitTyping(bool v) {
    _socket.emitTyping(convoId, v);
  }

  Future<void> _markReadLatest() async {
    if (messages.isEmpty) return;
    final last = messages.last;
    final id = (last['id'] ?? last['_id'] ?? '').toString();
    if (id.isEmpty) return;
    await ChatService().markRead(convoId, lastMessageId: id);
    _socket.emitRead(convoId, id);
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    if (_isMessageQuotaExceeded) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.l10n.t('quota.exceeded'))));
      return;
    }
    _input.clear();

    // Optimistic append
    final tempMsg = {
      'id': 'local-${DateTime.now().millisecondsSinceEpoch}',
      'text': text,
      'mine': true,
      'createdAt': DateTime.now().toIso8601String(),
    };
    messages.add(tempMsg);
    if (mounted) setState(() {});
    _jumpToBottom();

    try {
      // Prefer socket; backend should broadcast back canonical message
      _socket.sendMessage(convoId, text);
      // Also call REST as fallback
      await _svc.send(convoId, text); // FIX: pass text as positional arg
      await _markReadLatest();
      unawaited(AppStateScope.of(context).refreshQuota(force: true));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = context.l10n;
    final currentUserId = _currentUserId;
    final app = AppStateScope.of(context);
    final quota = app.quotaSnapshot;
    final tier = SubscriptionTierDisplay.parse(app.subscriptionType);
    final upgradeAction = tier == SubscriptionTier.freemium ? () => SubscriptionManagerSheet.show(context) : null;
    final dynamic messageLimit = quota?.limits.messages;
    final int? messageLimitValue = messageLimit is num && messageLimit > 0 ? messageLimit.toInt() : null;
    final int messagesUsed = quota?.usage.messagesUsed ?? 0;
    final double? usagePercent = messageLimitValue != null && messageLimitValue > 0
        ? (messagesUsed / messageLimitValue).clamp(0, 1).toDouble()
        : null;
    final bool quotaExceeded = messageLimitValue != null && messagesUsed >= messageLimitValue;
    final bool showQuotaWarning = usagePercent != null && usagePercent >= 0.8 && !quotaExceeded;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!, style: TextStyle(color: cs.error)))
              : Column(
                  children: [
                    if (quota != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                        child: QuotaUsageBanner(
                          snapshot: quota,
                          onUpgrade: upgradeAction,
                          margin: EdgeInsets.zero,
                        ),
                      ),
                    if ((showQuotaWarning || quotaExceeded) && quota != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                        child: _QuotaNotice(
                          quotaExceeded: quotaExceeded,
                          percent: usagePercent,
                          onUpgrade: upgradeAction,
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.all(12),
                        itemCount: messages.length,
                        itemBuilder: (_, i) {
                          final m = messages[i];
                          final mine = m['mine'] == true ||
                              (currentUserId != null && m['senderId']?.toString() == currentUserId);
                          final txt = (m['text'] ?? '').toString();

                          return Align(
                            alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: mine
                                    ? cs.primary.withValues(alpha: 0.12)
                                    : cs.surfaceContainerHighest.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(txt, style: TextStyle(color: cs.onSurface)),
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _input,
                                enabled: !quotaExceeded,
                                decoration: InputDecoration(
                                  hintText: l10n.t('coach.messagePlaceholder'),
                                ), // use global InputDecorationTheme
                                onSubmitted: (_) {
                                  if (!quotaExceeded) _send();
                                },
                                onChanged:
                                    quotaExceeded ? null : (v) => _emitTyping(v.isNotEmpty),
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              tooltip: 'Send',
                              icon: Icon(Icons.send, color: cs.primary),
                              onPressed: quotaExceeded ? null : _send,
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

class _QuotaNotice extends StatelessWidget {
  const _QuotaNotice({
    required this.quotaExceeded,
    required this.percent,
    this.onUpgrade,
  });

  final bool quotaExceeded;
  final double? percent;
  final VoidCallback? onUpgrade;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bgColor = quotaExceeded
      ? colorScheme.errorContainer
      : Colors.orange.withValues(alpha: 0.12);
    final textColor = quotaExceeded ? colorScheme.onErrorContainer : Colors.orange.shade900;
    final icon = quotaExceeded ? Icons.lock : Icons.warning_amber_rounded;
    final percentValue = ((percent ?? 0) * 100).clamp(0, 100).round();
    final subtitle = quotaExceeded
        ? l10n.t('quota.upgradeForMore')
        : l10n.t('coach.quotaWarning').replaceFirst('{percent}', percentValue.toString());

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quotaExceeded ? l10n.t('quota.exceeded') : l10n.t('quota.runningLow'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                        color: textColor.withValues(alpha: 0.9),
                      ),
                ),
                if (onUpgrade != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: onUpgrade,
                      child: Text(l10n.t('quota.upgradePrompt')),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}