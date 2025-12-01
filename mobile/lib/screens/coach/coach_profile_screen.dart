import 'package:flutter/material.dart';

import '../../localization/app_localizations.dart';
import '../../services/coach_service.dart';
import '../../state/app_state.dart';

class CoachProfileScreen extends StatefulWidget {
  const CoachProfileScreen({super.key, required this.coachId});

  final String coachId;

  @override
  State<CoachProfileScreen> createState() => _CoachProfileScreenState();
}

class _CoachProfileScreenState extends State<CoachProfileScreen> {
  final _coachService = CoachService();

  bool _loading = true;
  String? _error;
  String? _userId;

  Map<String, dynamic>? _coach;
  Map<String, dynamic>? _stats;
  Map<String, dynamic>? _contact;
  List<Map<String, dynamic>> _certificates = const [];
  List<Map<String, dynamic>> _experiences = const [];
  List<Map<String, dynamic>> _achievements = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final app = AppStateScope.of(context);
    final userId = app.user?['id']?.toString() ?? app.user?['_id']?.toString();
    if (_userId != userId) {
      _userId = userId;
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profile = await _coachService.profile(widget.coachId, userId: _userId);
      if (!mounted) return;
      setState(() {
        _coach = profile['coach'] is Map
            ? Map<String, dynamic>.from(profile['coach'] as Map)
            : null;
        _stats = profile['stats'] is Map
            ? Map<String, dynamic>.from(profile['stats'] as Map)
            : null;
        _contact = profile['contact'] is Map
            ? Map<String, dynamic>.from(profile['contact'] as Map)
            : null;
        _certificates = _mapList(profile['certificates']);
        _experiences = _mapList(profile['experiences']);
        _achievements = _mapList(profile['achievements']);
        _loading = false;
      });
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = err.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.t('coach.myProfile')),
          actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))],
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.t('coach.myProfile')),
          actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _load,
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.t('common.retry')),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.t('coach.myProfile')),
          actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))],
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: l10n.t('coach.overview')),
              Tab(text: l10n.t('coach.certificates')),
              Tab(text: l10n.t('coach.experience')),
              Tab(text: l10n.t('coach.achievements')),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _overviewTab(l10n),
            _certificatesTab(l10n),
            _experienceTab(l10n),
            _achievementsTab(l10n),
          ],
        ),
      ),
    );
  }

  Widget _overviewTab(AppLocalizations l10n) {
    final bio = _coach?['bio']?.toString();
    final specializations = (_coach?['specializations'] as List?)
            ?.whereType<String>()
            .where((value) => value.trim().isNotEmpty)
            .toList() ??
        const [];

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Text(
            l10n.t('coach.professionalProfile'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          _ProfileHeroCard(coach: _coach, stats: _stats, specializations: specializations, l10n: l10n),
          const SizedBox(height: 16),
          _QuickStatGrid(stats: _stats, l10n: l10n),
          const SizedBox(height: 16),
          if (bio != null && bio.isNotEmpty)
            _SectionCard(
              icon: Icons.person_outline,
              title: l10n.t('coach.bio'),
              child: Text(bio),
            ),
          if ((bio == null || bio.isEmpty))
            _SectionCard(
              icon: Icons.person_outline,
              title: l10n.t('coach.bio'),
              child: Text(l10n.t('coach.noData')),
            ),
          if (_contact?['email'] != null || _contact?['phone'] != null) ...[
            const SizedBox(height: 16),
            _SectionCard(
              icon: Icons.call_outlined,
              title: l10n.t('coach.contactInfo'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_contact?['email'] != null) ...[
                    Text(l10n.t('account.email'), style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(height: 4),
                    Text(_contact!['email'].toString()),
                    const SizedBox(height: 12),
                  ],
                  if (_contact?['phone'] != null) ...[
                    Text(l10n.t('account.phone'), style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(height: 4),
                    Text(_contact!['phone'].toString()),
                  ],
                ],
              ),
            ),
          ],
          if (specializations.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionCard(
              icon: Icons.local_fire_department_outlined,
              title: l10n.t('coach.specializations'),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final tag in specializations)
                    Chip(label: Text(tag)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _certificatesTab(AppLocalizations l10n) {
    if (_certificates.isEmpty) {
      return _emptyTab(l10n.t('coach.myCertificates'), l10n.t('coach.noData'));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemBuilder: (context, index) {
          final cert = _certificates[index];
          return _CertificateCard(cert: cert, l10n: l10n);
        },
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: _certificates.length,
      ),
    );
  }

  Widget _experienceTab(AppLocalizations l10n) {
    if (_experiences.isEmpty) {
      return _emptyTab(l10n.t('coach.workExperience'), l10n.t('coach.noData'));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemBuilder: (context, index) {
          final exp = _experiences[index];
          return _ExperienceCard(exp: exp, l10n: l10n);
        },
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: _experiences.length,
      ),
    );
  }

  Widget _achievementsTab(AppLocalizations l10n) {
    if (_achievements.isEmpty) {
      return _emptyTab(l10n.t('coach.myAchievements'), l10n.t('coach.noData'));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemBuilder: (context, index) {
          final achievement = _achievements[index];
          return _AchievementCard(achievement: achievement);
        },
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: _achievements.length,
      ),
    );
  }

  Widget _emptyTab(String title, String message) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          _EmptyStateCard(title: title, message: message),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _mapList(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    return <Map<String, dynamic>>[];
  }
}

class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({required this.coach, required this.stats, required this.specializations, required this.l10n});

  final Map<String, dynamic>? coach;
  final Map<String, dynamic>? stats;
  final List<String> specializations;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final user = coach?['user'] as Map<String, dynamic>?;
    final name = user?['name']?.toString() ?? 'Coach';
    final email = user?['email']?.toString();
    final verified = coach?['verified'] == true;
    final experienceYears = coach?['experienceYears'];
    final activeClients = stats?['activeClients'];
    final rating = stats?['averageRating'];
    final ratingCount = stats?['ratingCount'];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 32,
                  child: Text(_initial(name)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          if (verified)
                            Chip(
                              avatar: const Icon(Icons.verified_outlined, size: 18),
                              label: Text(l10n.t('coach.verified')),
                            ),
                        ],
                      ),
                      if (email != null) ...[
                        const SizedBox(height: 4),
                        Text(email, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          if (rating != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text('${rating.toStringAsFixed(1)} (${ratingCount ?? 0} ${l10n.t('coach.reviews')})'),
                              ],
                            ),
                          if (activeClients != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.people_alt_outlined),
                                const SizedBox(width: 4),
                                Text('${activeClients.toString()} ${l10n.t('coach.activeClients')}'),
                              ],
                            ),
                          if (experienceYears != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.timelapse_outlined),
                                const SizedBox(width: 4),
                                Text('$experienceYears ${l10n.t('coach.yearsExp')}'),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (specializations.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final item in specializations.take(4))
                    Chip(label: Text(item)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuickStatGrid extends StatelessWidget {
  const _QuickStatGrid({required this.stats, required this.l10n});

  final Map<String, dynamic>? stats;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final data = [
      _StatMeta(icon: Icons.people_outline, label: l10n.t('coach.totalClients'), value: _formatNumber(stats?['totalClients'])),
      _StatMeta(icon: Icons.calendar_month_outlined, label: l10n.t('coach.sessions'), value: _formatNumber(stats?['completedSessions'])),
      _StatMeta(icon: Icons.trending_up_outlined, label: l10n.t('coach.successRate'), value: _formatPercent(stats?['successRate'])),
      _StatMeta(icon: Icons.payments_outlined, label: l10n.t('coach.monthlyRevenue'), value: _formatCurrency(stats?['monthlyRevenue'])),
    ];

    return GridView.builder(
      shrinkWrap: true,
      itemCount: data.length,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.4,
      ),
      itemBuilder: (context, index) {
        final item = data[index];
        return _StatTile(meta: item);
      },
    );
  }
}

