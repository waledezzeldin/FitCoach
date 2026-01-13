import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/workout_plan.dart';
import '../../providers/coach_provider.dart';
import '../../providers/language_provider.dart';
import '../../widgets/custom_button.dart';
import '../../../core/constants/colors.dart';

/// Workout Plan Editor Screen
/// Allows coach to edit client's workout plan
class WorkoutPlanEditorScreen extends StatefulWidget {
  final String clientId;
  final String coachId;

  const WorkoutPlanEditorScreen({
    super.key,
    required this.clientId,
    required this.coachId,
  });

  @override
  State<WorkoutPlanEditorScreen> createState() =>
      _WorkoutPlanEditorScreenState();
}

class _WorkoutPlanEditorScreenState extends State<WorkoutPlanEditorScreen> {
  bool _isLoading = true;
  WorkoutPlan? _currentPlan;
  final TextEditingController _notesController = TextEditingController();

  // Plan data structure
  Map<String, dynamic> _planData = {};

  @override
  void initState() {
    super.initState();
    _loadCurrentPlan();
  }

  Future<void> _loadCurrentPlan() async {
    setState(() {
      _isLoading = true;
    });

    final provider = Provider.of<CoachProvider>(context, listen: false);
    final plan = await provider.getClientWorkoutPlan(
      widget.coachId,
      widget.clientId,
    );

    if (plan != null) {
      setState(() {
        _currentPlan = plan;
        _planData = plan.planData ?? {};
        _notesController.text = plan.notes ?? '';
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _savePlan() async {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    final isArabic = languageProvider.isArabic;

    // Validate
    if (_planData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic ? 'الرجاء إضافة تمارين' : 'Please add exercises',
          ),
        ),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final provider = Provider.of<CoachProvider>(context, listen: false);
    final success = await provider.updateClientWorkoutPlan(
      widget.coachId,
      widget.clientId,
      _planData,
      _notesController.text,
    );

    // ignore: use_build_context_synchronously
    Navigator.of(context).pop(); // Close loading

    if (success) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic
                ? 'تم تحديث خطة التمرين بنجاح'
                : 'Workout plan updated successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true); // Go back with success
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic
                ? 'فشل تحديث خطة التمرين'
                : 'Failed to update workout plan',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final isArabic = languageProvider.isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'تعديل خطة التمرين' : 'Edit Workout Plan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _savePlan,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current plan info
                  if (_currentPlan != null)
                    Card(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.info_outline,
                                    color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(
                                  isArabic ? 'الخطة الحالية' : 'Current Plan',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (_currentPlan!.customizedByCoach == true)
                              Text(
                                isArabic
                                    ? '✓ مخصصة من قبل المدرب'
                                    : '✓ Customized by coach',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Plan editor
                  Text(
                    isArabic ? 'تفاصيل الخطة' : 'Plan Details',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Weeks/Days structure
                  _buildWeeksList(),

                  const SizedBox(height: 24),

                  // Notes
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: isArabic ? 'ملاحظات' : 'Notes',
                      hintText: isArabic
                          ? 'أضف ملاحظات للعميل'
                          : 'Add notes for client',
                      border: const OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Save button
                  CustomButton(
                    text: isArabic ? 'حفظ التغييرات' : 'Save Changes',
                    onPressed: _savePlan,
                    icon: Icons.save,
                  ),

                  const SizedBox(height: 16),

                  // Cancel button
                  CustomButton(
                    text: isArabic ? 'إلغاء' : 'Cancel',
                    onPressed: () => Navigator.of(context).pop(),
                    variant: ButtonVariant.secondary,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildWeeksList() {
    final languageProvider = context.read<LanguageProvider>();
    final isArabic = languageProvider.isArabic;

    if (_planData['weeks'] == null) {
      _planData['weeks'] = [];
    }

    List<dynamic> weeks = _planData['weeks'];

    return Column(
      children: [
        // Add week button
        OutlinedButton.icon(
          onPressed: _addWeek,
          icon: const Icon(Icons.add),
          label: Text(isArabic ? 'إضافة أسبوع' : 'Add Week'),
        ),
        const SizedBox(height: 16),

        // Weeks list
        ...List.generate(weeks.length, (weekIndex) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ExpansionTile(
              title: Text(
                isArabic
                    ? 'الأسبوع ${weekIndex + 1}'
                    : 'Week ${weekIndex + 1}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeWeek(weekIndex),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'الأيام' : 'Days',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _buildDaysList(weekIndex),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDaysList(int weekIndex) {
    final languageProvider = context.read<LanguageProvider>();
    final isArabic = languageProvider.isArabic;

    List<dynamic> weeks = _planData['weeks'];
    if (weeks[weekIndex]['days'] == null) {
      weeks[weekIndex]['days'] = [];
    }

    List<dynamic> days = weeks[weekIndex]['days'];

    return Column(
      children: [
        // Add day button
        TextButton.icon(
          onPressed: () => _addDay(weekIndex),
          icon: const Icon(Icons.add),
          label: Text(isArabic ? 'إضافة يوم' : 'Add Day'),
        ),

        // Days list
        ...List.generate(days.length, (dayIndex) {
          return ListTile(
            title: Text(
              isArabic ? 'اليوم ${dayIndex + 1}' : 'Day ${dayIndex + 1}',
            ),
            subtitle: Text(
              '${days[dayIndex]['exercises']?.length ?? 0} ${isArabic ? 'تمارين' : 'exercises'}',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeDay(weekIndex, dayIndex),
            ),
            onTap: () => _editDay(weekIndex, dayIndex),
          );
        }),
      ],
    );
  }

  void _addWeek() {
    setState(() {
      List<dynamic> weeks = _planData['weeks'] ?? [];
      weeks.add({
        'weekNumber': weeks.length + 1,
        'days': [],
      });
      _planData['weeks'] = weeks;
    });
  }

  void _removeWeek(int weekIndex) {
    setState(() {
      List<dynamic> weeks = _planData['weeks'];
      weeks.removeAt(weekIndex);
    });
  }

  void _addDay(int weekIndex) {
    setState(() {
      List<dynamic> weeks = _planData['weeks'];
      List<dynamic> days = weeks[weekIndex]['days'] ?? [];
      days.add({
        'dayNumber': days.length + 1,
        'exercises': [],
      });
      weeks[weekIndex]['days'] = days;
    });
  }

  void _removeDay(int weekIndex, int dayIndex) {
    setState(() {
      List<dynamic> weeks = _planData['weeks'];
      List<dynamic> days = weeks[weekIndex]['days'];
      days.removeAt(dayIndex);
    });
  }

  void _editDay(int weekIndex, int dayIndex) {
    final languageProvider = context.read<LanguageProvider>();
    final isArabic = languageProvider.isArabic;

    // Show dialog to edit exercises
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isArabic ? 'تمارين اليوم' : 'Day Exercises',
        ),
        content: Text(
          isArabic
              ? 'استخدم شاشة بناء الخطة الكاملة لتعديل التمارين'
              : 'Use the full plan builder to edit exercises',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(isArabic ? 'حسناً' : 'OK'),
          ),
        ],
      ),
    );
  }
}
