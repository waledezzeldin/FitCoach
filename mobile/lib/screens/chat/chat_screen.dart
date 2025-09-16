import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import '../../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String token;
  final String channelId;
  final List<String> members;

  const ChatScreen({
    super.key,
    required this.userId,
    required this.token,
    required this.channelId,
    required this.members,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _chatService = ChatService();
  Channel? _channel;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    try {
      await _chatService.connectUser(widget.userId, widget.token);

      final channel = _chatService.streamClient.channel(
        'messaging',
        id: widget.channelId,
        extraData: {'members': widget.members},
      );

      await channel.watch();

      if (mounted) {
        setState(() => _channel = channel);
      }
    } catch (e) {
      debugPrint('❌ Chat init failed: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_channel == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return StreamChat(
      client: _chatService.streamClient,
      child: StreamChannel(
        channel: _channel!,
        child: Scaffold(
          appBar: const StreamChannelHeader(),
          body: Column(
            children: [
              Expanded(
                // Here's where MessageListView is used as a widget
                child: StreamMessageListView(
                  // Optionally, you can pass parameters here
                  // For example: thread: null, parentMessage: null
                ),
              ),
              const StreamMessageInput(),
            ],
          ),
        ),
      ),
    );
  }
}