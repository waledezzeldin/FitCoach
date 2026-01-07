import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/message.dart';
import '../../providers/language_provider.dart';
import '../../providers/messaging_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/quota_provider.dart';
import '../booking/video_booking_screen.dart';
import '../../widgets/quota_indicator.dart';
import 'coach_intro_screen.dart';

class CoachMessagingScreen extends StatefulWidget {
  final int initialTabIndex;

  const CoachMessagingScreen({super.key, this.initialTabIndex = 0});

  @override
  State<CoachMessagingScreen> createState() => _CoachMessagingScreenState();
}

class _CoachMessagingScreenState extends State<CoachMessagingScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showIntro = false;
  bool _introLoaded = false;
  
  @override
  void initState() {
    super.initState();
    _loadIntroFlag();
    Future.microtask(() {
      final provider = context.read<MessagingProvider>();
      provider.loadConversations();
      provider.connectSocket();
    });
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadIntroFlag() async {
    final prefs = await SharedPreferences.getInstance();
    final seenIntro = prefs.getBool('coach_intro_seen') ?? false;
    if (mounted) {
      setState(() {
        _showIntro = !seenIntro;
        _introLoaded = true;
      });
    }
  }

  Future<void> _completeIntro() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('coach_intro_seen', true);
    if (mounted) {
      setState(() {
        _showIntro = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final messagingProvider = context.watch<MessagingProvider>();
    final quotaProvider = context.watch<QuotaProvider>();
    final authProvider = context.watch<AuthProvider>();
    final tier = authProvider.user?.subscriptionTier ?? 'Freemium';
    final canAttach = tier == 'Smart Premium';
    final isArabic = languageProvider.isArabic;

    if (!_introLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_showIntro) {
      return CoachIntroScreen(onGetStarted: _completeIntro);
    }
    
    return DefaultTabController(
      length: 2,
      initialIndex: widget.initialTabIndex.clamp(0, 1),
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.8,
                child: Image.asset(
                  'assets/placeholders/splash_onboarding/coach_onboarding.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF4338CA), Color(0xFF6D28D9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.of(context).maybePop(),
                              icon: Icon(
                                isArabic ? Icons.arrow_forward : Icons.arrow_back,
                                color: Colors.white,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    languageProvider.t('coach_messaging'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    languageProvider.t('coach_messaging_subtitle'),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.videocam, color: Colors.white),
                              onPressed: quotaProvider.canMakeVideoCall() ? _openVideoBooking : null,
                              tooltip: languageProvider.t('book_video_call'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildCoachInfoCard(languageProvider, isArabic),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const QuotaBanner(type: 'message'),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: (0.9 * 255)),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              QuotaIndicator(type: 'message', showDetails: false),
                              SizedBox(width: 16),
                              QuotaIndicator(type: 'videoCall', showDetails: false),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: (0.9 * 255)),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: TabBar(
                            labelColor: AppColors.primary,
                            unselectedLabelColor: AppColors.textSecondary,
                            indicatorColor: AppColors.primary,
                            indicatorWeight: 3,
                            tabs: [
                              Tab(text: languageProvider.t('messages')),
                              Tab(text: languageProvider.t('sessions')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildMessagesTab(
                          languageProvider,
                          messagingProvider,
                          quotaProvider,
                          canAttach,
                        ),
                        _buildSessionsTab(languageProvider, quotaProvider),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesTab(
    LanguageProvider lang,
    MessagingProvider messagingProvider,
    QuotaProvider quotaProvider,
    bool canAttach,
  ) {
    return Column(
      children: [
        Expanded(
          child: messagingProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : messagingProvider.messages.isEmpty
                  ? _buildEmptyState(lang, lang.isArabic)
                  : _buildMessagesList(
                      messagingProvider,
                      lang,
                      lang.isArabic,
                    ),
        ),
        _buildMessageInput(
          lang,
          messagingProvider,
          quotaProvider,
          lang.isArabic,
          canAttach,
        ),
      ],
    );
  }

  Widget _buildSessionsTab(LanguageProvider lang, QuotaProvider quotaProvider) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.video_call,
                  size: 64,
                  color: AppColors.primary.withValues(alpha: (0.8 * 255)),
                ),
                const SizedBox(height: 16),
                Text(
                  lang.t('sessions'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  lang.t('book_video_call_hint'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: quotaProvider.canMakeVideoCall() ? _openVideoBooking : null,
                    icon: const Icon(Icons.calendar_month),
                    label: Text(lang.t('book_video_call')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openVideoBooking() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const VideoBookingScreen()),
    );
  }

  Widget _buildCoachInfoCard(LanguageProvider lang, bool isArabic) {
    final coachName = lang.t('coach_demo_name');
    final coachInitials = lang.t('coach_demo_initials');
    final specialties = [
      lang.t('coach_specialty_strength'),
      lang.t('coach_specialty_weight_loss'),
      lang.t('coach_specialty_nutrition'),
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: (0.12 * 255)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: (0.2 * 255))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white.withValues(alpha: (0.25 * 255)),
                child: Text(
                  coachInitials,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coachName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Color(0xFFFBBF24)),
                        const SizedBox(width: 4),
                        const Text(
                          '4.9',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '8 ${lang.t('coach_years')}',
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: specialties
                .map(
                  (specialty) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: (0.2 * 255)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      specialty,
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.star, color: Colors.white, size: 16),
              label: Text(
                lang.t('coach_view_profile'),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white70),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(LanguageProvider lang, bool isArabic) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: AppColors.textDisabled,
          ),
          const SizedBox(height: 24),
          Text(
            lang.t('start_conversation_with_coach'),
            style: const TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            lang.t('ask_questions_about_workouts_nutrition'),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textDisabled,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildMessagesList(
    MessagingProvider provider,
    LanguageProvider lang,
    bool isArabic,
  ) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      reverse: true,
      itemCount: provider.messages.length,
      itemBuilder: (context, index) {
        final message = provider.messages[provider.messages.length - 1 - index];
        return _buildMessageBubble(message, lang, isArabic);
      },
    );
  }
  
  Widget _buildMessageBubble(
    Message message,
    LanguageProvider lang,
    bool isArabic,
  ) {
    final authProvider = context.read<AuthProvider>();
    final isMe = message.senderId == authProvider.user?.id;
    
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: isMe 
              ? CrossAxisAlignment.end 
              : CrossAxisAlignment.start,
          children: [
            // Message bubble
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomRight: isMe ? const Radius.circular(4) : null,
                  bottomLeft: !isMe ? const Radius.circular(4) : null,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.type == 'text')
                    Text(
                      message.content,
                      style: TextStyle(
                        fontSize: 15,
                        color: isMe ? Colors.white : AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  
                  if (message.type == 'image' && message.attachmentUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        message.attachmentUrl!,
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  
                  if (message.type == 'video' && message.attachmentUrl != null)
                    Container(
                      width: 200,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.play_circle_outline,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  
                  if (message.type == 'file' && message.attachmentUrl != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isMe 
                            ? Colors.white.withValues(alpha: 0.2)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.insert_drive_file,
                            color: isMe ? Colors.white : AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              message.content,
                              style: TextStyle(
                                color: isMe ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            
            // Timestamp and status
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.createdAt),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textDisabled,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.status == 'read'
                        ? Icons.done_all
                        : message.status == 'delivered'
                            ? Icons.done_all
                            : Icons.done,
                    size: 14,
                    color: message.status == 'read'
                        ? AppColors.primary
                        : AppColors.textDisabled,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMessageInput(
    LanguageProvider lang,
    MessagingProvider messagingProvider,
    QuotaProvider quotaProvider,
    bool isArabic,
    bool canAttach,
  ) {
    final canSend = quotaProvider.canSendMessage();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (canAttach)
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: canSend ? () => _showAttachmentOptions(lang, isArabic) : null,
              color: AppColors.textSecondary,
            ),
          
          Expanded(
            child: TextField(
              controller: _messageController,
              enabled: canSend,
              decoration: InputDecoration(
                hintText: lang.t('type_a_message'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          
          const SizedBox(width: 8),
          
          IconButton(
            icon: messagingProvider.isSending
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            onPressed: canSend && !messagingProvider.isSending
                ? () => _sendMessage(messagingProvider, quotaProvider)
                : null,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
  
  Future<void> _sendMessage(
    MessagingProvider messagingProvider,
    QuotaProvider quotaProvider,
  ) async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;
    
    _messageController.clear();
    
    final success = await messagingProvider.sendMessage(
      content,
      type: MessageType.text,
    );
    
    if (success) {
      quotaProvider.incrementMessageCount();
      _scrollToBottom();
    } else if (messagingProvider.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(messagingProvider.error!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
  
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
  
  void _showAttachmentOptions(LanguageProvider lang, bool isArabic) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo, color: AppColors.primary),
              title: Text(lang.t('photo')),
              onTap: () {
                Navigator.pop(context);
                _pickAttachment('image');
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam, color: AppColors.secondary),
              title: Text(lang.t('video')),
              onTap: () {
                Navigator.pop(context);
                _pickAttachment('video');
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file, color: AppColors.accent),
              title: Text(lang.t('file')),
              onTap: () {
                Navigator.pop(context);
                _pickAttachment('file');
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _pickAttachment(String type) async {
    // Placeholder for file picker integration
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$type picker - to be implemented'),
      ),
    );
  }
  
  Future<void> _requestVideoCall() async {
    final languageProvider = context.read<LanguageProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(languageProvider.t('request_video_call')),
        content: Text(languageProvider.t('do_you_want_video_call_with_coach')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(languageProvider.t('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(languageProvider.t('request')),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final messagingProvider = context.read<MessagingProvider>();
      final quotaProvider = context.read<QuotaProvider>();
      final success = await messagingProvider.sendMessage(
        languageProvider.t('video_call_request_message'),
        type: MessageType.video,
      );
      if (success && mounted) {
        quotaProvider.incrementMessageCount();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(languageProvider.t('video_call_request_sent')),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }
  
  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${timestamp.day}/${timestamp.month}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
