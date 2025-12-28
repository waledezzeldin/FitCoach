import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../providers/language_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_button.dart';

class NutritionPlanBuilderScreen extends StatefulWidget {
  final String clientId;
  final String clientName;
  
  const NutritionPlanBuilderScreen({
    super.key,
    required this.clientId,
    required this.clientName,
  });

  @override
  State<NutritionPlanBuilderScreen> createState() => _NutritionPlanBuilderScreenState();
}

class _NutritionPlanBuilderScreenState extends State<NutritionPlanBuilderScreen> {
  final TextEditingController _planNameController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  
  String _selectedGoal = 'fat_loss';
  List<Map<String, dynamic>> _meals = [];
  
  @override
  void initState() {
    super.initState();
    _initializeMeals();
  }
  
  void _initializeMeals() {
    _meals = [
      {'type': 'breakfast', 'name': 'Breakfast', 'foods': []},
      {'type': 'lunch', 'name': 'Lunch', 'foods': []},
      {'type': 'dinner', 'name': 'Dinner', 'foods': []},
      {'type': 'snack', 'name': 'Snack', 'foods': []},
    ];
  }
  
  @override
  void dispose() {
    _planNameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final isArabic = languageProvider.isArabic;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'إنشاء خطة تغذية' : 'Create Nutrition Plan'),
        actions: [
          TextButton(
            onPressed: () => _savePlan(isArabic),
            child: Text(
              isArabic ? 'حفظ' : 'Save',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Client info
            CustomCard(
              color: AppColors.success.withValues(alpha: 0.1),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.success,
                    child: Icon(Icons.restaurant, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'العميل' : 'Client',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        widget.clientName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Plan name
            Text(
              isArabic ? 'اسم الخطة' : 'Plan Name',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _planNameController,
              decoration: InputDecoration(
                hintText: isArabic ? 'مثال: خطة حرق الدهون' : 'e.g., Fat Loss Plan',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Daily targets
            Text(
              isArabic ? 'الأهداف اليومية' : 'Daily Targets',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildMacroInput(
                    controller: _caloriesController,
                    label: isArabic ? 'السعرات' : 'Calories',
                    hint: '2000',
                    icon: Icons.local_fire_department,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMacroInput(
                    controller: _proteinController,
                    label: isArabic ? 'البروتين (جم)' : 'Protein (g)',
                    hint: '150',
                    icon: Icons.egg,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildMacroInput(
                    controller: _carbsController,
                    label: isArabic ? 'الكربوهيدرات (جم)' : 'Carbs (g)',
                    hint: '200',
                    icon: Icons.grain,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMacroInput(
                    controller: _fatController,
                    label: isArabic ? 'الدهون (جم)' : 'Fat (g)',
                    hint: '60',
                    icon: Icons.water_drop,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Goal
            Text(
              isArabic ? 'الهدف' : 'Goal',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['fat_loss', 'muscle_gain', 'maintenance'].map((goal) {
                final isSelected = _selectedGoal == goal;
                return FilterChip(
                  label: Text(_getGoalLabel(goal, isArabic)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedGoal = goal;
                    });
                  },
                  selectedColor: AppColors.success.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.success,
                );
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            
            // Meals
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isArabic ? 'الوجبات' : 'Meals',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _addFromTemplate(isArabic),
                  icon: const Icon(Icons.file_copy, size: 18),
                  label: Text(isArabic ? 'من قالب' : 'From Template'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            ..._meals.map((meal) => _buildMealCard(meal, isArabic)).toList(),
            
            const SizedBox(height: 32),
            
            // Save button
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: isArabic ? 'حفظ الخطة' : 'Save Plan',
                onPressed: () => _savePlan(isArabic),
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
  
  Widget _buildMacroInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color color,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: color, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
  
  Widget _buildMealCard(Map<String, dynamic> meal, bool isArabic) {
    final foods = meal['foods'] as List;
    final mealType = meal['type'] as String;
    
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    _getMealIcon(mealType),
                    color: AppColors.success,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _getMealLabel(mealType, isArabic),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 20),
                onPressed: () => _addFood(mealType, isArabic),
              ),
            ],
          ),
          
          if (foods.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  isArabic ? 'لا توجد أطعمة' : 'No foods',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            ...foods.asMap().entries.map((entry) {
              final index = entry.key;
              final food = entry.value;
              return ListTile(
                leading: const Icon(Icons.restaurant_menu, size: 20),
                title: Text(food['name'] ?? ''),
                subtitle: Text(
                  '${food['calories']} cal | P: ${food['protein']}g | C: ${food['carbs']}g | F: ${food['fat']}g',
                  style: const TextStyle(fontSize: 11),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, size: 20, color: AppColors.error),
                  onPressed: () {
                    setState(() {
                      foods.removeAt(index);
                    });
                  },
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
  
  IconData _getMealIcon(String type) {
    switch (type) {
      case 'breakfast':
        return Icons.breakfast_dining;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      case 'snack':
        return Icons.cookie;
      default:
        return Icons.restaurant;
    }
  }
  
  String _getMealLabel(String type, bool isArabic) {
    final labels = {
      'breakfast': isArabic ? 'إفطار' : 'Breakfast',
      'lunch': isArabic ? 'غداء' : 'Lunch',
      'dinner': isArabic ? 'عشاء' : 'Dinner',
      'snack': isArabic ? 'وجبة خفيفة' : 'Snack',
    };
    return labels[type] ?? type;
  }
  
  String _getGoalLabel(String goal, bool isArabic) {
    final labels = {
      'fat_loss': isArabic ? 'حرق دهون' : 'Fat Loss',
      'muscle_gain': isArabic ? 'بناء عضلات' : 'Muscle Gain',
      'maintenance': isArabic ? 'حفاظ' : 'Maintenance',
    };
    return labels[goal] ?? goal;
  }
  
  void _addFood(String mealType, bool isArabic) {
    showDialog(
      context: context,
      builder: (context) {
        String foodName = '';
        int calories = 0;
        int protein = 0;
        int carbs = 0;
        int fat = 0;
        
        return AlertDialog(
          title: Text(isArabic ? 'إضافة طعام' : 'Add Food'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: isArabic ? 'اسم الطعام' : 'Food Name',
                  ),
                  onChanged: (value) => foodName = value,
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    labelText: isArabic ? 'السعرات' : 'Calories',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => calories = int.tryParse(value) ?? 0,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: isArabic ? 'بروتين' : 'Protein',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => protein = int.tryParse(value) ?? 0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: isArabic ? 'كارب' : 'Carbs',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => carbs = int.tryParse(value) ?? 0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: isArabic ? 'دهون' : 'Fat',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => fat = int.tryParse(value) ?? 0,
                      ),
                    ),
                  ],
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
                if (foodName.isNotEmpty) {
                  setState(() {
                    final meal = _meals.firstWhere((m) => m['type'] == mealType);
                    (meal['foods'] as List).add({
                      'name': foodName,
                      'calories': calories,
                      'protein': protein,
                      'carbs': carbs,
                      'fat': fat,
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: Text(isArabic ? 'إضافة' : 'Add'),
            ),
          ],
        );
      },
    );
  }
  
  void _addFromTemplate(bool isArabic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isArabic ? 'اختر قالب' : 'Choose Template'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(isArabic ? 'قالب حرق الدهون' : 'Fat Loss Template'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Load template
              },
            ),
            ListTile(
              title: Text(isArabic ? 'قالب بناء العضلات' : 'Muscle Gain Template'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Load template
              },
            ),
            ListTile(
              title: Text(isArabic ? 'قالب متوازن' : 'Balanced Template'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Load template
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _savePlan(bool isArabic) {
    if (_planNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic ? 'الرجاء إدخال اسم الخطة' : 'Please enter plan name',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    // TODO: Save to API
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isArabic ? 'تم حفظ الخطة بنجاح' : 'Plan saved successfully',
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
