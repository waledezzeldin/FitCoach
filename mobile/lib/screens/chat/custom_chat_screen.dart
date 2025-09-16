// lib/screens/chat/custom_chat_screen.dart
import 'package:flutter/material.dart';
import 'package:stream_chat/stream_chat.dart';
import '../../services/chat_service.dart';

class CustomChatScreen extends StatefulWidget {
  final String userId;
  final String token;
  final String channelId;
  final List<String> members;

  const CustomChatScreen({
    super.key,
    required this.userId,
    required this.token,
    required this.channelId,
    required this.members,
  });

  @override
  State<CustomChatScreen> createState() => _CustomChatScreenState();
}

class _CustomChatScreenState extends State<CustomChatScreen> {
  final _chatService = ChatService();
  Channel? _channel;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    try {
      await _chatService.connectUser(widget.userId, widget.token);
      final client = _chatService.streamClient;
      final channel = client.channel('messaging', id: widget.channelId, extraData: {'members': widget.members});
      await channel.watch();

      // Listen for new events to rebuild UI
      client.on(EventType.messageNew).listen((event) {
        if (mounted) setState(() {});
      });

      if (mounted) setState(() => _channel = channel);
    } catch (e) {
      debugPrint('Chat init failed: $e');
    }
  }

  List<Message> _messages() {
    return _channel?.state?.messages.reversed.toList() ?? [];
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _channel == null) return;
    try {
      final message = Message(text: text);
      await _channel!.sendMessage(message);
      _textController.clear();
      setState(() {}); // rebuild to show message optimistically
    } catch (e) {
      debugPrint('Send failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_channel == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final msgs = _messages();

    return Scaffold(
      appBar: AppBar(title: Text('Chat - ${widget.channelId}')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: msgs.length,
              itemBuilder: (context, index) {
                final m = msgs[index];
                final isMe = m.user?.id == widget.userId;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue.shade200 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(m.text ?? ''),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: TextField(
                      controller: _textController,
                      decoration: const InputDecoration(hintText: 'Type a message...'),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
