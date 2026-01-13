import 'package:flutter/material.dart';
import '../../core/config/demo_config.dart';
import '../../data/demo/demo_data.dart';
import '../../data/repositories/messaging_repository.dart';
import '../../data/models/message.dart';
import '../../data/models/coach_client.dart';

class MessagingProvider extends ChangeNotifier {
  final MessagingRepository _repository;
  List<Message> _messages = [];
  List<Conversation> _conversations = [];
  Conversation? _activeConversation;
  bool _isLoading = false;
  bool _isSending = false;
  bool _isConnected = false;
  String? _error;

  String currentChatId = '';

  MessagingProvider(this._repository);

  List<Message> get messages => _messages;
  List<Conversation> get conversations => List.unmodifiable(_conversations);
  Conversation? get activeConversation => _activeConversation;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  bool get isConnected => _isConnected;
  String? get error => _error;

  Future<void> connect(
    String userId,
    String coachId, {
    bool isArabic = false,
  }) async {
    if (DemoConfig.isDemo) {
      currentChatId = '${userId}_$coachId';
      _activeConversation = DemoData.demoConversation(
        userId: userId,
        coachId: coachId,
        isArabic: isArabic,
      );
      _messages = DemoData.chatMessages(
        conversationId: currentChatId,
        isArabic: isArabic,
      );
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

  Future<void> loadConversations({bool isArabic = false}) async {
    if (DemoConfig.isDemo) {
      final List<CoachClient> clients = DemoData.coachClients();
      final demoCoachId = DemoConfig.demoCoachId;
      if (clients.isEmpty) {
        final conversation = DemoData.demoConversation(
          userId: DemoConfig.demoUserId,
          coachId: demoCoachId,
          isArabic: isArabic,
        );
        _conversations = [conversation];
      } else {
        _conversations = clients.asMap().entries.map((entry) {
          final client = entry.value;
          final base = DemoData.demoConversation(
            userId: client.id,
            coachId: demoCoachId,
            isArabic: isArabic,
          );
          final offsetMinutes = entry.key * 9;
          return Conversation(
            id: base.id,
            userId: client.id,
            coachId: base.coachId,
            lastMessageContent: base.lastMessageContent ??
                (isArabic
                    ? 'جاهز للجلسة القادمة؟'
                    : 'Ready for the next check-in?'),
            lastMessageAt: base.lastMessageAt?.subtract(
                  Duration(minutes: offsetMinutes),
                ) ??
                DateTime.now().subtract(Duration(minutes: offsetMinutes + 4)),
            unreadCount: entry.key == 0 ? 2 : 0,
            createdAt: base.createdAt,
            updatedAt:
                base.updatedAt.subtract(Duration(minutes: offsetMinutes)),
          );
        }).toList();
      }

      _activeConversation =
          _conversations.isNotEmpty ? _conversations.first : null;
      currentChatId = _activeConversation?.id ?? '';
      _messages = _activeConversation != null
          ? DemoData.chatMessages(
              conversationId: _activeConversation!.id,
              isArabic: isArabic,
            )
          : [];
      notifyListeners();
      return;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final conversations = await getConversations();
      _conversations = conversations;
      if (conversations.isNotEmpty) {
        await loadConversation(conversations.first.id, isArabic: isArabic);
      } else {
        _activeConversation = null;
        _messages = [];
        currentChatId = '';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadConversation(String conversationId,
      {bool isArabic = false}) async {
    if (DemoConfig.isDemo) {
      final existing = _conversations.firstWhere(
        (c) => c.id == conversationId,
        orElse: () => DemoData.demoConversation(
          userId: DemoConfig.demoUserId,
          coachId: DemoConfig.demoCoachId,
          isArabic: isArabic,
        ),
      );
      _activeConversation = existing;
      currentChatId = conversationId;
      _messages = DemoData.chatMessages(
        conversationId: conversationId,
        isArabic: isArabic,
      );
      notifyListeners();
      return;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final conversation = await _repository.getConversation(conversationId);
      _activeConversation = conversation;
      currentChatId = conversation.id;
      final index = _conversations.indexWhere((c) => c.id == conversation.id);
      if (index != -1) {
        _conversations[index] = conversation;
      }
      final messages = await _repository.getMessages(conversationId);
      _messages = messages;
    } catch (e) {
      _error = e.toString();
      _activeConversation = null;
      _messages = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectConversation(
    String conversationId, {
    bool isArabic = false,
  }) async {
    if (_activeConversation?.id == conversationId && _messages.isNotEmpty) {
      return;
    }
    await loadConversation(conversationId, isArabic: isArabic);
  }

  Message _createLocalMessage(
    String content, {
    String senderId = 'user',
    MessageType type = MessageType.text,
    String? attachmentUrl,
    String? attachmentType,
  }) {
    return Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: currentChatId.isEmpty ? 'local' : currentChatId,
      senderId: senderId,
      receiverId: senderId == 'user' ? 'coach' : 'user',
      content: content,
      type: type,
      attachmentUrl: attachmentUrl,
      attachmentType: attachmentType,
      isRead: false,
      createdAt: DateTime.now(),
    );
  }

  Future<bool> sendMessage(String content,
      {MessageType type = MessageType.text}) async {
    if (DemoConfig.isDemo) {
      final message = _createLocalMessage(
        content,
        senderId: DemoConfig.demoUserId,
        type: type,
      );
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
    } catch (e) {
      _error = e.toString();
      return false;
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
      final message = _createLocalMessage(
        content,
        senderId: DemoConfig.demoUserId,
        type: type,
        attachmentUrl: filePath,
        attachmentType: type.name,
      );
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
          userId: DemoConfig.demoUserId,
          coachId: DemoConfig.demoCoachId,
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
