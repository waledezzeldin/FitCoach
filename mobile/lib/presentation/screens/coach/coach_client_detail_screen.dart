import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../providers/language_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/coach_provider.dart';
import '../../widgets/custom_card.dart';
// ...existing code...
import 'workout_plan_editor_screen.dart';
import 'nutrition_plan_editor_screen.dart';

class CoachClientDetailScreen extends StatefulWidget {
  final String clientId;

  const CoachClientDetailScreen({
    super.key,
    required this.clientId,
  });

  @override
  State<CoachClientDetailScreen> createState() => _CoachClientDetailScreenState();
}

class _CoachClientDetailScreenState extends State<CoachClientDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadClientDetails();
    });
  }

  void _loadClientDetails() {
    final authProvider = context.read<AuthProvider>();
    final coachProvider = context.read<CoachProvider>();
    
    if (authProvider.user?.id != null) {
      coachProvider.loadClientDetails(
        coachId: authProvider.user!.id,
        clientId: widget.clientId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final authProvider = context.watch<AuthProvider>();
    final coachProvider = context.watch<CoachProvider>();
    final isArabic = languageProvider.isArabic;
    final client = coachProvider.selectedClient;

    return Scaffold(
      appBar: AppBar(
        title: Text(client?.fullName ?? (isArabic ? 'تفاصيل العميل' : 'Client Details')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadClientDetails,
          ),
        ],
      ),
      body: coachProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : coachProvider.error != null || client == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        coachProvider.error ?? (isArabic ? 'فشل تحميل البيانات' : 'Failed to load data'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.error),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadClientDetails,
                        child: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async => _loadClientDetails(),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Client header
                        _buildClientHeader(client, isArabic),
                        
                        const SizedBox(height: 24),
                        
                        // Fitness score section
                        _buildFitnessScoreSection(client, authProvider, isArabic),
                        
                        const SizedBox(height: 16),
                        
                        // Plans section
                        _buildPlansSection(client, isArabic),
                        
                        const SizedBox(height: 16),
                        
                        // Activity section
                        _buildActivitySection(client, isArabic),
                        
                        const SizedBox(height: 16),
                        
                        // Contact section
                        _buildContactSection(client, isArabic),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildClientHeader(client, bool isArabic) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              backgroundImage: client.profilePhotoUrl != null
                  ? NetworkImage(client.profilePhotoUrl!)
                  : null,
              child: client.profilePhotoUrl == null
                  ? Text(
                      client.initials,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                    )
                  : null,
            ),
            
            const SizedBox(height: 16),
            
            Text(
              client.fullName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            // Badges
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                // Subscription tier
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getTierColor(client.subscriptionTier),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    client.subscriptionTier,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                // Status
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(client.statusText),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    client.statusText,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            if (client.goal != null) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.flag, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    client.goal!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFitnessScoreSection(client, AuthProvider authProvider, bool isArabic) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isArabic ? 'نتيجة اللياقة' : 'Fitness Score',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showAssignScoreDialog(authProvider, isArabic),
                  icon: const Icon(Icons.edit, size: 16),
                  label: Text(isArabic ? 'تعديل' : 'Edit'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: client.fitnessScore != null
                      ? _getScoreColor(client.fitnessScore!)
                      : AppColors.textDisabled,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        client.fitnessScore?.toString() ?? '--',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        isArabic ? 'من 100' : 'out of 100',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlansSection(client, bool isArabic) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic ? 'الخطط المعينة' : 'Assigned Plans',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Workout plan
            ListTile(
              leading: const Icon(Icons.fitness_center, color: AppColors.primary),
              title: Text(isArabic ? 'خطة التمرين' : 'Workout Plan'),
              subtitle: Text(
                client.workoutPlanName ?? (isArabic ? 'غير معينة' : 'Not assigned'),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                final authProvider = context.read<AuthProvider>();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkoutPlanEditorScreen(
                      clientId: client.id,
                      coachId: authProvider.user!.id,
                    ),
                  ),
                ).then((_) => _loadClientDetails()); // Reload after editing
              },
            ),
            
            const Divider(),
            
            // Nutrition plan
            ListTile(
              leading: const Icon(Icons.restaurant, color: AppColors.success),
              title: Text(isArabic ? 'خطة التغذية' : 'Nutrition Plan'),
              subtitle: Text(
                client.nutritionPlanName ?? (isArabic ? 'غير معينة' : 'Not assigned'),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                final authProvider = context.read<AuthProvider>();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NutritionPlanEditorScreen(
                      clientId: client.id,
                      coachId: authProvider.user!.id,
                    ),
                  ),
                ).then((_) => _loadClientDetails()); // Reload after editing
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySection(client, bool isArabic) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic ? 'النشاط' : 'Activity',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Assigned date
            if (client.assignedDate != null)
              _buildInfoRow(
                icon: Icons.calendar_today,
                label: isArabic ? 'تاريخ التعيين' : 'Assigned Date',
                value: _formatDate(client.assignedDate!),
              ),
            
            const SizedBox(height: 12),
            
            // Last activity
            if (client.lastActivity != null)
              _buildInfoRow(
                icon: Icons.access_time,
                label: isArabic ? 'آخر نشاط' : 'Last Activity',
                value: _formatDate(client.lastActivity!),
              ),
            
            const SizedBox(height: 12),
            
            // Message count
            _buildInfoRow(
              icon: Icons.message,
              label: isArabic ? 'عدد الرسائل' : 'Messages',
              value: '${client.messageCount}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection(client, bool isArabic) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic ? 'معلومات الاتصال' : 'Contact Information',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Email
            if (client.email != null)
              _buildInfoRow(
                icon: Icons.email,
                label: isArabic ? 'البريد الإلكتروني' : 'Email',
                value: client.email!,
              ),
            
            if (client.email != null && client.phoneNumber != null)
              const SizedBox(height: 12),
            
            // Phone
            if (client.phoneNumber != null)
              _buildInfoRow(
                icon: Icons.phone,
                label: isArabic ? 'الهاتف' : 'Phone',
                value: client.phoneNumber!,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAssignScoreDialog(AuthProvider authProvider, bool isArabic) {
    final coachProvider = context.read<CoachProvider>();
    final client = coachProvider.selectedClient;
    if (client == null) return;

    int score = client.fitnessScore ?? 50;
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isArabic ? 'تعيين نتيجة اللياقة' : 'Assign Fitness Score'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: _getScoreColor(score),
                ),
              ),
              
              Slider(
                value: score.toDouble(),
                min: 0,
                max: 100,
                divisions: 100,
                label: score.toString(),
                onChanged: (value) {
                  setState(() {
                    score = value.round();
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: isArabic ? 'ملاحظات (اختياري)' : 'Notes (optional)',
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
                Navigator.pop(context);
                
                final success = await coachProvider.assignFitnessScore(
                  coachId: authProvider.user!.id,
                  clientId: client.id,
                  fitnessScore: score,
                  notes: notesController.text.isNotEmpty ? notesController.text : null,
                );
                
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isArabic 
                            ? 'تم تعيين النتيجة بنجاح'
                            : 'Fitness score assigned successfully',
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(coachProvider.error ?? 'Failed to assign score'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              child: Text(isArabic ? 'تعيين' : 'Assign'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getTierColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'smart premium':
        return const Color(0xFFFFD700);
      case 'premium':
        return AppColors.primary;
      case 'freemium':
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'recent':
        return AppColors.warning;
      case 'inactive':
        return AppColors.error;
      case 'new':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    return AppColors.error;
  }
}