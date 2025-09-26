import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import 'assigned_chat_screen.dart';
import 'coach_conversations_screen.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final role = AppStateScope.of(context).role ?? 'user';
    return role == 'coach' ? const CoachConversationsScreen() : const AssignedChatScreen();
  }
}