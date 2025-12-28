import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../providers/language_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_button.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  String _selectedCategory = 'all';
  String _selectedDifficulty = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  
  final List<String> _categories = [
    'all',
    'chest',
    'back',
    'shoulders',
    'arms',
    'legs',
    'core',
    'cardio',
  ];
  
  final List<String> _difficulties = ['all', 'beginner', 'intermediate', 'advanced'];
  
  // Mock exercises data
  final List<Map<String, dynamic>> _exercises = [
    {
      'id': '1',
      'nameEn': 'Bench Press',
      'nameAr': 'ضغط البنش',
      'category': 'chest',
      'difficulty': 'intermediate',
      'equipment': 'Barbell',
      'muscle': 'Chest, Triceps',
      'videoUrl': 'https://example.com/video1.mp4',
      'thumbnail': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
      'instructions': [
        'Lie flat on bench',
        'Grip bar slightly wider than shoulders',
        'Lower bar to chest',
        'Press up explosively',
      ],
    },
    {
      'id': '2',
      'nameEn': 'Squat',
      'nameAr': 'القرفصاء',
      'category': 'legs',
      'difficulty': 'beginner',
      'equipment': 'Barbell',
      'muscle': 'Quadriceps, Glutes',
      'videoUrl': 'https://example.com/video2.mp4',
      'thumbnail': 'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=400',
      'instructions': [
        'Stand with feet shoulder-width',
        'Lower body by bending knees',
        'Keep chest up and back straight',
        'Push through heels to stand',
      ],
    },
    {
      'id': '3',
      'nameEn': 'Deadlift',
      'nameAr': 'الرفعة الميتة',
      'category': 'back',
      'difficulty': 'advanced',
      'equipment': 'Barbell',
      'muscle': 'Back, Hamstrings',
      'videoUrl': 'https://example.com/video3.mp4',
      'thumbnail': 'https://images.unsplash.com/photo-1605296867304-46d5465a13f1?w=400',
      'instructions': [
        'Stand with feet hip-width',
        'Bend and grip bar',
        'Keep back straight',
        'Lift by extending hips and knees',
      ],
    },
    {
      'id': '4',
      'nameEn': 'Pull-ups',
      'nameAr': 'العقلة',
      'category': 'back',
      'difficulty': 'intermediate',
      'equipment': 'Pull-up bar',
      'muscle': 'Lats, Biceps',
      'videoUrl': 'https://example.com/video4.mp4',
      'thumbnail': 'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?w=400',
      'instructions': [
        'Hang from bar with palms facing away',
        'Pull body up until chin over bar',
        'Lower with control',
        'Repeat',
      ],
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final isArabic = languageProvider.isArabic;
    
    final filteredExercises = _exercises.where((ex) {
      if (_selectedCategory != 'all' && ex['category'] != _selectedCategory) {
        return false;
      }
      if (_selectedDifficulty != 'all' && ex['difficulty'] != _selectedDifficulty) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final name = isArabic ? ex['nameAr'] : ex['nameEn'];
        return name.toLowerCase().contains(query);
      }
      return true;
    }).toList();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'مكتبة التمارين' : 'Exercise Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilters(context, isArabic),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: isArabic ? 'ابحث عن تمرين...' : 'Search exercises...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
            ),
          ),
          
          // Category chips
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(_getCategoryName(category, isArabic)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    checkmarkColor: AppColors.primary,
                  ),
                );
              },
            ),
          ),
          
          // Exercise list
          Expanded(
            child: filteredExercises.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 80,
                          color: AppColors.textDisabled,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          isArabic
                              ? 'لم يتم العثور على تمارين'
                              : 'No exercises found',
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredExercises.length,
                    itemBuilder: (context, index) {
                      return _buildExerciseCard(
                        filteredExercises[index],
                        isArabic,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildExerciseCard(Map<String, dynamic> exercise, bool isArabic) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => _showExerciseDetail(exercise, isArabic),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              exercise['thumbnail'],
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? exercise['nameAr'] : exercise['nameEn'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  exercise['muscle'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildBadge(
                      _getDifficultyLabel(exercise['difficulty'], isArabic),
                      _getDifficultyColor(exercise['difficulty']),
                    ),
                    const SizedBox(width: 8),
                    _buildBadge(
                      exercise['equipment'],
                      AppColors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const Icon(Icons.chevron_right, color: AppColors.textDisabled),
        ],
      ),
    );
  }
  
  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  
  String _getCategoryName(String category, bool isArabic) {
    final names = {
      'all': isArabic ? 'الكل' : 'All',
      'chest': isArabic ? 'صدر' : 'Chest',
      'back': isArabic ? 'ظهر' : 'Back',
      'shoulders': isArabic ? 'أكتاف' : 'Shoulders',
      'arms': isArabic ? 'ذراعين' : 'Arms',
      'legs': isArabic ? 'أرجل' : 'Legs',
      'core': isArabic ? 'بطن' : 'Core',
      'cardio': isArabic ? 'كارديو' : 'Cardio',
    };
    return names[category] ?? category;
  }
  
  String _getDifficultyLabel(String difficulty, bool isArabic) {
    final labels = {
      'beginner': isArabic ? 'مبتدئ' : 'Beginner',
      'intermediate': isArabic ? 'متوسط' : 'Intermediate',
      'advanced': isArabic ? 'متقدم' : 'Advanced',
    };
    return labels[difficulty] ?? difficulty;
  }
  
  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'beginner':
        return AppColors.success;
      case 'intermediate':
        return AppColors.warning;
      case 'advanced':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
  
  void _showFilters(BuildContext context, bool isArabic) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic ? 'المستوى' : 'Difficulty Level',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _difficulties.map((diff) {
                final isSelected = _selectedDifficulty == diff;
                return FilterChip(
                  label: Text(_getDifficultyLabel(diff, isArabic)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedDifficulty = diff;
                    });
                    Navigator.pop(context);
                  },
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.primary,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showExerciseDetail(Map<String, dynamic> exercise, bool isArabic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Video thumbnail with play button
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        exercise['thumbnail'],
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Title
                Text(
                  isArabic ? exercise['nameAr'] : exercise['nameEn'],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Badges
                Row(
                  children: [
                    _buildBadge(
                      _getDifficultyLabel(exercise['difficulty'], isArabic),
                      _getDifficultyColor(exercise['difficulty']),
                    ),
                    const SizedBox(width: 8),
                    _buildBadge(
                      exercise['equipment'],
                      AppColors.textSecondary,
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Target muscles
                _buildSection(
                  isArabic ? 'العضلات المستهدفة' : 'Target Muscles',
                  exercise['muscle'],
                  isArabic,
                ),
                
                const SizedBox(height: 24),
                
                // Instructions
                Text(
                  isArabic ? 'التعليمات' : 'Instructions',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...List<Widget>.generate(
                  exercise['instructions'].length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            exercise['instructions'][index],
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Add to workout button
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: isArabic ? 'إضافة إلى التمرين' : 'Add to Workout',
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isArabic
                                ? 'تمت الإضافة إلى التمرين'
                                : 'Added to workout',
                          ),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    variant: ButtonVariant.primary,
                    size: ButtonSize.large,
                    fullWidth: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSection(String title, String content, bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
