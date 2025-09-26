import 'package:flutter/material.dart';

class BundleDetailsScreen extends StatelessWidget {
  const BundleDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final green = Theme.of(context).colorScheme.primary;
    final bundle = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    if (bundle == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Bundle Details'),
          backgroundColor: Colors.black,
          foregroundColor: green,
        ),
        body: const Center(
          child: Text('No bundle details available.', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(bundle['name'] ?? 'Bundle Details'),
        backgroundColor: Colors.black,
        foregroundColor: green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(bundle['name'] ?? '', style: TextStyle(color: green, fontSize: 22)),
            const SizedBox(height: 16),
            Text(bundle['description'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 16),
            Text('Price: \$${bundle['price']}', style: TextStyle(color: green, fontSize: 18)),
            // TODO: Add more details, list of included products, images, etc.
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement add to cart or purchase logic
              },
              child: const Text('Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }
}