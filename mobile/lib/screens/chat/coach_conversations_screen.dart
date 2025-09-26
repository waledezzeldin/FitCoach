import 'package:flutter/material.dart';
import '../../services/chat_service.dart';
import 'chat_thread_screen.dart';
import '../../services/chat_socket_service.dart';
import 'dart:async';

class CoachConversationsScreen extends StatefulWidget {
  const CoachConversationsScreen({super.key});
  @override
  State<CoachConversationsScreen> createState() => _CoachConversationsScreenState();
}

class _CoachConversationsScreenState extends State<CoachConversationsScreen> {
  bool loading = true;
  String? error;
  List<Map<String, dynamic>> items = [];
  final _socket = ChatSocketService();
  StreamSubscription<Map<String, dynamic>>? _subMsg;

  @override
  void initState() {
    super.initState();
    _load();
    _initSocket();
  }

  Future<void> _initSocket() async {
    try {
      await _socket.connect();
      _subMsg = _socket.onMessage.listen((m) {
        // Any new message may change list ordering/unread counts
        if (mounted) _load();
      });
    } catch (_) {
      // ignore socket failures; fallback to manual refresh
    }
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      items = await ChatService().conversations();
    } catch (_) {
      error = 'Failed to load conversations';
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    _subMsg?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
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
                  child: ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final c = items[i];
                      final name = (c['peerName'] ?? c['userName'] ?? c['coachName'] ?? 'Chat').toString();
                      final last = (c['lastMessage'] ?? '').toString();
                      final unread = c['unread'] is num
                          ? (c['unread'] as num).toInt()
                          : int.tryParse('${c['unread']}') ?? 0;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: cs.primary.withOpacity(0.12),
                            child: Icon(Icons.person, color: cs.primary),
                          ),
                          title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(last, maxLines: 1, overflow: TextOverflow.ellipsis),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (unread > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: cs.primary.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '$unread',
                                    style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/chat_thread',
                            arguments: c,
                          ).then((_) => _load()),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}