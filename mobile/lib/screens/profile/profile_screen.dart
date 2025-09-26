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

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ProfileHeader(name: name, email: email, showEdit: !Env.demo),
        const SizedBox(height: 24),
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