import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../providers/language_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_stat_info_card.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  String _selectedPeriod = 'week';
  
  final Map<String, List<double>> _mockData = {
    'weight': [75.0, 74.8, 74.5, 74.3, 74.0, 73.8, 73.5],
    'workouts': [1, 1, 0, 1, 1, 0, 1],
    'calories': [1800, 2000, 1900, 2100, 1950, 2050, 1850],
  };

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final isArabic = languageProvider.isArabic;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.t('progress')),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Show full history
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period selector
            _buildPeriodSelector(isArabic),
            
            const SizedBox(height: 24),
            
            // Summary cards
            _buildSummaryCards(isArabic),
            
            const SizedBox(height: 24),
            
            // Weight chart
            _buildWeightChart(isArabic),
            
            const SizedBox(height: 24),
            
            // Workout frequency
            _buildWorkoutFrequency(isArabic),
            
            const SizedBox(height: 24),
            
            // Calories chart
            _buildCaloriesChart(isArabic),
            
            const SizedBox(height: 24),
            
            // Achievements
            _buildAchievements(isArabic),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addProgress(isArabic),
        icon: const Icon(Icons.add),
        label: Text(isArabic ? 'سجل تقدم' : 'Log Progress'),
      ),
    );
  }
  
  Widget _buildPeriodSelector(bool isArabic) {
    return Row(
      children: ['week', 'month', 'year'].map((period) {
        final isSelected = _selectedPeriod == period;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: FilterChip(
            label: Text(_getPeriodLabel(period, isArabic)),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _selectedPeriod = period;
              });
            },
            selectedColor: AppColors.primary.withValues(alpha: 0.2),
            checkmarkColor: AppColors.primary,
          ),
        );
      }).toList(),
    );
  }
  
  String _getPeriodLabel(String period, bool isArabic) {
    final labels = {
      'week': isArabic ? 'أسبوع' : 'Week',
      'month': isArabic ? 'شهر' : 'Month',
      'year': isArabic ? 'سنة' : 'Year',
    };
    return labels[period] ?? period;
  }
  
  Widget _buildSummaryCards(bool isArabic) {
    return Row(
      children: [
        Expanded(
          child: CustomStatCard(
            title: isArabic ? 'فقدت' : 'Lost',
            value: '-1.5kg',
            icon: Icons.trending_down,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomStatCard(
            title: isArabic ? 'تمارين' : 'Workouts',
            value: '24',
            icon: Icons.fitness_center,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomStatCard(
            title: isArabic ? 'متتالي' : 'Streak',
            value: '7d',
            icon: Icons.local_fire_department,
            color: AppColors.accent,
          ),
        ),
      ],
    );
  }
  
  Widget _buildWeightChart(bool isArabic) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isArabic ? 'الوزن' : 'Weight',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: CustomPaint(
              painter: _LineChartPainter(
                data: _mockData['weight']!,
                color: AppColors.primary,
              ),
              child: Container(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isArabic ? 'البداية: 75 كجم' : 'Start: 75kg',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                isArabic ? 'الحالي: 73.5 كجم' : 'Current: 73.5kg',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildWorkoutFrequency(bool isArabic) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isArabic ? 'تكرار التمارين' : 'Workout Frequency',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final hasWorkout = _mockData['workouts']![index] == 1;
              final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
              return Column(
                children: [
                  Text(
                    days[index],
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: hasWorkout 
                          ? AppColors.success 
                          : AppColors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: hasWorkout
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCaloriesChart(bool isArabic) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isArabic ? 'السعرات الحرارية' : 'Calories',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _mockData['calories']!.map((cal) {
                const maxCal = 2500;
                final height = (cal / maxCal) * 150;
                return Container(
                  width: 30,
                  height: height,
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isArabic 
                ? 'متوسط: 1950 سعرة/يوم'
                : 'Average: 1950 cal/day',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildAchievements(bool isArabic) {
    final achievements = [
      {
        'icon': Icons.emoji_events,
        'title': isArabic ? 'أول أسبوع' : 'First Week',
        'description': isArabic ? 'أكملت أسبوعك الأول' : 'Completed your first week',
        'unlocked': true,
      },
      {
        'icon': Icons.local_fire_department,
        'title': isArabic ? 'متتالي 7 أيام' : '7 Day Streak',
        'description': isArabic ? '7 أيام متتالية' : '7 consecutive days',
        'unlocked': true,
      },
      {
        'icon': Icons.star,
        'title': isArabic ? '20 تمرين' : '20 Workouts',
        'description': isArabic ? 'أكملت 20 تمرين' : 'Completed 20 workouts',
        'unlocked': false,
      },
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'الإنجازات' : 'Achievements',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...achievements.map((achievement) {
          final unlocked = achievement['unlocked'] as bool;
          return CustomCard(
            margin: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: unlocked 
                        ? AppColors.accent.withValues(alpha: 0.1)
                        : AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    achievement['icon'] as IconData,
                    color: unlocked 
                        ? AppColors.accent
                        : AppColors.textDisabled,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        achievement['title'] as String,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: unlocked 
                              ? AppColors.textPrimary
                              : AppColors.textDisabled,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        achievement['description'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (unlocked)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                  ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
  
  void _addProgress(bool isArabic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isArabic ? 'سجل تقدمك' : 'Log Your Progress',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                decoration: InputDecoration(
                  labelText: isArabic ? 'الوزن (كجم)' : 'Weight (kg)',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: isArabic ? 'ملاحظات' : 'Notes',
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isArabic 
                              ? 'تم حفظ التقدم'
                              : 'Progress saved',
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  child: Text(isArabic ? 'حفظ' : 'Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Simple line chart painter
class _LineChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;
  
  _LineChartPainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    final path = Path();
    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final minValue = data.reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;
    
    for (var i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - ((data[i] - minValue) / range) * size.height;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    canvas.drawPath(path, paint);
    
    // Draw points
    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    for (var i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - ((data[i] - minValue) / range) * size.height;
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(_LineChartPainter oldDelegate) => false;
}
