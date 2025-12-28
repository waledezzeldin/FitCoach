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
  final List<Map<String, dynamic>> _cartItems = [];
  
  final List<String> _categories = [
    'all',
    'supplements',
    'equipment',
    'apparel',
    'accessories',
  ];
  
  // Mock products data
  final List<Map<String, dynamic>> _products = [
    {
      'id': '1',
      'nameEn': 'Whey Protein 2kg',
      'nameAr': 'بروتين واي 2 كجم',
      'descriptionEn': 'Premium whey protein isolate',
      'descriptionAr': 'بروتين واي ممتاز معزول',
      'price': 299.99,
      'category': 'supplements',
      'image': 'https://images.unsplash.com/photo-1579722821273-0f6c7d44362f?w=400',
      'rating': 4.5,
      'reviews': 128,
      'inStock': true,
    },
    {
      'id': '2',
      'nameEn': 'Resistance Bands Set',
      'nameAr': 'مجموعة أحزمة المقاومة',
      'descriptionEn': '5-piece resistance band set',
      'descriptionAr': 'مجموعة 5 قطع من أحزمة المقاومة',
      'price': 89.99,
      'category': 'equipment',
      'image': 'https://images.unsplash.com/photo-1598289431512-b97b0917affc?w=400',
      'rating': 4.7,
      'reviews': 89,
      'inStock': true,
    },
    {
      'id': '3',
      'nameEn': 'Gym Bag',
      'nameAr': 'حقيبة رياضية',
      'descriptionEn': 'Durable sports duffel bag',
      'descriptionAr': 'حقيبة رياضية متينة',
      'price': 149.99,
      'category': 'accessories',
      'image': 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400',
      'rating': 4.3,
      'reviews': 45,
      'inStock': true,
    },
    {
      'id': '4',
      'nameEn': 'Training T-Shirt',
      'nameAr': 'قميص تدريب',
      'descriptionEn': 'Breathable performance tee',
      'descriptionAr': 'قميص أداء قابل للتنفس',
      'price': 79.99,
      'category': 'apparel',
      'image': 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400',
      'rating': 4.6,
      'reviews': 234,
      'inStock': true,
    },
    {
      'id': '5',
      'nameEn': 'BCAA Supplement',
      'nameAr': 'مكمل BCAA',
      'descriptionEn': 'Branched-chain amino acids',
      'descriptionAr': 'أحماض أمينية متفرعة السلسلة',
      'price': 159.99,
      'category': 'supplements',
      'image': 'https://images.unsplash.com/photo-1593095948071-474c5cc2989d?w=400',
      'rating': 4.4,
      'reviews': 67,
      'inStock': false,
    },
    {
      'id': '6',
      'nameEn': 'Yoga Mat',
      'nameAr': 'سجادة يوجا',
      'descriptionEn': 'Non-slip exercise mat',
      'descriptionAr': 'سجادة تمرين غير قابلة للانزلاق',
      'price': 129.99,
      'category': 'equipment',
      'image': 'https://images.unsplash.com/photo-1601925260368-ae2f83cf8b7f?w=400',
      'rating': 4.8,
      'reviews': 156,
      'inStock': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final isArabic = languageProvider.isArabic;
    
    final filteredProducts = _selectedCategory == 'all'
        ? _products
        : _products.where((p) => p['category'] == _selectedCategory).toList();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.t('store')),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () => _showCart(languageProvider, isArabic),
              ),
              if (_cartItems.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${_cartItems.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filters
          _buildCategoryFilters(languageProvider, isArabic),
          
          // Products grid
          Expanded(
            child: filteredProducts.isEmpty
                ? _buildEmptyState(languageProvider, isArabic)
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      return _buildProductCard(
                        filteredProducts[index],
                        languageProvider,
                        isArabic,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
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
              label: Text(_getCategoryName(category, isArabic)),
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
  
  String _getCategoryName(String category, bool isArabic) {
    final names = {
      'all': isArabic ? 'الكل' : 'All',
      'supplements': isArabic ? 'مكملات' : 'Supplements',
      'equipment': isArabic ? 'معدات' : 'Equipment',
      'apparel': isArabic ? 'ملابس' : 'Apparel',
      'accessories': isArabic ? 'إكسسوارات' : 'Accessories',
    };
    return names[category] ?? category;
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
          // Product image
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
                        isArabic ? 'نفذ المخزون' : 'Out of Stock',
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
          
          // Product info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic ? product['nameAr'] : product['nameEn'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
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
                      const SizedBox(width: 4),
                      Text(
                        '(${product['reviews']})',
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
                        '${product['price']} ${isArabic ? 'ر.س' : 'SAR'}',
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
  
  Widget _buildEmptyState(LanguageProvider lang, bool isArabic) {
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
            isArabic 
                ? 'لا توجد منتجات في هذه الفئة'
                : 'No products in this category',
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
      _cartItems.add(product);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isArabic 
              ? 'تمت الإضافة إلى السلة'
              : 'Added to cart',
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 1),
      ),
    );
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
                // Handle bar
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
                
                // Product image
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
                
                // Product name
                Text(
                  isArabic ? product['nameAr'] : product['nameEn'],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Rating
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
                      '(${product['reviews']} ${isArabic ? 'تقييم' : 'reviews'})',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Price
                Text(
                  '${product['price']} ${isArabic ? 'ر.س' : 'SAR'}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Description
                Text(
                  isArabic ? 'الوصف' : 'Description',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isArabic 
                      ? product['descriptionAr']
                      : product['descriptionEn'],
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Add to cart button
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: isArabic ? 'أضف إلى السلة' : 'Add to Cart',
                    onPressed: product['inStock']
                        ? () {
                            Navigator.pop(context);
                            _addToCart(product, lang, isArabic);
                          }
                        : null,
                    variant: ButtonVariant.primary,
                    size: ButtonSize.large,
                    icon: Icons.shopping_cart,
                    fullWidth: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _showCart(LanguageProvider lang, bool isArabic) {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic ? 'السلة فارغة' : 'Cart is empty',
          ),
        ),
      );
      return;
    }
    
    final total = _cartItems.fold<double>(
      0,
      (sum, item) => sum + (item['price'] as double),
    );
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isArabic ? 'سلة التسوق' : 'Shopping Cart',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _cartItems.length,
                itemBuilder: (context, index) {
                  final item = _cartItems[index];
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item['image'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(isArabic ? item['nameAr'] : item['nameEn']),
                    subtitle: Text('${item['price']} ${isArabic ? 'ر.س' : 'SAR'}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: AppColors.error),
                      onPressed: () {
                        setState(() {
                          _cartItems.removeAt(index);
                        });
                        Navigator.pop(context);
                        if (_cartItems.isNotEmpty) {
                          _showCart(lang, isArabic);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isArabic ? 'الإجمالي:' : 'Total:',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${total.toStringAsFixed(2)} ${isArabic ? 'ر.س' : 'SAR'}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: isArabic ? 'إتمام الطلب' : 'Checkout',
                onPressed: () {
                  Navigator.pop(context);
                  _checkout(lang, isArabic);
                },
                variant: ButtonVariant.primary,
                size: ButtonSize.large,
                fullWidth: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _checkout(LanguageProvider lang, bool isArabic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isArabic ? 'إتمام الطلب' : 'Checkout'),
        content: Text(
          isArabic
              ? 'سيتم توجيهك إلى صفحة الدفع'
              : 'You will be redirected to payment',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isArabic ? 'حسناً' : 'OK'),
          ),
        ],
      ),
    );
  }
}
