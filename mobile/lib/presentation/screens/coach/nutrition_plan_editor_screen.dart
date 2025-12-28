import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/nutrition_plan.dart';
import '../../providers/coach_provider.dart';
import '../../providers/language_provider.dart';
import '../../widgets/custom_button.dart';
import '../../../core/constants/colors.dart';

/// Nutrition Plan Editor Screen
/// Allows coach to edit client's nutrition plan
class NutritionPlanEditorScreen extends StatefulWidget {
  final String clientId;
  final String coachId;

  const NutritionPlanEditorScreen({
    super.key,
    required this.clientId,
    required this.coachId,
  });

  @override
  State<NutritionPlanEditorScreen> createState() =>
      _NutritionPlanEditorScreenState();
}

class _NutritionPlanEditorScreenState extends State<NutritionPlanEditorScreen> {
  bool _isLoading = true;
  NutritionPlan? _currentPlan;

  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  final TextEditingController _fatsController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  Map<String, dynamic> _mealPlan = {};

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
    final plan = await provider.getClientNutritionPlan(
      widget.coachId,
      widget.clientId,
    );

    if (plan != null) {
      setState(() {
        _currentPlan = plan;
        _caloriesController.text = plan.dailyCalories?.toString() ?? '';
        _proteinController.text = plan.macros?['protein']?.toString() ?? '';
        _carbsController.text = plan.macros?['carbs']?.toString() ?? '';
        _fatsController.text = plan.macros?['fats']?.toString() ?? '';
        _notesController.text = plan.notes ?? '';
        _mealPlan = plan.mealPlan ?? {};
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
    if (_caloriesController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic ? 'الرجاء إدخال السعرات' : 'Please enter calories',
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
    final success = await provider.updateClientNutritionPlan(
      widget.coachId,
      widget.clientId,
      int.tryParse(_caloriesController.text) ?? 0,
      {
        'protein': int.tryParse(_proteinController.text) ?? 0,
        'carbs': int.tryParse(_carbsController.text) ?? 0,
        'fats': int.tryParse(_fatsController.text) ?? 0,
      },
      _mealPlan,
      _notesController.text,
    );

    Navigator.of(context).pop(); // Close loading

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic
                ? 'تم تحديث خطة التغذية بنجاح'
                : 'Nutrition plan updated successfully',
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
                ? 'فشل تحديث خطة التغذية'
                : 'Failed to update nutrition plan',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final isArabic = languageProvider.isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'تعديل خطة التغذية' : 'Edit Nutrition Plan'),
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
                                Icon(Icons.info_outline,
                                    color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(
                                  isArabic ? 'الخطة الحالية' : 'Current Plan',
                                  style: TextStyle(
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

                  // Calories section
                  Text(
                    isArabic ? 'السعرات اليومية' : 'Daily Calories',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _caloriesController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: isArabic ? 'السعرات' : 'Calories',
                      hintText: '2000',
                      suffixText: isArabic ? 'سعرة' : 'kcal',
                      border: const OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Macros section
                  Text(
                    isArabic ? 'التوزيع الغذائي' : 'Macronutrients',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _proteinController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: isArabic ? 'البروتين' : 'Protein',
                            hintText: '150',
                            suffixText: isArabic ? 'جم' : 'g',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _carbsController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: isArabic ? 'الكربوهيدرات' : 'Carbs',
                            hintText: '200',
                            suffixText: isArabic ? 'جم' : 'g',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: _fatsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: isArabic ? 'الدهون' : 'Fats',
                      hintText: '65',
                      suffixText: isArabic ? 'جم' : 'g',
                      border: const OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Meal plan preview
                  Text(
                    isArabic ? 'خطة الوجبات' : 'Meal Plan',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_mealPlan.isEmpty)
                            Text(
                              isArabic
                                  ? 'لا توجد وجبات محددة'
                                  : 'No meals specified',
                              style: TextStyle(color: Colors.grey[600]),
                            )
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _mealPlan.keys.map((mealType) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Text(
                                    '• $mealType: ${_mealPlan[mealType].length} ${isArabic ? 'وجبات' : 'meals'}',
                                  ),
                                );
                              }).toList(),
                            ),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: () {
                              // Navigate to meal plan builder
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isArabic
                                        ? 'استخدم منشئ الوجبات الكامل'
                                        : 'Use full meal plan builder',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit),
                            label: Text(
                                isArabic ? 'تعديل الوجبات' : 'Edit Meals'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Notes
                  Text(
                    isArabic ? 'ملاحظات' : 'Notes',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
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
}