class _StatMeta {
  const _StatMeta({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.meta});

  final _StatMeta meta;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: cs.primaryContainer.withValues(alpha: 0.25),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(meta.icon, color: cs.primary),
          const SizedBox(height: 8),
          Text(meta.value, style: Theme.of(context).textTheme.titleLarge),
          Text(meta.label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.icon, required this.title, required this.child});

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _CertificateCard extends StatelessWidget {
  const _CertificateCard({required this.cert, required this.l10n});

  final Map<String, dynamic> cert;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final issuedAt = DateTime.tryParse(cert['issuedAt']?.toString() ?? '');
    final expiresAt = DateTime.tryParse(cert['expiresAt']?.toString() ?? '');
    final loc = MaterialLocalizations.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.workspace_premium_outlined),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cert['name']?.toString() ?? '-', style: Theme.of(context).textTheme.titleMedium),
                      if (cert['issuingOrganization'] != null)
                        Text(cert['issuingOrganization'].toString(), style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('${l10n.t('coach.issued')}: ${issuedAt != null ? loc.formatMediumDate(issuedAt) : l10n.t('coach.noData')}'),
            if (expiresAt != null)
              Text('${l10n.t('coach.expires')}: ${loc.formatMediumDate(expiresAt)}'),
            if (cert['certificateUrl'] != null) ...[
              const SizedBox(height: 12),
              Text(cert['certificateUrl'].toString(), style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

class _ExperienceCard extends StatelessWidget {
  const _ExperienceCard({required this.exp, required this.l10n});

  final Map<String, dynamic> exp;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final loc = MaterialLocalizations.of(context);
    final start = DateTime.tryParse(exp['startDate']?.toString() ?? '');
    final end = DateTime.tryParse(exp['endDate']?.toString() ?? '');
    final isCurrent = exp['isCurrent'] == true;
    final timeline = [
      start != null ? loc.formatMediumDate(start) : null,
      isCurrent
          ? l10n.t('coach.present')
          : (end != null ? loc.formatMediumDate(end) : null),
    ].whereType<String>().join(' • ');

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(isCurrent ? Icons.flag_circle_outlined : Icons.work_outline),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(exp['title']?.toString() ?? '-', style: Theme.of(context).textTheme.titleMedium),
                      if (exp['organization'] != null)
                        Text(exp['organization'].toString(), style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                if (isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(l10n.t('coach.current')),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(timeline.isEmpty ? l10n.t('coach.noData') : timeline),
            if (exp['description'] != null && exp['description'].toString().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(exp['description'].toString()),
            ],
          ],
        ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.achievement});

  final Map<String, dynamic> achievement;

  @override
  Widget build(BuildContext context) {
    final loc = MaterialLocalizations.of(context);
    final date = DateTime.tryParse(achievement['achievedAt']?.toString() ?? '');
    final icon = _achievementIcon(achievement['type']?.toString());

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(achievement['title']?.toString() ?? '-', style: Theme.of(context).textTheme.titleMedium),
                  if (achievement['description'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(achievement['description'].toString()),
                    ),
                  if (date != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(loc.formatMediumDate(date)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, size: 48),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

String _initial(String value) {
  if (value.isEmpty) return '?';
  final first = value.runes.isNotEmpty ? value.runes.first : '?'.codeUnitAt(0);
  return String.fromCharCode(first).toUpperCase();
}

String _formatNumber(dynamic value) {
  if (value is num) return value.toStringAsFixed(0);
  return '—';
}

String _formatPercent(dynamic value) {
  if (value is num) return '${value.toStringAsFixed(0)}%';
  return '—';
}

String _formatCurrency(dynamic value) {
  if (value is! num) return '—';
  final absValue = value.abs();
  num scaled = absValue;
  var suffix = '';
  if (absValue >= 1000000000) {
    scaled = absValue / 1000000000;
    suffix = 'B';
  } else if (absValue >= 1000000) {
    scaled = absValue / 1000000;
    suffix = 'M';
  } else if (absValue >= 1000) {
    scaled = absValue / 1000;
    suffix = 'K';
  }
  final decimals = scaled >= 100 || scaled % 1 == 0 ? 0 : 1;
  final formatted = scaled.toStringAsFixed(decimals);
  final sign = value < 0 ? '-' : '';
  return '$sign\$$formatted$suffix';
}

IconData _achievementIcon(String? type) {
  switch (type) {
    case 'medal':
      return Icons.emoji_events_outlined;
    case 'award':
      return Icons.workspace_premium_outlined;
    case 'recognition':
      return Icons.star_border;
    default:
      return Icons.military_tech_outlined;
  }
}
