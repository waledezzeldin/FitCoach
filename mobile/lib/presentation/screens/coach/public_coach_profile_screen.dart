import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../providers/language_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_button.dart';
import '../../../data/models/public_coach_profile.dart';
import '../../../data/repositories/coach_repository.dart';

class PublicCoachProfileScreen extends StatefulWidget {
  final String coachId;
  final VoidCallback? onMessage;
  final VoidCallback? onBookCall;

  const PublicCoachProfileScreen({
    super.key,
    required this.coachId,
    this.onMessage,
    this.onBookCall,
  });

  @override
  State<PublicCoachProfileScreen> createState() =>
      _PublicCoachProfileScreenState();
}

class _PublicCoachProfileScreenState extends State<PublicCoachProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  PublicCoachProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadProfile();
  }


  void _loadProfile() async {
    try {
      final repo = CoachRepository();
      final profile = await repo.getCoachProfile(coachId: widget.coachId);
      setState(() {
        _profile = _publicFromComprehensive(profile);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _profile = null;
        _isLoading = false;
      });
    }
  }

  // Convert comprehensive CoachProfile to PublicCoachProfile for UI
  PublicCoachProfile _publicFromComprehensive(dynamic profile) {
    // If already PublicCoachProfile, just return
    if (profile is PublicCoachProfile) return profile;
    return PublicCoachProfile(
      id: profile.id,
      fullName: profile.name,
      email: profile.email,
      phoneNumber: profile.phone,
      bio: profile.bio,
      yearsOfExperience: profile.yearsOfExperience,
      specializations: profile.specializations,
      isVerified: profile.isVerified,
      isApproved: true,
      averageRating: profile.stats.avgRating,
      totalClients: profile.stats.totalClients,
      activeClients: profile.stats.activeClients,
      completedSessions: profile.stats.completedSessions,
      successRate: 0, // Not available in backend, set to 0 or compute if possible
      profilePhotoUrl: profile.avatar,
      certificates: (profile.certificates as List).map((e) => Certificate.fromJson(e)).toList(),
      experiences: (profile.experiences as List).map((e) => WorkExperience.fromJson(e)).toList(),
      achievements: (profile.achievements as List).map((e) => Achievement.fromJson(e)).toList(),
      createdAt: DateTime.now(), // Not available, fallback
    );
  }

  PublicCoachProfile _getDemoProfile() {
    return PublicCoachProfile(
      id: widget.coachId,
      fullName: 'Ahmed Hassan',
      email: 'ahmed.hassan@demo.com',
      phoneNumber: '+966 50 123 4567',
      bio:
          'Certified fitness professional with 8+ years of experience in strength training, bodybuilding, and sports nutrition. Specialized in helping clients achieve sustainable fitness transformations.',
      yearsOfExperience: 8,
      specializations: [
        'Strength Training',
        'Bodybuilding',
        'Sports Nutrition',
        'Weight Loss',
        'Muscle Gain'
      ],
      isVerified: true,
      isApproved: true,
      averageRating: 4.8,
      totalClients: 156,
      activeClients: 42,
      completedSessions: 1240,
      successRate: 92.5,
      certificates: [
        Certificate(
          id: '1',
          name: 'Certified Personal Trainer (CPT)',
          issuingOrganization: 'NASM',
          dateObtained: DateTime(2016, 3, 15),
        ),
        Certificate(
          id: '2',
          name: 'Sports Nutrition Specialist',
          issuingOrganization: 'ISSN',
          dateObtained: DateTime(2018, 7, 20),
          expiryDate: DateTime(2025, 7, 20),
        ),
        Certificate(
          id: '3',
          name: 'Corrective Exercise Specialist',
          issuingOrganization: 'NASM',
          dateObtained: DateTime(2019, 11, 10),
        ),
      ],
      experiences: [
        WorkExperience(
          id: '1',
          title: 'Senior Fitness Coach',
          organization: 'Elite Fitness Center',
          startDate: DateTime(2020, 1, 1),
          isCurrent: true,
          description:
              'Lead coach managing high-performance training programs for athletes and fitness enthusiasts.',
        ),
        WorkExperience(
          id: '2',
          title: 'Personal Trainer',
          organization: 'Gold\'s Gym',
          startDate: DateTime(2016, 6, 1),
          endDate: DateTime(2019, 12, 31),
          isCurrent: false,
          description:
              'Provided personalized training and nutrition guidance to 50+ clients.',
        ),
      ],
      achievements: [
        Achievement(
          id: '1',
          title: 'Best Trainer Award 2023',
          description: 'Recognized for outstanding client results',
          date: DateTime(2023, 12, 15),
          type: 'award',
        ),
        Achievement(
          id: '2',
          title: 'Marathon Finisher',
          description: 'Completed Riyadh Marathon 2022',
          date: DateTime(2022, 10, 20),
          type: 'medal',
        ),
      ],
      createdAt: DateTime(2016, 1, 1),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final isArabic = languageProvider.isArabic;

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _profile == null
              ? Center(
                  child: Text(
                    isArabic ? 'فشل تحميل الملف الشخصي' : 'Failed to load profile',
                  ),
                )
              : NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverAppBar(
                        expandedHeight: 280,
                        pinned: true,
                        flexibleSpace: FlexibleSpaceBar(
                          background: _buildHeader(isArabic),
                        ),
                      ),
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _SliverAppBarDelegate(
                          TabBar(
                            controller: _tabController,
                            labelColor: AppColors.primary,
                            unselectedLabelColor: AppColors.textSecondary,
                            indicatorColor: AppColors.primary,
                            tabs: [
                              Tab(text: isArabic ? 'نظرة عامة' : 'Overview'),
                              Tab(text: isArabic ? 'الشهادات' : 'Certificates'),
                              Tab(text: isArabic ? 'الخبرة' : 'Experience'),
                              Tab(text: isArabic ? 'الإنجازات' : 'Achievements'),
                            ],
                          ),
                        ),
                      ),
                    ];
                  },
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(isArabic),
                      _buildCertificatesTab(isArabic),
                      _buildExperienceTab(isArabic),
                      _buildAchievementsTab(isArabic),
                    ],
                  ),
                ),
      bottomNavigationBar: _profile != null && _profile!.isApproved
          ? _buildActionBar(isArabic)
          : null,
    );
  }

  Widget _buildHeader(bool isArabic) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.secondary],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Text(
                    _profile!.initials,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                if (_profile!.isVerified)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _profile!.fullName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text(
                  _profile!.ratingText,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${_profile!.yearsOfExperience} ${isArabic ? 'سنة خبرة' : 'years exp'}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(
                  isArabic ? 'عملاء' : 'Clients',
                  '${_profile!.totalClients}',
                ),
                _buildStatItem(
                  isArabic ? 'جلسات' : 'Sessions',
                  '${_profile!.completedSessions}',
                ),
                _buildStatItem(
                  isArabic ? 'نجاح' : 'Success',
                  '${_profile!.successRate.toStringAsFixed(0)}%',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab(bool isArabic) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bio
          if (_profile!.bio != null) ...[
            Text(
              isArabic ? 'نبذة' : 'About',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            CustomCard(
              child: Text(_profile!.bio!),
            ),
            const SizedBox(height: 24),
          ],

          // Specializations
          Text(
            isArabic ? 'التخصصات' : 'Specializations',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _profile!.specializations.map((spec) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary),
                ),
                child: Text(
                  spec,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Contact Info
          Text(
            isArabic ? 'معلومات التواصل' : 'Contact Information',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          CustomCard(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.email, color: AppColors.primary),
                  title: Text(_profile!.email),
                ),
                if (_profile!.phoneNumber != null)
                  ListTile(
                    leading: const Icon(Icons.phone, color: AppColors.primary),
                    title: Text(_profile!.phoneNumber!),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificatesTab(bool isArabic) {
    return _profile!.certificates.isEmpty
        ? Center(
            child: Text(
              isArabic ? 'لا توجد شهادات' : 'No certificates',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _profile!.certificates.length,
            itemBuilder: (context, index) {
              final cert = _profile!.certificates[index];
              return CustomCard(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.workspace_premium,
                        color: AppColors.primary),
                  ),
                  title: Text(
                    cert.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cert.issuingOrganization),
                      const SizedBox(height: 4),
                      Text(
                        '${_formatDate(cert.dateObtained)}${cert.expiryDate != null ? ' - ${_formatDate(cert.expiryDate!)}' : ''}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: cert.certificateUrl != null
                      ? IconButton(
                          icon: const Icon(Icons.open_in_new),
                          onPressed: () {
                            // Open certificate URL
                          },
                        )
                      : null,
                ),
              );
            },
          );
  }

  Widget _buildExperienceTab(bool isArabic) {
    return _profile!.experiences.isEmpty
        ? Center(
            child: Text(
              isArabic ? 'لا توجد خبرة' : 'No experience',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _profile!.experiences.length,
            itemBuilder: (context, index) {
              final exp = _profile!.experiences[index];
              return CustomCard(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: exp.isCurrent
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.textSecondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.work,
                      color: exp.isCurrent
                          ? AppColors.success
                          : AppColors.textSecondary,
                    ),
                  ),
                  title: Text(
                    exp.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(exp.organization),
                      const SizedBox(height: 4),
                      Text(
                        '${_formatDate(exp.startDate)} - ${exp.isCurrent ? (isArabic ? 'الحالي' : 'Present') : _formatDate(exp.endDate!)} (${exp.duration})',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Text(exp.description),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
  }

  Widget _buildAchievementsTab(bool isArabic) {
    return _profile!.achievements.isEmpty
        ? Center(
            child: Text(
              isArabic ? 'لا توجد إنجازات' : 'No achievements',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _profile!.achievements.length,
            itemBuilder: (context, index) {
              final achievement = _profile!.achievements[index];
              return CustomCard(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getAchievementColor(achievement.type)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getAchievementIcon(achievement.type),
                      color: _getAchievementColor(achievement.type),
                    ),
                  ),
                  title: Text(
                    achievement.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(achievement.description),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(achievement.date),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
  }

  Widget _buildActionBar(bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (widget.onMessage != null)
            Expanded(
              child: CustomButton(
                text: isArabic ? 'رسالة' : 'Message',
                onPressed: widget.onMessage!,
                icon: Icons.message,
              ),
            ),
          if (widget.onMessage != null && widget.onBookCall != null)
            const SizedBox(width: 12),
          if (widget.onBookCall != null)
            Expanded(
              child: CustomButton(
                text: isArabic ? 'حجز مكالمة' : 'Book Call',
                onPressed: widget.onBookCall!,
                icon: Icons.video_call,
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.year}';
  }

  IconData _getAchievementIcon(String type) {
    switch (type) {
      case 'medal':
        return Icons.emoji_events;
      case 'award':
        return Icons.workspace_premium;
      case 'recognition':
        return Icons.star;
      default:
        return Icons.workspace_premium;
    }
  }

  Color _getAchievementColor(String type) {
    switch (type) {
      case 'medal':
        return const Color(0xFFFFD700);
      case 'award':
        return const Color(0xFF9C27B0);
      case 'recognition':
        return AppColors.primary;
      default:
        return AppColors.primary;
    }
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
