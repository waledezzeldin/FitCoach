import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';
import '../../services/profile_service.dart';
import '../../services/notification_service.dart';
import '../../state/app_state.dart';
import '../../widgets/demo_banner.dart';
import '../../config/env.dart';
import '../../repositories/profile_repository.dart';
import '../../models/quota_models.dart';
import '../../widgets/subscription_manager_sheet.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _repo = ProfileRepository();
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final d = await _repo.fetchMe();
      if (!mounted) return;
      setState(() {
        _data = d;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final name = _data?['name']?.toString() ?? 'User';
    final email = _data?['email']?.toString() ?? '';
    final app = AppStateScope.of(context);
    final tier = SubscriptionTierDisplay.parse(app.subscriptionType);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ProfileHeader(name: name, email: email, showEdit: !Env.demo),
        const SizedBox(height: 24),
        _SubscriptionStatusCard(
          tier: tier,
          onManage: () => _openSubscriptionManager(context),
        ),
        const SizedBox(height: 16),
        if (Env.demo)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Demo mode: data is mock. Editing disabled.',
              style: TextStyle(fontSize: 12),
            ),
          ),
        // ...other sections (guard each with if(!Env.demo) where needed)...
      ],
    );
  }

  Future<void> _openSubscriptionManager(BuildContext context) async {
    final before = AppStateScope.of(context).subscriptionType;
    await SubscriptionManagerSheet.show(context);
    if (!mounted) return;
    final after = AppStateScope.of(context).subscriptionType;
    if (before != after) {
      setState(() {});
    }
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final bool showEdit;
  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.showEdit,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: cs.primary.withValues(alpha: 0.15),
          child: Text(
            (name.isNotEmpty ? name[0] : '?').toUpperCase(),
            style: TextStyle(
              fontSize: 24,
              color: cs.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(name,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(email,
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        if (showEdit)
          SizedBox(
            height: 36,
            child: OutlinedButton(
              onPressed: () {},
              child: const Text('Edit'),
            ),
          ),
      ],
    );
  }
}

class _SubscriptionStatusCard extends StatelessWidget {
  const _SubscriptionStatusCard({required this.tier, required this.onManage});
  final SubscriptionTier tier;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isFreemium = tier == SubscriptionTier.freemium;
    return Card(
      child: ListTile(
        leading: Icon(Icons.workspace_premium_outlined, color: cs.primary),
        title: Text(isFreemium ? 'Freemium plan' : tier.label, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          isFreemium
              ? 'Upgrade to unlock personalized nutrition and coaching access.'
              : 'Manage your billing or switch plans any time.',
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
        trailing: isFreemium
            ? FilledButton(onPressed: onManage, child: const Text('Upgrade'))
            : TextButton(onPressed: onManage, child: const Text('Manage')),
      ),
    );
  }
}