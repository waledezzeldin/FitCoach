import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../providers/language_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_button.dart';

class VideoBookingScreen extends StatefulWidget {
  const VideoBookingScreen({super.key});

  @override
  State<VideoBookingScreen> createState() => _VideoBookingScreenState();
}

class _VideoBookingScreenState extends State<VideoBookingScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedDuration = '30';
  String _topic = '';
  final TextEditingController _notesController = TextEditingController();
  
  final List<String> _availableSlots = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
  ];
  
  String? _selectedSlot;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isArabic = languageProvider.isArabic;
    final tier = authProvider.user?.subscriptionTier ?? 'Freemium';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'حجز مكالمة فيديو' : 'Book Video Call'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quota info card
            CustomCard(
              color: AppColors.primary.withValues(alpha: 0.1),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isArabic
                          ? 'لديك ${_getCallsRemaining(tier)} مكالمة متبقية هذا الشهر'
                          : 'You have ${_getCallsRemaining(tier)} calls remaining this month',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Select date
            Text(
              isArabic ? 'اختر التاريخ' : 'Select Date',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            CustomCard(
              onTap: () => _selectDate(context),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _selectedDate != null
                          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                          : isArabic ? 'اختر التاريخ' : 'Choose a date',
                      style: TextStyle(
                        fontSize: 16,
                        color: _selectedDate != null
                            ? AppColors.textPrimary
                            : AppColors.textDisabled,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textDisabled),
                ],
              ),
            ),
            
            if (_selectedDate != null) ...[
              const SizedBox(height: 24),
              
              // Available slots
              Text(
                isArabic ? 'الأوقات المتاحة' : 'Available Times',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableSlots.map((slot) {
                  final isSelected = _selectedSlot == slot;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedSlot = slot;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
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
                      child: Text(
                        slot,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Duration
            Text(
              isArabic ? 'المدة' : 'Duration',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: ['30', '45', '60'].map((duration) {
                final isSelected = _selectedDuration == duration;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDuration = duration;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
                            '$duration ${isArabic ? 'دقيقة' : 'min'}',
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            
            // Topic
            Text(
              isArabic ? 'الموضوع' : 'Topic',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            ...['workout', 'nutrition', 'general'].map((topic) {
              final isSelected = _topic == topic;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: CustomCard(
                  onTap: () {
                    setState(() {
                      _topic = topic;
                    });
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Center(
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primary,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        _getTopicLabel(topic, isArabic),
                        style: TextStyle(
                          fontSize: 16,
                          color: isSelected
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            
            const SizedBox(height: 24),
            
            // Notes
            Text(
              isArabic ? 'ملاحظات إضافية' : 'Additional Notes',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: isArabic
                    ? 'أخبر مدربك بما تريد التحدث عنه...'
                    : 'Tell your coach what you want to discuss...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Book button
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: isArabic ? 'تأكيد الحجز' : 'Confirm Booking',
                onPressed: _canBook() ? () => _bookCall(context, isArabic) : null,
                variant: ButtonVariant.primary,
                size: ButtonSize.large,
                fullWidth: true,
              ),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
  bool _canBook() {
    return _selectedDate != null && 
           _selectedSlot != null && 
           _topic.isNotEmpty;
  }
  
  int _getCallsRemaining(String tier) {
    switch (tier) {
      case 'Smart Premium':
        return 4;
      case 'Premium':
        return 2;
      default:
        return 1;
    }
  }
  
  String _getTopicLabel(String topic, bool isArabic) {
    final labels = {
      'workout': isArabic ? 'استشارة تمرين' : 'Workout Consultation',
      'nutrition': isArabic ? 'استشارة تغذية' : 'Nutrition Consultation',
      'general': isArabic ? 'استشارة عامة' : 'General Consultation',
    };
    return labels[topic] ?? topic;
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedSlot = null; // Reset slot when date changes
      });
    }
  }
  
  void _bookCall(BuildContext context, bool isArabic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isArabic ? 'تأكيد الحجز' : 'Confirm Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic ? 'تفاصيل الحجز:' : 'Booking Details:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('${isArabic ? 'التاريخ:' : 'Date:'} ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
            Text('${isArabic ? 'الوقت:' : 'Time:'} $_selectedSlot'),
            Text('${isArabic ? 'المدة:' : 'Duration:'} $_selectedDuration ${isArabic ? 'دقيقة' : 'minutes'}'),
            Text('${isArabic ? 'الموضوع:' : 'Topic:'} ${_getTopicLabel(_topic, isArabic)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to previous screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isArabic
                        ? 'تم حجز المكالمة بنجاح'
                        : 'Video call booked successfully',
                  ),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text(isArabic ? 'تأكيد' : 'Confirm'),
          ),
        ],
      ),
    );
  }
}
