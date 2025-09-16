import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class ChatService {
  final client = StreamChatClient(
    'STREAM_API_KEY', // replace with your key
    logLevel: Level.INFO,
  );

  Future<void> connectUser(String userId, String token) async {
    await client.connectUser(
      User(id: userId),
      token,
    );
  }

  Future<Channel> createChannel(String channelId, List<String> members) async {
    final channel = client.channel('messaging', id: channelId, extraData: {
      'members': members,
    });
    await channel.create();
    return channel;
  }

  StreamChatClient get streamClient => client;
}
