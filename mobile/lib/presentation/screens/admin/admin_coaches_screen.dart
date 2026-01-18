import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../providers/language_provider.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_button.dart';
import '../../../data/models/admin_coach.dart';

class AdminCoachesScreen extends StatefulWidget {
  const AdminCoachesScreen({super.key});

  @override
  State<AdminCoachesScreen> createState() => _AdminCoachesScreenState();
}

class _AdminCoachesScreenState extends State<AdminCoachesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _statusFilter;
  bool _showPendingOnly = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCoaches();
    });
  }

  void _loadCoaches() {
    final adminProvider = context.read<AdminProvider>();
    adminProvider.loadCoaches(
      search: _searchController.text.isNotEmpty ? _searchController.text : null,
      status: _statusFilter,
      approved: _showPendingOnly ? 'false' : null,
    );
  }

  void _showCreateCoachSheet(bool isArabic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return _CreateCoachSheet(
          isArabic: isArabic,
          onSubmit: (payload) async {
            final adminProvider = context.read<AdminProvider>();
            final success = await adminProvider.createCoach(
              fullName: payload.fullName,
              email: payload.email,
              phoneNumber: payload.phoneNumber,
              specializations: payload.specializations,
              sendInvitation: payload.sendInvite,
            );

            if (!mounted) return false;

            if (success) {
              Navigator.of(sheetContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isArabic ? 'تم إنشاء حساب المدرب وإرسال الدعوة' : 'Coach account created and invite sent',
                  ),
                  backgroundColor: AppColors.success,
                ),
              );
              _loadCoaches();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    adminProvider.error ??
                        (isArabic ? 'تعذر إنشاء المدرب، حاول مرة أخرى' : 'Failed to create coach'),
                  ),
                  backgroundColor: AppColors.error,
                ),
              );
            }
            return success;
          },
        );
      },
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
        title: Text(isArabic ? 'المدربون' : 'Coaches'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCoaches,
          ),
        ],
      ),
      body: Column(
        children: [
          // Pending approvals banner
          if (adminProvider.pendingCoaches.isNotEmpty && !_showPendingOnly)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: AppColors.warning.withValues(alpha: 0.1),
              child: Row(
                children: [
                  const Icon(Icons.pending_actions, color: AppColors.warning),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isArabic
                          ? '${adminProvider.pendingCoaches.length} مدرب بانتظار الموافقة'
                          : '${adminProvider.pendingCoaches.length} coaches pending approval',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showPendingOnly = true;
                      });
                      _loadCoaches();
                    },
                    child: Text(isArabic ? 'عرض' : 'View'),
                  ),
                ],
              ),
            ),

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
                              _loadCoaches();
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
                        _loadCoaches();
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
                          _loadCoaches();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilterChip(
                        label: Text(isArabic ? 'بانتظار الموافقة' : 'Pending Only'),
                        selected: _showPendingOnly,
                        onSelected: (value) {
                          setState(() {
                            _showPendingOnly = value;
                          });
                          _loadCoaches();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Coach list
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
                              onPressed: _loadCoaches,
                              child: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
                            ),
                          ],
                        ),
                      )
                    : adminProvider.coaches.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.fitness_center,
                                  size: 64,
                                  color: AppColors.textDisabled,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  isArabic ? 'لا يوجد مدربون' : 'No coaches found',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async => _loadCoaches(),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: adminProvider.coaches.length,
                              itemBuilder: (context, index) {
                                final coach = adminProvider.coaches[index];
                                return _buildCoachCard(coach, isArabic);
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateCoachSheet(isArabic),
        icon: const Icon(Icons.person_add_alt_1),
        label: Text(isArabic ? 'إضافة مدرب' : 'Add Coach'),
      ),
    );
  }

  Widget _buildCoachCard(AdminCoach coach, bool isArabic) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showCoachDetailsDialog(coach, isArabic),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    backgroundImage: coach.profilePhotoUrl != null
                        ? NetworkImage(coach.profilePhotoUrl!)
                        : null,
                    child: coach.profilePhotoUrl == null
                        ? Text(
                            coach.initials,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          )
                        : null,
                  ),

                  const SizedBox(width: 16),

                  // Coach info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                coach.fullName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (!coach.isApproved)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.warning,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isArabic ? 'بانتظار الموافقة' : 'PENDING',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (coach.email != null)
                          Text(
                            coach.email!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildStatChip(
                              Icons.people,
                              '${coach.clientCount}',
                              isArabic ? 'عملاء' : 'clients',
                            ),
                            const SizedBox(width: 8),
                            _buildStatChip(
                              Icons.attach_money,
                              '\$${coach.totalEarnings.toStringAsFixed(0)}',
                              isArabic ? 'أرباح' : 'earned',
                            ),
                            if (coach.averageRating != null) ...[
                              const SizedBox(width: 8),
                              _buildStatChip(
                                Icons.star,
                                coach.averageRating!.toStringAsFixed(1),
                                isArabic ? 'تقييم' : 'rating',
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
                        case 'approve':
                          _showApproveCoachDialog(coach, isArabic);
                          break;
                        case 'suspend':
                          _showSuspendCoachDialog(coach, isArabic);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      if (!coach.isApproved)
                        PopupMenuItem(
                          value: 'approve',
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, size: 18, color: AppColors.success),
                              const SizedBox(width: 8),
                              Text(isArabic ? 'الموافقة' : 'Approve'),
                            ],
                          ),
                        ),
                      PopupMenuItem(
                        value: 'suspend',
                        child: Row(
                          children: [
                            const Icon(Icons.block, size: 18, color: AppColors.error),
                            const SizedBox(width: 8),
                            Text(isArabic ? 'إيقاف' : 'Suspend'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              if (coach.specializations.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: coach.specializations.map((spec) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        spec,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showCoachDetailsDialog(AdminCoach coach, bool isArabic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(coach.fullName),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(isArabic ? 'البريد الإلكتروني' : 'Email', coach.email ?? 'N/A'),
              _buildDetailRow(isArabic ? 'الهاتف' : 'Phone', coach.phoneNumber ?? 'N/A'),
              _buildDetailRow(isArabic ? 'العملاء' : 'Clients', '${coach.clientCount}'),
              _buildDetailRow(isArabic ? 'الأرباح' : 'Earnings', '\$${coach.totalEarnings.toStringAsFixed(2)}'),
              if (coach.averageRating != null)
                _buildDetailRow(isArabic ? 'التقييم' : 'Rating', '${coach.averageRating!.toStringAsFixed(1)} ⭐'),
              _buildDetailRow(
                isArabic ? 'الحالة' : 'Status',
                coach.isApproved
                    ? (isArabic ? 'موافق عليه' : 'Approved')
                    : (isArabic ? 'بانتظار الموافقة' : 'Pending'),
              ),
              _buildDetailRow(isArabic ? 'تاريخ التسجيل' : 'Created', _formatDate(coach.createdAt)),
              if (coach.approvedAt != null)
                _buildDetailRow(isArabic ? 'تاريخ الموافقة' : 'Approved', _formatDate(coach.approvedAt!)),
              if (coach.specializations.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  isArabic ? 'التخصصات:' : 'Specializations:',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: coach.specializations.map((spec) {
                    return Chip(
                      label: Text(spec, style: const TextStyle(fontSize: 12)),
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    );
                  }).toList(),
                ),
              ],
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

  void _showApproveCoachDialog(AdminCoach coach, bool isArabic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isArabic ? 'الموافقة على المدرب' : 'Approve Coach'),
        content: Text(
          isArabic
              ? 'هل أنت متأكد من الموافقة على ${coach.fullName}؟'
              : 'Are you sure you want to approve ${coach.fullName}?',
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
              final success = await adminProvider.approveCoach(coach.id);

              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isArabic ? 'تمت الموافقة بنجاح' : 'Approved successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
                _loadCoaches();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: Text(isArabic ? 'موافقة' : 'Approve'),
          ),
        ],
      ),
    );
  }

  void _showSuspendCoachDialog(AdminCoach coach, bool isArabic) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isArabic ? 'إيقاف المدرب' : 'Suspend Coach'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isArabic
                  ? 'هل أنت متأكد من إيقاف ${coach.fullName}؟'
                  : 'Are you sure you want to suspend ${coach.fullName}?',
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
              final success = await adminProvider.suspendCoach(coach.id, reasonController.text);

              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isArabic ? 'تم الإيقاف بنجاح' : 'Suspended successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
                _loadCoaches();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(isArabic ? 'إيقاف' : 'Suspend'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _CreateCoachSheet extends StatefulWidget {
  final bool isArabic;
  final Future<bool> Function(_CoachInvitePayload payload) onSubmit;

  const _CreateCoachSheet({
    required this.isArabic,
    required this.onSubmit,
  });

  @override
  State<_CreateCoachSheet> createState() => _CreateCoachSheetState();
}

class _CreateCoachSheetState extends State<_CreateCoachSheet> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specializationController = TextEditingController();
  final List<String> _specializations = [];
  bool _sendInvite = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _specializationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = widget.isArabic;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 46,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              Text(
                isArabic ? 'إنشاء حساب مدرب' : 'Create Coach Account',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isArabic
                    ? 'سنرسل دعوة للمدرب بنفس البريد الإلكتروني ليكمل ملفه الشخصي ويحدد كلمة المرور.'
                    : 'We will email an invite so the coach can finish onboarding and set a password.',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: isArabic ? 'الاسم الكامل' : 'Full name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return isArabic ? 'الاسم مطلوب' : 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: isArabic ? 'البريد الإلكتروني' : 'Email',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return isArabic ? 'البريد الإلكتروني مطلوب' : 'Email is required';
                  }
                  if (!value.contains('@')) {
                    return isArabic ? 'صيغة البريد غير صحيحة' : 'Invalid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: isArabic ? 'رقم الهاتف (اختياري)' : 'Phone (optional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isArabic ? 'التخصصات' : 'Specializations',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _specializationController,
                      decoration: InputDecoration(
                        hintText: isArabic ? 'أدخل تخصص المدرب' : 'Add a specialty',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onSubmitted: (_) => _addSpecialization(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _addSpecialization,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    child: Text(isArabic ? 'إضافة' : 'Add'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_specializations.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _specializations.map((spec) {
                    return Chip(
                      label: Text(spec),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () => _removeSpecialization(spec),
                    );
                  }).toList(),
                )
              else
                Text(
                  isArabic ? 'لا توجد تخصصات مضافة بعد' : 'No specializations yet',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              const SizedBox(height: 16),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _sendInvite,
                onChanged: (value) {
                  setState(() => _sendInvite = value);
                },
                title: Text(isArabic ? 'إرسال دعوة عبر البريد' : 'Send onboarding email invite'),
                subtitle: Text(
                  isArabic
                      ? 'سيتلقى المدرب رابطاً لإكمال حسابه بنفس البريد.'
                      : 'Coach receives a link to finish the profile with this email.',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: _isSubmitting
                    ? (isArabic ? 'جاري الإرسال...' : 'Sending...')
                    : (isArabic ? 'إرسال الدعوة' : 'Send Invite'),
                onPressed: _isSubmitting ? null : _handleSubmit,
                fullWidth: true,
                size: ButtonSize.large,
                icon: Icons.send,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addSpecialization() {
    final value = _specializationController.text.trim();
    if (value.isEmpty) return;
    setState(() {
      _specializations.add(value);
      _specializationController.clear();
    });
  }

  void _removeSpecialization(String spec) {
    setState(() {
      _specializations.remove(spec);
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final payload = _CoachInvitePayload(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      specializations: List<String>.from(_specializations),
      sendInvite: _sendInvite,
    );

    final success = await widget.onSubmit(payload);

    if (mounted && !success) {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
}

class _CoachInvitePayload {
  final String fullName;
  final String email;
  final String? phoneNumber;
  final List<String> specializations;
  final bool sendInvite;

  const _CoachInvitePayload({
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.specializations = const [],
    this.sendInvite = true,
  });
}
