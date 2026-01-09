import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/config/demo_config.dart';
import '../../../core/constants/colors.dart';
import '../../../data/repositories/workout_repository.dart';
import '../../../data/models/inbody_model.dart';
import '../../providers/language_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_button.dart';
import '../subscription/subscription_manager_screen.dart';

class InBodyInputScreen extends StatefulWidget {
  const InBodyInputScreen({super.key});

  @override
  State<InBodyInputScreen> createState() => _InBodyInputScreenState();
}

class _InBodyInputScreenState extends State<InBodyInputScreen> {
  String _inputMode = 'selection'; // 'selection', 'ai-scan', 'manual'
  File? _selectedImage;
  bool _isAnalyzing = false;
  bool _extractionComplete = false;
  Map<String, dynamic>? _extractedData;
  final ImagePicker _picker = ImagePicker();
  
  // InBody metrics
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _bodyFatController = TextEditingController();
  final TextEditingController _muscleMassController = TextEditingController();
  final TextEditingController _bmiController = TextEditingController();
  final TextEditingController _visceralFatController = TextEditingController();
  final TextEditingController _bodyWaterController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _mineralController = TextEditingController();
  final TextEditingController _bmrController = TextEditingController();
  
  @override
  void dispose() {
    _weightController.dispose();
    _bodyFatController.dispose();
    _muscleMassController.dispose();
    _bmiController.dispose();
    _visceralFatController.dispose();
    _bodyWaterController.dispose();
    _proteinController.dispose();
    _mineralController.dispose();
    _bmrController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isArabic = languageProvider.isArabic;
    final subscriptionTier = authProvider.user?.subscriptionTier ?? 'Freemium';
    final isPremium = subscriptionTier == 'Premium' || subscriptionTier == 'Smart Premium';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'تحليل InBody' : 'InBody Analysis'),
      ),
      body: _inputMode == 'selection'
          ? _buildModeSelection(isArabic, isPremium)
          : _inputMode == 'ai-scan'
              ? _buildAIScan(isArabic)
              : _buildManualInput(isArabic),
    );
  }
  
  Widget _buildModeSelection(bool isArabic, bool isPremium) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isArabic ? 'اختر طريقة الإدخال' : 'Choose Input Method',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isArabic
                ? 'كيف تريد إدخال بيانات InBody الخاصة بك؟'
                : 'How would you like to enter your InBody data?',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          
          // AI Scan option
          Stack(
            children: [
              Opacity(
                opacity: isPremium ? 1.0 : 0.6,
                child: CustomCard(
                  onTap: isPremium
                      ? () {
                          setState(() {
                            _inputMode = 'ai-scan';
                          });
                        }
                      : () {
                          // Show upgrade dialog
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SubscriptionManagerScreen(),
                            ),
                          );
                        },
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: isPremium
                              ? const LinearGradient(
                                  colors: [AppColors.primary, AppColors.accent],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: isPremium ? null : AppColors.textDisabled.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.auto_awesome,
                          color: isPremium ? Colors.white : AppColors.textDisabled,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  isArabic ? 'مسح بالذكاء الاصطناعي' : 'AI Scan',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (!isPremium)
                                  const Icon(
                                    Icons.lock,
                                    size: 16,
                                    color: AppColors.textDisabled,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isArabic
                                  ? 'التقط صورة لتقرير InBody الخاص بك'
                                  : 'Take a photo of your InBody report',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (isPremium)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      size: 16,
                                      color: AppColors.success,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      isArabic ? 'استخراج فوري للبيانات' : 'Instant data extraction',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.success,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: CustomButton(
                                  text: isArabic ? 'ترقية للذكاء الاصطناعي' : 'Upgrade for AI',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const SubscriptionManagerScreen(),
                                      ),
                                    );
                                  },
                                  size: ButtonSize.small,
                                  variant: ButtonVariant.outline,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: isPremium ? AppColors.textSecondary : AppColors.textDisabled,
                      ),
                    ],
                  ),
                ),
              ),
              // Premium badge
              if (!isPremium)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF97316), Color(0xFFEC4899)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.workspace_premium,
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isArabic ? 'ميزة بريميوم' : 'Premium Feature',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Manual input option
          CustomCard(
            onTap: () {
              setState(() {
                _inputMode = 'manual';
              });
            },
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: AppColors.success,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'إدخال يدوي' : 'Manual Input',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isArabic
                            ? 'أدخل القياسات يدوياً'
                            : 'Enter measurements manually',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            size: 16,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isArabic ? 'متاح لجميع المستخدمين' : 'Available for all users',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textDisabled),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Info card
          CustomCard(
            color: AppColors.primary.withValues(alpha: 0.05),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isArabic
                        ? 'يساعدك تحليل InBody على تتبع تكوين جسمك بدقة وتحديد أهداف واقعية'
                        : 'InBody analysis helps you track your body composition accurately and set realistic goals',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAIScan(bool isArabic) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            height: 400,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, width: 2),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.camera_alt_outlined,
                    size: 80,
                    color: AppColors.textDisabled,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isArabic ? 'التقط صورة لتقرير InBody' : 'Capture InBody Report',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isArabic
                        ? 'تأكد من أن جميع الأرقام واضحة'
                        : 'Make sure all numbers are clear',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: isArabic ? 'فتح الكاميرا' : 'Open Camera',
              onPressed: () {
                // Implement camera
                _openCamera();
              },
              variant: ButtonVariant.primary,
              size: ButtonSize.large,
              icon: Icons.camera_alt,
              fullWidth: true,
            ),
          ),
          
          const SizedBox(height: 12),
          
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: isArabic ? 'اختيار من المعرض' : 'Choose from Gallery',
              onPressed: () {
                // Implement gallery picker
                _openGallery();
              },
              variant: ButtonVariant.secondary,
              size: ButtonSize.large,
              icon: Icons.photo_library,
              fullWidth: true,
            ),
          ),
          
          const SizedBox(height: 24),
          
          TextButton(
            onPressed: () {
              setState(() {
                _inputMode = 'selection';
              });
            },
            child: Text(isArabic ? 'رجوع' : 'Back'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildManualInput(bool isArabic) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isArabic ? 'أدخل قياساتك' : 'Enter Your Measurements',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Weight
          _buildInputField(
            controller: _weightController,
            label: isArabic ? 'الوزن (كجم)' : 'Weight (kg)',
            hint: '70.5',
            icon: Icons.monitor_weight,
          ),
          
          const SizedBox(height: 16),
          
          // Body Fat %
          _buildInputField(
            controller: _bodyFatController,
            label: isArabic ? 'نسبة الدهون (%)' : 'Body Fat (%)',
            hint: '18.5',
            icon: Icons.pie_chart,
          ),
          
          const SizedBox(height: 16),
          
          // Muscle Mass
          _buildInputField(
            controller: _muscleMassController,
            label: isArabic ? 'الكتلة العضلية (كجم)' : 'Muscle Mass (kg)',
            hint: '35.2',
            icon: Icons.fitness_center,
          ),
          
          const SizedBox(height: 16),
          
          // BMI
          _buildInputField(
            controller: _bmiController,
            label: isArabic ? 'مؤشر كتلة الجسم' : 'BMI',
            hint: '23.4',
            icon: Icons.straighten,
          ),
          
          const SizedBox(height: 24),
          
          Text(
            isArabic ? 'قياسات إضافية (اختياري)' : 'Additional Measurements (Optional)',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Visceral Fat
          _buildInputField(
            controller: _visceralFatController,
            label: isArabic ? 'الدهون الحشوية' : 'Visceral Fat',
            hint: '8',
            icon: Icons.health_and_safety,
          ),
          
          const SizedBox(height: 16),
          
          // Body Water
          _buildInputField(
            controller: _bodyWaterController,
            label: isArabic ? 'ماء الجسم (%)' : 'Body Water (%)',
            hint: '60.2',
            icon: Icons.water_drop,
          ),
          
          const SizedBox(height: 16),
          
          // Protein
          _buildInputField(
            controller: _proteinController,
            label: isArabic ? 'البروتين (كجم)' : 'Protein (kg)',
            hint: '12.5',
            icon: Icons.restaurant,
          ),
          
          const SizedBox(height: 16),
          
          // Mineral
          _buildInputField(
            controller: _mineralController,
            label: isArabic ? 'المعادن (كجم)' : 'Mineral (kg)',
            hint: '3.2',
            icon: Icons.science,
          ),
          
          const SizedBox(height: 16),
          
          // BMR
          _buildInputField(
            controller: _bmrController,
            label: isArabic ? 'معدل الأيض الأساسي' : 'BMR (kcal)',
            hint: '1650',
            icon: Icons.local_fire_department,
          ),
          
          const SizedBox(height: 32),
          
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: isArabic ? 'حفظ النتائج' : 'Save Results',
              onPressed: () => _saveResults(isArabic),
              variant: ButtonVariant.primary,
              size: ButtonSize.large,
              fullWidth: true,
            ),
          ),
          
          const SizedBox(height: 12),
          
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: isArabic ? 'إلغاء' : 'Cancel',
              onPressed: () {
                setState(() {
                  _inputMode = 'selection';
                });
              },
              variant: ButtonVariant.secondary,
              size: ButtonSize.large,
              fullWidth: true,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
  
  void _saveResults(bool isArabic) async {
    if (_weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic ? 'الرجاء إدخال الوزن على الأقل' : 'Please enter at least weight',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    try {
      // Parse inputs
      final weight = double.parse(_weightController.text);
      final bodyFat = double.tryParse(_bodyFatController.text) ?? 18.0;
      final muscleMass = double.tryParse(_muscleMassController.text) ?? weight * 0.4;
      final bmi = double.tryParse(_bmiController.text) ?? weight / ((1.70 * 1.70)); // Estimate
      final visceralFat = int.tryParse(_visceralFatController.text) ?? 8;
      final bodyWater = double.tryParse(_bodyWaterController.text) ?? weight * 0.6;
      final protein = double.tryParse(_proteinController.text) ?? weight * 0.18;
      final mineral = double.tryParse(_mineralController.text) ?? weight * 0.045;
      final bmr = int.tryParse(_bmrController.text) ?? 1650;
      
      // Calculate derived values
      final bodyFatMass = (weight * bodyFat) / 100;
      final dryLeanMass = protein + mineral;
      final totalBodyWater = bodyWater;
      final intracellularWater = totalBodyWater * 0.625;
      final extracellularWater = totalBodyWater * 0.375;
      
      // Create InBody scan object
      final scan = InBodyScan(
        userId: 'user', // Will be set by backend
        weight: weight,
        bmi: bmi,
        percentBodyFat: bodyFat,
        skeletalMuscleMass: muscleMass,
        bodyFatMass: bodyFatMass,
        totalBodyWater: totalBodyWater,
        intracellularWater: intracellularWater,
        extracellularWater: extracellularWater,
        dryLeanMass: dryLeanMass,
        basalMetabolicRate: bmr,
        visceralFatLevel: visceralFat,
        ecwTbwRatio: extracellularWater / totalBodyWater,
        inBodyScore: 75 + ((muscleMass / weight) * 100).toInt(), // Simple score calculation
        segmentalLean: SegmentalLean(
          leftArm: 100,
          rightArm: 100,
          trunk: 100,
          leftLeg: 100,
          rightLeg: 100,
        ),
        scanDate: DateTime.now(),
      );
      
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic ? 'جاري الحفظ...' : 'Saving...',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
      
      if (!DemoConfig.isDemo) {
        // Save to backend
        final repository = WorkoutRepository();
        await repository.saveInBodyScan(scan);
      }
      
      // Success
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isArabic ? 'تم حفظ نتائج InBody بنجاح' : 'InBody results saved successfully',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      // Error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic 
              ? 'فشل في حفظ النتائج: ${e.toString()}' 
              : 'Failed to save results: ${e.toString()}',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
  
  void _openCamera() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _isAnalyzing = true;
      });
      // Simulate analysis
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isAnalyzing = false;
            _extractionComplete = true;
            _extractedData = {
              'weight': 70.5,
              'bodyFat': 18.5,
              'muscleMass': 35.2,
              'bmi': 23.4,
              'visceralFat': 8,
              'bodyWater': 60.2,
              'protein': 12.5,
              'mineral': 3.2,
              'bmr': 1650,
            };
          });
        }
      });
    }
  }
  
  void _openGallery() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _isAnalyzing = true;
      });
      // Simulate analysis
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isAnalyzing = false;
            _extractionComplete = true;
            _extractedData = {
              'weight': 70.5,
              'bodyFat': 18.5,
              'muscleMass': 35.2,
              'bmi': 23.4,
              'visceralFat': 8,
              'bodyWater': 60.2,
              'protein': 12.5,
              'mineral': 3.2,
              'bmr': 1650,
            };
          });
        }
      });
    }
  }
}
