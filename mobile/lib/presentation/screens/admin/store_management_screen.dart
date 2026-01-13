import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/config/demo_config.dart';
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

  final List<Map<String, dynamic>> _categories = [
    {
      'id': 'c1',
      'name': 'Supplements',
      'count': 24,
      'icon': Icons.medical_services
    },
    {
      'id': 'c2',
      'name': 'Equipment',
      'count': 18,
      'icon': Icons.fitness_center
    },
    {'id': 'c3', 'name': 'Apparel', 'count': 32, 'icon': Icons.checkroom},
    {'id': 'c4', 'name': 'Accessories', 'count': 15, 'icon': Icons.watch},
  ];

  final List<Map<String, dynamic>> _orders = [
    {
      'id': '#1234',
      'customer': 'Ahmed Ali',
      'total': 599,
      'status': 'pending',
      'date': '2024-12-21',
      'items': 2,
      'address': 'Riyadh, KSA',
    },
    {
      'id': '#1233',
      'customer': 'Sara Mohammed',
      'total': 299,
      'status': 'shipped',
      'date': '2024-12-20',
      'items': 1,
      'address': 'Jeddah, KSA',
    },
    {
      'id': '#1232',
      'customer': 'Omar Hassan',
      'total': 449,
      'status': 'delivered',
      'date': '2024-12-19',
      'items': 3,
      'address': 'Dammam, KSA',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final isArabic = languageProvider.isArabic;

    if (!DemoConfig.isDemo) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isArabic ? 'إدارة المتجر' : 'Store Management'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              isArabic
                  ? 'إدارة المتجر متاحة حالياً في وضع العرض التجريبي فقط.'
                  : 'Store management is currently available in demo mode only.',
              textAlign: TextAlign.center,
              style:
                  const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ),
        ),
      );
    }

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
                _buildTab(
                    'products', isArabic ? 'المنتجات' : 'Products', isArabic),
                _buildTab(
                    'categories', isArabic ? 'الفئات' : 'Categories', isArabic),
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
                      onPressed: () =>
                          _openProductForm(isArabic, product: product),
                      icon: const Icon(Icons.edit, size: 18),
                      label: Text(isArabic ? 'تعديل' : 'Edit'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmDeleteProduct(isArabic, product),
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
    final filteredCategories = _categories.where((category) {
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
          onTap: () {
            _openCategoryDetails(isArabic, category);
          },
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
              Icon(
                isArabic ? Icons.chevron_left : Icons.chevron_right,
                color: AppColors.textDisabled,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrdersList(bool isArabic) {
    final filteredOrders = _orders.where((order) {
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
          onTap: () {
            _openOrderDetails(isArabic, order);
          },
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
    if (_selectedTab == 'products') {
      _openProductForm(isArabic);
      return;
    }
    if (_selectedTab == 'categories') {
      _openCategoryForm(isArabic);
      return;
    }
    _openOrderForm(isArabic);
  }

  Future<void> _openProductForm(bool isArabic,
      {Map<String, dynamic>? product}) async {
    final isEdit = product != null;
    final nameController =
        TextEditingController(text: product?['name']?.toString() ?? '');
    final categoryController =
        TextEditingController(text: product?['category']?.toString() ?? '');
    final priceController =
        TextEditingController(text: product?['price']?.toString() ?? '');
    final stockController =
        TextEditingController(text: product?['stock']?.toString() ?? '');
    String status = product?['status']?.toString() ?? 'active';

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit
            ? (isArabic ? 'تعديل منتج' : 'Edit Product')
            : (isArabic ? 'إضافة منتج' : 'Add Product')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration:
                    InputDecoration(labelText: isArabic ? 'الاسم' : 'Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: categoryController,
                decoration:
                    InputDecoration(labelText: isArabic ? 'الفئة' : 'Category'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration:
                    InputDecoration(labelText: isArabic ? 'السعر' : 'Price'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration:
                    InputDecoration(labelText: isArabic ? 'المخزون' : 'Stock'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: status,
                items: const [
                  DropdownMenuItem(value: 'active', child: Text('active')),
                  DropdownMenuItem(
                      value: 'low_stock', child: Text('low_stock')),
                  DropdownMenuItem(
                      value: 'out_of_stock', child: Text('out_of_stock')),
                ],
                onChanged: (v) => status = v ?? status,
                decoration:
                    InputDecoration(labelText: isArabic ? 'الحالة' : 'Status'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              final category = categoryController.text.trim();
              final price = int.tryParse(priceController.text.trim()) ?? 0;
              final stock = int.tryParse(stockController.text.trim()) ?? 0;

              setState(() {
                if (isEdit) {
                  final index =
                      _products.indexWhere((p) => p['id'] == product['id']);
                  if (index != -1) {
                    _products[index] = {
                      ..._products[index],
                      'name': name,
                      'category': category.isEmpty
                          ? _products[index]['category']
                          : category,
                      'price': price,
                      'stock': stock,
                      'status': status,
                    };
                  }
                } else {
                  _products.insert(0, {
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'name': name,
                    'category': category.isEmpty ? 'General' : category,
                    'price': price,
                    'stock': stock,
                    'status': status,
                    'sales': 0,
                  });
                }
              });

              Navigator.pop(context);
            },
            child: Text(isArabic ? 'حفظ' : 'Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteProduct(
      bool isArabic, Map<String, dynamic> product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isArabic ? 'حذف المنتج' : 'Delete Product'),
        content: Text(
          isArabic
              ? 'هل أنت متأكد من حذف "${product['name']}"؟'
              : 'Are you sure you want to delete "${product['name']}"?',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(isArabic ? 'إلغاء' : 'Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(isArabic ? 'حذف' : 'Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _products.removeWhere((p) => p['id'] == product['id']);
      });
    }
  }

  Future<void> _openCategoryForm(bool isArabic,
      {Map<String, dynamic>? category}) async {
    final isEdit = category != null;
    final nameController =
        TextEditingController(text: category?['name']?.toString() ?? '');
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit
            ? (isArabic ? 'تعديل فئة' : 'Edit Category')
            : (isArabic ? 'إضافة فئة' : 'Add Category')),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
              labelText: isArabic ? 'اسم الفئة' : 'Category name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isArabic ? 'إلغاء' : 'Cancel')),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              setState(() {
                if (isEdit) {
                  final index =
                      _categories.indexWhere((c) => c['id'] == category['id']);
                  if (index != -1) {
                    _categories[index] = {..._categories[index], 'name': name};
                  }
                } else {
                  _categories.insert(0, {
                    'id': 'c-${DateTime.now().millisecondsSinceEpoch}',
                    'name': name,
                    'count': 0,
                    'icon': Icons.category,
                  });
                }
              });
              Navigator.pop(context);
            },
            child: Text(isArabic ? 'حفظ' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _openCategoryDetails(bool isArabic, Map<String, dynamic> category) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category['name'] as String,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '${category['count']} ${isArabic ? 'منتج' : 'products'}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _openCategoryForm(isArabic, category: category);
                      },
                      icon: const Icon(Icons.edit),
                      label: Text(isArabic ? 'تعديل' : 'Edit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _products.removeWhere(
                              (p) => p['category'] == category['name']);
                          _categories
                              .removeWhere((c) => c['id'] == category['id']);
                        });
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: Text(isArabic ? 'حذف' : 'Delete'),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openOrderForm(bool isArabic,
      {Map<String, dynamic>? order}) async {
    final isEdit = order != null;
    final idController = TextEditingController(
        text: order?['id']?.toString() ??
            '#${DateTime.now().millisecondsSinceEpoch % 10000}');
    final customerController =
        TextEditingController(text: order?['customer']?.toString() ?? '');
    final totalController =
        TextEditingController(text: order?['total']?.toString() ?? '');
    String status = order?['status']?.toString() ?? 'pending';
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit
            ? (isArabic ? 'تعديل طلب' : 'Edit Order')
            : (isArabic ? 'طلب جديد' : 'New Order')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: idController,
                decoration: InputDecoration(
                    labelText: isArabic ? 'رقم الطلب' : 'Order ID'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: customerController,
                decoration: InputDecoration(
                    labelText: isArabic ? 'العميل' : 'Customer'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: totalController,
                keyboardType: TextInputType.number,
                decoration:
                    InputDecoration(labelText: isArabic ? 'الإجمالي' : 'Total'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: status,
                items: const [
                  DropdownMenuItem(value: 'pending', child: Text('pending')),
                  DropdownMenuItem(value: 'shipped', child: Text('shipped')),
                  DropdownMenuItem(
                      value: 'delivered', child: Text('delivered')),
                ],
                onChanged: (v) => status = v ?? status,
                decoration:
                    InputDecoration(labelText: isArabic ? 'الحالة' : 'Status'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isArabic ? 'إلغاء' : 'Cancel')),
          TextButton(
            onPressed: () {
              final id = idController.text.trim();
              final customer = customerController.text.trim();
              final total = int.tryParse(totalController.text.trim()) ?? 0;
              if (id.isEmpty || customer.isEmpty) return;
              setState(() {
                if (isEdit) {
                  final index =
                      _orders.indexWhere((o) => o['id'] == order['id']);
                  if (index != -1) {
                    _orders[index] = {
                      ..._orders[index],
                      'id': id,
                      'customer': customer,
                      'total': total,
                      'status': status
                    };
                  }
                } else {
                  _orders.insert(0, {
                    'id': id,
                    'customer': customer,
                    'total': total,
                    'status': status,
                    'date': DateTime.now().toIso8601String().substring(0, 10),
                    'items': 1,
                    'address': '—',
                  });
                }
              });
              Navigator.pop(context);
            },
            child: Text(isArabic ? 'حفظ' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _openOrderDetails(bool isArabic, Map<String, dynamic> order) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order['id'] as String,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  _buildStatusBadge(order['status'] as String, isArabic),
                ],
              ),
              const SizedBox(height: 12),
              Text('${isArabic ? 'العميل' : 'Customer'}: ${order['customer']}'),
              const SizedBox(height: 6),
              Text('${isArabic ? 'التاريخ' : 'Date'}: ${order['date']}'),
              const SizedBox(height: 6),
              Text('${isArabic ? 'العناصر' : 'Items'}: ${order['items'] ?? 0}'),
              const SizedBox(height: 6),
              Text(
                  '${isArabic ? 'العنوان' : 'Address'}: ${order['address'] ?? '—'}'),
              const SizedBox(height: 12),
              Text(
                '${isArabic ? 'الإجمالي' : 'Total'}: ${order['total']} ${isArabic ? 'ر.س' : 'SAR'}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _openOrderForm(isArabic, order: order);
                      },
                      icon: const Icon(Icons.edit),
                      label: Text(isArabic ? 'تعديل' : 'Edit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _orders.removeWhere((o) => o['id'] == order['id']);
                        });
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: Text(isArabic ? 'حذف' : 'Delete'),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
