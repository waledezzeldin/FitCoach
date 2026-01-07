import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../providers/language_provider.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/custom_card.dart';
import '../../../data/models/admin_user.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _tierFilter;
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUsers();
    });
  }

  void _loadUsers() {
    final adminProvider = context.read<AdminProvider>();
    adminProvider.loadUsers(
      search: _searchController.text.isNotEmpty ? _searchController.text : null,
      subscriptionTier: _tierFilter,
      status: _statusFilter,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final adminProvider = context.watch<AdminProvider>();
    final isArabic = languageProvider.isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'المستخدمون' : 'Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filters
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: isArabic ? 'بحث...' : 'Search...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _loadUsers();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (_searchController.text == value) {
                        _loadUsers();
                      }
                    });
                  },
                ),

                const SizedBox(height: 12),

                // Filters
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        value: _tierFilter,
                        decoration: InputDecoration(
                          labelText: isArabic ? 'الباقة' : 'Tier',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: null,
                            child: Text(isArabic ? 'الكل' : 'All'),
                          ),
                          DropdownMenuItem(
                            value: 'freemium',
                            child: Text(isArabic ? 'مجاني' : 'Freemium'),
                          ),
                          DropdownMenuItem(
                            value: 'premium',
                            child: Text(isArabic ? 'بريميوم' : 'Premium'),
                          ),
                          DropdownMenuItem(
                            value: 'smart_premium',
                            child: Text(isArabic ? 'سمارت بريميوم' : 'Smart Premium'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _tierFilter = value;
                          });
                          _loadUsers();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        value: _statusFilter,
                        decoration: InputDecoration(
                          labelText: isArabic ? 'الحالة' : 'Status',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: null,
                            child: Text(isArabic ? 'الكل' : 'All'),
                          ),
                          DropdownMenuItem(
                            value: 'active',
                            child: Text(isArabic ? 'نشط' : 'Active'),
                          ),
                          DropdownMenuItem(
                            value: 'inactive',
                            child: Text(isArabic ? 'غير نشط' : 'Inactive'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _statusFilter = value;
                          });
                          _loadUsers();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // User list
          Expanded(
            child: adminProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : adminProvider.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                            const SizedBox(height: 16),
                            Text(
                              adminProvider.error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.error),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadUsers,
                              child: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
                            ),
                          ],
                        ),
                      )
                    : adminProvider.users.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 64,
                                  color: AppColors.textDisabled,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  isArabic ? 'لا يوجد مستخدمون' : 'No users found',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async => _loadUsers(),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: adminProvider.users.length,
                              itemBuilder: (context, index) {
                                final user = adminProvider.users[index];
                                return _buildUserCard(user, isArabic);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(AdminUser user, bool isArabic) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showUserDetailsDialog(user, isArabic),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                backgroundImage: user.profilePhotoUrl != null
                    ? NetworkImage(user.profilePhotoUrl!)
                    : null,
                child: user.profilePhotoUrl == null
                    ? Text(
                        user.initials,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      )
                    : null,
              ),

              const SizedBox(width: 16),

              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (user.email != null)
                      Text(
                        user.email!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Tier badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getTierColor(user.subscriptionTier),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            user.subscriptionTier,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: user.isActive ? AppColors.success : AppColors.error,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            user.isActive
                                ? (isArabic ? 'نشط' : 'Active')
                                : (isArabic ? 'غير نشط' : 'Inactive'),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        if (user.coachName != null) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${isArabic ? 'المدرب:' : 'Coach:'} ${user.coachName}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Action menu
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _showEditUserDialog(user, isArabic);
                      break;
                    case 'suspend':
                      _showSuspendUserDialog(user, isArabic);
                      break;
                    case 'delete':
                      _showDeleteUserDialog(user, isArabic);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit, size: 18),
                        const SizedBox(width: 8),
                        Text(isArabic ? 'تعديل' : 'Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'suspend',
                    child: Row(
                      children: [
                        const Icon(Icons.block, size: 18),
                        const SizedBox(width: 8),
                        Text(isArabic ? 'إيقاف' : 'Suspend'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete, size: 18, color: AppColors.error),
                        const SizedBox(width: 8),
                        Text(
                          isArabic ? 'حذف' : 'Delete',
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ],
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

  void _showUserDetailsDialog(AdminUser user, bool isArabic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.fullName),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(isArabic ? 'البريد الإلكتروني' : 'Email', user.email ?? 'N/A'),
              _buildDetailRow(isArabic ? 'الهاتف' : 'Phone', user.phoneNumber ?? 'N/A'),
              _buildDetailRow(isArabic ? 'الباقة' : 'Tier', user.subscriptionTier),
              _buildDetailRow(
                isArabic ? 'الحالة' : 'Status',
                user.isActive ? (isArabic ? 'نشط' : 'Active') : (isArabic ? 'غير نشط' : 'Inactive'),
              ),
              _buildDetailRow(isArabic ? 'المدرب' : 'Coach', user.coachName ?? (isArabic ? 'غير معين' : 'Not assigned')),
              _buildDetailRow(isArabic ? 'تاريخ التسجيل' : 'Created', _formatDate(user.createdAt)),
              if (user.lastLogin != null)
                _buildDetailRow(isArabic ? 'آخر تسجيل دخول' : 'Last Login', _formatDate(user.lastLogin!)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isArabic ? 'إغلاق' : 'Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(AdminUser user, bool isArabic) {
    final adminProvider = context.read<AdminProvider>();
    if (adminProvider.coaches.isEmpty) {
      adminProvider.loadCoaches();
    }
    final nameController = TextEditingController(text: user.fullName);
    final emailController = TextEditingController(text: user.email);
    String selectedTier = _normalizeTier(user.subscriptionTier);
    bool isActive = user.isActive;
    String? selectedCoachId = user.coachId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isArabic ? 'تعديل المستخدم' : 'Edit User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: isArabic ? 'الاسم' : 'Name',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: isArabic ? 'البريد الإلكتروني' : 'Email',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedTier,
                  decoration: InputDecoration(
                    labelText: isArabic ? 'الباقة' : 'Tier',
                    border: const OutlineInputBorder(),
                  ),
                  items: const ['Freemium', 'Premium', 'Smart Premium']
                      .map(
                        (tier) => DropdownMenuItem(
                          value: tier,
                          child: Text(_formatTierLabel(tier, isArabic)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedTier = value ?? selectedTier;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String?>(
                  value: selectedCoachId,
                  decoration: InputDecoration(
                    labelText: isArabic ? 'OU,U.O_OñO"' : 'Coach',
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(isArabic ? 'O§USOñ U.O1USU+' : 'Not assigned'),
                    ),
                    ...context
                        .watch<AdminProvider>()
                        .coaches
                        .map(
                          (coach) => DropdownMenuItem(
                            value: coach.id,
                            child: Text(coach.fullName),
                          ),
                        ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedCoachId = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: Text(isArabic ? 'نشط' : 'Active'),
                  value: isActive,
                  onChanged: (value) {
                    setState(() {
                      isActive = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isArabic ? 'إلغاء' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);

                final adminProvider = context.read<AdminProvider>();
                final success = await adminProvider.updateUser(
                  user.id,
                  fullName: nameController.text,
                  email: emailController.text,
                  subscriptionTier: selectedTier,
                  isActive: isActive,
                  coachId: selectedCoachId,
                );

                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isArabic ? 'تم التحديث بنجاح' : 'Updated successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  _loadUsers();
                }
              },
              child: Text(isArabic ? 'حفظ' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuspendUserDialog(AdminUser user, bool isArabic) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isArabic ? 'إيقاف المستخدم' : 'Suspend User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isArabic
                  ? 'هل أنت متأكد من إيقاف ${user.fullName}؟'
                  : 'Are you sure you want to suspend ${user.fullName}?',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: isArabic ? 'السبب' : 'Reason',
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isArabic ? 'الرجاء إدخال السبب' : 'Please enter a reason'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              Navigator.pop(context);

              final adminProvider = context.read<AdminProvider>();
              final success = await adminProvider.suspendUser(user.id, reasonController.text);

              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isArabic ? 'تم الإيقاف بنجاح' : 'Suspended successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
                _loadUsers();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(isArabic ? 'إيقاف' : 'Suspend'),
          ),
        ],
      ),
    );
  }

  void _showDeleteUserDialog(AdminUser user, bool isArabic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isArabic ? 'حذف المستخدم' : 'Delete User'),
        content: Text(
          isArabic
              ? 'هل أنت متأكد من حذف ${user.fullName}؟ هذا الإجراء لا يمكن التراجع عنه.'
              : 'Are you sure you want to delete ${user.fullName}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              final adminProvider = context.read<AdminProvider>();
              final success = await adminProvider.deleteUser(user.id);

              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isArabic ? 'تم الحذف بنجاح' : 'Deleted successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
                _loadUsers();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(isArabic ? 'حذف' : 'Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getTierColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'smart premium':
      case 'smart_premium':
        return const Color(0xFFFFD700);
      case 'premium':
        return AppColors.primary;
      case 'freemium':
      default:
        return AppColors.textSecondary;
    }
  }

  String _normalizeTier(String tier) {
    switch (tier.trim().toLowerCase()) {
      case 'premium':
        return 'Premium';
      case 'smart premium':
      case 'smart_premium':
        return 'Smart Premium';
      default:
        return 'Freemium';
    }
  }

  String _formatTierLabel(String tier, bool isArabic) {
    switch (tier.toLowerCase()) {
      case 'premium':
        return isArabic ? 'بريميوم' : 'Premium';
      case 'smart premium':
        return isArabic ? 'سمارت بريميوم' : 'Smart Premium';
      default:
        return isArabic ? 'مجاني' : 'Freemium';
    }
  }
}
