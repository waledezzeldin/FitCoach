import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  Locale _locale = const Locale('ar');
  bool _hasSelectedLanguage = false;
  String _currentLanguage = 'ar';
  
  LanguageProvider() {
    _loadLanguage();
  }
  
  Locale get locale => _locale;
  bool get hasSelectedLanguage => _hasSelectedLanguage;
  bool get isArabic => _locale.languageCode == 'ar';
  bool get isEnglish => _locale.languageCode == 'en';
  String get currentLanguage => _currentLanguage;

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('fitcoach_language');
    
    if (languageCode != null) {
      _locale = Locale(languageCode);
      _hasSelectedLanguage = true;
      _currentLanguage = languageCode;
      notifyListeners();
    }
  }
  
  Future<void> setLanguage(String languageCode) async {
    _locale = Locale(languageCode);
    _hasSelectedLanguage = true;
    _currentLanguage = languageCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fitcoach_language', languageCode);
    notifyListeners();
  }

  /// Toggle between Arabic and English
  Future<void> toggleLanguage() async {
    if (_locale.languageCode == 'ar') {
      await setLanguage('en');
    } else {
      await setLanguage('ar');
    }
  }
  
  String translate(String key, {Map<String, String>? args}) {
    // Simple translation system - in production, use proper i18n
    final translations = _getTranslations();
    String text = translations[key] ?? key;
    
    // Replace placeholders
    if (args != null) {
      args.forEach((key, value) {
        text = text.replaceAll('{$key}', value);
      });
    }
    
    return text;
  }
  
  String t(String key, {Map<String, String>? args}) => translate(key, args: args);
  
  Map<String, String> _getTranslations() {
    if (isArabic) {
      return _arabicTranslations;
    }
    return _englishTranslations;
  }
  
  // English translations
  static const Map<String, String> _englishTranslations = {
    'app_name': 'FitCoach+',
    'welcome': 'Welcome to FitCoach+',
    'select_language': 'Select your language',
    'english': 'English',
    'arabic': 'Arabic',
    'continue': 'Continue',
    'skip': 'Skip',
    'next': 'Next',
    'back': 'Back',
    'save': 'Save',
    'cancel': 'Cancel',
    'loading': 'Loading...',
    'error': 'An error occurred',
    
    // Auth
    'enter_phone': 'Enter your phone number',
    'phone_hint': '+966 5X XXX XXXX',
    'send_otp': 'Send OTP',
    'enter_otp': 'Enter verification code',
    'verify': 'Verify',
    'resend': 'Resend code',
    
    // Intake
    'lets_know_you': 'Let\'s get to know you',
    'gender': 'Gender',
    'male': 'Male',
    'female': 'Female',
    'goal': 'What\'s your main goal?',
    'fat_loss': 'Fat Loss',
    'muscle_gain': 'Muscle Gain',
    'general_fitness': 'General Fitness',
    'location': 'Where do you work out?',
    'gym': 'Gym',
    
    // Home
    'workout': 'Workout',
    'nutrition': 'Nutrition',
    'coach': 'Coach',
    'store': 'Store',
    'account': 'Account',
    'greeting': 'Hello, {name}',
    'todays_workout': 'Today\'s Workout',
    'nutrition_plan': 'Nutrition Plan',
    'message_coach': 'Message Coach',
    
    // Workout
    'no_plan': 'No workout plan yet',
    'ask_coach': 'Ask your coach for a plan',
    'start_workout': 'Start Workout',
    'complete_set': 'Complete Set',
    'substitute': 'Substitute Exercise',
    
    // Nutrition
    'trial_expiring': 'Trial expires in {days} days',
    'trial_expired': 'Trial expired',
    'upgrade_prompt': 'Upgrade to Premium for unlimited access',
    'macros': 'Macros',
    'protein': 'Protein',
    'carbs': 'Carbs',
    'fats': 'Fats',
    'calories': 'Calories',
    
    // Messaging
    'type_message': 'Type a message...',
    'send': 'Send',
    'quota_warning': '{remaining} messages remaining this month',
    'quota_exceeded': 'Message quota exceeded',
    
    // Store
    'categories': 'Categories',
    'featured': 'Featured Products',
    'add_to_cart': 'Add to Cart',
    'buy_now': 'Buy Now',
    
    // Account
    'profile': 'Profile',
    'subscription': 'Subscription',
    'settings': 'Settings',
    'logout': 'Logout',
  };
  
  // Arabic translations
  static const Map<String, String> _arabicTranslations = {
    'app_name': 'عاش',
    'welcome': 'مرحباً بك في عاش',
    'select_language': 'اختر لغتك',
    'english': 'English',
    'arabic': 'العربية',
    'continue': 'متابعة',
    'skip': 'تخطي',
    'next': 'التالي',
    'back': 'رجوع',
    'save': 'حفظ',
    'cancel': 'إلغاء',
    'loading': 'جاري التحميل...',
    'error': 'حدث خطأ',
    
    // Auth
    'enter_phone': 'أدخل رقم هاتفك',
    'phone_hint': '+966 5X XXX XXXX',
    'send_otp': 'إرسال رمز التحقق',
    'enter_otp': 'أدخل رمز التحقق',
    'verify': 'تحقق',
    'resend': 'إعادة إرسال',
    
    // Intake
    'lets_know_you': 'دعنا نتعرف عليك',
    'gender': 'الجنس',
    'male': 'ذكر',
    'female': 'أنثى',
    'goal': 'ما هو هدفك الرئيسي؟',
    'fat_loss': 'فقدان الدهون',
    'muscle_gain': 'بناء العضلات',
    'general_fitness': 'لياقة عامة',
    'location': 'أين تتمرن؟',
    'gym': 'الجيم',
    
    // Home
    'home': 'الرئيسية',
    'workout': 'التمرين',
    'nutrition': 'التغذية',
    'coach': 'المدرب',
    'store': 'المتجر',
    'account': 'الحساب',
    'greeting': 'مرحباً، {name}',
    'todays_workout': 'تمرين اليوم',
    'nutrition_plan': 'خطة التغذية',
    'message_coach': 'راسل المدرب',
    
    // Workout
    'no_plan': 'لا توجد خطة تمرين بعد',
    'ask_coach': 'اطلب خطة من مدربك',
    'start_workout': 'ابدأ التمرين',
    'complete_set': 'إكمال المجموعة',
    'substitute': 'استبدال التمرين',
    
    // Nutrition
    'trial_expiring': 'تنتهي التجربة خلال {days} أيام',
    'trial_expired': 'انتهت فترة التجربة',
    'upgrade_prompt': 'قم بالترقية إلى Premium للوصول غير المحدود',
    'macros': 'العناصر الغذائية',
    'protein': 'البروتين',
    'carbs': 'الكربوهيدرات',
    'fats': 'الدهون',
    'calories': 'السعرات الحرارية',
    
    // Messaging
    'type_message': 'اكتب رسالة...',
    'send': 'إرسال',
    'quota_warning': '{remaining} رسالة متبقية هذا الشهر',
    'quota_exceeded': 'تم تجاوز حصة الرسائل',
    
    // Store
    'categories': 'الفئات',
    'featured': 'منتجات مميزة',
    'add_to_cart': 'أضف إلى السلة',
    'buy_now': 'اشتر الآن',
    
    // Account
    'profile': 'الملف الشخصي',
    'subscription': 'الاشتراك',
    'settings': 'الإعدادات',
    'logout': 'تسجيل الخروج',
  };
}
