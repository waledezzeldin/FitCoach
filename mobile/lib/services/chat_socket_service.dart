import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'api_service.dart';

class ChatSocketService {
  ChatSocketService._();
  static final ChatSocketService _i = ChatSocketService._();
  factory ChatSocketService() => _i;

  IO.Socket? _socket;
  bool get connected => _socket?.connected == true;

  final _messageCtrl = StreamController<Map<String, dynamic>>.broadcast();
  final _typingCtrl = StreamController<Map<String, dynamic>>.broadcast();
  final _readCtrl = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get onMessage => _messageCtrl.stream;
  Stream<Map<String, dynamic>> get onTyping => _typingCtrl.stream;
  Stream<Map<String, dynamic>> get onRead => _readCtrl.stream;

  Future<void> connect({String? urlOverride}) async {
    if (connected) return;
    final api = ApiService();
    final token = await api.getAccessToken();

    // Build origin from Dio baseUrl
    final httpBase = api.dio.options.baseUrl; // e.g. https://api.example.com/v1
    if (httpBase.isEmpty) {
      throw StateError('Api baseUrl is not set');
    }
    final baseUri = Uri.parse(httpBase);
    final scheme = baseUri.scheme == 'https' ? 'wss' : 'ws';
    final origin = Uri(
      scheme: scheme,
      host: baseUri.host,
      port: baseUri.hasPort ? baseUri.port : null,
      // adjust path if your socket endpoint is different (e.g. '/socket.io/')
      path: '/', // default path; socket_io_client will use its default '/socket.io/'
    ).toString();

    final url = urlOverride ?? origin;

    final sock = IO.io(
      url,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .enableReconnection()
          .setReconnectionDelay(500)
          // .setPath('/socket.io') // uncomment if your server uses a non-default path
          .build(),
    );

    sock.onConnect((_) {});
    sock.onDisconnect((_) {});
    sock.on('message:new', (data) {
      if (data is Map) _messageCtrl.add(data.cast<String, dynamic>());
    });
    sock.on('typing', (data) {
      if (data is Map) _typingCtrl.add(data.cast<String, dynamic>());
    });
    sock.on('read', (data) {
      if (data is Map) _readCtrl.add(data.cast<String, dynamic>());
    });

    _socket = sock;
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  void joinConversation(String conversationId) {
    _socket?.emit('conversation:join', {'id': conversationId});
  }

  void leaveConversation(String conversationId) {
    _socket?.emit('conversation:leave', {'id': conversationId});
  }

  void sendMessage(String conversationId, String text) {
    _socket?.emit('message:send', {'conversationId': conversationId, 'text': text});
  }

  void emitTyping(String conversationId, bool isTyping) {
    _socket?.emit('typing', {'conversationId': conversationId, 'typing': isTyping});
  }

  void emitRead(String conversationId, String lastMessageId) {
    _socket?.emit('read', {'conversationId': conversationId, 'lastMessageId': lastMessageId});
  }
}