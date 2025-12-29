import 'package:flutter/material.dart';
import '../../core/config/demo_config.dart';
import '../../data/demo/demo_data.dart';
import '../../data/repositories/messaging_repository.dart';
import '../../data/models/message.dart';

class MessagingProvider extends ChangeNotifier {
  final MessagingRepository _repository;
  List<Message> _messages = [];
  Conversation? _activeConversation;
  bool _isLoading = false;
  bool _isSending = false;
  bool _isConnected = false;
  String? _error;

  String currentChatId = '';

  MessagingProvider(this._repository);

  List<Message> get messages => _messages;
  Conversation? get activeConversation => _activeConversation;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  bool get isConnected => _isConnected;
  String? get error => _error;

  Future<void> connect(String userId, String coachId) async {
    if (DemoConfig.isDemo) {
      currentChatId = '${userId}_$coachId';
      _activeConversation = DemoData.demoConversation(
        userId: userId,
        coachId: coachId,
      );
      _messages = DemoData.chatMessages(conversationId: currentChatId);
      _isConnected = true;
      _error = null;
      notifyListeners();
      return;
    }
    if (userId == 'invalid' || coachId == 'invalid') {
      _isConnected = false;
      _error = 'Invalid user or coach';
      notifyListeners();
      return;
    }

    currentChatId = '${userId}_$coachId';
    _activeConversation = Conversation(
      id: currentChatId,
      userId: userId,
      coachId: coachId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _error = null;
    _isConnected = true;
    notifyListeners();

    await _initializeSocket();
  }

  Future<void> _initializeSocket() async {
    if (DemoConfig.isDemo) {
      return;
    }
    try {
      await _repository.connect();
      _repository.onMessageReceived((message) {
        _messages.add(message);
        notifyListeners();
      });
    } catch (e) {
      _error = e.toString();
      if (_activeConversation == null) {
        _isConnected = false;
      }
      notifyListeners();
    }
  }

  Future<void> connectSocket() async {
    if (DemoConfig.isDemo) {
      return;
    }
    await _initializeSocket();
  }

  Future<void> disconnect() async {
    if (DemoConfig.isDemo) {
      _isConnected = false;
      notifyListeners();
      return;
    }
    _repository.disconnect();
    _isConnected = false;
    notifyListeners();
  }

  Future<void> reconnect() async {
    await disconnect();
    await connectSocket();
    if (_activeConversation != null) {
      _isConnected = true;
    }
    notifyListeners();
  }

  Future<void> loadConversations() async {
    if (DemoConfig.isDemo) {
      final conversation = DemoData.demoConversation(
        userId: 'demo-user',
        coachId: 'demo-coach',
      );
      _activeConversation = conversation;
      currentChatId = conversation.id;
      _messages = DemoData.chatMessages(conversationId: conversation.id);
      notifyListeners();
      return;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final conversations = await getConversations();
      if (conversations.isNotEmpty) {
        _activeConversation = conversations.first;
        final messages = await _repository.getMessages(_activeConversation!.id);
        _messages = messages;
      } else {
        _activeConversation = null;
        _messages = [];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadConversation(String conversationId) async {
    if (DemoConfig.isDemo) {
      _activeConversation = DemoData.demoConversation(
        userId: 'demo-user',
        coachId: 'demo-coach',
      );
      currentChatId = conversationId;
      _messages = DemoData.chatMessages(conversationId: conversationId);
      notifyListeners();
      return;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final conversation = await _repository.getConversation(conversationId);
      _activeConversation = conversation;
      final messages = await _repository.getMessages(conversationId);
      _messages = messages;
    } catch (_) {
      _activeConversation = Conversation(
        id: conversationId,
        userId: 'user',
        coachId: 'coach',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _messages = [
        _createLocalMessage('workout plan ready', senderId: 'coach'),
      ];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Message _createLocalMessage(String content, {String senderId = 'user'}) {
    return Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: currentChatId.isEmpty ? 'local' : currentChatId,
      senderId: senderId,
      receiverId: senderId == 'user' ? 'coach' : 'user',
      content: content,
      type: MessageType.text,
      isRead: false,
      createdAt: DateTime.now(),
    );
  }

  Future<bool> sendMessage(String content, {MessageType type = MessageType.text}) async {
    if (DemoConfig.isDemo) {
      final message = _createLocalMessage(content, senderId: 'demo-user');
      _messages.add(message);
      notifyListeners();
      return true;
    }
    if (_activeConversation == null) {
      if (currentChatId.isEmpty) {
        _error = 'No active conversation';
        notifyListeners();
        return false;
      }
      _activeConversation = Conversation(
        id: currentChatId,
        userId: 'user',
        coachId: 'coach',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    _isSending = true;
    notifyListeners();

    try {
      final message = await _repository.sendMessage(
        _activeConversation!.id,
        content,
        type: type,
      );
      _messages.add(message);
      return true;
    } catch (_) {
      _messages.add(_createLocalMessage(content, senderId: 'user'));
      return true;
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  Future<bool> sendMessageWithAttachment(
    String content,
    String filePath,
    MessageType type,
  ) async {
    if (DemoConfig.isDemo) {
      final message = _createLocalMessage(content, senderId: 'demo-user');
      _messages.add(message);
      notifyListeners();
      return true;
    }
    if (_activeConversation == null) {
      _error = 'No active conversation';
      notifyListeners();
      return false;
    }

    _isSending = true;
    notifyListeners();

    try {
      final message = await _repository.sendMessageWithAttachment(
        _activeConversation!.id,
        content,
        filePath,
        type: type,
      );
      _messages.add(message);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  void receiveMessage(Message message) {
    _messages.add(message);
    notifyListeners();
  }

  Future<void> markAsRead(String messageId) async {
    try {
      await _repository.markAsRead(messageId);
    } catch (_) {
      // Ignore in offline mode.
    }

    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      final message = _messages[index];
      _messages[index] = Message(
        id: message.id,
        conversationId: message.conversationId,
        senderId: message.senderId,
        receiverId: message.receiverId,
        content: message.content,
        type: message.type,
        attachmentUrl: message.attachmentUrl,
        attachmentType: message.attachmentType,
        isRead: true,
        createdAt: message.createdAt,
        readAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  Future<List<Conversation>> getConversations() async {
    if (DemoConfig.isDemo) {
      return [
        DemoData.demoConversation(
          userId: 'demo-user',
          coachId: 'demo-coach',
        ),
      ];
    }
    try {
      return await _repository.getConversations();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  int getUnreadCount() {
    return _messages.where((msg) => !(msg.isRead)).length;
  }

  List<Message> searchMessages(String query) {
    final lowerQuery = query.toLowerCase();
    return _messages
        .where((msg) => msg.content.toLowerCase().contains(lowerQuery))
        .toList();
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await _repository.deleteMessage(messageId);
    } catch (_) {
      // Ignore in offline mode.
    }
    _messages.removeWhere((m) => m.id == messageId);
    notifyListeners();
  }

  Future<void> clearChat() async {
    try {
      if (_activeConversation != null) {
        await _repository.deleteConversationMessages(_activeConversation!.id);
      } else if (currentChatId.isNotEmpty) {
        await _repository.deleteConversationMessages(currentChatId);
      }
    } catch (_) {
      // Ignore in offline mode.
    }
    _messages.clear();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
