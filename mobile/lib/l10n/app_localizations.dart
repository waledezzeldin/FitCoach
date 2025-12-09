import 'package:flutter/widgets.dart';

/// Minimal localizations to bootstrap the app; expand via ARB later.
class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) => Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const supportedLocales = [Locale('en'), Locale('ar')];

  bool get isRTL => locale.languageCode == 'ar';

  // Strings (seed set; extend to match UI_UX)
  String get titleWelcome => locale.languageCode == 'ar' ? 'مرحبًا في FitCoach' : 'Welcome to FitCoach';
  String get selectLanguage => locale.languageCode == 'ar' ? 'اختر اللغة للبدء' : 'Select your language to get started';
  String get changeLater => locale.languageCode == 'ar' ? 'يمكنك تغيير اللغة لاحقًا من الإعدادات' : 'You can change language later in Settings';
  String get authTitle => locale.languageCode == 'ar' ? 'تسجيل الدخول' : 'Sign in';
  String get phoneNumber => locale.languageCode == 'ar' ? 'رقم الهاتف' : 'Phone number';
  String get continueCta => locale.languageCode == 'ar' ? 'متابعة' : 'Continue';
  String get tryDemo => locale.languageCode == 'ar' ? 'جرّب الوضع التجريبي' : 'Try Demo Mode';
  String helloUser(String name) => locale.languageCode == 'ar' ? 'مرحبًا، $name!' : 'Hello, $name!';
  String get readyForWorkout => locale.languageCode == 'ar' ? 'هل أنت مستعد لتمرين اليوم؟' : "Ready for today's workout?";
  String get caloriesBurned => locale.languageCode == 'ar' ? 'السعرات المحروقة' : 'Calories Burned';
  String get caloriesConsumed => locale.languageCode == 'ar' ? 'سعرات مستهلكة' : 'Calories Consumed';
  String get today => locale.languageCode == 'ar' ? 'اليوم' : 'Today';
  String get navigation => locale.languageCode == 'ar' ? 'التنقل' : 'Navigation';

  // Subscription
  String get subscriptionTitle => locale.languageCode == 'ar' ? 'الاشتراك' : 'Subscription';
  String get tierFreemium => locale.languageCode == 'ar' ? 'مجاني' : 'Freemium';
  String get tierPremium => locale.languageCode == 'ar' ? 'بريميوم' : 'Premium';
  String get tierSmartPremium => locale.languageCode == 'ar' ? 'بريميوم ذكي' : 'Smart Premium';
  String get upgrade => locale.languageCode == 'ar' ? 'ترقية' : 'Upgrade';
  String get manageSubscription => locale.languageCode == 'ar' ? 'إدارة الاشتراك' : 'Manage Subscription';
  String get tapToUpgradeBadge => locale.languageCode == 'ar' ? '👆 اضغط للترقية' : '👆 Tap to Upgrade';

  // Intake
  String get intakeStep1Title => locale.languageCode == 'ar' ? 'البيانات الأساسية' : 'Basic Information';
  String get intakeStep2Title => locale.languageCode == 'ar' ? 'التقييم المتقدم' : 'Advanced Assessment';
  String get intakePremiumOnly => locale.languageCode == 'ar' ? 'متاح لأعضاء البريميوم فقط' : 'Available for Premium members only';
  String get starterPlanTitle => locale.languageCode == 'ar' ? 'خطة البداية الخاصة بك' : 'Your Starter Plan';
  String get viewPlan => locale.languageCode == 'ar' ? 'عرض الخطة' : 'View Plan';
  String get expiresIn => locale.languageCode == 'ar' ? 'ستنتهي خلال' : 'Expires in';
  String get days => locale.languageCode == 'ar' ? 'أيام' : 'days';
  String get planExperience => locale.languageCode == 'ar' ? 'المستوى' : 'Experience';
  String get planDaysPerWeek => locale.languageCode == 'ar' ? 'الأيام في الأسبوع' : 'Days per week';
  // Coach strings
  String get coachTitle => locale.languageCode == 'ar' ? 'المدرب' : 'Coach';
  String get coachSchedule => locale.languageCode == 'ar' ? 'الجدول' : 'Schedule';
  String get sessionRequests => locale.languageCode == 'ar' ? 'طلبات الجلسات' : 'Session Requests';
  String get approve => locale.languageCode == 'ar' ? 'قبول' : 'Approve';
  String get reject => locale.languageCode == 'ar' ? 'رفض' : 'Reject';
  String get chatTitle => locale.languageCode == 'ar' ? 'المحادثة' : 'Chat';
  String get typeMessage => locale.languageCode == 'ar' ? 'اكتب رسالة' : 'Type a message';
  String get sendMessageCta => locale.languageCode == 'ar' ? 'إرسال' : 'Send';
  String get startCallCta => locale.languageCode == 'ar' ? 'بدء مكالمة' : 'Start Call';
  String get ratingTitle => locale.languageCode == 'ar' ? 'التقييم' : 'Rating';
  String get attachmentsPremiumOnly => locale.languageCode == 'ar' ? 'المرفقات متاحة فقط للمميز' : 'Attachments are Premium-only';
  String get attachmentsEnabled => locale.languageCode == 'ar' ? 'المرفقات مفعلة' : 'Attachments enabled';
  String get completeIntake => locale.languageCode == 'ar' ? 'أكمِل التقييم' : 'Complete Intake';
  String get workoutsTitle => locale.languageCode == 'ar' ? 'التمارين' : 'Workouts';

  // Nutrition
  String get nutritionTitle => locale.languageCode == 'ar' ? 'التغذية' : 'Nutrition';
  String get nutritionPlan => locale.languageCode == 'ar' ? 'خطة التغذية' : 'Nutrition Plan';
  String get nutritionExpired => locale.languageCode == 'ar' ? 'انتهت صلاحية الخطة التجريبية' : 'Your trial nutrition plan has expired';
  String nutritionExpiresAt(String date) => locale.languageCode == 'ar' ? 'تنتهي في $date' : 'Expires on $date';
  String get startTrial => locale.languageCode == 'ar' ? 'ابدأ التجربة' : 'Start Trial';
  String get unlockedPermanently => locale.languageCode == 'ar' ? 'تم الفتح بشكل دائم' : 'Unlocked permanently';

  // Store
  String get storeTitle => locale.languageCode == 'ar' ? 'المتجر' : 'Store';
  String get cartLabel => locale.languageCode == 'ar' ? 'السلة' : 'Cart';
  String get totalLabel => locale.languageCode == 'ar' ? 'الإجمالي' : 'Total';
  String get checkoutTitle => locale.languageCode == 'ar' ? 'الدفع' : 'Checkout';
  String get checkoutSuccess => locale.languageCode == 'ar' ? 'شكرًا لشرائك!' : 'Thank you for your purchase!';
  String get checkoutCta => locale.languageCode == 'ar' ? 'ادفع الآن' : 'Checkout';
  String get currencySymbol => locale.languageCode == 'ar' ? 'ج.م' : '4';

  // Coach limits
  String get messageLimitReached => locale.languageCode == 'ar' ? 'لقد وصلت إلى حد الرسائل' : 'You have reached the message limit';
  String get callLimitReached => locale.languageCode == 'ar' ? 'لقد وصلت إلى حد المكالمات' : 'You have reached the call limit';
  String remainingOf(int used, int limit) => locale.languageCode == 'ar' ? 'المتبقي: ${limit - used} من $limit' : 'Remaining: ${limit - used} of $limit';

  // Workouts/Session controls
  String get prev => locale.languageCode == 'ar' ? 'السابق' : 'Prev';
  String get next => locale.languageCode == 'ar' ? 'التالي' : 'Next';
  String get skip => locale.languageCode == 'ar' ? 'تخطي' : 'Skip';
  String get start => locale.languageCode == 'ar' ? 'ابدأ' : 'Start';
  String get pause => locale.languageCode == 'ar' ? 'إيقاف مؤقت' : 'Pause';
  String get reset => locale.languageCode == 'ar' ? 'إعادة ضبط' : 'Reset';
  String get completeSession => locale.languageCode == 'ar' ? 'إنهاء الجلسة' : 'Complete Session';
  String sessionTitle(String id) => locale.languageCode == 'ar' ? 'الجلسة - $id' : 'Session - $id';
  String get elapsed => locale.languageCode == 'ar' ? 'انقضى' : 'Elapsed';

  // Intake reminder banner (workouts)
  String get intakeReminderTitle => locale.languageCode == 'ar' ? 'افتح خطتك المخصصة' : 'Unlock your Customized Plan';
  String get intakeReminderDesc => locale.languageCode == 'ar'
      ? 'أكمل التقييم المتقدم بسرعة أو تابع بالخطة العامة.'
      : 'Complete a quick advanced intake or continue with the generic plan.';
  String get completeIntakeCta => locale.languageCode == 'ar' ? 'أكمِل التقييم' : 'Complete Intake';
  String get talkToCoachCta => locale.languageCode == 'ar' ? 'تحدث إلى المدرب' : 'Talk to Coach';
  String get continueGenericCta => locale.languageCode == 'ar' ? 'متابعة بالخطة العامة' : 'Continue Generic';

  // Common UI
  String get ok => locale.languageCode == 'ar' ? 'حسنًا' : 'OK';
  String get cancel => locale.languageCode == 'ar' ? 'إلغاء' : 'Cancel';
  String get save => locale.languageCode == 'ar' ? 'حفظ' : 'Save';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}
