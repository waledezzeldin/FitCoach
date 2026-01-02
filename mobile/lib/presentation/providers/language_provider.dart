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
    String text;
    if (isArabic) {
      text = _arabicTranslations[key] ?? _englishTranslations[key] ?? key;
    } else {
      text = _englishTranslations[key] ?? key;
    }
    
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
    'splash_headline_en': 'Your Fitness Journey Starts Now',
    'splash_headline_ar': 'رحلتك الرياضية تبدأ الآن',
    'splash_start': 'Start / ابدأ',
    
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
    'no_active_workout_plan': 'No active workout plan',
    'workout_plan_coming_soon': 'Your coach will create a plan for you soon',
    'workout_select_day': 'Select a day to view exercises',
    'workout_overview': 'Workout Overview',
    'workout_day': 'Day {number}',
    'workout_progress': '{completed} of {total} exercises completed',
    'completed': 'Completed',
    'sets': 'sets',
    'reps': 'reps',
    'substitute': 'Substitute',
    'substitute_exercise': 'Substitute Exercise',
    'no_alternatives_available': 'No alternatives available',
    'exercise_substituted_successfully': 'Exercise substituted successfully',
    'workout_injury_conflict': 'This exercise may conflict with your injury',
    'home_hello': 'Hello',
    'home_ready': 'Ready for your next session?',
    'home_fitness_score': 'Fitness Score',
    'home_updated_by_coach': 'Updated by coach',
    'home_auto_updated': 'Auto updated',
    'home_calories_burned': 'Calories Burned',
    'home_calories_consumed': 'Calories Consumed',
    'home_workouts_completed': 'Workouts Completed',
    'home_quick_access': 'Quick Access',
    'home_workouts': 'Workouts',
    'home_workouts_desc': 'Training plans and today\'s session',
    'home_nutrition': 'Nutrition',
    'home_nutrition_desc': 'Meals, macros, and daily targets',
    'home_coach': 'Coach',
    'home_coach_desc': 'Chat and video sessions',
    'home_store': 'Store',
    'home_store_desc': 'Supplements and gear',
    'home_locked': 'Locked',
    
    // Workout
    'no_plan': 'No workout plan yet',
    'ask_coach': 'Ask your coach for a plan',
    'start_workout': 'Start Workout',
    'complete_set': 'Complete Set',
    
    // Nutrition
    'trial_period': 'Trial Period',
    'trial_expiring': 'You have {days} days of free access remaining',
    'trial_expired': 'Trial Period Ended',
    'upgrade_to_premium': 'Upgrade to Premium',
    'upgrade_prompt': 'Upgrade to Premium for unlimited access to nutrition plans',
    'macros': 'Macros',
    'protein': 'Protein',
    'carbs': 'Carbs',
    'fats': 'Fats',
    'calories': 'Calories',
    'consumed': 'Consumed',
    'remaining': 'Remaining',
    'cal_unit': 'cal',
    'more_items': '+ {count} more',
    'todays_meals': 'Today\'s Meals',
    'no_active_nutrition_plan': 'No active nutrition plan',
    'nutrition_plan_coming_soon': 'Your coach will create a plan for you soon',
    'instructions': 'Instructions',
    
    // Messaging
    'messages': 'Messages',
    'sessions': 'Sessions',
    'coach_messaging': 'Coach Messaging',
    'coach_messaging_subtitle': 'Message your coach and book sessions',
    'book_video_call': 'Book Video Call',
    'book_video_call_hint': 'Schedule a video session with your coach',
    'start_conversation_with_coach': 'Start a conversation with your coach',
    'ask_questions_about_workouts_nutrition': 'Ask about workouts or nutrition',
    'type_a_message': 'Type a message...',
    'photo': 'Photo',
    'video': 'Video',
    'file': 'File',
    'request': 'Request',
    'request_video_call': 'Request Video Call',
    'do_you_want_video_call_with_coach': 'Do you want to request a video call with your coach?',
    'video_call_request_message': 'Video call request',
    'video_call_request_sent': 'Video call request sent',
    'type_message': 'Type a message...',
    'send': 'Send',
    'quota_warning': '{remaining} messages remaining this month',
    'quota_exceeded': 'Message quota exceeded',
    
    // Store
    'categories': 'Categories',
    'featured': 'Featured Products',
    'store_all': 'All',
    'store_supplements': 'Supplements',
    'store_equipment': 'Equipment',
    'store_apparel': 'Apparel',
    'store_accessories': 'Accessories',
    'store_title': 'FitCoach Store',
    'store_subtitle': 'Supplements and gear picked for you',
    'store_search_placeholder': 'Search products or brands',
    'store_products': 'Products',
    'store_cart': 'Cart',
    'store_orders': 'Orders',
    'store_popular': 'Popular',
    'store_no_products': 'No products in this category',
    'store_no_orders': 'No orders yet',
    'store_added_to_cart': 'Added to cart',
    'store_status_processing': 'Processing',
    'store_status_shipped': 'Shipped',
    'store_status_delivered': 'Delivered',
    'add_to_cart': 'Add to Cart',
    'buy_now': 'Buy Now',
    'out_of_stock': 'Out of Stock',
    'currency_sar': 'SAR',
    'reviews_count': '({count} reviews)',
    'cart_empty': 'Cart is empty',
    'shopping_cart': 'Shopping Cart',
    'total': 'Total:',
    'checkout': 'Checkout',
    'checkout_message': 'You will be redirected to payment',
    'ok': 'OK',
    'description': 'Description',
    
    // Account
    'profile': 'Profile',
    'subscription': 'Subscription',
    'settings': 'Settings',
    'logout': 'Logout',
    'tagline': 'Your Fitness Journey Starts Here',
    'welcome_back': 'Welcome Back',
    'sign_in_subtitle': 'Sign in to your account',
    'email_or_phone': 'Email or Phone',
    'email': 'Email',
    'email_or_phone_hint': 'example@email.com or +966...',
    'password': 'Password',
    'password_hint': 'Enter your password',
    'remember_me': 'Remember me',
    'forgot_password': 'Forgot Password?',
    'or': 'OR',
    'continue_with_phone': 'Continue with Phone',
    'or_continue_with': 'Or continue with',
    'dont_have_account': 'Don\'t have an account?',
    'sign_up': 'Sign Up',
    'otp_invalid_phone': 'Please enter a valid Saudi phone number',
    'otp_incomplete': 'Please enter the complete OTP code',
    'change_phone': 'Change phone number',
    'onboarding_slide1_title': 'Welcome to FitCoach+',
    'onboarding_slide1_desc': 'Your fitness journey starts here with professional coaches',
    'onboarding_slide2_title': 'Personalized Workout Plans',
    'onboarding_slide2_desc': 'Get workout plans tailored to your goals and condition',
    'onboarding_slide3_title': 'Connect with Your Coach',
    'onboarding_slide3_desc': 'Direct communication with your coach for guidance and support',
    'onboarding_coaching_title': 'Your Personal Coach Awaits',
    'onboarding_coaching_desc': 'Connect with certified fitness professionals who understand your goals. Get real-time guidance, motivation, and accountability through personalized coaching.',
    'onboarding_nutrition_title': 'Fuel Your Transformation',
    'onboarding_nutrition_desc': 'Discover customized meal plans designed for your body and goals. Track macros effortlessly and learn sustainable nutrition habits that last a lifetime.',
    'onboarding_workouts_title': 'Train Smarter, Not Harder',
    'onboarding_workouts_desc': 'Access scientifically-designed workout programs that adapt to your fitness level. Every exercise is demonstrated with proper form to maximize results and prevent injury.',
    'onboarding_store_title': 'Everything You Need, One Place',
    'onboarding_store_desc': 'Shop premium supplements, training gear, and wellness products curated by fitness experts. Quality nutrition and equipment to support your journey.',
    'onboarding_go_to_slide': 'Go to slide {index}',
    'get_started': 'Get Started',
    'sign_in': 'Sign In',
    'signing_in': 'Signing in...',
    'forgot_password_title': 'Forgot Password',
    'forgot_password_desc': 'Enter your email and we\'ll send you a reset link',
    'reset_link_sent': 'Reset link sent to your email',
  };
  
  // Arabic translations
  static const Map<String, String> _arabicTranslations = {
    'splash_headline_en': 'Your Fitness Journey Starts Now',
    'splash_headline_ar': 'رحلتك الرياضية تبدأ الآن',
    'splash_start': 'Start / ابدأ',
    'account': 'الحساب',
    'additional_info': 'معلومات إضافية',
    'app_name': 'عاش',
    'appointment_details': 'تفاصيل الموعد',
    'ask_questions_about_workouts_nutrition': 'اسأل عن التمارين أو التغذية',
    'assessment': 'تقييم',
    'back': 'رجوع',
    'calories': 'السعرات',
    'can_join_now': 'يمكنك الانضمام الآن',
    'cancel': 'إلغاء',
    'cannot_join_call': 'لا يمكن الانضمام للمكالمة',
    'cannot_join_yet': 'لا يمكنك الانضمام بعد',
    'change_phone': 'تغيير رقم الهاتف',
    'chat': 'محادثة',
    'chest_day': 'يوم الصدر',
    'coach': 'المدرب',
    'coach_messaging': 'مراسلة المدرب',
    'messages': 'الرسائل',
    'sessions': 'الجلسات',
    'coach_messaging_subtitle': 'تواصل مع مدربك واحجز جلسات',
    'book_video_call': 'حجز مكالمة فيديو',
    'book_video_call_hint': 'جدول جلسة فيديو مع مدربك',
    'completed': 'مكتمل',
    'complete': 'إكمال',
    'connect_with_coach': 'تواصل مع مدربك',
    'continue': 'متابعة',
    'continue_with_phone': 'متابعة عبر الهاتف',
    'current_plan': 'الخطة الحالية',
    'date_time': 'التاريخ والوقت',
    'day_streak': 'سلسلة الأيام',
    'do_you_want_video_call_with_coach': 'هل تريد إجراء مكالمة فيديو مع المدرب؟',
    'dont_have_account': 'ليس لديك حساب؟',
    'duration': 'المدة',
    'email': 'البريد الإلكتروني',
    'email_or_phone': 'البريد الإلكتروني أو الهاتف',
    'email_or_phone_hint': 'example@email.com أو +966...',
    'enter_otp': 'أدخل رمز التحقق',
    'enter_phone': 'أدخل رقم هاتفك',
    'exercises': 'تمارين',
    'no_active_workout_plan': 'لا توجد خطة تمرين نشطة',
    'workout_plan_coming_soon': 'سيقوم مدربك بإنشاء خطة لك قريباً',
    'workout_select_day': 'اختر يوماً لعرض التمارين',
    'workout_overview': 'نظرة عامة على التمرين',
    'workout_day': 'يوم {number}',
    'workout_progress': '{completed} من {total} تمارين مكتملة',
    'fat_loss': 'فقدان الدهون',
    'female': 'أنثى',
    'file': 'ملف',
    'forgot_password': 'نسيت كلمة المرور؟',
    'forgot_password_desc': 'أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة تعيين',
    'forgot_password_title': 'نسيت كلمة المرور',
    'gender': 'الجنس',
    'general_fitness': 'لياقة عامة',
    'get_started': 'ابدأ الآن',
    'goal': 'ما هدفك الرئيسي؟',
    'gym': 'النادي الرياضي',
    'home': 'الرئيسية',
    'home_auto_updated': 'محدث تلقائياً',
    'home_calories_burned': 'سعرات محروقة',
    'home_calories_consumed': 'سعرات مستهلكة',
    'home_coach': 'المدرب',
    'home_coach_desc': 'محادثة ومكالمات فيديو',
    'home_fitness_score': 'مؤشر اللياقة',
    'home_hello': 'مرحباً',
    'home_locked': 'مقفل',
    'home_nutrition': 'التغذية',
    'home_nutrition_desc': 'الوجبات والماكروز والأهداف اليومية',
    'home_quick_access': 'وصول سريع',
    'home_ready': 'هل أنت مستعد للجلسة التالية؟',
    'home_store': 'المتجر',
    'home_store_desc': 'مكملات ومعدات',
    'home_updated_by_coach': 'محدث بواسطة المدرب',
    'home_workouts': 'التمارين',
    'home_workouts_completed': 'تمارين مكتملة',
    'home_workouts_desc': 'خطط التدريب وتمرين اليوم',
    'join_video_call': 'انضم لمكالمة الفيديو',
    'lets_know_you': 'دعنا نتعرف عليك',
    'location': 'أين تفضل التمرين؟',
    'male': 'ذكر',
    'meals': 'وجبات',
    'message_coach': 'راسل المدرب',
    'minute_short': 'د',
    'minutes': 'دقائق',
    'monthly_quota': 'الحصة الشهرية',
    'muscle_gain': 'بناء العضلات',
    'next': 'التالي',
    'notes': 'ملاحظات',
    'nutrition': 'التغذية',
    'sets': 'مجموعات',
    'reps': 'تكرارات',
    'substitute': 'بديل',
    'substitute_exercise': 'استبدال التمرين',
    'no_alternatives_available': 'لا توجد بدائل متاحة',
    'exercise_substituted_successfully': 'تم استبدال التمرين بنجاح',
    'workout_injury_conflict': 'قد يتعارض هذا التمرين مع إصابتك',
    'onboarding_coaching_desc': 'تواصل مع متخصصي اللياقة البدنية المعتمدين الذين يفهمون أهدافك. احصل على إرشادات فورية، تحفيز، ومتابعة من خلال التدريب الشخصي.',
    'onboarding_coaching_title': 'مدربك الشخصي في انتظارك',
    'onboarding_go_to_slide': 'الانتقال إلى الشريحة {index}',
    'onboarding_nutrition_desc': 'اكتشف خطط وجبات مخصصة مصممة لجسمك وأهدافك. تتبع العناصر الغذائية بسهولة وتعلم عادات تغذية مستدامة تدوم مدى الحياة.',
    'onboarding_nutrition_title': 'غذِّ تحولك',
    'onboarding_store_desc': 'تسوق المكملات الفاخرة، معدات التدريب، ومنتجات العافية المختارة من قبل خبراء اللياقة. تغذية ومعدات عالية الجودة لدعم رحلتك.',
    'onboarding_store_title': 'كل ما تحتاجه، في مكان واحد',
    'onboarding_workouts_desc': 'احصل على برامج تمارين مصممة علمياً تتكيف مع مستوى لياقتك. كل تمرين معروض مع الأداء الصحيح لتعظيم النتائج ومنع الإصابات.',
    'onboarding_workouts_title': 'تدرب بذكاء، وليس بجهد أكبر',
    'or': 'أو',
    'or_continue_with': 'أو المتابعة عبر',
    'otp_incomplete': 'يرجى إدخال رمز التحقق كاملاً',
    'otp_invalid_phone': 'يرجى إدخال رقم سعودي صحيح',
    'password': 'كلمة المرور',
    'password_hint': 'أدخل كلمة المرور',
    'phone_hint': '+966 5X XXX XXXX',
    'trial_period': 'فترة التجربة',
    'trial_expiring': 'لديك {days} أيام متبقية من الوصول المجاني',
    'trial_expired': 'انتهت فترة التجربة',
    'upgrade_to_premium': 'ترقية إلى Premium',
    'upgrade_prompt': 'قم بالترقية إلى Premium للوصول غير المحدود إلى خطط التغذية',
    'protein': 'بروتين',
    'carbs': 'كربوهيدرات',
    'fats': 'دهون',
    'consumed': 'مستهلك',
    'remaining': 'متبقي',
    'cal_unit': 'سعرة',
    'more_items': '+ {count} أكثر',
    'todays_meals': 'وجبات اليوم',
    'no_active_nutrition_plan': 'لا توجد خطة تغذية نشطة',
    'nutrition_plan_coming_soon': 'سيقوم مدربك بإنشاء خطة لك قريباً',
    'instructions': 'التعليمات',
    'photo': 'صورة',
    'progress': 'التقدم',
    'quick_actions': 'إجراءات سريعة',
    'remember_me': 'تذكرني',
    'request': 'طلب',
    'request_video_call': 'طلب مكالمة فيديو',
    'resend': 'إعادة إرسال',
    'reset_link_sent': 'تم إرسال رابط إعادة التعيين إلى بريدك',
    'send': 'إرسال',
    'send_otp': 'إرسال رمز التحقق',
    'shop_products': 'تسوق المنتجات',
    'store_all': 'الكل',
    'store_supplements': 'مكملات',
    'store_equipment': 'معدات',
    'store_apparel': 'ملابس',
    'store_accessories': 'إكسسوارات',
    'store_title': 'متجر فت كوتش',
    'store_subtitle': 'مكملات ومعدات مختارة لك',
    'store_search_placeholder': 'ابحث عن منتج أو علامة تجارية',
    'store_products': 'المنتجات',
    'store_cart': 'السلة',
    'store_orders': 'الطلبات',
    'store_popular': 'الأكثر طلباً',
    'store_no_products': 'لا توجد منتجات في هذه الفئة',
    'store_no_orders': 'لا توجد طلبات بعد',
    'store_added_to_cart': 'تمت الإضافة إلى السلة',
    'store_status_processing': 'قيد المعالجة',
    'store_status_shipped': 'تم الشحن',
    'store_status_delivered': 'تم التوصيل',
    'out_of_stock': 'نفذ المخزون',
    'currency_sar': 'ر.س',
    'reviews_count': '({count} تقييم)',
    'cart_empty': 'السلة فارغة',
    'shopping_cart': 'سلة التسوق',
    'total': 'الإجمالي:',
    'checkout': 'إتمام الطلب',
    'checkout_message': 'سيتم تحويلك إلى الدفع',
    'ok': 'حسناً',
    'description': 'الوصف',
    'sign_in': 'تسجيل الدخول',
    'sign_in_subtitle': 'سجل الدخول إلى حسابك',
    'sign_up': 'إنشاء حساب',
    'signing_in': 'جارٍ تسجيل الدخول...',
    'skip': 'تخطي',
    'start_conversation_with_coach': 'ابدأ محادثة مع المدرب',
    'store': 'المتجر',
    'tagline': 'رحلتك الرياضية تبدأ هنا',
    'todays_nutrition': 'تغذية اليوم',
    'todays_workout': 'تمرين اليوم',
    'type': 'النوع',
    'type_a_message': 'اكتب رسالة...',
    'unknown': 'غير معروف',
    'upgrade': 'ترقية',
    'user': 'مستخدم',
    'verify': 'تحقق',
    'video': 'فيديو',
    'video_call': 'مكالمة فيديو',
    'video_call_request_message': 'طلب مكالمة فيديو',
    'video_call_request_sent': 'تم إرسال طلب مكالمة الفيديو',
    'view_achievements': 'عرض الإنجازات',
    'welcome': 'مرحباً بك في عاش',
    'welcome_back': 'مرحباً بعودتك',
    'workout': 'التمارين',
    'workouts': 'التمارين',
    'your_progress': 'تقدمك',
  };
}
