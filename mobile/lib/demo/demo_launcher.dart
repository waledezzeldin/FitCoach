import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../state/app_state.dart';
import 'demo_session.dart';

class DemoLauncher {
  const DemoLauncher._();

  static Future<void> showSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => _DemoRoleSheet(
        onSelect: (role) async {
          Navigator.pop(sheetContext);
          await launch(context, role);
        },
      ),
    );
  }

  static Future<void> launch(BuildContext context, DemoRole role) async {
    DemoSession.role = role;
    final app = AppStateScope.of(context);
    final fixtures = await _fetchFixtures(role, app.locale);
    final userPayload = _coerceMap(fixtures['user']) ?? {
      'id': 'demo_${role.name}',
      'role': role.name,
      'name': _displayName(role),
      'preferredLocale': app.locale?.languageCode,
    };
    final subscription = (fixtures['subscription'] ??
            (role == DemoRole.user ? 'freemium' : 'smart_premium'))
        .toString();
    app.setDemoMode(true);
    await app.signIn(
      user: userPayload,
      subscription: subscription,
      role: userPayload['role']?.toString() ?? role.name,
    );
    await app.applyDemoFixtures(fixtures);
    if (!context.mounted) return;
    final landing = app.resolveLandingRoute();
    Navigator.pushNamedAndRemoveUntil(context, landing, (_) => false);
  }

  static String _displayName(DemoRole role) {
    switch (role) {
      case DemoRole.coach:
        return 'Coach (Demo)';
      case DemoRole.admin:
        return 'Admin (Demo)';
      default:
        return 'Demo User';
    }
  }

  static Future<Map<String, dynamic>> _fetchFixtures(DemoRole role, Locale? locale) async {
    try {
      final api = ApiService();
      final response = await api.dio.get(
        '/v1/demo/fixtures',
        queryParameters: {
          'persona': role.name,
          if (locale != null) 'locale': locale.languageCode,
        },
      );
      final body = response.data;
      if (body is Map<String, dynamic>) {
        return Map<String, dynamic>.from(body);
      }
      if (body is Map) {
        return body.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (err, stack) {
      debugPrint('Demo fixtures unavailable: $err');
      debugPrint('$stack');
    }
    return {};
  }

  static Map<String, dynamic>? _coerceMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return Map<String, dynamic>.from(value);
    }
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return null;
  }
}

class _DemoRoleSheet extends StatelessWidget {
  const _DemoRoleSheet({required this.onSelect});

  final ValueChanged<DemoRole> onSelect;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose a demo persona', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _DemoRoleTile(
              icon: Icons.person_outline,
              title: 'Demo User',
              subtitle: 'Explore the member experience',
              color: cs.primary,
              onTap: () => onSelect(DemoRole.user),
            ),
            const SizedBox(height: 8),
            _DemoRoleTile(
              icon: Icons.fitness_center,
              title: 'Demo Coach',
              subtitle: 'Review coaching & quota flows',
              color: cs.tertiary,
              onTap: () => onSelect(DemoRole.coach),
            ),
            const SizedBox(height: 8),
            _DemoRoleTile(
              icon: Icons.admin_panel_settings_outlined,
              title: 'Demo Admin',
              subtitle: 'Preview dashboards and approvals',
              color: cs.secondary,
              onTap: () => onSelect(DemoRole.admin),
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoRoleTile extends StatelessWidget {
  const _DemoRoleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
