import 'package:flutter/material.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    // Example static data (replace with real)
    final categories = [
      _Category('Supplements', 'assets/images/store/supplements.png'),
      _Category('Equipment', 'assets/images/store/equipment.png'),
      _Category('Apparel', 'assets/images/store/apparel.png'),
      _Category('Accessories', 'assets/images/store/accessories.png'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Store', style: text.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
        centerTitle: false,
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cs.surface,
              cs.surfaceContainerHighest.withValues(alpha: 0.65),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: .92,
              ),
              itemBuilder: (_, i) {
                final c = categories[i];
                return CategoryCard(
                  title: c.title,
                  image: c.imagePath,
                  onTap: () {
                    // TODO: navigate to category detail
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final String image;
  final VoidCallback onTap;
  const CategoryCard({
    super.key,
    required this.title,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final borderColor = cs.outlineVariant;
    final highlight = cs.primary.withValues(alpha: 0.08);

    return Material(
      color: cs.surface,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: cs.primary.withValues(alpha: 0.12),
        highlightColor: highlight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                  child: _ImageBox(image: image),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
                child: Text(
                  title,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ],
        ),
      ),
    );
  }
}

class _ImageBox extends StatelessWidget {
  final String image;
  const _ImageBox({required this.image});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: cs.surfaceContainerHighest.withValues(alpha: 0.30),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Image.asset(
          image,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Icon(Icons.inventory_2_outlined, color: cs.primary),
        ),
      ),
    );
  }
}

class _Category {
  final String title;
  final String imagePath;
  _Category(this.title, this.imagePath);
}