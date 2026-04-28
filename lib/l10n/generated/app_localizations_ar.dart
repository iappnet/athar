// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'أثر';

  @override
  String get appTagline => 'حياة متوازنة، أثر مستدام';

  @override
  String get appDescription => 'تطبيق شامل لإدارة الحياة اليومية';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get add => 'إضافة';

  @override
  String get create => 'إنشاء';

  @override
  String get update => 'تحديث';

  @override
  String get remove => 'إزالة';

  @override
  String get search => 'بحث';

  @override
  String get filter => 'تصفية';

  @override
  String get sort => 'ترتيب';

  @override
  String get share => 'مشاركة';

  @override
  String get copy => 'نسخ';

  @override
  String get paste => 'لصق';

  @override
  String get select => 'اختيار';

  @override
  String get selectAll => 'اختيار الكل';

  @override
  String get clear => 'مسح';

  @override
  String get clearAll => 'مسح الكل';

  @override
  String get reset => 'إعادة تعيين';

  @override
  String get refresh => 'تحديث';

  @override
  String get reload => 'إعادة تحميل';

  @override
  String get close => 'إغلاق';

  @override
  String get open => 'فتح';

  @override
  String get show => 'عرض';

  @override
  String get hide => 'إخفاء';

  @override
  String get expand => 'توسيع';

  @override
  String get collapse => 'طي';

  @override
  String get more => 'المزيد';

  @override
  String get less => 'أقل';

  @override
  String get all => 'الكل';

  @override
  String get none => 'لا شيء';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get ok => 'موافق';

  @override
  String get confirm => 'تأكيد';

  @override
  String get done => 'تم';

  @override
  String get finish => 'إنهاء';

  @override
  String get complete => 'اكتمل';

  @override
  String get next => 'التالي';

  @override
  String get previous => 'السابق';

  @override
  String get back => 'رجوع';

  @override
  String get forward => 'تقدم';

  @override
  String get skip => 'تخطي';

  @override
  String get continue_ => 'متابعة';

  @override
  String get start => 'بدء';

  @override
  String get stop => 'إيقاف';

  @override
  String get pause => 'إيقاف مؤقت';

  @override
  String get resume => 'استئناف';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get submit => 'إرسال';

  @override
  String get send => 'إرسال';

  @override
  String get apply => 'تطبيق';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get pleaseWait => 'يرجى الانتظار...';

  @override
  String get processing => 'جاري المعالجة...';

  @override
  String get success => 'نجاح';

  @override
  String get error => 'خطأ';

  @override
  String get warning => 'تحذير';

  @override
  String get info => 'معلومات';

  @override
  String get pending => 'قيد الانتظار';

  @override
  String get active => 'نشط';

  @override
  String get inactive => 'غير نشط';

  @override
  String get enabled => 'مفعّل';

  @override
  String get disabled => 'معطّل';

  @override
  String get online => 'متصل';

  @override
  String get offline => 'غير متصل';

  @override
  String get syncing => 'جاري المزامنة...';

  @override
  String get synced => 'تمت المزامنة';

  @override
  String get notSynced => 'غير متزامن';

  @override
  String errorOccurred(String error) {
    return 'حدث خطأ: $error';
  }

  @override
  String get errorUnknown => 'حدث خطأ غير معروف';

  @override
  String get errorNetwork => 'خطأ في الاتصال بالإنترنت';

  @override
  String get errorServer => 'خطأ في الخادم';

  @override
  String get errorTimeout => 'انتهت مهلة الاتصال';

  @override
  String get errorNotFound => 'غير موجود';

  @override
  String get errorPermission => 'ليس لديك الصلاحية';

  @override
  String get errorRequired => 'هذا الحقل مطلوب';

  @override
  String get errorInvalid => 'قيمة غير صالحة';

  @override
  String errorMinLength(int count) {
    return 'يجب أن يكون على الأقل $count أحرف';
  }

  @override
  String errorMaxLength(int count) {
    return 'يجب ألا يتجاوز $count أحرف';
  }

  @override
  String get errorInvalidEmail => 'البريد الإلكتروني غير صالح';

  @override
  String get errorInvalidPhone => 'رقم الهاتف غير صالح';

  @override
  String get errorInvalidPassword => 'كلمة المرور غير صالحة';

  @override
  String get errorPasswordMismatch => 'كلمات المرور غير متطابقة';

  @override
  String get errorWeakPassword => 'كلمة المرور ضعيفة';

  @override
  String get errorEmailInUse => 'البريد الإلكتروني مستخدم مسبقاً';

  @override
  String get errorUserNotFound => 'المستخدم غير موجود';

  @override
  String get errorWrongPassword => 'كلمة المرور خاطئة';

  @override
  String get errorNoData => 'لا توجد بيانات';

  @override
  String get errorEmpty => 'فارغ';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get register => 'إنشاء حساب';

  @override
  String get signUp => 'التسجيل';

  @override
  String get signIn => 'الدخول';

  @override
  String get signOut => 'الخروج';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get emailOrUsername => 'البريد الإلكتروني أو اسم المستخدم';

  @override
  String get password => 'كلمة المرور';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get currentPassword => 'كلمة المرور الحالية';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get resetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get rememberMe => 'تذكرني';

  @override
  String get staySignedIn => 'البقاء مسجلاً';

  @override
  String get loginAsGuest => 'الدخول كزائر';

  @override
  String get continueAsGuest => 'المتابعة كزائر';

  @override
  String get createAccount => 'أنشئ حسابًا';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟';

  @override
  String get orContinueWith => 'أو المتابعة باستخدام';

  @override
  String get loginWithGoogle => 'الدخول بحساب Google';

  @override
  String get loginWithApple => 'الدخول بحساب Apple';

  @override
  String get loginWithFacebook => 'الدخول بحساب Facebook';

  @override
  String get verifyEmail => 'تأكيد البريد الإلكتروني';

  @override
  String get emailVerificationSent => 'تم إرسال رابط التأكيد';

  @override
  String get enterVerificationCode => 'أدخل رمز التحقق';

  @override
  String get resendCode => 'إعادة إرسال الرمز';

  @override
  String get verificationCodeSent => 'تم إرسال رمز التحقق';

  @override
  String get accountCreated => 'تم إنشاء الحساب بنجاح';

  @override
  String get welcomeBack => 'أهلاً بك 👋';

  @override
  String welcomeUser(String name) {
    return 'مرحباً $name';
  }

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get myProfile => 'ملفي الشخصي';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get viewProfile => 'عرض الملف الشخصي';

  @override
  String get name => 'الاسم';

  @override
  String get firstName => 'الاسم الأول';

  @override
  String get lastName => 'الاسم الأخير';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get phone => 'رقم الهاتف';

  @override
  String get dateOfBirth => 'تاريخ الميلاد';

  @override
  String get gender => 'الجنس';

  @override
  String get male => 'ذكر';

  @override
  String get female => 'أنثى';

  @override
  String get country => 'الدولة';

  @override
  String get city => 'المدينة';

  @override
  String get address => 'العنوان';

  @override
  String get bio => 'نبذة';

  @override
  String get avatar => 'الصورة الشخصية';

  @override
  String get changeAvatar => 'تغيير الصورة';

  @override
  String get removeAvatar => 'إزالة الصورة';

  @override
  String get accountSettings => 'إعدادات الحساب';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get deleteAccountConfirm =>
      'هل أنت متأكد من حذف حسابك؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get settings => 'الإعدادات';

  @override
  String get generalSettings => 'الإعدادات العامة';

  @override
  String get appearance => 'المظهر';

  @override
  String get theme => 'السمة';

  @override
  String get lightMode => 'الوضع الفاتح';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get systemMode => 'حسب النظام';

  @override
  String get language => 'اللغة';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get notificationSettings => 'إعدادات الإشعارات';

  @override
  String get enableNotifications => 'تفعيل الإشعارات';

  @override
  String get disableNotifications => 'تعطيل الإشعارات';

  @override
  String get sound => 'الصوت';

  @override
  String get vibration => 'الاهتزاز';

  @override
  String get privacy => 'الخصوصية';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get termsOfService => 'شروط الخدمة';

  @override
  String get about => 'حول التطبيق';

  @override
  String get version => 'الإصدار';

  @override
  String get buildNumber => 'رقم البناء';

  @override
  String get checkForUpdates => 'التحقق من التحديثات';

  @override
  String get rateApp => 'تقييم التطبيق';

  @override
  String get shareApp => 'شارك التطبيق';

  @override
  String get contactUs => 'تواصل معنا';

  @override
  String get helpAndSupport => 'المساعدة والدعم';

  @override
  String get faq => 'الأسئلة الشائعة';

  @override
  String get feedback => 'ملاحظاتك';

  @override
  String get reportBug => 'الإبلاغ عن خطأ';

  @override
  String get licenses => 'التراخيص';

  @override
  String get home => 'الرئيسية';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get overview => 'نظرة عامة';

  @override
  String get summary => 'ملخص';

  @override
  String get today => 'اليوم';

  @override
  String get yesterday => 'أمس';

  @override
  String get tomorrow => 'غداً';

  @override
  String get thisWeek => 'هذا الأسبوع';

  @override
  String get lastWeek => 'الأسبوع الماضي';

  @override
  String get nextWeek => 'الأسبوع القادم';

  @override
  String get thisMonth => 'هذا الشهر';

  @override
  String get lastMonth => 'الشهر الماضي';

  @override
  String get nextMonth => 'الشهر القادم';

  @override
  String get thisYear => 'هذه السنة';

  @override
  String get quickActions => 'إجراءات سريعة';

  @override
  String get recentActivity => 'النشاط الأخير';

  @override
  String get statistics => 'الإحصائيات';

  @override
  String get progress => 'التقدم';

  @override
  String get achievements => 'الإنجازات';

  @override
  String get tasks => 'المهام';

  @override
  String get task => 'مهمة';

  @override
  String get myTasks => 'مهامي';

  @override
  String get allTasks => 'جميع المهام';

  @override
  String get addTask => 'إضافة المهمة';

  @override
  String get newTask => 'مهمة جديدة';

  @override
  String get editTask => 'تعديل المهمة';

  @override
  String get deleteTask => 'حذف المهمة';

  @override
  String get taskTitle => 'عنوان المهمة';

  @override
  String get taskDescription => 'وصف المهمة';

  @override
  String get taskDetails => 'تفاصيل المهمة';

  @override
  String get dueDate => 'الموعد';

  @override
  String get dueTime => 'وقت الاستحقاق';

  @override
  String get reminder => 'التذكير';

  @override
  String get reminders => 'التذكيرات';

  @override
  String get addReminder => 'إضافة تذكير';

  @override
  String get priority => 'الأولوية';

  @override
  String get highPriority => 'أولوية عالية';

  @override
  String get mediumPriority => 'أولوية متوسطة';

  @override
  String get lowPriority => 'أولوية منخفضة';

  @override
  String get noPriority => 'بدون أولوية';

  @override
  String get status => 'الحالة';

  @override
  String get todo => 'للقيام به';

  @override
  String get inProgress => 'جاري العمل';

  @override
  String get completed => 'مكتمل';

  @override
  String get cancelled => 'ملغى';

  @override
  String get overdue => 'متأخر';

  @override
  String get markAsComplete => 'تحديد كمكتمل';

  @override
  String get markAsIncomplete => 'تحديد كغير مكتمل';

  @override
  String get taskCompleted => 'تم إكمال المهمة';

  @override
  String get taskDeleted => 'تم حذف المهمة';

  @override
  String get noTasks => 'لا توجد مهام';

  @override
  String get noTasksToday => 'لا توجد مهام لليوم';

  @override
  String get noTasksThisWeek => 'لا توجد مهام لهذا الأسبوع';

  @override
  String tasksCompleted(int count) {
    return '$count مهمة مكتملة';
  }

  @override
  String tasksPending(int count) {
    return '$count مهمة معلقة';
  }

  @override
  String get category => 'التصنيف';

  @override
  String get categories => 'التصنيفات';

  @override
  String get addCategory => 'إضافة تصنيف';

  @override
  String get selectCategory => 'اختر التصنيف';

  @override
  String get subtasks => 'المهام الفرعية';

  @override
  String get addSubtask => 'إضافة مهمة فرعية';

  @override
  String get attachments => 'المرفقات';

  @override
  String get addAttachment => 'إضافة مرفق';

  @override
  String get notes => 'ملاحظات';

  @override
  String get addNote => 'إضافة ملاحظة';

  @override
  String get repeat => 'تكرار';

  @override
  String get repeatDaily => 'يومياً';

  @override
  String get repeatWeekly => 'أسبوعياً';

  @override
  String get repeatMonthly => 'شهرياً';

  @override
  String get repeatYearly => 'سنوياً';

  @override
  String get repeatCustom => 'مخصص';

  @override
  String get noRepeat => 'بدون تكرار';

  @override
  String get habits => 'العادات';

  @override
  String get habit => 'عادة';

  @override
  String get myHabits => 'عاداتي';

  @override
  String get addHabit => 'إضافة عادة';

  @override
  String get newHabit => 'عادة جديدة';

  @override
  String get editHabit => 'تعديل العادة';

  @override
  String get deleteHabit => 'حذف العادة';

  @override
  String get habitName => 'اسم العادة';

  @override
  String get habitDescription => 'وصف العادة';

  @override
  String get streak => 'السلسلة';

  @override
  String get currentStreak => 'السلسلة الحالية';

  @override
  String get longestStreak => 'أطول سلسلة';

  @override
  String streakDays(int count) {
    return '$count يوم';
  }

  @override
  String get habitCompleted => 'تم إكمال العادة';

  @override
  String get habitMissed => 'فاتتك العادة';

  @override
  String get noHabits => 'لا توجد عادات';

  @override
  String get completionRate => 'نسبة الإكمال';

  @override
  String get dailyGoal => 'الهدف اليومي';

  @override
  String get weeklyGoal => 'الهدف الأسبوعي';

  @override
  String get monthlyGoal => 'الهدف الشهري';

  @override
  String get trackingDays => 'أيام التتبع';

  @override
  String get selectDays => 'اختر الأيام';

  @override
  String get everyday => 'كل يوم';

  @override
  String get weekdays => 'أيام الأسبوع';

  @override
  String get weekends => 'عطلة نهاية الأسبوع';

  @override
  String get frequency => 'التكرار';

  @override
  String timesPerDay(int count) {
    return '$count مرة في اليوم';
  }

  @override
  String timesPerWeek(int count) {
    return '$count مرة في الأسبوع';
  }

  @override
  String get prayer => 'الصلاة';

  @override
  String get prayers => 'الصلوات';

  @override
  String get prayerTimes => 'أوقات الصلاة';

  @override
  String get nextPrayer => 'الصلاة القادمة';

  @override
  String get fajr => 'الفجر';

  @override
  String get sunrise => 'الشروق';

  @override
  String get dhuhr => 'الظهر';

  @override
  String get asr => 'العصر';

  @override
  String get maghrib => 'المغرب';

  @override
  String get isha => 'العشاء';

  @override
  String get timeRemaining => 'الوقت المتبقي';

  @override
  String timeRemainingValue(String time) {
    return '$time متبقي';
  }

  @override
  String get prayerReminder => 'تذكير الصلاة';

  @override
  String get enablePrayerReminder => 'تفعيل تذكير الصلاة';

  @override
  String get reminderBefore => 'التذكير قبل';

  @override
  String minutesBefore(int count) {
    return '$count دقيقة قبل';
  }

  @override
  String get atPrayerTime => 'وقت الصلاة';

  @override
  String get qiblaDirection => 'اتجاه القبلة';

  @override
  String get qibla => 'القبلة';

  @override
  String get location => 'الموقع';

  @override
  String get detectLocation => 'تحديد الموقع';

  @override
  String get locationDetected => 'تم تحديد الموقع';

  @override
  String get locationError => 'خطأ في تحديد الموقع';

  @override
  String get calculationMethod => 'طريقة الحساب';

  @override
  String get adjustments => 'التعديلات';

  @override
  String get hijriDate => 'التاريخ الهجري';

  @override
  String get gregorianDate => 'التاريخ الميلادي';

  @override
  String get prayerTracker => 'متتبع الصلاة';

  @override
  String get prayedOnTime => 'صليت في الوقت';

  @override
  String get prayedLate => 'صليت متأخراً';

  @override
  String get missed => 'فاتتني';

  @override
  String get prayerLog => 'سجل الصلوات';

  @override
  String get athkar => 'الأذكار';

  @override
  String get morningAthkar => 'أذكار الصباح';

  @override
  String get eveningAthkar => 'أذكار المساء';

  @override
  String get sleepAthkar => 'أذكار النوم';

  @override
  String get wakeUpAthkar => 'أذكار الاستيقاظ';

  @override
  String get afterPrayerAthkar => 'أذكار بعد الصلاة';

  @override
  String get generalAthkar => 'أذكار متنوعة';

  @override
  String get tasbih => 'التسبيح';

  @override
  String get counter => 'العداد';

  @override
  String get resetCounter => 'إعادة تعيين العداد';

  @override
  String get count => 'العدد';

  @override
  String get target => 'الهدف';

  @override
  String get targetReached => 'تم الوصول للهدف';

  @override
  String get customThikr => 'ذكر مخصص';

  @override
  String get addThikr => 'إضافة ذكر';

  @override
  String get focus => 'التركيز';

  @override
  String get focusMode => 'تركيز';

  @override
  String get startFocus => 'بدء التركيز';

  @override
  String get endFocus => 'إنهاء التركيز';

  @override
  String get focusSession => 'جلسة تركيز';

  @override
  String get focusSessions => 'جلسات التركيز';

  @override
  String get pomodoro => 'بومودورو';

  @override
  String get pomodoroTimer => 'مؤقت بومودورو';

  @override
  String get workDuration => 'مدة العمل';

  @override
  String get breakDuration => 'مدة الاستراحة';

  @override
  String get longBreakDuration => 'مدة الاستراحة الطويلة';

  @override
  String get sessionsBeforeLongBreak => 'الجلسات قبل الاستراحة الطويلة';

  @override
  String get focusTime => 'وقت التركيز';

  @override
  String get breakTime => 'وقت الاستراحة';

  @override
  String get minutes => 'دقائق';

  @override
  String get minutesShort => 'د';

  @override
  String get hours => 'ساعات';

  @override
  String get hoursShort => 'س';

  @override
  String get seconds => 'ثواني';

  @override
  String get secondsShort => 'ث';

  @override
  String get totalFocusTime => 'إجمالي وقت التركيز';

  @override
  String get todayFocusTime => 'وقت التركيز اليوم';

  @override
  String get sessionCompleted => '🎉 أحسنت! أنهيت الجلسة';

  @override
  String get takeABreak => 'خذ استراحة';

  @override
  String get breakOver => 'انتهت الاستراحة';

  @override
  String get skipBreak => 'تخطي الاستراحة';

  @override
  String get blockApps => 'حظر التطبيقات';

  @override
  String get blockedApps => 'التطبيقات المحظورة';

  @override
  String get doNotDisturb => 'عدم الإزعاج';

  @override
  String get health => 'الصحة';

  @override
  String get healthTracker => 'متتبع الصحة';

  @override
  String get medicines => 'الأدوية';

  @override
  String get medicine => 'دواء';

  @override
  String get addMedicine => 'إضافة دواء';

  @override
  String get medicineName => 'اسم الدواء';

  @override
  String get dosage => 'الجرعة';

  @override
  String get medicineReminder => 'تذكير الدواء';

  @override
  String get takeMedicine => 'تناول الدواء';

  @override
  String get medicineTaken => 'تم تناول الدواء';

  @override
  String get appointments => 'المواعيد';

  @override
  String get appointment => 'موعد';

  @override
  String get addAppointment => 'إضافة موعد';

  @override
  String get doctorName => 'اسم الطبيب';

  @override
  String get specialty => 'التخصص';

  @override
  String get clinic => 'العيادة';

  @override
  String get hospital => 'المستشفى';

  @override
  String get appointmentDate => 'تاريخ الموعد';

  @override
  String get appointmentTime => 'وقت الموعد';

  @override
  String get vitals => 'العلامات الحيوية';

  @override
  String get weight => 'الوزن';

  @override
  String get height => 'الطول';

  @override
  String get bloodPressure => 'ضغط الدم';

  @override
  String get heartRate => 'معدل ضربات القلب';

  @override
  String get bloodSugar => 'سكر الدم';

  @override
  String get temperature => 'درجة الحرارة';

  @override
  String get sleep => 'النوم';

  @override
  String get sleepTracker => 'متتبع النوم';

  @override
  String get sleepDuration => 'مدة النوم';

  @override
  String get bedtime => 'وقت النوم';

  @override
  String get wakeTime => 'وقت الاستيقاظ';

  @override
  String get sleepQuality => 'جودة النوم';

  @override
  String get water => 'الماء';

  @override
  String get waterIntake => 'شرب الماء';

  @override
  String get glasses => 'أكواب';

  @override
  String glassesOfWater(int count) {
    return '$count كوب ماء';
  }

  @override
  String get dailyWaterGoal => 'هدف الماء اليومي';

  @override
  String get steps => 'الخطوات';

  @override
  String stepsCount(int count) {
    return '$count خطوة';
  }

  @override
  String get dailyStepsGoal => 'هدف الخطوات اليومي';

  @override
  String get calories => 'السعرات';

  @override
  String get caloriesBurned => 'السعرات المحروقة';

  @override
  String get caloriesConsumed => 'السعرات المستهلكة';

  @override
  String get spaces => 'المساحات';

  @override
  String get space => 'مساحة';

  @override
  String get mySpaces => 'مساحاتي';

  @override
  String get addSpace => 'إضافة مساحة';

  @override
  String get newSpace => 'مساحة جديدة';

  @override
  String get editSpace => 'تعديل المساحة';

  @override
  String get deleteSpace => 'حذف المساحة';

  @override
  String get spaceName => 'اسم المساحة';

  @override
  String get spaceDescription => 'وصف المساحة';

  @override
  String get spaceMembers => 'أعضاء المساحة';

  @override
  String get addMember => 'إضافة عضو';

  @override
  String get removeMember => 'إزالة عضو';

  @override
  String get inviteMember => 'دعوة عضو';

  @override
  String get pendingInvitations => 'الدعوات المعلقة';

  @override
  String get acceptInvitation => 'قبول الدعوة';

  @override
  String get declineInvitation => 'رفض الدعوة';

  @override
  String get owner => 'المالك';

  @override
  String get admin => 'مدير';

  @override
  String get member => 'عضو';

  @override
  String get viewer => 'مشاهد';

  @override
  String get permissions => 'الصلاحيات';

  @override
  String get sharedWith => 'مشترك مع';

  @override
  String get private => 'خاص';

  @override
  String get public => 'عام';

  @override
  String get team => 'فريق';

  @override
  String get personal => 'شخصي';

  @override
  String get work => 'عمل';

  @override
  String get family => 'عائلة';

  @override
  String get points => 'النقاط';

  @override
  String get totalPoints => 'إجمالي النقاط';

  @override
  String pointsEarned(int count) {
    return '+$count نقطة';
  }

  @override
  String get level => 'المستوى';

  @override
  String get currentLevel => 'المستوى الحالي';

  @override
  String get nextLevel => 'المستوى التالي';

  @override
  String get levelUp => 'ترقية المستوى!';

  @override
  String get badges => 'الشارات';

  @override
  String get badge => 'شارة';

  @override
  String get newBadge => 'شارة جديدة!';

  @override
  String get badgeUnlocked => 'تم فتح شارة جديدة';

  @override
  String get rewards => 'المكافآت';

  @override
  String get reward => 'مكافأة';

  @override
  String get claimReward => 'استلام المكافأة';

  @override
  String get dailyReward => 'المكافأة اليومية';

  @override
  String get streakReward => 'مكافأة السلسلة';

  @override
  String get leaderboard => 'لوحة المتصدرين';

  @override
  String get rank => 'الترتيب';

  @override
  String get yourRank => 'ترتيبك';

  @override
  String get topPlayers => 'أفضل اللاعبين';

  @override
  String get challenges => 'التحديات';

  @override
  String get challenge => 'تحدي';

  @override
  String get dailyChallenge => 'التحدي اليومي';

  @override
  String get weeklyChallenge => 'التحدي الأسبوعي';

  @override
  String get acceptChallenge => 'قبول التحدي';

  @override
  String get challengeCompleted => 'تم إكمال التحدي';

  @override
  String get sunday => 'الأحد';

  @override
  String get monday => 'الإثنين';

  @override
  String get tuesday => 'الثلاثاء';

  @override
  String get wednesday => 'الأربعاء';

  @override
  String get thursday => 'الخميس';

  @override
  String get friday => 'الجمعة';

  @override
  String get saturday => 'السبت';

  @override
  String get sundayShort => 'أحد';

  @override
  String get mondayShort => 'إثن';

  @override
  String get tuesdayShort => 'ثلا';

  @override
  String get wednesdayShort => 'أرب';

  @override
  String get thursdayShort => 'خمي';

  @override
  String get fridayShort => 'جمع';

  @override
  String get saturdayShort => 'سبت';

  @override
  String get january => 'يناير';

  @override
  String get february => 'فبراير';

  @override
  String get march => 'مارس';

  @override
  String get april => 'أبريل';

  @override
  String get may => 'مايو';

  @override
  String get june => 'يونيو';

  @override
  String get july => 'يوليو';

  @override
  String get august => 'أغسطس';

  @override
  String get september => 'سبتمبر';

  @override
  String get october => 'أكتوبر';

  @override
  String get november => 'نوفمبر';

  @override
  String get december => 'ديسمبر';

  @override
  String get now => 'الآن';

  @override
  String get justNow => 'الآن';

  @override
  String minutesAgo(int count) {
    return 'منذ $count دقيقة';
  }

  @override
  String hoursAgo(int count) {
    return 'منذ $count ساعة';
  }

  @override
  String daysAgo(int count) {
    return 'منذ $count يوم';
  }

  @override
  String weeksAgo(int count) {
    return 'منذ $count أسبوع';
  }

  @override
  String monthsAgo(int count) {
    return 'منذ $count شهر';
  }

  @override
  String yearsAgo(int count) {
    return 'منذ $count سنة';
  }

  @override
  String inMinutes(int count) {
    return 'بعد $count دقيقة';
  }

  @override
  String inHours(int count) {
    return 'بعد $count ساعة';
  }

  @override
  String inDays(int count) {
    return 'بعد $count يوم';
  }

  @override
  String get confirmDelete => 'تأكيد الحذف';

  @override
  String get confirmDeleteMessage => 'هل أنت متأكد من حذف هذا العنصر؟';

  @override
  String get confirmLogout => 'تأكيد تسجيل الخروج';

  @override
  String get confirmLogoutMessage => 'هل أنت متأكد من تسجيل الخروج؟';

  @override
  String get discardChanges => 'تجاهل التغييرات';

  @override
  String get discardChangesMessage =>
      'لديك تغييرات غير محفوظة. هل تريد تجاهلها؟';

  @override
  String get unsavedChanges => 'تغييرات غير محفوظة';

  @override
  String get saveChanges => 'حفظ التعديلات';

  @override
  String get dontSave => 'عدم الحفظ';

  @override
  String get keepEditing => 'متابعة التحرير';

  @override
  String get noResults => 'لا توجد نتائج';

  @override
  String noResultsFor(String query) {
    return 'لا توجد نتائج لـ \"$query\"';
  }

  @override
  String get noItemsYet => 'لا توجد عناصر بعد';

  @override
  String get startByAdding => 'ابدأ بإضافة عنصر جديد';

  @override
  String get nothingHere => 'لا يوجد شيء هنا';

  @override
  String get emptyList => 'القائمة فارغة';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get letsStart => 'هيا نبدأ';

  @override
  String get welcomeToApp => 'مرحباً بك في أثر';

  @override
  String get onboardingCategory1 => 'المهام والعادات';

  @override
  String get onboardingTitle1 => 'يومك بيدك';

  @override
  String get onboardingDesc1 =>
      'نظّم مهامك وعاداتك في مكان واحد.\nابدأ يومك بوضوح وأنهِه بفخر.';

  @override
  String get onboardingChip11 => 'مهام ذكية';

  @override
  String get onboardingChip12 => 'عادات يومية';

  @override
  String get onboardingChip13 => 'تتبع التقدم';

  @override
  String get onboardingCategory2 => 'الصلاة والذكر';

  @override
  String get onboardingTitle2 => 'لا يفوتك وقت صلاة';

  @override
  String get onboardingDesc2 =>
      'أوقات صلاة دقيقة حسب موقعك،\nمع اتجاه القبلة وأذكار اليوم.';

  @override
  String get onboardingChip21 => 'أوقات الصلاة';

  @override
  String get onboardingChip22 => 'القبلة';

  @override
  String get onboardingChip23 => 'الأذكار';

  @override
  String get onboardingCategory3 => 'التركيز والإنتاجية';

  @override
  String get onboardingTitle3 => 'أنجز ما يهمّك فعلاً';

  @override
  String get onboardingDesc3 =>
      'وضع التركيز يمنع المشتّتات\nويتتبّع وقتك لإنجاز حقيقي.';

  @override
  String get onboardingChip31 => 'بومودورو';

  @override
  String get onboardingChip32 => 'حجب المشتّتات';

  @override
  String get onboardingChip33 => 'إحصاءات';

  @override
  String get onboardingCategory4 => 'ابدأ الآن';

  @override
  String get onboardingTitle4 => 'حياة أكثر أثراً';

  @override
  String get onboardingDesc4 =>
      'انضم إلى من يبنون عادات صحية\nوحياة منتجة ومتوازنة كل يوم.';

  @override
  String get onboardingChip41 => 'مجاني للبدء';

  @override
  String get onboardingChip42 => 'بدون إعلانات';

  @override
  String get onboardingChip43 => 'خصوصية تامة';

  @override
  String selectedCountLabel(int count) {
    return '$count محدد';
  }

  @override
  String get completeAll => 'إكمال الكل';

  @override
  String get postponeAll => 'تأجيل الكل';

  @override
  String get assignAll => 'إسناد الكل';

  @override
  String get deleteAll => 'حذف الكل';

  @override
  String confirmDeleteCount(int count) {
    return 'هل أنت متأكد من حذف $count عنصر؟';
  }

  @override
  String get readyTemplates => 'القوالب الجاهزة';

  @override
  String get noTemplatesSaved => 'لا توجد قوالب محفوظة';

  @override
  String templatesAvailable(int count) {
    return '$count قالب متاح';
  }

  @override
  String get noTemplatesYet => 'لم تقم بحفظ أي قوالب بعد';

  @override
  String get saveTaskAsTemplate => 'احفظ هذه المهمة كقالب';

  @override
  String get createNewTemplate => 'إنشاء قالب جديد';

  @override
  String get saveAsTemplate => 'حفظ كقالب';

  @override
  String get templateNameRequired => 'اسم القالب *';

  @override
  String get templateNameHint => 'مثال: اجتماع أسبوعي';

  @override
  String get defaultTaskTitleRequired => 'عنوان المهمة الافتراضي *';

  @override
  String get defaultTitleHint => 'مثال: اجتماع الفريق';

  @override
  String get descriptionOptional => 'وصف (اختياري)';

  @override
  String get selectIcon => 'اختر أيقونة:';

  @override
  String get priorityLabel => 'الأولوية:';

  @override
  String get urgent => 'عاجل';

  @override
  String get important => 'مهم';

  @override
  String defaultDurationMinutes(int minutes) {
    return 'المدة الافتراضية: $minutes دقيقة';
  }

  @override
  String durationMinutesShort(int count) {
    return '$count د';
  }

  @override
  String get fillRequiredFields => 'يرجى ملء الحقول المطلوبة';

  @override
  String get recurrence => 'التكرار';

  @override
  String get enableRecurrence => 'تفعيل التكرار';

  @override
  String get recurrenceTypeLabel => 'التكرار:';

  @override
  String get recurrenceDaily => 'يومي';

  @override
  String get recurrenceWeekly => 'أسبوعي';

  @override
  String get recurrenceMonthly => 'شهري';

  @override
  String get everyInterval => 'كل';

  @override
  String get recurrenceDays => 'الأيام:';

  @override
  String get recurrenceEnds => 'ينتهي:';

  @override
  String get recurrenceNever => 'أبداً';

  @override
  String get recurrenceAfter => 'بعد';

  @override
  String get recurrenceTimes => 'مرة';

  @override
  String get recurrenceOn => 'في';

  @override
  String get intervalDay => 'يوم';

  @override
  String get intervalWeek => 'أسبوع';

  @override
  String get intervalMonth => 'شهر';

  @override
  String get intervalPeriod => 'فترة';

  @override
  String get selectDate => 'اختر تاريخ';

  @override
  String everyNDays(int count) {
    return 'كل $count أيام';
  }

  @override
  String everyNWeeks(int count) {
    return 'كل $count أسابيع';
  }

  @override
  String everyNMonths(int count) {
    return 'كل $count أشهر';
  }

  @override
  String everyDayNames(String days) {
    return 'كل $days';
  }

  @override
  String nTimesParenthetical(int count) {
    return '($count مرة)';
  }

  @override
  String untilDateParenthetical(String date) {
    return '(حتى $date)';
  }

  @override
  String get foreverParenthetical => '(إلى الأبد)';

  @override
  String get wellDone => 'أحسنت! 🎉';

  @override
  String reflectionPrompt(String taskTitle) {
    return 'لقد أنجزت \"$taskTitle\". كيف كان ذلك؟';
  }

  @override
  String get addNoteOptionalHint => 'أضف ملاحظة (اختياري)...';

  @override
  String get categoryLabel => 'التصنيف:';

  @override
  String get deleteCategory => 'حذف التصنيف';

  @override
  String confirmDeleteCategory(String name) {
    return 'هل أنت متأكد من حذف تصنيف \'$name\'؟';
  }

  @override
  String get urgentFire => 'عاجل 🔥';

  @override
  String get importantStar => 'مهم ⭐';

  @override
  String get conflictWarningTitle => 'انتبه، يوجد تداخل زمني';

  @override
  String get delayAfterFinish => 'تأجيل لما بعد الانتهاء';

  @override
  String moveTimeTo(String time) {
    return 'نقل الموعد إلى $time';
  }

  @override
  String get saveAnyway => 'حفظ على أي حال';

  @override
  String get keepTimeAsIs => 'إبقاء الوقت كما هو';

  @override
  String get cancelAndEditManually => 'إلغاء وتعديل الوقت يدوياً';

  @override
  String get expectedDuration => 'المدة المتوقعة:';

  @override
  String durationHours(int count) {
    return '$count س';
  }

  @override
  String get noProject => 'بدون مشروع';

  @override
  String get selectProject => 'اختر مشروعاً';

  @override
  String get projectLabel => 'مشروع';

  @override
  String correspondingDate(String date) {
    return 'الموافق: $date';
  }

  @override
  String get myBoard => 'سبورتي 📝';

  @override
  String teamBoardsCount(int count) {
    return 'سبورات الفريق ($count)';
  }

  @override
  String lastUpdate(String time) {
    return 'آخر تحديث: $time';
  }

  @override
  String get boardNoteHint => 'اكتب ملاحظاتك، شرح المشكلة، أو التحديثات هنا...';

  @override
  String get boardUpdated => 'تم تحديث السبورة ✅';

  @override
  String get teamMember => 'عضو فريق';

  @override
  String get noTeamNotesYet => 'لا توجد ملاحظات من الفريق بعد';

  @override
  String get unifiedOpsCenter => 'مركز العمليات الموحد';

  @override
  String get allInOnePlace => 'كل ما يهمك في مكان واحد';

  @override
  String deletedItem(String title) {
    return 'تم حذف: $title';
  }

  @override
  String get undo => 'تراجع';

  @override
  String get noPermissionEdit => 'عذراً، لا تملك صلاحية تعديل هذا العنصر';

  @override
  String get dueAndOperations => 'المستحق والعمليات';

  @override
  String get completedToday => 'المكتمل اليوم';

  @override
  String get postponeSelectedTasks => 'تأجيل المهام المحددة';

  @override
  String get afterOneWeek => 'بعد أسبوع';

  @override
  String get assignSelectedTasks => 'إسناد المهام المحددة';

  @override
  String get featureUnderDevelopment => 'الميزة قيد التطوير';

  @override
  String get workZone => 'منطقة العمل';

  @override
  String get homeZone => 'وقت المنزل';

  @override
  String get quietZone => 'وقت الهدوء';

  @override
  String get freeTime => 'وقتك الحر';

  @override
  String get dayClearIdeal => 'يومك صافي ومثالي!';

  @override
  String get noTasksPending => 'لا يوجد مهام أو عمليات معلقة حالياً';

  @override
  String get yourAtharToday => 'أثرك اليوم';

  @override
  String get focusOnWhatMatters => 'ركز على ما يهم';

  @override
  String get itemDeleted => 'تم الحذف';

  @override
  String get noPermissionDelete => 'عذراً، لا تملك صلاحية حذف هذه المهمة';

  @override
  String get listView => 'عرض القائمة';

  @override
  String get boardView => 'عرض اللوحة';

  @override
  String get dayClear => 'يومك صافي!';

  @override
  String get addTasksToStart => 'أضف مهامك لتبدأ الأثر';

  @override
  String get details => 'التفاصيل';

  @override
  String get boardsAndTeam => 'السبورات & الفريق';

  @override
  String get taskTitleHint => 'عنوان المهمة';

  @override
  String get statusWaiting => 'قائمة الانتظار';

  @override
  String get statusInProgress => 'جاري التنفيذ';

  @override
  String get statusCompleted => 'مكتملة';

  @override
  String get descriptionAndNotes => 'الوصف والملاحظات';

  @override
  String get addDetailsHint => 'أضف تفاصيل، روابط، أو ملاحظات فرعية...';

  @override
  String get generalCategory => 'عام';

  @override
  String get classification => 'التصنيف';

  @override
  String get willRemindBeforeDue => 'سيتم تنبيهك قبل الموعد';

  @override
  String get noReminder => 'لن يتم تنبيهك';

  @override
  String get selectReminderTime => 'اختر وقت التذكير';

  @override
  String get quickSuggestions => 'اقتراحات سريعة:';

  @override
  String get tenMinutes => '10 دقائق';

  @override
  String get thirtyMinutes => '30 دقيقة';

  @override
  String get oneHour => 'ساعة';

  @override
  String get oneDay => 'يوم';

  @override
  String beforeDuration(String label) {
    return 'قبل $label';
  }

  @override
  String get cannotPickPastTime => 'لا يمكن اختيار وقت في الماضي';

  @override
  String get reminderMustBeBeforeTask => 'يجب أن يكون التذكير قبل موعد المهمة';

  @override
  String get whatToAccomplish => 'ماذا تريد أن تنجز؟';

  @override
  String get assignToMemberOptional => 'إسناد إلى عضو (اختياري)';

  @override
  String get memberSelected => 'تم اختيار عضو';

  @override
  String get newCategory => 'تصنيف جديد';

  @override
  String get categoryName => 'اسم التصنيف';

  @override
  String get appointmentTitle => 'عنوان الموعد';

  @override
  String get required => 'مطلوب';

  @override
  String get pills => 'حبوب';

  @override
  String get syrup => 'شراب';

  @override
  String get injection => 'إبرة';

  @override
  String get drops => 'قطرة';

  @override
  String get ointment => 'مرهم';

  @override
  String get spray => 'بخاخ';

  @override
  String get fixedTimes => 'أوقات ثابتة';

  @override
  String get repeatByHours => 'تكرار بالساعات';

  @override
  String get schedulePattern => 'نمط الجدولة';

  @override
  String get unit => 'الوحدة';

  @override
  String get selectIntakeTimes => 'حدد أوقات التناول:';

  @override
  String get every => 'كل';

  @override
  String hoursCount(int count) {
    return '$count ساعات';
  }

  @override
  String get currentStock => 'المخزون الحالي';

  @override
  String get byDays => 'بالأيام';

  @override
  String get byDate => 'بالتاريخ';

  @override
  String get treatmentDuration => 'مدة العلاج';

  @override
  String get daysCount => 'عدد الأيام';

  @override
  String get selectEndDate => 'حدد تاريخ النهاية';

  @override
  String get checkup => 'كشف';

  @override
  String get labTest => 'تحليل';

  @override
  String get vaccine => 'تطعيم';

  @override
  String get procedure => 'إجراء';

  @override
  String get doctor => 'الطبيب';

  @override
  String get locationClinic => 'المكان/العيادة';

  @override
  String get appointmentNotes => 'ملاحظات الموعد';

  @override
  String get usageInstructions => 'تعليمات الاستخدام';

  @override
  String get beforeMeal => 'قبل الأكل';

  @override
  String get afterMeal => 'بعد الأكل';

  @override
  String get withMeal => 'مع الأكل';

  @override
  String get anytime => 'في أي وقت';

  @override
  String get smartRefill => 'إعادة التعبئة الذكية';

  @override
  String get off => 'إيقاف';

  @override
  String get byQuantity => 'حسب الكمية';

  @override
  String get beforeCourseEnd => 'قبل انتهاء الكورس';

  @override
  String get autoOrderMode => 'وضع الطلب التلقائي';

  @override
  String get alertOnLowStock => 'تنبيه عند نقص الكمية لـ';

  @override
  String get alertBeforeCourseEndDays => 'تنبيه قبل انتهاء الكورس بـ (أيام)';

  @override
  String get addToList => 'إضافة للقائمة';

  @override
  String get createTask => 'إنشاء مهمة';

  @override
  String get bothTaskAndList => 'كلاهما (مهمة + قائمة)';

  @override
  String get action => 'الإجراء';

  @override
  String get assignToMember => 'إسناد لعضو';

  @override
  String get assigned => 'تم الإسناد';

  @override
  String get saveItem => 'حفظ العنصر';

  @override
  String get deleteAccountConfirmMessage =>
      'هل أنت متأكد؟ سيتم حذف حسابك السحابي نهائياً.\nماذا تريد أن تفعل بالبيانات المحفوظة في جهازك؟';

  @override
  String get deleteEverything => 'حذف كل شيء (فرمته)';

  @override
  String get deleteEverythingDesc =>
      'حذف السحابة + حذف بيانات الجهاز والبدء من الصفر.';

  @override
  String get keepLocalData => 'الاحتفاظ ببيانات الجهاز';

  @override
  String get keepLocalDataDesc =>
      'حذف السحابة فقط وتحويل الحساب لاستخدام محلي.';

  @override
  String get prayerTimesLocation => 'موقع المواقيت';

  @override
  String get detectingLocation => 'جاري تحديد الموقع...';

  @override
  String get myCurrentLocation => 'موقعي الحالي';

  @override
  String locationDetectionFailed(String error) {
    return 'فشل تحديد الموقع: $error';
  }

  @override
  String get searching => 'جاري البحث...';

  @override
  String get cityNotFound => 'لم يتم العثور على المدينة';

  @override
  String get searchError => 'حدث خطأ أثناء البحث';

  @override
  String locationUpdatedSuccess(String city) {
    return 'تم تحديث الموقع بنجاح: $city ✅';
  }

  @override
  String get useCurrentLocationGPS => 'استخدام الموقع الحالي (GPS)';

  @override
  String get or => 'أو';

  @override
  String get cityNameHint => 'اسم المدينة (مثلاً: الرياض، القاهرة)';

  @override
  String get smartZones => 'المناطق الذكية';

  @override
  String get familyTimeHome => 'وقت الأهل (المنزل)';

  @override
  String get freeTimeZone => 'وقت حر';

  @override
  String get quietZoneSettings => 'منطقة الهدوء';

  @override
  String get sleepZone => 'منطقة النوم';

  @override
  String get smartModeDisabled => 'الوضع الذكي معطل';

  @override
  String get enableSmartModeDesc => 'فعله ليقوم أثر بتنظيم وقتك تلقائياً';

  @override
  String get enableAutoMode => 'تفعيل الوضع التلقائي';

  @override
  String get changeContextByTime => 'تغيير السياق بناءً على الوقت';

  @override
  String get periodStartTime => 'وقت بداية الفترة';

  @override
  String get periodEndTime => 'وقت نهاية الفترة';

  @override
  String get addPeriod => 'إضافة فترة';

  @override
  String get workDays => 'أيام العمل:';

  @override
  String get noTimesSetYet => 'لم يتم تحديد أوقات بعد';

  @override
  String get noCategory => 'بدون تصنيف';

  @override
  String get customizeCategory => 'تخصيص التصنيف';

  @override
  String get biometricLogin => 'الدخول بالبصمة';

  @override
  String get biometricLoginDesc => 'حماية التطبيق ببصمة الوجه أو الأصبع';

  @override
  String get biometricVerificationFailed => 'فشل التحقق من البصمة';

  @override
  String get loginOrCreateAccount => 'تسجيل الدخول / إنشاء حساب';

  @override
  String get forSyncAndFamilySharing => 'للمزامنة والمشاركة العائلية';

  @override
  String get syncAndData => 'المزامنة والبيانات';

  @override
  String get autoSync => 'المزامنة التلقائية';

  @override
  String get autoSyncDesc => 'حفظ بياناتك في السحابة تلقائياً';

  @override
  String get loginRequired => 'مطلوب تسجيل الدخول';

  @override
  String get syncRequiresAccount =>
      'المزامنة السحابية تتطلب حساباً.\nهل تود تسجيل الدخول الآن؟';

  @override
  String get smartFeatures => 'الذكاء والميزات';

  @override
  String get smartZonesDesc => 'تخصيص أوقات العمل والمنزل';

  @override
  String get prayerSettings => 'إعدادات الصلاة';

  @override
  String get enablePrayerTimes => 'تفعيل مواقيت الصلاة';

  @override
  String get enablePrayerTimesDesc => 'البطاقات، التنبيهات، والتعارضات';

  @override
  String get notSet => 'غير محدد';

  @override
  String get prayerCardLocations => 'أماكن ظهور بطاقة الصلاة:';

  @override
  String get dashboardOnly => 'الداشبورد فقط';

  @override
  String get dashboardAndTasks => 'الداشبورد وصفحة المهام';

  @override
  String get allPages => 'جميع الصفحات';

  @override
  String get preferences => 'التفضيلات';

  @override
  String get hijriCalendar => 'التقويم الهجري';

  @override
  String get hijriCalendarDesc => 'استخدام التاريخ الهجري كافتراضي';

  @override
  String get morningEveningAthkar => 'أذكار الصباح والمساء';

  @override
  String get morningEveningAthkarDesc => 'تفعيل نظام الأذكار اليومي';

  @override
  String get displayMode => 'طريقة العرض:';

  @override
  String get cards => 'بطاقات';

  @override
  String get compact => 'مدمجة';

  @override
  String get sessionDisplayMode => 'طريقة عرض الجلسة:';

  @override
  String get listMode => 'قائمة';

  @override
  String get aboutApp => 'عن التطبيق';

  @override
  String get aboutAthar => 'عن أثر';

  @override
  String get whatToAdd => 'ماذا تريد أن تضيف؟';

  @override
  String get project => 'مشروع';

  @override
  String get myHabitsToday => 'عاداتي اليوم';

  @override
  String get greatJobCompletedCurrentTasks =>
      'أنت رائع! أكملت مهام الوقت الحالي.';

  @override
  String get athar => 'أثر';

  @override
  String get leaveYourMark => 'اترك أثراً في يومك';

  @override
  String get biometricLoginFailed => 'فشل الدخول البيومتري، يرجى تسجيل الدخول';

  @override
  String greetingName(Object name) {
    return '، $name';
  }

  @override
  String goodMorning(Object name) {
    return 'صباح الخير$name ☀️';
  }

  @override
  String goodAfternoon(Object name) {
    return 'طاب يومك$name ✨';
  }

  @override
  String goodEvening(Object name) {
    return 'مساء النور$name 🌙';
  }

  @override
  String goodNight(Object name) {
    return 'ليلة هادئة$name ⭐️';
  }

  @override
  String get syncSuccessful => 'تمت المزامنة بنجاح';

  @override
  String get sync => 'مزامنة';

  @override
  String get goodMorningChamp => 'صباح الخير، يا بطل ☀️';

  @override
  String get haveANiceDay => 'طاب يومك 🌤️';

  @override
  String get goodEveningSimple => 'مساء الخير 🌙';

  @override
  String get settingsComingSoon => 'الإعدادات قادمة قريباً...';

  @override
  String get drawerWelcomeGreeting => 'أهلاً بك 👋';

  @override
  String get drawerMotivationalSubtitle => 'لنجعل يومك مثمراً';

  @override
  String get drawerSmartZones => 'المناطق الذكية';

  @override
  String get drawerSmartZonesSubtitle => 'اضبط أوقات العمل والراحة';

  @override
  String get drawerHabitTracker => 'متتبع العادات';

  @override
  String get drawerHabitTrackerSubtitle => 'ابنِ عاداتك واستمر عليها';

  @override
  String get drawerFocusTimer => 'مؤقت التركيز';

  @override
  String get drawerFocusTimerSubtitle => 'تقنية بومودورو (25 دقيقة)';

  @override
  String get drawerStatistics => 'الإحصائيات';

  @override
  String get drawerStatisticsSubtitle => 'راقب إنجازك الأسبوعي';

  @override
  String get drawerGeneralSettings => 'الإعدادات العامة';

  @override
  String drawerVersionLabel(Object version) {
    return 'الإصدار $version';
  }

  @override
  String get timelineDoseTakenSuccess => 'تم تسجيل الجرعة ✅';

  @override
  String get timelineTaskCompletedSuccess => 'تم إنجاز المهمة 💪';

  @override
  String get timelineEmptyMessage =>
      'يومك صافٍ! لا توجد مهام أو أدوية حالياً 🌿';

  @override
  String get habitsHeaderQuote =>
      'وَأَن لَّيْسَ لِلْإِنسَانِ إِلَّا مَا سَعَىٰ';

  @override
  String get habitsViewCompact => 'مختصر';

  @override
  String get habitsViewDetailed => 'مفصل (أثر)';

  @override
  String get habitsSectionFajr => 'الفجر';

  @override
  String get habitsSectionBakur => 'البكور';

  @override
  String get habitsSectionMorning => 'الضحى والصباح';

  @override
  String get habitsSectionNoon => 'الظهيرة';

  @override
  String get habitsSectionAsr => 'العصر';

  @override
  String get habitsSectionMaghrib => 'المغرب';

  @override
  String get habitsSectionIsha => 'العشاء';

  @override
  String get habitsSectionNightPrayer => 'قيام الليل';

  @override
  String get habitsSectionLastThird => 'الثلث الأخير';

  @override
  String get habitsSectionAnytime => 'في أي وقت';

  @override
  String get habitsSectionDayStart => 'بداية اليوم';

  @override
  String get habitsSectionProductivity => 'وقت الإنتاجية';

  @override
  String get habitsSectionDayEnd => 'ختام اليوم';

  @override
  String get habitsSectionFlexible => 'عادات مرنة';

  @override
  String get habitsWellDone => 'أحسنت! 👏';

  @override
  String habitsCompletedHabit(Object title) {
    return 'أتممت $title';
  }

  @override
  String habitsProgressLabel(Object current, Object target) {
    return '$current / $target منجز';
  }

  @override
  String get habitsStartButton => 'ابدأ';

  @override
  String get habitsEmptyTitle => 'ابدأ رحلة العادات';

  @override
  String get habitsEmptySubtitle => 'أضف عادة جديدة من الزر أدناه';

  @override
  String get habitsCannotCompleteFuture => 'لا يمكن إنجاز عادات المستقبل!';

  @override
  String get habitsEditComingSoon => 'تعديل العادة (قريباً)';

  @override
  String get habitsDeleteTitle => 'حذف العادة؟';

  @override
  String habitsDeleteConfirm(Object title) {
    return 'هل أنت متأكد من حذف \'$title\'؟';
  }

  @override
  String get habitsDeleteCancel => 'إلغاء';

  @override
  String get habitsDeleteAction => 'حذف';

  @override
  String get athkarResetTooltip => 'تحديث الأذكار';

  @override
  String athkarProgressPercent(Object percent) {
    return '$percent% مكتمل';
  }

  @override
  String get athkarResetDialogTitle => 'تحديث قائمة الأذكار؟';

  @override
  String get athkarResetDialogContent =>
      'سيقوم هذا بتحديث نصوص الأذكار إلى النسخة الأصح والأحدث، ولكنه سيعيد تعيين تقدمك في هذا الورد إلى الصفر.\n\nهل أنت متأكد؟';

  @override
  String get athkarResetCancel => 'إلغاء';

  @override
  String get athkarResetConfirm => 'تحديث';

  @override
  String get athkarWellDone => 'أحسنت!';

  @override
  String get athkarTapToCount => 'اضغط للعد';

  @override
  String get habitFormEditTitle => 'تعديل العادة';

  @override
  String get habitFormAddTitle => 'إضافة عادة جديدة 💪';

  @override
  String get habitFormNameHint => 'ما هي عادتك القادمة؟';

  @override
  String get habitFormFrequency => 'التكرار';

  @override
  String get habitFormPreferredPeriod => 'الفترة المفضلة';

  @override
  String get habitFormTargetLabel => 'الهدف التكراري';

  @override
  String get habitFormTargetHint => 'عدد المرات';

  @override
  String get habitFormSaveEdits => 'حفظ التعديلات';

  @override
  String get habitFormStartNow => 'ابدأ العادة الآن';

  @override
  String get habitFormFreqDaily => 'يومي';

  @override
  String get habitFormFreqWeekly => 'أسبوعي';

  @override
  String get habitFormFreqMonthly => 'شهري';

  @override
  String get habitFormPeriodMorning => 'صباحاً';

  @override
  String get habitFormPeriodAfternoon => 'عصراً';

  @override
  String get habitFormPeriodNight => 'ليلاً';

  @override
  String get habitFormPeriodAnytime => 'أي وقت';

  @override
  String get habitTileDeleteConfirmTitle => 'تأكيد الحذف';

  @override
  String get habitTileDeleteConfirmContent => 'هل أنت متأكد من حذف هذه العادة؟';

  @override
  String get habitTileDeleteCancel => 'إلغاء';

  @override
  String get habitTileDeleteAction => 'حذف';

  @override
  String get habitDetailsCurrentStreak => 'السلسلة الحالية';

  @override
  String habitDetailsStreakDays(Object count) {
    return '$count يوم';
  }

  @override
  String get habitDetailsTotalCompleted => 'مجموع الإنجاز';

  @override
  String habitDetailsCompletedTimes(Object count) {
    return '$count مرة';
  }

  @override
  String get habitDetailsCommitmentLog => 'سجل الالتزام (آخر 30 يوم)';

  @override
  String get habitDetailsMotivationalMessage =>
      'كل يوم تلتزم فيه هو خطوة نحو شخصيتك الجديدة. استمر يا بطل! 🚀';

  @override
  String get habitHeatmapTitle => 'خارطة الالتزام';

  @override
  String habitHeatmapDayAchievements(Object day, Object month) {
    return 'إنجازات يوم: $day/$month';
  }

  @override
  String get healthQuickAccess => 'الوصول السريع';

  @override
  String healthBloodType(Object type) {
    return 'فصيلة الدم: $type';
  }

  @override
  String healthAllergy(Object allergies) {
    return 'حساسية: $allergies';
  }

  @override
  String get healthMedicines => 'الأدوية';

  @override
  String get healthAppointments => 'المواعيد';

  @override
  String get healthVitals => 'المؤشرات';

  @override
  String get healthTimeline => 'السجل';

  @override
  String get healthTodaySchedule => 'جدولي اليوم';

  @override
  String get healthMedFixedTimes => 'أوقات ثابتة';

  @override
  String healthMedEveryHours(Object hours) {
    return 'كل $hours ساعات';
  }

  @override
  String get healthNoAppointmentsToday => 'لا توجد مواعيد اليوم، صحتك تمام! 🌟';

  @override
  String get vitalSheetUnitLabel => 'الوحدة';

  @override
  String get healthRecords => 'السجل';

  @override
  String get healthFixedTimes => 'أوقات ثابتة';

  @override
  String healthEveryHours(Object hours) {
    return 'كل $hours ساعات';
  }

  @override
  String get vitalSheetTitle => 'تسجيل جديد 📈';

  @override
  String get vitalSheetVitalSign => 'مؤشر حيوي';

  @override
  String get vitalSheetGeneralNote => 'ملاحظة عامة';

  @override
  String get vitalSheetVitalType => 'نوع المؤشر:';

  @override
  String get vitalSheetWeight => 'وزن';

  @override
  String get vitalSheetTemperature => 'حرارة';

  @override
  String get vitalSheetPressure => 'ضغط';

  @override
  String get vitalSheetSugar => 'سكر';

  @override
  String get vitalSheetValue => 'القيمة';

  @override
  String get vitalSheetValueHint => 'مثلاً: 70';

  @override
  String get vitalSheetUnit => 'الوحدة';

  @override
  String get vitalSheetNoteLabel => 'نص الملاحظة';

  @override
  String get vitalSheetNoteHint => 'اكتب ملاحظاتك الطبية هنا...';

  @override
  String get vitalSheetSaveButton => 'حفظ السجل';

  @override
  String get medicineEditTitle => 'تعديل الدواء ✏️';

  @override
  String get medicineAddTitle => 'إضافة دواء جديد 💊';

  @override
  String get medicineRequired => 'مطلوب';

  @override
  String get medicineDosageForm => 'الشكل الدوائي:';

  @override
  String get medicineTypePill => 'حبوب';

  @override
  String get medicineTypeSyrup => 'شراب';

  @override
  String get medicineTypeInjection => 'إبرة';

  @override
  String get medicineTypeDrops => 'قطرة';

  @override
  String get medicineTypeOintment => 'مرهم';

  @override
  String get medicineTypeSpray => 'بخاخ';

  @override
  String get medicineDoseAmount => 'مقدار الجرعة';

  @override
  String get medicineDoseUnit => 'الوحدة';

  @override
  String get medicineInstructions => 'تعليمات الاستخدام';

  @override
  String get medicineBeforeMeal => 'قبل الأكل';

  @override
  String get medicineAfterMeal => 'بعد الأكل';

  @override
  String get medicineWithMeal => 'مع الأكل';

  @override
  String get medicineAnytime => 'في أي وقت';

  @override
  String get medicineFixedTimes => 'أوقات ثابتة';

  @override
  String get medicineIntervalHours => 'تكرار بالساعات';

  @override
  String get medicineStock => 'المخزون';

  @override
  String get medicineTreatmentDuration => 'مدة العلاج:';

  @override
  String get medicineSwitchToDate => 'تحديد بالتاريخ؟';

  @override
  String get medicineSwitchToDays => 'تحديد بالأيام؟';

  @override
  String get medicineDaysCount => 'عدد الأيام';

  @override
  String get medicinePickEndDate => 'اختر تاريخ النهاية';

  @override
  String get medicineAutoRefill => 'إعادة التعبئة التلقائية';

  @override
  String get medicineRefillWhen => 'متى يتم الطلب؟';

  @override
  String get medicineRefillOff => 'إيقاف (يدوي)';

  @override
  String get medicineRefillOnLowStock => 'عند نقص الكمية';

  @override
  String get medicineRefillBeforeEnd => 'قبل انتهاء الكورس';

  @override
  String get medicineRefillAtQuantity => 'عند الوصول لـ (كمية)';

  @override
  String get medicineRefillBeforeDays => 'قبل الانتهاء بـ (أيام)';

  @override
  String get medicineRefillQuantityHint => 'مثال: اطلب عندما يتبقى 5 حبات';

  @override
  String get medicineRefillDaysHint => 'مثال: اطلب قبل 3 أيام من النهاية';

  @override
  String get medicineRefillAction => 'الإجراء المطلوب';

  @override
  String get medicineRefillActionList => 'إضافة لقائمة المشتريات';

  @override
  String get medicineRefillActionTask => 'إنشاء مهمة متابعة';

  @override
  String get medicineRefillActionBoth => 'كلاهما (مهمة + قائمة)';

  @override
  String get medicineSaveEdits => 'حفظ التعديلات';

  @override
  String get medicineSave => 'حفظ الدواء';

  @override
  String get medicineSelectTimes => 'حدد أوقات التناول:';

  @override
  String get medicineEvery => 'كل';

  @override
  String medicineHoursUnit(Object count) {
    return '$count ساعات';
  }

  @override
  String get healthTimelineTitle => 'Complete Medical Record';

  @override
  String get healthTimelineAddRecord => 'Add Record';

  @override
  String get healthTimelineFilterAll => 'All';

  @override
  String get healthTimelineFilterVisits => 'Visits';

  @override
  String get healthTimelineFilterVitals => 'Vitals';

  @override
  String get healthTimelineFilterDocs => 'Documents';

  @override
  String get healthTimelineMedicalVisit => 'Medical Visit';

  @override
  String get healthTimelineDoctorPrefix => 'Dr.';

  @override
  String get healthTimelineNoteDoc => 'Note/Document';

  @override
  String get healthTimelineVitalSign => 'Vital Sign';

  @override
  String get healthTimelineNoTitle => 'Untitled';

  @override
  String get healthTimelineEmpty => 'Medical record is empty';

  @override
  String get appointmentsTitle => 'Appointments Center';

  @override
  String get appointmentsTabUpcoming => 'Upcoming';

  @override
  String get appointmentsTabArchive => 'Previous (Archive)';

  @override
  String get appointmentsNewButton => 'New Appointment';

  @override
  String get appointmentsEmptyUpcoming => 'No upcoming appointments';

  @override
  String get appointmentsEmptyArchive => 'Visit history is empty';

  @override
  String get appointmentsTypeLab => 'Lab Test';

  @override
  String get appointmentsTypeVaccine => 'Vaccination';

  @override
  String get appointmentsTypeProcedure => 'Procedure/Surgery';

  @override
  String get appointmentsTypeCheckup => 'Checkup';

  @override
  String get appointmentsDeleteAction => 'Delete Appointment';

  @override
  String get medicinesPageTitle => 'خزانة الأدوية';

  @override
  String get medicinesTabActive => 'الأدوية الحالية';

  @override
  String get medicinesTabArchive => 'الأرشيف';

  @override
  String get medicinesNewButton => 'دواء جديد';

  @override
  String get medicinesEmptyActive => 'لا توجد أدوية نشطة حالياً';

  @override
  String get medicinesEmptyArchive => 'الأرشيف فارغ';

  @override
  String medicinesEveryHours(Object hours) {
    return 'كل $hours ساعات';
  }

  @override
  String get medicinesMenuEdit => 'تعديل';

  @override
  String get medicinesMenuArchive => 'نقل للأرشيف (إيقاف)';

  @override
  String get medicinesMenuReactivate => 'تفعيل مجدداً';

  @override
  String get medicinesMenuDelete => 'حذف نهائي';

  @override
  String get vitalsPageTitle => 'المؤشرات والأرشيف';

  @override
  String get vitalsNewButton => 'قراءة جديدة';

  @override
  String get vitalsEmptyState => 'لا توجد سجلات';

  @override
  String get vitalsFilterAll => 'الكل';

  @override
  String get vitalsFilterWeight => 'الوزن';

  @override
  String get vitalsFilterTemp => 'الحرارة';

  @override
  String get vitalsFilterPressure => 'الضغط';

  @override
  String get vitalsFilterSugar => 'السكر';

  @override
  String get vitalsFilterDocuments => 'ملاحظات/وثائق';

  @override
  String get vitalsIndicatorGeneric => 'مؤشر';

  @override
  String get vitalsNoteDocument => 'ملاحظة/وثيقة';

  @override
  String get vitalsNoTitle => 'بدون عنوان';

  @override
  String get appointmentSheetTitle => 'حجز موعد جديد 🗓️';

  @override
  String get appointmentTitleLabel => 'عنوان الموعد (مطلوب)';

  @override
  String get appointmentTitleHint => 'مثلاً: فحص نظر، تطعيم 6 شهور';

  @override
  String get appointmentVisitType => 'نوع الزيارة:';

  @override
  String get appointmentTypeCheckup => 'كشف';

  @override
  String get appointmentTypeLab => 'تحليل';

  @override
  String get appointmentTypeVaccine => 'تطعيم';

  @override
  String get appointmentTypeProcedure => 'إجراء';

  @override
  String get appointmentDateLabel => 'التاريخ';

  @override
  String get appointmentTimeLabel => 'الوقت';

  @override
  String get appointmentDoctorLabel => 'الطبيب';

  @override
  String get appointmentLocationLabel => 'العيادة/المكان';

  @override
  String get appointmentNotesLabel => 'ملاحظات';

  @override
  String get appointmentSaveButton => 'حفظ الموعد';

  @override
  String projectDetailsError(Object message) {
    return 'خطأ: $message';
  }

  @override
  String get projectDetailsNewTask => 'مهمة جديدة';

  @override
  String get projectDetailsViewList => 'عرض القائمة';

  @override
  String get projectDetailsViewBoard => 'عرض اللوحة';

  @override
  String get projectDetailsSettings => 'إعدادات المشروع';

  @override
  String projectDetailsTaskCount(Object count) {
    return 'المهام ($count)';
  }

  @override
  String get projectDetailsSortManual => 'ترتيب يدوي';

  @override
  String get projectDetailsSortEisenhower => 'الأهمية (ايزنهاور)';

  @override
  String get projectDetailsSortTime => 'الأقرب وقتاً';

  @override
  String get projectDetailsTimeExpired => 'انتهى الوقت';

  @override
  String projectDetailsDaysLeft(Object days) {
    return 'باقي $days يوم';
  }

  @override
  String get projectDetailsShowMore => 'المزيد...';

  @override
  String get projectDetailsProgressLabel => 'نسبة الإنجاز';

  @override
  String get projectDetailsNameLabel => 'اسم المشروع';

  @override
  String get projectDetailsDescLabel => 'وصف المشروع (اختياري)';

  @override
  String get projectDetailsStartDate => 'البداية';

  @override
  String get projectDetailsEndDate => 'النهاية (Deadline)';

  @override
  String get projectDetailsUpdateSuccess => 'تم تحديث بيانات المشروع بنجاح ✅';

  @override
  String get projectDetailsSaveChanges => 'حفظ التغييرات';

  @override
  String get projectDetailsRestore => 'استعادة المشروع';

  @override
  String get projectDetailsArchive => 'أرشفة المشروع';

  @override
  String get projectDetailsRestoreDesc => 'سيعود للقائمة الرئيسية';

  @override
  String get projectDetailsArchiveDesc =>
      'سيتم إخفاؤه من القائمة الرئيسية (نسبة الإنجاز محفوظة)';

  @override
  String get projectDetailsArchived => 'تم أرشفة المشروع';

  @override
  String get projectDetailsNotSet => 'غير محدد';

  @override
  String get projectDetailsTaskDeleted => 'تم حذف المهمة';

  @override
  String get projectDetailsNoDeletePermission =>
      'عذراً، لا تملك صلاحية حذف هذه المهمة 🚫';

  @override
  String get projectDetailsEmptyState => 'ابدأ مشروعك بإضافة مهمة';

  @override
  String get spaceSettings => 'إعدادات المساحة';

  @override
  String get spacePermissionSettings => 'إعدادات الصلاحيات';

  @override
  String get spaceDeleteAction => 'حذف';

  @override
  String get spaceDeleteModuleTitle => 'حذف العنصر';

  @override
  String spaceDeleteModuleContent(Object name) {
    return 'هل أنت متأكد من حذف \'$name\'؟\nيمكنك استعادته لاحقاً من الأرشيف (قريباً).';
  }

  @override
  String get spaceModuleDeletedSuccess => 'تم حذف العنصر بنجاح 🗑️';

  @override
  String get spaceCancel => 'إلغاء';

  @override
  String get spaceEmptyTitle => 'المساحة فارغة';

  @override
  String get spaceEmptySubtitle => 'أضف مشاريع أو قوائم أو خزينة أصول';

  @override
  String get spaceAddNewTitle => 'إضافة جديد';

  @override
  String get spaceModuleNameHint => 'الاسم (مثلاً: عزبة البر)';

  @override
  String get spacePrivateModule => 'موديول خاص (Private)';

  @override
  String get spacePrivateModuleDesc => 'لا يراه إلا من تقوم بدعوته';

  @override
  String get spaceCreateAction => 'إنشاء';

  @override
  String get spaceCopyFromTemplate => 'نسخ من قائمة سابقة (اختياري)';

  @override
  String get spaceEmptyList => 'قائمة فارغة';

  @override
  String get spaceListCopiedSuccess => 'تم إنشاء القائمة ونسخ العناصر بنجاح ✅';

  @override
  String get moduleTypeProject => 'مشروع';

  @override
  String get moduleTypeList => 'قائمة';

  @override
  String get moduleTypeHealth => 'ملف صحي';

  @override
  String get moduleTypeAssets => 'خزينة أصول';

  @override
  String get moduleTypeGeneral => 'عام';

  @override
  String get listPurchaseHistory => 'سجل المشتريات';

  @override
  String get listCopyAsTemplate => 'نسخ القائمة (حفظ كقالب)';

  @override
  String get listResetTitle => 'إعادة تصفير القائمة';

  @override
  String get listAdvancedOptions => 'خيارات متقدمة (كمية، تكرار)';

  @override
  String get listQuickAddHint => 'إضافة سريعة...';

  @override
  String get listEmptyState => 'القائمة فارغة';

  @override
  String get listResetContent => 'هل تريد إلغاء تحديد جميع العناصر؟';

  @override
  String get listResetAction => 'تصفير';

  @override
  String get listDuplicateTitle => 'تكرار القائمة';

  @override
  String get listDuplicateDesc =>
      'سيتم إنشاء قائمة جديدة تحتوي على نفس العناصر.';

  @override
  String get listNewListName => 'اسم القائمة الجديدة';

  @override
  String get listCopyAction => 'نسخ';

  @override
  String get listCopiedSuccess => 'تم نسخ القائمة بنجاح ✅';

  @override
  String listCopyOfName(Object name) {
    return 'نسخة من $name';
  }

  @override
  String listRepeatEveryDays(Object days) {
    return ' كل $days يوم';
  }

  @override
  String get moduleTypeAssetsShort => 'أصول';

  @override
  String get moduleTypeHealthShort => 'صحي';

  @override
  String get listPageHistoryTooltip => 'سجل المشتريات';

  @override
  String get listPageDuplicateOption => 'نسخ القائمة (حفظ كقالب)';

  @override
  String get listPageResetOption => 'إعادة تصفير القائمة';

  @override
  String listPageRepeatEvery(Object days) {
    return ' كل $days يوم';
  }

  @override
  String get listPageAdvancedTooltip => 'خيارات متقدمة (كمية، تكرار)';

  @override
  String get listPageQuickAddHint => 'إضافة سريعة...';

  @override
  String get listPageEmptyTitle => 'القائمة فارغة';

  @override
  String get listPageResetTitle => 'إعادة تصفير القائمة';

  @override
  String get listPageResetMessage => 'هل تريد إلغاء تحديد جميع العناصر؟';

  @override
  String get listPageCancel => 'إلغاء';

  @override
  String get listPageResetAction => 'تصفير';

  @override
  String listPageDuplicateDefaultName(Object name) {
    return 'نسخة من $name';
  }

  @override
  String get listPageDuplicateTitle => 'تكرار القائمة';

  @override
  String get listPageDuplicateDescription =>
      'سيتم إنشاء قائمة جديدة تحتوي على نفس العناصر.';

  @override
  String get listPageNewListNameLabel => 'اسم القائمة الجديدة';

  @override
  String get listPageDuplicateSuccess => 'تم نسخ القائمة بنجاح ✅';

  @override
  String get listPageDuplicateAction => 'نسخ';

  @override
  String get spaceListTitle => 'مساحاتي 🪐';

  @override
  String get spaceListInboxTooltip => 'الدعوات';

  @override
  String get spaceListNewSpace => 'مساحة جديدة';

  @override
  String get spaceListPersonalSpace => 'مساحة خاصة';

  @override
  String get spaceListSharedSpace => 'مساحة مشتركة';

  @override
  String get spaceListDeleteTitle => 'حذف المساحة';

  @override
  String spaceListDeleteMessage(String name) {
    return 'هل أنت متأكد من حذف مساحة \'$name\'؟\nسيؤدي هذا لحذف جميع المشاريع والمهام بداخلها.';
  }

  @override
  String get spaceListCancel => 'إلغاء';

  @override
  String get spaceListDelete => 'حذف';

  @override
  String get spaceListEmptyTitle => 'لا توجد مساحات بعد';

  @override
  String get spaceListCreateTitle => 'إنشاء مساحة جديدة';

  @override
  String get spaceListNameLabel => 'اسم المساحة (البيت، العمل...)';

  @override
  String get spaceListSharedQuestion => 'مساحة مشتركة؟';

  @override
  String get spaceListSharedSubtitle => 'سيتمكن الآخرون من الانضمام';

  @override
  String get spaceListPrivateSubtitle => 'خاصة بك فقط';

  @override
  String get spaceListCreate => 'إنشاء';

  @override
  String get moduleSettingsTitle => 'إعدادات الموديول';

  @override
  String get moduleSettingsContextHealth =>
      'صلاحيات متابعة الأدوية والمهام الصحية';

  @override
  String get moduleSettingsContextAssets =>
      'صلاحيات تعيين مسؤوليات الصيانة والجرد';

  @override
  String get moduleSettingsContextList => 'صلاحيات قائمة المشتريات والمهام';

  @override
  String get moduleSettingsContextProject =>
      'صلاحيات إسناد وتفويض مهام المشروع';

  @override
  String get moduleSettingsDelegationLabel => 'نظام التفويض (Delegation):';

  @override
  String get moduleSettingsModeInherit => 'افتراضي (يتبع المساحة)';

  @override
  String get moduleSettingsModeInheritDesc => 'تطبق إعدادات المساحة العامة';

  @override
  String get moduleSettingsModeEnabled => 'مسموح دائماً';

  @override
  String get moduleSettingsModeEnabledDesc =>
      'يستطيع الأعضاء سحب وإسناد المهام بحرية';

  @override
  String get moduleSettingsModeDisabled => 'محمي (ممنوع)';

  @override
  String get moduleSettingsModeDisabledDesc =>
      'لا يمكن للأعضاء تغيير المسؤولين (للمدراء فقط)';

  @override
  String get moduleSettingsCancel => 'إلغاء';

  @override
  String get moduleSettingsSave => 'حفظ';

  @override
  String get moduleSettingsSaveSuccess => 'تم تحديث الصلاحيات بنجاح ✅';

  @override
  String get addModuleTitle => 'إضافة موديول';

  @override
  String get addModuleNewProject => 'مشروع جديد 🚀';

  @override
  String get addModuleEditProject => 'تعديل المشروع';

  @override
  String get addModuleProjectNameLabel => 'اسم المشروع';

  @override
  String get addModuleNameLabel => 'اسم الموديول';

  @override
  String get addModuleDeadlineHint => 'موعد التسليم (اختياري)';

  @override
  String get addModuleSave => 'حفظ';

  @override
  String get addListItemEditTitle => 'تعديل الغرض ✏️';

  @override
  String get addListItemAddTitle => 'إضافة غرض جديد 🛒';

  @override
  String get addListItemNameLabel => 'اسم الغرض';

  @override
  String get addListItemQuantityLabel => 'الكمية';

  @override
  String get addListItemUnitLabel => 'الوحدة';

  @override
  String get addListItemRepeatTitle => 'التكرار التلقائي';

  @override
  String get addListItemRepeatDaysLabel => 'يتكرر كل (أيام)';

  @override
  String get addListItemRepeatDaysHelper => 'مثال: 7 لأسبوع';

  @override
  String get addListItemAutoUncheck => 'إعادة تلقائية';

  @override
  String get addListItemAutoUncheckDesc => 'يعود للقائمة';

  @override
  String get addListItemSaveEdits => 'حفظ التعديلات';

  @override
  String get addListItemAddToList => 'إضافة للقائمة';

  @override
  String get inboxTitle => 'صندوق الدعوات';

  @override
  String get inboxNewInvite => 'دعوة جديدة';

  @override
  String get inboxInviteMessage =>
      'لقد تمت دعوتك للانضمام إلى مساحة عمل جديدة.\nانقر قبول للبدء بالتعاون.';

  @override
  String get inboxJoiningSpace => 'جاري الانضمام للمساحة... 🚀';

  @override
  String get inboxAcceptInvite => 'قبول الدعوة';

  @override
  String get inboxEmptyTitle => 'لا توجد دعوات جديدة';

  @override
  String get inboxEmptySubtitle => 'أنت جاهز تماماً! استمتع بوقتك';

  @override
  String get spaceSettingsDialogTitle => 'إعدادات المساحة';

  @override
  String spaceSettingsDialogDesc(String name) {
    return 'التحكم في صلاحيات الأعضاء العامة داخل \'$name\'';
  }

  @override
  String get spaceSettingsDelegationToggle => 'السماح بالتفويض (Delegation)';

  @override
  String get spaceSettingsDelegationOnDesc =>
      'يستطيع الأعضاء تمرير المهام لبعضهم';

  @override
  String get spaceSettingsDelegationOffDesc =>
      'يمنع أي عضو من سحب أو تمرير المهام';

  @override
  String get spaceSettingsUpdateSuccess => 'تم تحديث إعدادات المساحة ✅';

  @override
  String listHistoryTitle(String name) {
    return 'سجل مشتريات: $name';
  }

  @override
  String get listHistoryEmpty => 'السجل فارغ';

  @override
  String get joinSpaceSuccess => 'تم الانضمام للمساحة بنجاح! 🎉';

  @override
  String get joinSpaceLoading => 'جاري الانضمام للمساحة...';

  @override
  String get joinSpaceBackHome => 'العودة للرئيسية';

  @override
  String get spaceMembersTitle => 'أعضاء المساحة';

  @override
  String get spaceMembersTotalLabel => 'إجمالي الأعضاء';

  @override
  String get spaceMembersAddButton => 'إضافة عضو';

  @override
  String get spaceMembersDefaultName => 'مستخدم أثر';

  @override
  String get spaceMembersRoleOwner => 'المالك';

  @override
  String get spaceMembersRoleAdmin => 'مدير';

  @override
  String get spaceMembersRoleMember => 'عضو';

  @override
  String get spaceMembersRoleFounder => 'مؤسس المساحة';

  @override
  String get spaceMembersSearchTitle => 'بحث عن أعضاء';

  @override
  String get spaceMembersSearchHint => 'البريد الإلكتروني أو اسم المستخدم';

  @override
  String get spaceMembersSearchPrompt => 'ابحث لإضافة أعضاء';

  @override
  String get spaceMembersInviteSent => 'تم إرسال الدعوة';

  @override
  String get spaceMembersPromoteAdmin => 'ترقية إلى مدير';

  @override
  String get spaceMembersDemoteMember => 'إلغاء الصلاحية (تخفيض لعضو)';

  @override
  String get spaceMembersKick => 'طرد من المساحة';

  @override
  String get spaceMembersConfirmPrompt => 'هل أنت متأكد؟';

  @override
  String get memberSelectorTitle => 'إسناد المهمة إلى...';

  @override
  String get memberSelectorEmpty => 'لا يوجد أعضاء في هذه المساحة';

  @override
  String get memberSelectorDefaultName => 'مستخدم';

  @override
  String get memberSelectorUnassign => 'إعادتها للمجموعة (إلغاء الإسناد)';

  @override
  String get assetsPageTitle => 'خزينة الأصول';

  @override
  String get assetsAddButton => 'إضافة أصل';

  @override
  String get assetsNoSearchResults => 'لا توجد أصول للبحث عنها';

  @override
  String get assetsEmptyTitle => 'خزينتك فارغة';

  @override
  String get assetsEmptySubtitle => 'أضف فواتيرك وضماناتك لترتاح بالك';

  @override
  String get assetsSearchNoMatch => 'لا توجد نتائج مطابقة';

  @override
  String serviceLogsTitle(String name) {
    return 'سجل: $name';
  }

  @override
  String get serviceLogsEmpty => 'لا توجد سجلات سابقة';

  @override
  String serviceLogsCost(num cost) {
    return '$cost ريال';
  }

  @override
  String serviceLogsOdometer(num reading) {
    return '$reading كم';
  }

  @override
  String get assetStatusActive => 'ساري';

  @override
  String get assetStatusExpiringSoon => 'قارب على الانتهاء';

  @override
  String get assetStatusExpired => 'منتهي';

  @override
  String assetDaysRemaining(int count) {
    return '$count يوم';
  }

  @override
  String get assetDetailsNotFound => 'لم يتم العثور على الأصل';

  @override
  String get comingSoon => 'قريباً...';

  @override
  String get assetDetailsTabOverview => 'نظرة عامة';

  @override
  String get assetDetailsTabMaintenance => 'سجل الصيانة';

  @override
  String get assetWarrantyActive => 'الضمان ساري';

  @override
  String get assetWarrantyExpiringSoon => 'ينتهي قريباً!';

  @override
  String get assetWarrantyExpired => 'الضمان منتهي';

  @override
  String get assetDetailsInvoicesPhotos => 'الفواتير والصور';

  @override
  String get assetDetailsAddPhoto => 'إضافة';

  @override
  String get assetDetailsNoAttachments => 'لا توجد صور للفاتورة أو الجهاز';

  @override
  String get assetDetailsInfo => 'التفاصيل';

  @override
  String get assetDetailsCategory => 'الفئة';

  @override
  String get assetDetailsVendor => 'المتجر/البائع';

  @override
  String get assetDetailsPrice => 'السعر';

  @override
  String get assetDetailsNotes => 'ملاحظات';

  @override
  String get assetDetailsDefineService => 'تعريف خدمة جديدة';

  @override
  String get assetServiceStatusPending => 'غير محدد (بانتظار أول سجل)';

  @override
  String assetServiceOverdue(int days) {
    return 'متأخر بـ $days يوم!';
  }

  @override
  String assetServiceAtOdometer(num reading) {
    return 'عند عداد: $reading كم';
  }

  @override
  String get assetServiceLogButton => 'السجل';

  @override
  String get assetServiceRecordButton => 'تسجيل صيانة';

  @override
  String get assetServicesEmpty => 'لم يتم تعريف أي خدمات صيانة';

  @override
  String get assetServicesDefineExample => 'تعريف خدمة (مثل: غيار زيت)';

  @override
  String get assetDeleteTitle => 'حذف الأصل';

  @override
  String get assetDeleteConfirm =>
      'هل أنت متأكد؟ سيتم حذف جميع الفواتير والسجلات المرتبطة.';

  @override
  String get assetDeleteSuccess => 'تم الحذف';

  @override
  String get addAssetTitle => 'إضافة أصل جديد 💎';

  @override
  String get addAssetNameLabel => 'اسم الجهاز/الأصل';

  @override
  String get addAssetNameRequired => 'الاسم مطلوب';

  @override
  String get addAssetCategoryLabel => 'الفئة (مثلاً: جوال)';

  @override
  String get addAssetPriceLabel => 'السعر';

  @override
  String addAssetPurchaseDate(String date) {
    return 'تاريخ الشراء: $date';
  }

  @override
  String get addAssetWarrantyLabel => 'مدة الضمان (بالأشهر)';

  @override
  String get addAssetWarrantyHint => 'مثال: 12 لسنة واحدة، 24 لسنتين';

  @override
  String get addAssetShowAdvanced => 'إضافة تفاصيل (البائع، السيريال، ملاحظات)';

  @override
  String get addAssetHideAdvanced => 'إخفاء التفاصيل الإضافية';

  @override
  String get addAssetVendorLabel => 'المتجر / البائع';

  @override
  String get addAssetSerialLabel => 'الرقم التسلسلي (S/N)';

  @override
  String get addAssetNotesLabel => 'ملاحظات إضافية';

  @override
  String get addAssetSaveButton => 'حفظ الأصل';

  @override
  String get addAssetSuccess => 'تمت إضافة الأصل بنجاح ✅';

  @override
  String get addServiceTitle => 'تعريف خدمة صيانة جديدة 🛠️';

  @override
  String get addServiceSubtitle =>
      'حدد نوع الصيانة وقواعد تكرارها ليقوم النظام بتذكيرك.';

  @override
  String get addServiceNameLabel => 'اسم الخدمة (مثلاً: غيار زيت)';

  @override
  String get addServiceNameRequired => 'الاسم مطلوب';

  @override
  String get addServiceRepeatLabel => 'تتكرر هذه الصيانة كل:';

  @override
  String get addServiceDaysLabel => 'عدد الأيام';

  @override
  String get addServiceDaysSuffix => 'يوم';

  @override
  String get addServiceKmLabel => 'المسافة';

  @override
  String get addServiceKmSuffix => 'كم';

  @override
  String get addServiceRepeatHint =>
      '* يمكنك تعبئة الحقلين معاً، وسينبهك النظام أيهما يأتي أولاً.';

  @override
  String get addServiceRepeatRequired =>
      'يجب تحديد قاعدة تكرار واحدة على الأقل (أيام أو كم)';

  @override
  String get addServiceSaveButton => 'حفظ الخدمة';

  @override
  String addServiceLogTitle(String name) {
    return 'تسجيل تنفيذ: $name ✅';
  }

  @override
  String get addServiceLogSubtitle =>
      'سيتم تحديث موعد الصيانة القادم تلقائياً بناءً على هذه البيانات.';

  @override
  String addServiceLogDate(String date) {
    return 'تاريخ التنفيذ: $date';
  }

  @override
  String get addServiceLogOdometerLabel => 'قراءة العداد';

  @override
  String get addServiceLogOdometerHint => 'كم الحالي';

  @override
  String get addServiceLogCostLabel => 'التكلفة';

  @override
  String get addServiceLogCostHint => 'اختياري';

  @override
  String get addServiceLogNotesLabel => 'ملاحظات (مثلاً: نوع الزيت)';

  @override
  String get addServiceLogSaveButton => 'حفظ وتحديث الموعد القادم';

  @override
  String get addServiceLogSuccess => 'تم تسجيل الصيانة وتحديث التوقعات ✅';

  @override
  String get prayerTimesTitle => 'مواقيت الصلاة';

  @override
  String get prayerTimesSubtitle =>
      'إن الصلاة كانت على المؤمنين كتاباً موقوتاً';

  @override
  String get prayerTabToday => 'اليوم';

  @override
  String get prayerTabWeek => 'أسبوع';

  @override
  String get prayerTabMonth => 'شهر';

  @override
  String get prayerMonthComingSoon => 'التقويم الشهري قادم قريباً';

  @override
  String get prayerFajrShort => 'فجر';

  @override
  String get prayerDhuhrShort => 'ظهر';

  @override
  String get prayerAsrShort => 'عصر';

  @override
  String get prayerMaghribShort => 'مغرب';

  @override
  String get prayerIshaShort => 'عشاء';

  @override
  String get prayerSunrise => 'الشروق';

  @override
  String get calendarTitle => 'التقويم';

  @override
  String get calendarDayEvents => 'أحداث هذا اليوم';

  @override
  String get calendarNoTasks => 'لا توجد مهام في هذا اليوم';

  @override
  String get weekdaySunAbbr => 'ح';

  @override
  String get weekdayMonAbbr => 'ن';

  @override
  String get weekdayTueAbbr => 'ث';

  @override
  String get weekdayWedAbbr => 'ر';

  @override
  String get weekdayThuAbbr => 'خ';

  @override
  String get weekdayFriAbbr => 'ج';

  @override
  String get weekdaySatAbbr => 'س';

  @override
  String get focusNowOn => 'أركز الآن على';

  @override
  String get focusStatusRunning => '⏱ جارٍ التركيز';

  @override
  String get focusStatusPaused => '⏸ متوقف مؤقتاً';

  @override
  String get focusStatusReady => 'جاهز للبدء';

  @override
  String get focusPause => 'إيقاف مؤقت';

  @override
  String get focusStop => 'إنهاء';

  @override
  String get focusResume => 'استئناف';

  @override
  String get focusReset => 'إعادة';

  @override
  String get notificationsTitle => 'مركز التنبيهات';

  @override
  String get notificationsClearAll => 'مسح الكل';

  @override
  String get notificationsEmpty => 'لا توجد تنبيهات حالياً';

  @override
  String get statsPageTitle => 'لوحة الإنجاز';

  @override
  String get statsFocusPerformance => 'أداء التركيز';

  @override
  String get statsHabitCommitment => 'التزام العادات';

  @override
  String get statsWelcome => 'مرحباً بك، يا بطل! 👋';

  @override
  String get statsMotivation => 'استمر في صناعة الأثر.';

  @override
  String get statsWeeklyFocusTitle => 'تركيزي هذا الأسبوع';

  @override
  String statsWeeklyFocusTotal(int minutes) {
    return '$minutes دقيقة إجمالية';
  }

  @override
  String statsMinutesAbbr(int count) {
    return '$count د';
  }

  @override
  String get statsRange7Days => '٧ أيام';

  @override
  String get statsRange30Days => '٣٠ يوماً';

  @override
  String get statsTodaySection => 'يومك اليوم';

  @override
  String statsTodayTasks(int done, int total) {
    return '$done/$total مهمة';
  }

  @override
  String statsTodayHabits(int done, int total) {
    return '$done/$total عادة';
  }

  @override
  String statsTodayFocus(int minutes) {
    return '$minutes د تركيز';
  }

  @override
  String get statsTasksSection => 'المهام';

  @override
  String statsCompletionRate(int pct) {
    return '$pct% مُنجز';
  }

  @override
  String statsOverdueTasks(int count) {
    return '$count متأخرة';
  }

  @override
  String statsAvgDelay(int days) {
    return 'متوسط التأخير $days يوم';
  }

  @override
  String get statsTasksByPriority => 'حسب الأولوية';

  @override
  String get statsPriorityHigh => 'عالية';

  @override
  String get statsPriorityMedium => 'متوسطة';

  @override
  String get statsPriorityLow => 'منخفضة';

  @override
  String get statsDailyCompletion => 'الإنجاز اليومي';

  @override
  String get statsHabitsSection => 'العادات';

  @override
  String statsConsistency(int pct) {
    return '$pct% استمرارية';
  }

  @override
  String get statsTopStreaks => 'أفضل السلاسل';

  @override
  String statsStreakDays(int days) {
    return '$days يوم';
  }

  @override
  String get statsHeatmapTitle => 'خريطة العادات';

  @override
  String get statsFocusSection => 'التركيز';

  @override
  String get statsFocusTotal => 'إجمالي التركيز';

  @override
  String statsFocusHours(int h, int m) {
    return '$hس $mد';
  }

  @override
  String get statsPeriodsSection => 'الإنتاجية حسب الوقت';

  @override
  String get statsDomainsSection => 'المجالات';

  @override
  String get statsDomainNeglected => 'يحتاج اهتماماً';

  @override
  String get statsDomainOverloaded => 'محمّل بكثير';

  @override
  String get statsInsightsSection => 'التحليلات';

  @override
  String get statsNoData => 'لا توجد بيانات كافية للعرض';

  @override
  String get statsNoDataSub => 'أضف مهاماً وعادات لرؤية تحليل شامل';

  @override
  String get statsUpgradeTitle => 'إحصائيات تفصيلية';

  @override
  String get statsUpgradeBody =>
      'اشترك للوصول إلى التقارير الكاملة والتحليلات المتقدمة';

  @override
  String get statsUpgradeCta => 'اشترك الآن';

  @override
  String get statsCardTitle => 'إحصائيات الأثر';

  @override
  String get statsCardSubtitle => 'شاهد ملخص أدائك وتركيزك';

  @override
  String get reminderToggleLabel => 'تفعيل التذكير';

  @override
  String get reminderTimeLabel => 'وقت التذكير';

  @override
  String get reminderChooseTime => 'اختر الوقت';

  @override
  String get datePickerGregorian => 'ميلادي';

  @override
  String get datePickerHijri => 'هجري';

  @override
  String datePickerCorresponding(String date) {
    return 'الموافق: $date';
  }

  @override
  String get datePickerConfirm => 'تأكيد التاريخ';

  @override
  String get timelineTypeTask => 'مهمة';

  @override
  String get timelineTypeMedicine => 'دواء';

  @override
  String get timelineTypeAppointment => 'موعد';

  @override
  String get kanbanTodo => 'للقيام به';

  @override
  String get kanbanInProgress => 'جاري العمل';

  @override
  String get kanbanDone => 'مكتمل';

  @override
  String get kanbanDragHere => 'اسحب المهام هنا';

  @override
  String get appBarSettingsTooltip => 'الإعدادات';

  @override
  String get appBarCalendarTooltip => 'التقويم';

  @override
  String get appBarFocusTooltip => 'وضع التركيز';

  @override
  String get prayerCardTimePrefix => 'المتبقي: ';

  @override
  String get prayerCardDuhaTime => 'وقت صلاة الضحى متاح الآن';

  @override
  String get prayerCardQiyamTime => 'وقت قيام الليل - الثلث الأخير';

  @override
  String get prayerCardSetLocation => 'تحديد الموقع';

  @override
  String get prayerCardChangeLocation => 'تغيير الموقع';

  @override
  String get taskRibbonInProgress => 'جاري العمل';

  @override
  String get taskRibbonNew => 'جديد';

  @override
  String get taskStatusOptions => 'خيارات الحالة';

  @override
  String get taskStatusWaiting => 'الانتظار';

  @override
  String get taskStatusExecuting => 'التنفيذ';

  @override
  String get taskStatusCompleted => 'مكتملة';

  @override
  String get taskAssignToMember => 'إسناد لموظف';

  @override
  String get taskPickedUp => '💪 كفو! المهمة صارت عندك';

  @override
  String get taskPickupLabel => 'أنا لها';

  @override
  String get taskAssignedToYou => 'مسندة إليك';

  @override
  String get taskAssignedToOther => 'مسندة لعضو آخر';

  @override
  String get textFieldEmailLabel => 'البريد الإلكتروني';

  @override
  String get textFieldPasswordLabel => 'كلمة المرور';

  @override
  String get textFieldPhoneLabel => 'رقم الهاتف';

  @override
  String get textFieldSearchHint => 'بحث...';

  @override
  String get dialogConfirmLabel => 'تأكيد';

  @override
  String get dialogCancelLabel => 'إلغاء';

  @override
  String get dialogOkLabel => 'حسناً';

  @override
  String get emptyStateNoData => 'لا توجد بيانات';

  @override
  String get emptyStateNoResults => 'لا توجد نتائج';

  @override
  String get emptyStateNoResultsMessage => 'جرب البحث بكلمات مختلفة';

  @override
  String get emptyStateError => 'حدث خطأ';

  @override
  String get emptyStateErrorMessage => 'حدث خطأ غير متوقع';

  @override
  String get emptyStateRetry => 'إعادة المحاولة';

  @override
  String get emptyStateNoConnection => 'لا يوجد اتصال';

  @override
  String get emptyStateNoConnectionMessage => 'تحقق من اتصالك بالإنترنت';

  @override
  String get attachmentImage => 'صورة';

  @override
  String get attachmentFile => 'ملف (PDF/Doc)';

  @override
  String get fileExpiredTitle => 'الملف منتهي الصلاحية';

  @override
  String get fileArchivedMessage =>
      'هذا الملف تم أرشفته سحابياً. هل تود إرسال إشعار للمالك لإعادة رفعه؟';

  @override
  String get requestReupload => 'طلب إعادة الرفع';

  @override
  String get requestSentToOwner => 'تم إرسال الطلب للمالك ✅';

  @override
  String get downloadingFromCloud => 'جاري التحميل من السحابة...';

  @override
  String get noAttachments => 'لا توجد مرفقات';

  @override
  String get logoutSuccess => 'تم تسجيل الخروج بنجاح';

  @override
  String get usernameLabel => 'اسم المستخدم (Username)';

  @override
  String get profileUpdatedSuccess => 'تم تحديث البيانات بنجاح';

  @override
  String get updateAthkarListTitle => 'تحديث قائمة الأذكار؟';

  @override
  String get updateAthkarDescription =>
      'سيقوم هذا بتحديث نصوص الأذكار إلى النسخة الأصح والأحدث، ولكنه سيعيد تعيين تقدمك في هذا القسم.';

  @override
  String get updateAthkar => 'تحديث الأذكار';

  @override
  String get tapToCount => 'اضغط للتسبيح';

  @override
  String get achievementDone => 'تم الإنجاز ✅';

  @override
  String progressPercent(Object count) {
    return '$count% مكتمل';
  }

  @override
  String get welcomeToAthar => 'أهلاً بك في أثر';

  @override
  String get loginSubtitle => 'سجل دخولك لتزامن مساحاتك المشتركة';

  @override
  String get passwordTooShort => 'كلمة المرور قصيرة';

  @override
  String get skipContinueAsGuest => 'تخطي (المتابعة كضيف)';

  @override
  String get noAccountCreateNew => 'ليس لديك حساب؟ أنشئ حساباً جديداً';

  @override
  String get dataSyncTitle => 'تزامن البيانات';

  @override
  String get dataSyncConflictMessage =>
      'توجد بيانات محفوظة على جهازك وأخرى في السحابة.\nكيف تود المتابعة؟';

  @override
  String get restoreCloudData => 'استرجاع السحابة (مسح المحلي)';

  @override
  String get syncKeepLocal => 'اعتماد المحلي (مسح السحابة)';

  @override
  String get mergeDataBest => 'دمج البيانات (الأفضل)';

  @override
  String get joinAtharFamily => 'انضم لعائلة أثر';

  @override
  String get minThreeChars => '3 أحرف على الأقل';

  @override
  String get minSixChars => '6 خانات على الأقل';

  @override
  String get completeProfile => 'إكمال الملف الشخصي';

  @override
  String get welcomeCompleteProfile => 'مرحباً بك! يرجى إكمال بياناتك للمتابعة';

  @override
  String get saveAndContinue => 'حفظ ومتابعة';

  @override
  String get projects => 'المشاريع';

  @override
  String get kanbanComingSoon => 'نظام كانبان قريباً...';

  @override
  String get chooseIcon => 'اختر أيقونة';

  @override
  String get searchIcons => 'البحث في الأيقونات...';

  @override
  String get icon => 'الأيقونة';

  @override
  String get color => 'اللون';

  @override
  String get tapToChangeIcon => 'اضغط لتغيير الأيقونة';

  @override
  String get skipAsGuest => 'تخطي (المتابعة كضيف)';

  @override
  String get noAccount => 'ليس لديك حساب؟';

  @override
  String get syncConflict => 'تزامن البيانات';

  @override
  String get syncConflictMessage =>
      'توجد بيانات على جهازك وأخرى في السحابة. كيف تود المتابعة؟';

  @override
  String get keepLocal => 'الاحتفاظ بالمحلي';

  @override
  String get keepCloud => 'الاحتفاظ بالسحابة';

  @override
  String get mergeBoth => 'دمج البيانات (الأفضل)';

  @override
  String get navigationSettings => 'التنقل';

  @override
  String get hideNavOnScroll => 'إخفاء شريط التنقل عند التمرير';

  @override
  String get hideNavOnScrollDesc =>
      'إخفاء الشريط السفلي تلقائياً عند التمرير للأسفل';
}
