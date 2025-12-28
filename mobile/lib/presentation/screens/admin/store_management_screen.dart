import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../providers/language_provider.dart';
import '../../widgets/custom_card.dart';
// ...existing code...

class StoreManagementScreen extends StatefulWidget {
  const StoreManagementScreen({super.key});

  @override
  State<StoreManagementScreen> createState() => _StoreManagementScreenState();
}

class _StoreManagementScreenState extends State<StoreManagementScreen> {
  String _selectedTab = 'products'; // products, categories, orders
  String _searchQuery = '';
  
  final List<Map<String, dynamic>> _products = [
    {
      'id': '1',
      'name': 'Whey Protein',
      'category': 'Supplements',
      'price': 299,
      'stock': 45,
      'status': 'active',
      'sales': 128,
    },
    {
      'id': '2',
      'name': 'Resistance Bands',
      'category': 'Equipment',
      'price': 79,
      'stock': 8,
      'status': 'low_stock',
      'sales': 56,
    },
    {
      'id': '3',
      'name': 'Yoga Mat',
      'category': 'Equipment',
      'price': 149,
      'stock': 0,
      'status': 'out_of_stock',
      'sales': 234,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final isArabic = languageProvider.isArabic;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'إدارة المتجر' : 'Store Management'),
      ),
      body: Column(
        children: [
          // Tabs
          Container(
            color: Colors.white,
            child: Row(
              children: [
                _buildTab('products', isArabic ? 'المنتجات' : 'Products', isArabic),
                _buildTab('categories', isArabic ? 'الفئات' : 'Categories', isArabic),
                _buildTab('orders', isArabic ? 'الطلبات' : 'Orders', isArabic),
              ],
            ),
          ),
          
          // Search
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: isArabic ? 'بحث...' : 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
            ),
          ),
          
          // Content
          Expanded(
            child: _selectedTab == 'products'
                ? _buildProductsList(isArabic)
                : _selectedTab == 'categories'
                    ? _buildCategoriesList(isArabic)
                    : _buildOrdersList(isArabic),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addNew(isArabic),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: Text(
          _selectedTab == 'products'
              ? (isArabic ? 'إضافة منتج' : 'Add Product')
              : _selectedTab == 'categories'
                  ? (isArabic ? 'إضافة فئة' : 'Add Category')
                  : (isArabic ? 'طلب جديد' : 'New Order'),
        ),
      ),
    );
  }
  
  Widget _buildTab(String tab, String label, bool isArabic) {
    final isSelected = _selectedTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = tab;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildProductsList(bool isArabic) {
    final filteredProducts = _products.where((product) {
      final query = _searchQuery.toLowerCase();
      return product['name'].toString().toLowerCase().contains(query) ||
          product['category'].toString().toLowerCase().contains(query);
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return CustomCard(
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.shopping_bag, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product['category'],
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(product['status'], isArabic),
                ],
              ),
              
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem(
                    isArabic ? 'السعر' : 'Price',
                    '${product['price']} ${isArabic ? 'ر.س' : 'SAR'}',
                    AppColors.primary,
                  ),
                  _buildStatItem(
                    isArabic ? 'المخزون' : 'Stock',
                    '${product['stock']}',
                    product['stock'] == 0
                        ? AppColors.error
                        : product['stock'] < 10
                            ? AppColors.warning
                            : AppColors.success,
                  ),
                  _buildStatItem(
                    isArabic ? 'المبيعات' : 'Sales',
                    '${product['sales']}',
                    AppColors.textSecondary,
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.edit, size: 18),
                      label: Text(isArabic ? 'تعديل' : 'Edit'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.delete, size: 18),
                      label: Text(isArabic ? 'حذف' : 'Delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildCategoriesList(bool isArabic) {
    final categories = [
      {'name': 'Supplements', 'count': 24, 'icon': Icons.medical_services},
      {'name': 'Equipment', 'count': 18, 'icon': Icons.fitness_center},
      {'name': 'Apparel', 'count': 32, 'icon': Icons.checkroom},
      {'name': 'Accessories', 'count': 15, 'icon': Icons.watch},
    ];

    final filteredCategories = categories.where((category) {
      final query = _searchQuery.toLowerCase();
      return category['name'].toString().toLowerCase().contains(query);
    }).toList();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredCategories.length,
      itemBuilder: (context, index) {
        final category = filteredCategories[index];
        return CustomCard(
          margin: const EdgeInsets.only(bottom: 12),
          onTap: () {},
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  category['icon'] as IconData,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category['name'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${category['count']} ${isArabic ? 'منتج' : 'products'}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textDisabled),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildOrdersList(bool isArabic) {
    final orders = [
      {
        'id': '#1234',
        'customer': 'Ahmed Ali',
        'total': 599,
        'status': 'pending',
        'date': '2024-12-21',
      },
      {
        'id': '#1233',
        'customer': 'Sara Mohammed',
        'total': 299,
        'status': 'shipped',
        'date': '2024-12-20',
      },
      {
        'id': '#1232',
        'customer': 'Omar Hassan',
        'total': 449,
        'status': 'delivered',
        'date': '2024-12-19',
      },
    ];

    final filteredOrders = orders.where((order) {
      final query = _searchQuery.toLowerCase();
      return order['id'].toString().toLowerCase().contains(query) ||
          order['customer'].toString().toLowerCase().contains(query) ||
          order['status'].toString().toLowerCase().contains(query);
    }).toList();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        return CustomCard(
          margin: const EdgeInsets.only(bottom: 12),
          onTap: () {},
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order['id'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildStatusBadge(order['status'] as String, isArabic),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                order['customer'] as String,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order['date'] as String,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${order['total']} ${isArabic ? 'ر.س' : 'SAR'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildStatusBadge(String status, bool isArabic) {
    Color color;
    String label;
    
    switch (status) {
      case 'active':
        color = AppColors.success;
        label = isArabic ? 'نشط' : 'Active';
        break;
      case 'low_stock':
        color = AppColors.warning;
        label = isArabic ? 'مخزون منخفض' : 'Low Stock';
        break;
      case 'out_of_stock':
        color = AppColors.error;
        label = isArabic ? 'نفذ' : 'Out of Stock';
        break;
      case 'pending':
        color = AppColors.warning;
        label = isArabic ? 'قيد الانتظار' : 'Pending';
        break;
      case 'shipped':
        color = AppColors.primary;
        label = isArabic ? 'تم الشحن' : 'Shipped';
        break;
      case 'delivered':
        color = AppColors.success;
        label = isArabic ? 'تم التوصيل' : 'Delivered';
        break;
      default:
        color = AppColors.textSecondary;
        label = status;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
  
  void _addNew(bool isArabic) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isArabic ? 'سيتم إضافة نموذج التفاصيل' : 'Add details form coming soon',
        ),
      ),
    );
  }
}
