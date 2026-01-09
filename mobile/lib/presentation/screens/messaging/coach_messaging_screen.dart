import 'package:characters/characters.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/appointment.dart';
import '../../../data/models/message.dart';
import '../../providers/language_provider.dart';
import '../../providers/messaging_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/quota_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/video_call_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/quota_indicator.dart';
import '../booking/appointment_detail_screen.dart';
import '../booking/video_booking_screen.dart';
import '../video_call/video_call_screen.dart';
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
  String? _joiningAppointmentId;
  
  @override
  void initState() {
    super.initState();
    _loadIntroFlag();
    Future.microtask(() async {
      final provider = context.read<MessagingProvider>();
      provider.loadConversations();
      provider.connectSocket();
      await _loadUserAppointments();
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

  Future<void> _loadUserAppointments({bool refresh = false}) async {
    final authProvider = context.read<AuthProvider>();
    final appointmentProvider = context.read<AppointmentProvider>();
    final userId = authProvider.user?.id;
    if (userId == null || userId.isEmpty) {
      return;
    }
    await appointmentProvider.loadUserAppointments(userId: userId, refresh: refresh);
  }

  Future<void> _refreshAppointments() async {
    await _loadUserAppointments(refresh: true);
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
    final appointmentProvider = context.watch<AppointmentProvider>();
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
                        _buildSessionsTab(
                          languageProvider,
                          quotaProvider,
                          appointmentProvider,
                        ),
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

  Widget _buildSessionsTab(
    LanguageProvider lang,
    QuotaProvider quotaProvider,
    AppointmentProvider appointmentProvider,
  ) {
    final isArabic = lang.isArabic;
    final upcoming = appointmentProvider.upcomingAppointments;
    final nextSession = appointmentProvider.nextVideoCall;
    final isLoading = appointmentProvider.isLoading && !appointmentProvider.hasLoaded;

    return RefreshIndicator(
      onRefresh: _refreshAppointments,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        children: [
          _buildSessionsHero(lang),
          const SizedBox(height: 16),
          if (isLoading) ...[
            const SizedBox(height: 80),
            const Center(child: CircularProgressIndicator()),
          ] else ...[
            if (appointmentProvider.error != null)
              CustomCard(
                padding: EdgeInsets.zero,
                color: AppColors.error.withValues(alpha: 0.08),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error),
                    const SizedBox(width: 12),
                    Expanded(child: Text(appointmentProvider.error!)),
                    TextButton(
                      onPressed: _refreshAppointments,
                      child: Text(lang.isArabic ? 'إعادة المحاولة' : 'Retry'),
                    ),
                  ],
                ),
              ),
            if (nextSession != null) ...[
              _buildNextSessionCard(nextSession, lang, isArabic, appointmentProvider),
              const SizedBox(height: 16),
            ],
            _buildUpcomingSessionsList(
              lang,
              isArabic,
              upcoming,
              appointmentProvider,
            ),
          ],
          const SizedBox(height: 24),
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
    );
  }

  Widget _buildSessionsHero(LanguageProvider lang) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: (0.92 * 255)),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.videocam_outlined, color: AppColors.primary, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lang.t('sessions'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  lang.t('book_video_call_hint'),
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextSessionCard(
    Appointment appointment,
    LanguageProvider lang,
    bool isArabic,
    AppointmentProvider provider,
  ) {
    final dateText = _formatSessionDate(appointment, isArabic);
    final countdown = _formatCountdown(appointment, isArabic);
    final canJoin = provider.canJoin(appointment);
    final isVideo = _isVideoSession(appointment);
    final isJoining = _joiningAppointmentId == appointment.id;
    final joinHint = isArabic
        ? 'سيتوفر زر الانضمام قبل 10 دقائق من بداية الجلسة'
        : 'Join opens 10 minutes before the start time';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4338CA), Color(0xFF6D28D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isArabic ? 'المكالمة القادمة' : 'Next video call',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            appointment.coachName ?? lang.t('coach'),
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text(
            dateText,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
          ),
          if (countdown != null) ...[
            const SizedBox(height: 4),
            Text(
              countdown,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
          const SizedBox(height: 16),
          CustomButton(
            text: lang.t('join_video_call'),
            onPressed: (isVideo && canJoin && !isJoining) ? () => _joinVideoCall(appointment) : null,
            isLoading: isJoining,
            fullWidth: true,
            variant: ButtonVariant.secondary,
            size: ButtonSize.large,
          ),
          if (!canJoin && isVideo)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                joinHint,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          TextButton(
            onPressed: () => _openAppointmentDetails(appointment),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: Text(isArabic ? 'تفاصيل الجلسة' : 'Session details'),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingSessionsList(
    LanguageProvider lang,
    bool isArabic,
    List<Appointment> appointments,
    AppointmentProvider provider,
  ) {
    final title = isArabic ? 'جلساتك القادمة' : 'Upcoming sessions';
    if (appointments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: (0.95 * 255)),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            const Icon(Icons.event_available_outlined, size: 40, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(
              isArabic ? 'لا توجد جلسات مجدولة حالياً' : 'No sessions scheduled yet',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              lang.t('book_video_call_hint'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        ...appointments.map(
          (appointment) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildSessionCard(appointment, lang, isArabic, provider),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionCard(
    Appointment appointment,
    LanguageProvider lang,
    bool isArabic,
    AppointmentProvider provider,
  ) {
    final dateText = _formatSessionDate(appointment, isArabic);
    final typeLabel = _typeLabel(appointment, lang);
    final isVideo = _isVideoSession(appointment);
    final canJoin = provider.canJoin(appointment);
    final isJoining = _joiningAppointmentId == appointment.id;
    final hint = isArabic
        ? 'يمكنك الانضمام قبل 10 دقائق من الموعد'
        : 'Join becomes available 10 minutes before the start';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                child: Text(
                  (appointment.coachName ?? lang.t('coach')).characters.take(2).toString().toUpperCase(),
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.coachName ?? lang.t('coach'),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      typeLabel,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(appointment.status, lang),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            dateText,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: lang.t('join_video_call'),
                  onPressed: (isVideo && canJoin && !isJoining) ? () => _joinVideoCall(appointment) : null,
                  isLoading: isJoining,
                  size: ButtonSize.small,
                  fullWidth: true,
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () => _openAppointmentDetails(appointment),
                child: Text(isArabic ? 'التفاصيل' : 'Details'),
              ),
            ],
          ),
          if (!canJoin && isVideo)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                hint,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status, LanguageProvider lang) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        lang.t(status),
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  String _formatSessionDate(Appointment appointment, bool isArabic) {
    final locale = isArabic ? 'ar' : 'en';
    try {
      final date = DateTime.parse(appointment.scheduledAt);
      final formatter = DateFormat('EEEE, MMM d • h:mm a', locale);
      return formatter.format(date);
    } catch (_) {
      return appointment.scheduledAt;
    }
  }

  String? _formatCountdown(Appointment appointment, bool isArabic) {
    try {
      final date = DateTime.parse(appointment.scheduledAt);
      final diff = date.difference(DateTime.now());
      if (diff.isNegative) return null;
      final hours = diff.inHours;
      final minutes = diff.inMinutes.remainder(60);
      if (hours <= 0 && minutes <= 0) {
        return isArabic ? 'يبدأ الآن' : 'Starting now';
      }
      if (hours <= 0) {
        return isArabic ? 'يبدأ بعد $minutes دقيقة' : 'Starts in $minutes min';
      }
      final minutesPart = minutes > 0 ? (isArabic ? ' و $minutes دقيقة' : ' ${minutes}m') : '';
      return isArabic
          ? 'يبدأ بعد $hours ساعة$minutesPart'
          : 'Starts in ${hours}h$minutesPart';
    } catch (_) {
      return null;
    }
  }

  String _typeLabel(Appointment appointment, LanguageProvider lang) {
    switch ((appointment.type ?? 'video').toLowerCase()) {
      case 'video':
        return lang.t('video_call');
      case 'chat':
        return lang.t('chat');
      case 'assessment':
        return lang.t('assessment');
      default:
        return lang.isArabic ? 'جلسة' : 'Session';
    }
  }

  bool _isVideoSession(Appointment appointment) {
    final type = (appointment.type ?? 'video').toLowerCase();
    return type == 'video';
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return AppColors.textSecondary;
    }
  }

  void _openVideoBooking() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const VideoBookingScreen()),
    );
  }

  void _openAppointmentDetails(Appointment appointment) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AppointmentDetailScreen(appointment: appointment),
      ),
    );
  }

  Future<void> _joinVideoCall(Appointment appointment) async {
    final videoCallProvider = context.read<VideoCallProvider>();
    final languageProvider = context.read<LanguageProvider>();

    setState(() => _joiningAppointmentId = appointment.id);

    try {
      final result = await videoCallProvider.canJoinCall(appointment.id);
      if (result == null || result['canJoin'] != true) {
        final message = result?['reason'] ?? languageProvider.t('cannot_join_call');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
        return;
      }

      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VideoCallScreen(
            appointmentId: appointment.id,
            coachId: appointment.coachId,
            coachName: appointment.coachName ?? languageProvider.t('coach'),
            isCoach: false,
          ),
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(languageProvider.t('error'))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _joiningAppointmentId = null);
      }
    }
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
