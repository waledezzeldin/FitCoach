import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/chat_socket_service.dart';
import '../../services/chat_service.dart';

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

  // Replace this with your actual user ID retrieval logic
  final String meId = 'CURRENT_USER_ID'; // TODO: Set this to the logged-in user's ID

  bool loading = true;
  String? error;
  List<Map<String, dynamic>> messages = [];
  String? beforeCursor;
  Timer? _poll;

  bool peerTyping = false;
  Timer? _typingDebounce;

  String get convoId => (widget.conversation['id'] ?? widget.conversation['_id']).toString();
  String get title => (widget.conversation['peerName'] ?? widget.conversation['userName'] ?? widget.conversation['coachName'] ?? 'Chat').toString();

  @override
  void initState() {
    super.initState();
    _initSocket();
    _load();
    // Simple polling; replace with WebSocket if available
    _poll = Timer.periodic(const Duration(seconds: 30), (_) => _refreshNew());
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

  Future<void> _loadOlder() async {
    if (beforeCursor == null) return;
    try {
      final older = await _svc.messages(convoId, before: beforeCursor);
      if (older.isEmpty) {
        beforeCursor = null;
      } else {
        messages.addAll(older);
        beforeCursor = older.last['createdAt']?.toString();
        if (mounted) setState(() {});
      }
    } catch (_) {}
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
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to send')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text((widget.conversation?['title'] ?? 'Chat').toString()),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!, style: TextStyle(color: cs.error)))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.all(12),
                        itemCount: messages.length,
                        itemBuilder: (_, i) {
                          final m = messages[i];
                          final mine = m['mine'] == true || (m['senderId'] == meId);
                          final txt = (m['text'] ?? '').toString();

                          return Align(
                            alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: mine
                                    ? cs.primary.withOpacity(0.12)
                                    : cs.surfaceVariant.withOpacity(0.8),
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
                                decoration: const InputDecoration(
                                  hintText: 'Message...',
                                ), // use global InputDecorationTheme
                                onSubmitted: (_) => _send(),
                                onChanged: (v) => _emitTyping?.call(v.isNotEmpty),
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              tooltip: 'Send',
                              icon: Icon(Icons.send, color: cs.primary),
                              onPressed: _send,
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