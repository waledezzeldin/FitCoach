import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../providers/language_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_button.dart';

class WorkoutPlanBuilderScreen extends StatefulWidget {
  final String clientId;
  final String clientName;
  
  const WorkoutPlanBuilderScreen({
    super.key,
    required this.clientId,
    required this.clientName,
  });

  @override
  State<WorkoutPlanBuilderScreen> createState() => _WorkoutPlanBuilderScreenState();
}

class _WorkoutPlanBuilderScreenState extends State<WorkoutPlanBuilderScreen> {
  final TextEditingController _planNameController = TextEditingController();
  final TextEditingController _planDescriptionController = TextEditingController();
  
  String _selectedGoal = 'fat_loss';
  int _daysPerWeek = 3;
  List<Map<String, dynamic>> _workoutDays = [];
  
  @override
  void initState() {
    super.initState();
    _initializeWorkoutDays();
  }
  
  void _initializeWorkoutDays() {
    _workoutDays = List.generate(_daysPerWeek, (index) => {
      'day': index + 1,
      'name': 'Day ${index + 1}',
      'exercises': <Map<String, dynamic>>[],
    });
  }
  
  @override
  void dispose() {
    _planNameController.dispose();
    _planDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final isArabic = languageProvider.isArabic;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'إنشاء خطة تمرين' : 'Create Workout Plan'),
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
              color: AppColors.primary.withValues(alpha: 0.1),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.person, color: Colors.white),
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
                hintText: isArabic ? 'مثال: خطة تحول الجسم' : 'e.g., Body Transformation Plan',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Description
            Text(
              isArabic ? 'الوصف' : 'Description',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _planDescriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: isArabic
                    ? 'وصف مختصر للخطة...'
                    : 'Brief description of the plan...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Goal selection
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
              children: ['fat_loss', 'muscle_gain', 'general_fitness'].map((goal) {
                final isSelected = _selectedGoal == goal;
                return FilterChip(
                  label: Text(_getGoalLabel(goal, isArabic)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedGoal = goal;
                    });
                  },
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.primary,
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
            
            // Days per week
            Text(
              isArabic ? 'أيام التمرين في الأسبوع' : 'Workout Days Per Week',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(7, (index) {
                final day = index + 1;
                final isSelected = _daysPerWeek == day;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _daysPerWeek = day;
                        _initializeWorkoutDays();
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.white,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '$day',
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            
            const SizedBox(height: 24),
            
            // Workout days
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isArabic ? 'أيام التمرين' : 'Workout Days',
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
            
            ..._workoutDays.asMap().entries.map((entry) {
              final index = entry.key;
              final day = entry.value;
              return _buildWorkoutDayCard(day, index, isArabic);
            }).toList(),
            
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
  
  Widget _buildWorkoutDayCard(Map<String, dynamic> day, int index, bool isArabic) {
    final exercises = day['exercises'] as List<Map<String, dynamic>>;
    
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isArabic ? 'اليوم ${day['day']}' : 'Day ${day['day']}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => _editDayName(index, isArabic),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 20),
                    onPressed: () => _addExercise(index, isArabic),
                  ),
                ],
              ),
            ],
          ),
          
          if (exercises.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.fitness_center,
                      size: 40,
                      color: AppColors.textDisabled,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isArabic ? 'لا توجد تمارين' : 'No exercises',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...exercises.asMap().entries.map((entry) {
              final exerciseIndex = entry.key;
              final exercise = entry.value;
              return ListTile(
                leading: const Icon(Icons.fitness_center, size: 20),
                title: Text(exercise['name'] ?? 'Exercise'),
                subtitle: Text(
                  '${exercise['sets']} sets × ${exercise['reps']} reps',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, size: 20, color: AppColors.error),
                  onPressed: () {
                    setState(() {
                      exercises.removeAt(exerciseIndex);
                    });
                  },
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
  
  String _getGoalLabel(String goal, bool isArabic) {
    final labels = {
      'fat_loss': isArabic ? 'حرق دهون' : 'Fat Loss',
      'muscle_gain': isArabic ? 'بناء عضلات' : 'Muscle Gain',
      'general_fitness': isArabic ? 'لياقة عامة' : 'General Fitness',
    };
    return labels[goal] ?? goal;
  }
  
  void _editDayName(int index, bool isArabic) {
    final controller = TextEditingController(text: _workoutDays[index]['name']);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isArabic ? 'تسمية اليوم' : 'Name Day'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: isArabic ? 'مثال: صدر وذراعين' : 'e.g., Chest & Arms',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _workoutDays[index]['name'] = controller.text;
              });
              Navigator.pop(context);
            },
            child: Text(isArabic ? 'حفظ' : 'Save'),
          ),
        ],
      ),
    );
  }
  
  void _addExercise(int dayIndex, bool isArabic) {
    showDialog(
      context: context,
      builder: (context) {
        String exerciseName = '';
        int sets = 3;
        int reps = 12;
        
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text(isArabic ? 'إضافة تمرين' : 'Add Exercise'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: isArabic ? 'اسم التمرين' : 'Exercise Name',
                      hintText: isArabic ? 'مثال: ضغط البنش' : 'e.g., Bench Press',
                    ),
                    onChanged: (value) => exerciseName = value,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: isArabic ? 'المجموعات' : 'Sets',
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) => sets = int.tryParse(value) ?? 3,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: isArabic ? 'التكرارات' : 'Reps',
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) => reps = int.tryParse(value) ?? 12,
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
                  if (exerciseName.isNotEmpty) {
                    setState(() {
                      (_workoutDays[dayIndex]['exercises'] as List).add({
                        'name': exerciseName,
                        'sets': sets,
                        'reps': reps,
                      });
                    });
                    Navigator.pop(context);
                  }
                },
                child: Text(isArabic ? 'إضافة' : 'Add'),
              ),
            ],
          ),
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
              title: Text(isArabic ? 'قالب المبتدئين' : 'Beginner Template'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Load template
              },
            ),
            ListTile(
              title: Text(isArabic ? 'قالب متوسط' : 'Intermediate Template'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Load template
              },
            ),
            ListTile(
              title: Text(isArabic ? 'قالب متقدم' : 'Advanced Template'),
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
