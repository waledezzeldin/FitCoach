import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../store/store_state.dart';
import '../../l10n/app_localizations.dart';

class StoreListScreen extends StatelessWidget {
  const StoreListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreState>();
    final t = AppLocalizations.of(context);
    final cartTotal = store.cartTotal;
    return Scaffold(
      appBar: AppBar(title: Text(t.storeTitle)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: store.products.length,
              itemBuilder: (context, i) {
                final p = store.products[i];
                return Card(
                  child: ListTile(
                    leading: p.imageUrl.isNotEmpty ? Image.network(p.imageUrl) : const Icon(Icons.shopping_bag),
                    title: Text(p.name),
                    subtitle: Text(p.description),
                    trailing: Text('${t.currencySymbol}${p.price.toStringAsFixed(2)}'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => StoreDetailScreen(product: p)),
                    ),
                  ),
                );
              },
            ),
          ),
          if (store.cart.isNotEmpty)
            Container(
              color: Colors.grey.shade100,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${t.cartLabel}: ${store.cart.length}'),
                  Text('${t.totalLabel}: ${t.currencySymbol}${cartTotal.toStringAsFixed(2)}'),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(t.checkoutTitle),
                          content: Text(t.checkoutSuccess),
                          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.ok))],
                        ),
                      );
                      store.cart.clear();
                    },
                    child: Text(t.checkoutCta),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class StoreDetailScreen extends StatelessWidget {
  final dynamic product;
  const StoreDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            product.imageUrl.isNotEmpty
                ? Image.network(product.imageUrl, height: 180)
                : const Icon(Icons.shopping_bag, size: 120),
            const SizedBox(height: 16),
            Text(product.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(product.description),
            const SizedBox(height: 16),
            Text('${t.currencySymbol}${product.price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleLarge),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                // Add to cart logic (assumes StoreState is available)
                final store = context.read<StoreState>();
                store.addToCart(product);
                Navigator.pop(context);
              },
              child: const Text('Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }
}
