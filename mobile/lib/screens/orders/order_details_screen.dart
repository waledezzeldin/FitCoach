import 'package:flutter/material.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Details')),
        body: Center(
          child: Text('No order data.', style: TextStyle(color: cs.onSurfaceVariant)),
        ),
      );
    }

    final id = (args['id'] ?? '').toString();
    final status = (args['status'] ?? 'pending').toString();
    final total = (args['total'] as num?)?.toDouble() ?? 0.0;
    final createdAt = (args['createdAt'] ?? '').toString();
    final items = (args['items'] as List?)?.cast<Map<String, dynamic>>() ??
        [
          // Fallback demo items
          {'name': 'Supplement A', 'qty': 1, 'price': 19.99},
          {'name': 'Supplement B', 'qty': 2, 'price': 7.50},
        ];

    return Scaffold(
      appBar: AppBar(title: Text(id.isEmpty ? 'Order' : id)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: Text('Status', style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    _StatusChip(status: status),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Placed: $createdAt',
                        style: TextStyle(color: cs.onSurfaceVariant),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ListTile(
                    title: Text('Items', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  const Divider(height: 1),
                  ...items.map((it) {
                    final name = (it['name'] ?? '').toString();
                    final qty = (it['qty'] as num?)?.toInt() ?? 1;
                    final price = (it['price'] as num?)?.toDouble() ?? 0.0;
                    return ListTile(
                      dense: true,
                      title: Text(name),
                      subtitle: Text('Qty: $qty', style: TextStyle(color: cs.onSurfaceVariant)),
                      trailing: Text('\$${(price * qty).toStringAsFixed(2)}',
                          style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600)),
                    );
                  }),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
                  const Spacer(),
                  Text('\$${total.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: cs.primary)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: implement invoice download / share
                  },
                  child: const Text('Invoice'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ],
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
      child: Text(status, style: TextStyle(color: fg, fontWeight: FontWeight.w600)),
    );
  }
}