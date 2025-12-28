import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../providers/language_provider.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/custom_card.dart';
import '../../../data/models/audit_log.dart';

class AdminAuditLogsScreen extends StatefulWidget {
  const AdminAuditLogsScreen({super.key});

  @override
  State<AdminAuditLogsScreen> createState() => _AdminAuditLogsScreenState();
}

class _AdminAuditLogsScreenState extends State<AdminAuditLogsScreen> {
  String? _actionFilter;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLogs();
    });
  }

  void _loadLogs() {
    final adminProvider = context.read<AdminProvider>();
    adminProvider.loadAuditLogs(
      action: _actionFilter,
      startDate: _dateRange?.start,
      endDate: _dateRange?.end,
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final adminProvider = context.watch<AdminProvider>();
    final isArabic = languageProvider.isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'سجلات التدقيق' : 'Audit Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFiltersBottomSheet(isArabic),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLogs,
          ),
        ],
      ),
      body: Column(
        children: [
          // Active filters
          if (_actionFilter != null || _dateRange != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.primary.withOpacity(0.1),
              child: Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (_actionFilter != null)
                          Chip(
                            label: Text(_actionFilter!),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () {
                              setState(() {
                                _actionFilter = null;
                              });
                              _loadLogs();
                            },
                          ),
                        if (_dateRange != null)
                          Chip(
                            label: Text(
                              '${_dateRange!.start.day}/${_dateRange!.start.month} - ${_dateRange!.end.day}/${_dateRange!.end.month}',
                            ),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () {
                              setState(() {
                                _dateRange = null;
                              });
                              _loadLogs();
                            },
                          ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _actionFilter = null;
                        _dateRange = null;
                      });
                      _loadLogs();
                    },
                    child: Text(isArabic ? 'مسح الكل' : 'Clear All'),
                  ),
                ],
              ),
            ),

          // Logs list
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
                              onPressed: _loadLogs,
                              child: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
                            ),
                          ],
                        ),
                      )
                    : adminProvider.auditLogs.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.history,
                                  size: 64,
                                  color: AppColors.textDisabled,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  isArabic ? 'لا توجد سجلات' : 'No logs found',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async => _loadLogs(),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: adminProvider.auditLogs.length,
                              itemBuilder: (context, index) {
                                final log = adminProvider.auditLogs[index];
                                return _buildLogCard(log, isArabic);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogCard(AuditLog log, bool isArabic) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showLogDetails(log, isArabic),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getActionColor(log.action).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getActionIcon(log.action),
                  color: _getActionColor(log.action),
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              // Log info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getActionDisplayName(log.action, isArabic),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (log.userName != null)
                      Text(
                        '${isArabic ? 'المستخدم:' : 'User:'} ${log.userName}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDateTime(log.createdAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (log.ipAddress != null) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.location_on,
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              log.ipAddress!,
                              style: const TextStyle(
                                fontSize: 12,
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

              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogDetails(AuditLog log, bool isArabic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getActionDisplayName(log.action, isArabic)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(
                isArabic ? 'المستخدم' : 'User',
                log.userName ?? (isArabic ? 'النظام' : 'System'),
              ),
              _buildDetailRow(
                isArabic ? 'الإجراء' : 'Action',
                log.action,
              ),
              _buildDetailRow(
                isArabic ? 'التوقيت' : 'Time',
                _formatDateTime(log.createdAt),
              ),
              if (log.ipAddress != null)
                _buildDetailRow(
                  isArabic ? 'عنوان IP' : 'IP Address',
                  log.ipAddress!,
                ),
              if (log.userAgent != null) ...[
                const SizedBox(height: 8),
                Text(
                  isArabic ? 'معلومات المتصفح:' : 'User Agent:',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  log.userAgent!,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
              if (log.metadata != null && log.metadata!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  isArabic ? 'تفاصيل إضافية:' : 'Additional Details:',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    log.metadata.toString(),
                    style: const TextStyle(fontSize: 12),
                  ),
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
      padding: const EdgeInsets.symmetric(vertical: 6),
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

  void _showFiltersBottomSheet(bool isArabic) {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isArabic ? 'الفلاتر' : 'Filters',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Action filter
              Text(
                isArabic ? 'الإجراء' : 'Action',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                value: _actionFilter,
                decoration: InputDecoration(
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
                    value: 'user_created',
                    child: Text(isArabic ? 'مستخدم جديد' : 'User Created'),
                  ),
                  DropdownMenuItem(
                    value: 'user_updated',
                    child: Text(isArabic ? 'تحديث مستخدم' : 'User Updated'),
                  ),
                  DropdownMenuItem(
                    value: 'user_deleted',
                    child: Text(isArabic ? 'حذف مستخدم' : 'User Deleted'),
                  ),
                  DropdownMenuItem(
                    value: 'coach_approved',
                    child: Text(isArabic ? 'الموافقة على مدرب' : 'Coach Approved'),
                  ),
                  DropdownMenuItem(
                    value: 'coach_suspended',
                    child: Text(isArabic ? 'إيقاف مدرب' : 'Coach Suspended'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _actionFilter = value;
                  });
                },
              ),

              const SizedBox(height: 24),

              // Date range
              Text(
                isArabic ? 'النطاق الزمني' : 'Date Range',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  final range = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now(),
                    initialDateRange: _dateRange,
                  );
                  if (range != null) {
                    setState(() {
                      _dateRange = range;
                    });
                  }
                },
                icon: const Icon(Icons.date_range),
                label: Text(
                  _dateRange != null
                      ? '${_dateRange!.start.day}/${_dateRange!.start.month} - ${_dateRange!.end.day}/${_dateRange!.end.month}'
                      : (isArabic ? 'اختر النطاق' : 'Select Range'),
                ),
              ),

              const SizedBox(height: 24),

              // Apply button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    this.setState(() {
                      // Update outer state
                    });
                    _loadLogs();
                  },
                  child: Text(isArabic ? 'تطبيق' : 'Apply'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  IconData _getActionIcon(String action) {
    if (action.contains('created')) return Icons.add_circle;
    if (action.contains('updated')) return Icons.edit;
    if (action.contains('deleted')) return Icons.delete;
    if (action.contains('approved')) return Icons.check_circle;
    if (action.contains('suspended')) return Icons.block;
    if (action.contains('login')) return Icons.login;
    if (action.contains('logout')) return Icons.logout;
    return Icons.info;
  }

  Color _getActionColor(String action) {
    if (action.contains('created') || action.contains('approved')) return AppColors.success;
    if (action.contains('deleted') || action.contains('suspended')) return AppColors.error;
    if (action.contains('updated')) return AppColors.warning;
    return AppColors.primary;
  }

  String _getActionDisplayName(String action, bool isArabic) {
    final Map<String, Map<String, String>> names = {
      'user_created': {'en': 'User Created', 'ar': 'مستخدم جديد'},
      'user_updated': {'en': 'User Updated', 'ar': 'تحديث مستخدم'},
      'user_deleted': {'en': 'User Deleted', 'ar': 'حذف مستخدم'},
      'coach_approved': {'en': 'Coach Approved', 'ar': 'الموافقة على مدرب'},
      'coach_suspended': {'en': 'Coach Suspended', 'ar': 'إيقاف مدرب'},
      'user_login': {'en': 'User Login', 'ar': 'تسجيل دخول'},
      'user_logout': {'en': 'User Logout', 'ar': 'تسجيل خروج'},
    };

    return names[action]?[isArabic ? 'ar' : 'en'] ?? action;
  }
}
