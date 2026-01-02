import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../providers/language_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_button.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  String _selectedCategory = 'all';
  String _searchQuery = '';

  final List<Map<String, dynamic>> _cartItems = [];
  final List<String> _categories = [
    'all',
    'Protein',
    'Pre-Workout',
    'Recovery',
    'Vitamins',
    'Fat Burners',
  ];

  final List<Map<String, dynamic>> _products = [
    {
      'id': '1',
      'nameEn': 'Whey Protein Isolate',
      'nameAr': '?????? ??? ?????',
      'brand': 'FitNutrition',
      'descriptionEn': 'Premium whey protein isolate for muscle building.',
      'descriptionAr': '?????? ??? ????? ???? ?????? ????? ???????.',
      'price': 59.99,
      'originalPrice': 69.99,
      'discount': 15,
      'category': 'Protein',
      'image': 'https://images.unsplash.com/photo-1579722821273-0f6c7d44362f?w=400',
      'rating': 4.8,
      'reviews': 1247,
      'inStock': true,
      'isPopular': true,
    },
    {
      'id': '2',
      'nameEn': 'Creatine Monohydrate',
      'nameAr': '??????? ??????????',
      'brand': 'PowerSupps',
      'descriptionEn': 'Pure creatine for increased strength.',
      'descriptionAr': '??????? ??? ?????? ????? ???????.',
      'price': 29.99,
      'category': 'Pre-Workout',
      'image': 'https://images.unsplash.com/photo-1593095948071-474c5cc2989d?w=400',
      'rating': 4.9,
      'reviews': 892,
      'inStock': true,
    },
    {
      'id': '3',
      'nameEn': 'BCAA Recovery',
      'nameAr': '????? ?????? ???????',
      'brand': 'RecoverMax',
      'descriptionEn': 'BCAA blend for recovery.',
      'descriptionAr': '???? ????? ?????? ??????? ??????.',
      'price': 39.99,
      'category': 'Recovery',
      'image': 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400',
      'rating': 4.6,
      'reviews': 654,
      'inStock': true,
    },
    {
      'id': '4',
      'nameEn': 'Pre-Workout Boost',
      'nameAr': '???? ??? ???????',
      'brand': 'EnergyCore',
      'descriptionEn': 'High-energy pre-workout formula.',
      'descriptionAr': '?????? ???? ????? ??? ???????.',
      'price': 44.99,
      'originalPrice': 49.99,
      'discount': 10,
      'category': 'Pre-Workout',
      'image': 'https://images.unsplash.com/photo-1556909212-d5b604d0c90d?w=400',
      'rating': 4.7,
      'reviews': 423,
      'inStock': false,
    },
    {
      'id': '5',
      'nameEn': 'Multivitamin Complex',
      'nameAr': '???? ????? ???????????',
      'brand': 'VitalHealth',
      'descriptionEn': 'Daily vitamin and mineral support.',
      'descriptionAr': '??? ???? ???????????? ????????.',
      'price': 24.99,
      'category': 'Vitamins',
      'image': 'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=400',
      'rating': 4.5,
      'reviews': 332,
      'inStock': true,
    },
    {
      'id': '6',
      'nameEn': 'Fat Burner Pro',
      'nameAr': '???? ???? ???????',
      'brand': 'LeanLife',
      'descriptionEn': 'Thermogenic formula for weight management.',
      'descriptionAr': '?????? ?????? ?????? ?????.',
      'price': 49.99,
      'category': 'Fat Burners',
      'image': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',
      'rating': 4.3,
      'reviews': 267,
      'inStock': true,
    },
  ];

  final List<Map<String, dynamic>> _orders = [
    {
      'id': 'ORD-2024-001',
      'status': 'delivered',
      'total': 89.98,
      'date': DateTime.now().subtract(const Duration(days: 5)),
    },
    {
      'id': 'ORD-2024-002',
      'status': 'shipped',
      'total': 39.99,
      'date': DateTime.now().subtract(const Duration(days: 2)),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final isArabic = languageProvider.isArabic;

    final filteredProducts = _products.where((product) {
      final matchesSearch = product['nameEn']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          product['brand'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'all' || product['category'] == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    final cartItemCount = _cartItems.fold<int>(
      0,
      (sum, item) => sum + (item['quantity'] as int),
    );

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                'https://images.unsplash.com/photo-1736236560164-bc741c70bca5?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(color: Colors.black.withValues(alpha: 0.15)),
            ),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(languageProvider, cartItemCount),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TabBar(
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textSecondary,
                      indicatorColor: AppColors.primary,
                      tabs: [
                        Tab(text: languageProvider.t('store_products')),
                        Tab(text: languageProvider.t('store_cart')),
                        Tab(text: languageProvider.t('store_orders')),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildProductsTab(filteredProducts, languageProvider, isArabic),
                        _buildCartTab(languageProvider, isArabic),
                        _buildOrdersTab(languageProvider),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(LanguageProvider lang, int cartItemCount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFB45309)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.t('store_title'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      lang.t('store_subtitle'),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart, color: Colors.white),
                    onPressed: () {},
                  ),
                  if (cartItemCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                        child: Text(
                          '$cartItemCount',
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: lang.t('store_search_placeholder'),
              prefixIcon: const Icon(Icons.search, color: Colors.white),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.15),
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTab(
    List<Map<String, dynamic>> products,
    LanguageProvider lang,
    bool isArabic,
  ) {
    return Column(
      children: [
        _buildCategoryFilters(lang, isArabic),
        Expanded(
          child: products.isEmpty
              ? _buildEmptyState(lang, isArabic, messageKey: 'store_no_products')
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.68,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return _buildProductCard(
                      products[index],
                      lang,
                      isArabic,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCartTab(LanguageProvider lang, bool isArabic) {
    if (_cartItems.isEmpty) {
      return _buildEmptyState(lang, isArabic, messageKey: 'cart_empty');
    }
    final total = _cartItems.fold<double>(
      0,
      (sum, item) => sum + (item['price'] as double) * (item['quantity'] as int),
    );
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ..._cartItems.map((item) {
          return CustomCard(
            margin: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item['image'],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isArabic ? item['nameAr'] : item['nameEn']),
                      const SizedBox(height: 4),
                      Text(
                        '${item['price']} ${lang.t('currency_sar')}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => _updateQuantity(item['id'], item['quantity'] - 1),
                    ),
                    Text('${item['quantity']}'),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => _updateQuantity(item['id'], item['quantity'] + 1),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              lang.t('total'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${total.toStringAsFixed(2)} ${lang.t('currency_sar')}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomButton(
          text: lang.t('checkout'),
          onPressed: () => _checkout(lang, isArabic),
          fullWidth: true,
          size: ButtonSize.large,
        ),
      ],
    );
  }

  Widget _buildOrdersTab(LanguageProvider lang) {
    if (_orders.isEmpty) {
      return _buildEmptyState(lang, lang.isArabic, messageKey: 'store_no_orders');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final order = _orders[index];
        return CustomCard(
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Icon(_statusIcon(order['status']), color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order['id'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      _statusLabel(order['status'], lang),
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Text(
                '${order['total']} ${lang.t('currency_sar')}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'processing':
        return Icons.schedule;
      case 'shipped':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.inventory_2;
      default:
        return Icons.schedule;
    }
  }

  String _statusLabel(String status, LanguageProvider lang) {
    switch (status) {
      case 'processing':
        return lang.t('store_status_processing');
      case 'shipped':
        return lang.t('store_status_shipped');
      case 'delivered':
        return lang.t('store_status_delivered');
      default:
        return status;
    }
  }

  Widget _buildCategoryFilters(LanguageProvider lang, bool isArabic) {
    return Container(
      height: 60,
      color: AppColors.surface,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category == 'all' ? lang.t('store_all') : category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              checkmarkColor: AppColors.primary,
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(
    Map<String, dynamic> product,
    LanguageProvider lang,
    bool isArabic,
  ) {
    final inStock = product['inStock'] as bool;

    return CustomCard(
      padding: EdgeInsets.zero,
      onTap: () => _showProductDetail(product, lang, isArabic),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  product['image'],
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              if (product['discount'] != null)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '-${product['discount']}%',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
              if (product['isPopular'] == true)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      lang.t('store_popular'),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
              if (!inStock)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        lang.t('out_of_stock'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['brand'],
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isArabic ? product['nameAr'] : product['nameEn'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.warning, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${product['rating']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${lang.t('reviews_count', args: {'count': '${product['reviews']}'})}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textDisabled,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${product['price']} ${lang.t('currency_sar')}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_shopping_cart, size: 20),
                        onPressed: inStock
                            ? () => _addToCart(product, lang, isArabic)
                            : null,
                        color: AppColors.primary,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(LanguageProvider lang, bool isArabic, {String? messageKey}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: AppColors.textDisabled,
          ),
          const SizedBox(height: 24),
          Text(
            messageKey != null ? lang.t(messageKey) : lang.t('store_no_products'),
            style: const TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _addToCart(
    Map<String, dynamic> product,
    LanguageProvider lang,
    bool isArabic,
  ) {
    setState(() {
      final existingIndex = _cartItems.indexWhere((item) => item['id'] == product['id']);
      if (existingIndex >= 0) {
        _cartItems[existingIndex]['quantity'] =
            (_cartItems[existingIndex]['quantity'] as int) + 1;
      } else {
        _cartItems.add({...product, 'quantity': 1});
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(lang.t('store_added_to_cart')),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _updateQuantity(String productId, int newQuantity) {
    setState(() {
      if (newQuantity <= 0) {
        _cartItems.removeWhere((item) => item['id'] == productId);
        return;
      }
      final index = _cartItems.indexWhere((item) => item['id'] == productId);
      if (index >= 0) {
        _cartItems[index]['quantity'] = newQuantity;
      }
    });
  }

  void _showProductDetail(
    Map<String, dynamic> product,
    LanguageProvider lang,
    bool isArabic,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    product['image'],
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  isArabic ? product['nameAr'] : product['nameEn'],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: AppColors.warning, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '${product['rating']}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${lang.t('reviews_count', args: {'count': '${product['reviews']}'})}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '${product['price']} ${lang.t('currency_sar')}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  lang.t('description'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isArabic ? product['descriptionAr'] : product['descriptionEn'],
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: lang.t('add_to_cart'),
                    onPressed: product['inStock'] == true
                        ? () {
                            Navigator.pop(context);
                            _addToCart(product, lang, isArabic);
                          }
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _checkout(LanguageProvider lang, bool isArabic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang.t('checkout')),
        content: Text(lang.t('checkout_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(lang.t('ok')),
          ),
        ],
      ),
    );
  }
}
