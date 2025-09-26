import 'package:flutter/material.dart';
import 'chat_thread_screen.dart';
import '../../services/chat_service.dart';

class AssignedChatScreen extends StatefulWidget {
  const AssignedChatScreen({super.key});

  @override
  State<AssignedChatScreen> createState() => _AssignedChatScreenState();
}

class _AssignedChatScreenState extends State<AssignedChatScreen> {
  bool loading = true;
  String? error;
  Map<String, dynamic>? convo;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { loading = true; error = null; });
    try {
      convo = await ChatService().assignedConversation();
    } catch (_) {
      error = 'Failed to load chat';
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text((convo?['title'] ?? 'Chat').toString()),
      ),
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
              : ChatThreadScreen(conversation: convo!), // keep your thread widget
    );
  }
}