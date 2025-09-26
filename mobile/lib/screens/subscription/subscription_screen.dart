import 'package:flutter/material.dart';
import '../../services/subscription_service.dart';
import '../../state/app_state.dart';
import '../../widgets/demo_banner.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});
  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool loading = true;
  String? error;
  List<Map<String, dynamic>> _plans = [];
  Map<String, dynamic>? _sub;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { loading = true; error = null; });
    try {
      final svc = SubscriptionService();
      final res = await Future.wait([svc.plans(), svc.current()]);
      _plans = (res[0] as List).cast<Map<String,dynamic>>();
      _sub = (res[1] is Map) ? Map<String, dynamic>.from(res[1] as Map) : null; // themed fix
    } catch (_) {
      error = 'Failed to load subscriptions';
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _purchase(Map<String,dynamic> plan) async {
    // ...existing purchase logic (keep)...
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final app = AppStateScope.of(context);
    final demo = app.demoMode;
    final sub = demo ? app.demoSubscription : _sub; // use loaded subscription

    return Scaffold(
      appBar: AppBar(title: const Text('Subscription')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(error!, style: TextStyle(color: cs.error)),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: _load, child: const Text('Retry')),
                  ]),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (demo) const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: DemoBanner(),
                      ),
                      if (_sub != null) _currentSubCard(cs),
                      ..._plans.map(_planCard),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _load,
                        child: const Text('Refresh'),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _currentSubCard(ColorScheme cs) {
    final status = (_sub?['status'] ?? '').toString();
    final planName = (_sub?['planName'] ?? _sub?['planId'] ?? '').toString();
    return Card(
      child: ListTile(
        title: Text('Current Plan', style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            planName.isEmpty ? '—' : '$planName (${status.isEmpty ? 'active' : status})',
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
        ),
        trailing: TextButton(
          onPressed: () {}, // manage / cancel flow
          child: const Text('Manage'),
        ),
      ),
    );
  }

  Widget _planCard(Map<String,dynamic> plan) {
    final cs = Theme.of(context).colorScheme;
    final id = (plan['id'] ?? '').toString();
    final name = (plan['name'] ?? id).toString();
    final price = (plan['price'] as num?)?.toDouble() ?? 0.0;
    final currency = (plan['currency'] ?? 'USD').toString();
    final isCurrent = _sub != null && (_sub?['planId'] == id || _sub?['planName'] == name);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name,
                    style: TextStyle(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    )),
                const SizedBox(height: 4),
                Text(
                  '$currency ${price.toStringAsFixed(2)}',
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              ]),
            ),
            if (isCurrent)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('Current', style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600)),
              )
            else
              ElevatedButton(
                onPressed: () => _purchase(plan),
                child: const Text('Choose'),
              ),
          ],
        ),
      ),
    );
  }
}