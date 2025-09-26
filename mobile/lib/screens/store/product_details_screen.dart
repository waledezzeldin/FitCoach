import 'package:flutter/material.dart';
import '../../state/cart_state.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key});
  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  Map<String, dynamic>? product;
  Map<String, dynamic>? selectedVariant;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (product == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        final rawVariants = args['variants'];
        final variants = (rawVariants is List) ? rawVariants.cast<Map<String, dynamic>>() : <Map<String, dynamic>>[];
        setState(() {
          product = args;
          if (variants.isNotEmpty) selectedVariant = variants.first;
        });
      }
    }
  }

  double _price() {
    final base = (product?['price'] as num?)?.toDouble() ?? 0.0;
    final vp = (selectedVariant?['price'] as num?)?.toDouble();
    return vp ?? base;
  }

  @override
  Widget build(BuildContext context) {
    final green = Theme.of(context).colorScheme.primary;
    final rawVariants = product?['variants'];
    final variants = (rawVariants is List) ? rawVariants.cast<Map<String, dynamic>>() : <Map<String, dynamic>>[];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text((product?['name'] ?? '').toString()), backgroundColor: Colors.black, foregroundColor: green),
      body: product == null
          ? const Center(child: Text('Product not found', style: TextStyle(color: Colors.white)))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (variants.isNotEmpty)
                    DropdownButtonFormField<Map<String, dynamic>>(
                      value: selectedVariant != null && variants.contains(selectedVariant) ? selectedVariant : null,
                      items: variants
                          .map((v) => DropdownMenuItem(
                                value: v,
                                child: Text((v['name'] ?? v['label'] ?? 'Option').toString(),
                                    style: const TextStyle(color: Colors.white)),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => selectedVariant = v),
                      dropdownColor: Colors.grey[900],
                      decoration: InputDecoration(
                        labelText: 'Choose option',
                        labelStyle: TextStyle(color: green),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: green)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: green)),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text('Price: \$${_price().toStringAsFixed(2)}', style: TextStyle(color: green, fontSize: 20)),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      final cart = CartStateScope.of(context);
                      final id = (product?['id'] ?? '').toString();
                      final name = (product?['name'] ?? '').toString();
                      final variantId = (selectedVariant?['id'] ?? selectedVariant?['sku'])?.toString();
                      final variantName = (selectedVariant?['name'] ?? selectedVariant?['label'])?.toString();

                      // If CartItem doesn’t support variants, encode them into id/name
                      final effectiveId = variantId != null && variantId.isNotEmpty ? '$id@$variantId' : id;
                      final effectiveName = (variantName != null && variantName.isNotEmpty) ? '$name ($variantName)' : name;

                      cart.addItem(CartItem(
                        id: effectiveId,
                        name: effectiveName,
                        price: _price(),
                      ));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart')));
                      Navigator.pushNamed(context, '/cart');
                    },
                    child: const Text('Add to Cart'),
                  ),
                ],
              ),
            ),
    );
  }
}