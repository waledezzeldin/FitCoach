import 'package:stream_chat/stream_chat.dart';

import '../config/env.dart';
import '../demo/demo_data.dart';
import 'api_service.dart';

class ChatService {
  ChatService._();
  static final ChatService _instance = ChatService._();
  factory ChatService() => _instance;

  StreamChatClient? _client;
  final _api = ApiService();

  // Expose initialized client
  StreamChatClient get streamClient {
    final c = _client;
    if (c == null) {
      throw StateError('StreamChatClient not initialized. Call connectUser first.');
    }
    return c;
  }

  // Connect current user to Stream Chat
  Future<void> connectUser(String userId, String token, {String? apiKey}) async {
    final key = apiKey ?? const String.fromEnvironment('STREAM_API_KEY', defaultValue: '');
    if (key.isEmpty) {
      throw StateError('STREAM_API_KEY not set. Pass apiKey or run with --dart-define=STREAM_API_KEY=your_key');
    }

    _client ??= StreamChatClient(key, logLevel: Level.INFO);

    // If already connected as same user, skip
    if (_client!.state.currentUser?.id == userId) return;

    // If connected as another user, disconnect first
    if (_client!.state.currentUser != null && _client!.state.currentUser!.id != userId) {
      await _client!.disconnectUser();
    }

    await _client!.connectUser(User(id: userId), token);
  }

  Future<void> disconnect() async {
    await _client?.disconnectUser();
    _client?.dispose();
    _client = null;
  }

  // For user: open conversation with assigned coach
  Future<Map<String, dynamic>> assignedConversation() async {
    try {
      final res = await _api.dio.get('/chat/assigned');
      return (res.data as Map).cast<String, dynamic>();
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Failed to open chat'));
    }
  }

  // For coach: list conversations with assigned users
  Future<List<Map<String, dynamic>>> conversations({int page = 1, int pageSize = 20}) async {
    if (Env.demo) return List<Map<String, dynamic>>.from(DemoData.conversations);
    try {
      final res = await _api.dio.get('/chat/conversations', queryParameters: {
        'page': page,
        'pageSize': pageSize,
      });
      return (res.data as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Failed to load conversations'));
    }
  }

  // Messages in a conversation (paged by "before" cursor = ISO timestamp or message id)
  Future<List<Map<String, dynamic>>> messages(String conversationId, {String? before}) async {
    if (Env.demo) return List<Map<String, dynamic>>.from(DemoData.messages[conversationId] ?? []);
    try {
      final res = await _api.dio.get('/chat/conversations/$conversationId/messages', queryParameters: {
        if (before != null) 'before': before,
      });
      return (res.data as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Failed to load messages'));
    }
  }

  // Send a text message
  Future<void> send(String conversationId, String text) async {
    if (Env.demo) {
      (DemoData.messages[conversationId] ??= []).add({'id': DateTime.now().toIso8601String(), 'sender': 'me', 'text': text});
      return;
    }
    try {
      final res = await _api.dio.post('/chat/conversations/$conversationId/messages', data: {'text': text});
      // No need to return anything since the return type is Future<void>
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Failed to send message'));
    }
  }

  // Mark conversation as read
  Future<void> markRead(String conversationId, {required String lastMessageId}) async {
    try {
      await _api.dio.post('/chat/conversations/$conversationId/read', data: {'lastMessageId': lastMessageId});
    } catch (e) {
      // ignore
    }
  }
}
