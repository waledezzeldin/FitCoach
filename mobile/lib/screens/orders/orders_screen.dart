import 'package:flutter/material.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool loading = true;
  String? error;
  List<Map<String, dynamic>> _orders = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      // ...existing service call...
      // final data = await OrdersService().list();
      // _orders = List<Map<String, dynamic>>.from(data);
      // Demo-safe placeholder:
      _orders = [
        {'id': 'ORD-1001', 'status': 'paid', 'total': 29.99, 'createdAt': DateTime.now().toIso8601String()},
        {'id': 'ORD-1000', 'status': 'pending', 'total': 14.50, 'createdAt': DateTime.now().subtract(const Duration(days: 2)).toIso8601String()},
      ];
    } catch (e) {
      error = 'Failed to load orders';
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
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
                  child: _orders.isEmpty
                      ? ListView(
                          children: [
                            const SizedBox(height: 80),
                            Center(child: Text('No orders yet', style: TextStyle(color: cs.onSurfaceVariant))),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(8),
                          itemCount: _orders.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, i) {
                            final o = _orders[i];
                            final id = (o['id'] ?? '').toString();
                            final status = (o['status'] ?? '').toString();
                            final total = (o['total'] as num?)?.toDouble() ?? 0.0;
                            final created = (o['createdAt'] ?? '').toString();

                            return Card(
                              child: ListTile(
                                title: Text(
                                  id.isEmpty ? 'Order' : id,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 2),
                                    Text('Placed: $created', style: TextStyle(color: cs.onSurfaceVariant)),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        _StatusChip(status: status),
                                        const SizedBox(width: 8),
                                        Text('\$${total.toStringAsFixed(2)}', style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => Navigator.pushNamed(context, '/order_details', arguments: {'id': id})
                                    .then((_) => _load()),
                              ),
                            );
                          },
                        ),
                ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final s = status.toLowerCase();
    Color bg;
    Color fg;
    if (s == 'paid' || s == 'completed' || s == 'delivered') {
      bg = cs.primary.withOpacity(0.15);
      fg = cs.primary;
    } else if (s == 'canceled' || s == 'failed') {
      bg = cs.error.withOpacity(0.15);
      fg = cs.error;
    } else {
      bg = cs.surfaceVariant;
      fg = cs.onSurfaceVariant;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(status.isEmpty ? '—' : status, style: TextStyle(color: fg, fontWeight: FontWeight.w600)),
    );
  }
}