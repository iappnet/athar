import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// اسم التطبيق
  ///
  /// In ar, this message translates to:
  /// **'أثر'**
  String get appName;

  /// شعار التطبيق
  ///
  /// In ar, this message translates to:
  /// **'حياة متوازنة، أثر مستدام'**
  String get appTagline;

  /// وصف التطبيق
  ///
  /// In ar, this message translates to:
  /// **'تطبيق شامل لإدارة الحياة اليومية'**
  String get appDescription;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get add;

  /// No description provided for @create.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء'**
  String get create;

  /// No description provided for @update.
  ///
  /// In ar, this message translates to:
  /// **'تحديث'**
  String get update;

  /// No description provided for @remove.
  ///
  /// In ar, this message translates to:
  /// **'إزالة'**
  String get remove;

  /// No description provided for @search.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In ar, this message translates to:
  /// **'تصفية'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In ar, this message translates to:
  /// **'ترتيب'**
  String get sort;

  /// No description provided for @share.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة'**
  String get share;

  /// No description provided for @copy.
  ///
  /// In ar, this message translates to:
  /// **'نسخ'**
  String get copy;

  /// No description provided for @paste.
  ///
  /// In ar, this message translates to:
  /// **'لصق'**
  String get paste;

  /// No description provided for @select.
  ///
  /// In ar, this message translates to:
  /// **'اختيار'**
  String get select;

  /// No description provided for @selectAll.
  ///
  /// In ar, this message translates to:
  /// **'اختيار الكل'**
  String get selectAll;

  /// No description provided for @clear.
  ///
  /// In ar, this message translates to:
  /// **'مسح'**
  String get clear;

  /// No description provided for @clearAll.
  ///
  /// In ar, this message translates to:
  /// **'مسح الكل'**
  String get clearAll;

  /// No description provided for @reset.
  ///
  /// In ar, this message translates to:
  /// **'إعادة تعيين'**
  String get reset;

  /// No description provided for @refresh.
  ///
  /// In ar, this message translates to:
  /// **'تحديث'**
  String get refresh;

  /// No description provided for @reload.
  ///
  /// In ar, this message translates to:
  /// **'إعادة تحميل'**
  String get reload;

  /// No description provided for @close.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get close;

  /// No description provided for @open.
  ///
  /// In ar, this message translates to:
  /// **'فتح'**
  String get open;

  /// No description provided for @show.
  ///
  /// In ar, this message translates to:
  /// **'عرض'**
  String get show;

  /// No description provided for @hide.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء'**
  String get hide;

  /// No description provided for @expand.
  ///
  /// In ar, this message translates to:
  /// **'توسيع'**
  String get expand;

  /// No description provided for @collapse.
  ///
  /// In ar, this message translates to:
  /// **'طي'**
  String get collapse;

  /// No description provided for @more.
  ///
  /// In ar, this message translates to:
  /// **'المزيد'**
  String get more;

  /// No description provided for @less.
  ///
  /// In ar, this message translates to:
  /// **'أقل'**
  String get less;

  /// No description provided for @all.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get all;

  /// No description provided for @none.
  ///
  /// In ar, this message translates to:
  /// **'لا شيء'**
  String get none;

  /// No description provided for @yes.
  ///
  /// In ar, this message translates to:
  /// **'نعم'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In ar, this message translates to:
  /// **'لا'**
  String get no;

  /// No description provided for @ok.
  ///
  /// In ar, this message translates to:
  /// **'موافق'**
  String get ok;

  /// No description provided for @confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// No description provided for @done.
  ///
  /// In ar, this message translates to:
  /// **'تم'**
  String get done;

  /// No description provided for @finish.
  ///
  /// In ar, this message translates to:
  /// **'إنهاء'**
  String get finish;

  /// No description provided for @complete.
  ///
  /// In ar, this message translates to:
  /// **'اكتمل'**
  String get complete;

  /// No description provided for @next.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In ar, this message translates to:
  /// **'السابق'**
  String get previous;

  /// No description provided for @back.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get back;

  /// No description provided for @forward.
  ///
  /// In ar, this message translates to:
  /// **'تقدم'**
  String get forward;

  /// No description provided for @skip.
  ///
  /// In ar, this message translates to:
  /// **'تخطي'**
  String get skip;

  /// No description provided for @continue_.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get continue_;

  /// No description provided for @start.
  ///
  /// In ar, this message translates to:
  /// **'بدء'**
  String get start;

  /// No description provided for @stop.
  ///
  /// In ar, this message translates to:
  /// **'إيقاف'**
  String get stop;

  /// No description provided for @pause.
  ///
  /// In ar, this message translates to:
  /// **'إيقاف مؤقت'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In ar, this message translates to:
  /// **'استئناف'**
  String get resume;

  /// No description provided for @retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// No description provided for @tryAgain.
  ///
  /// In ar, this message translates to:
  /// **'حاول مرة أخرى'**
  String get tryAgain;

  /// No description provided for @submit.
  ///
  /// In ar, this message translates to:
  /// **'إرسال'**
  String get submit;

  /// No description provided for @send.
  ///
  /// In ar, this message translates to:
  /// **'إرسال'**
  String get send;

  /// No description provided for @apply.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق'**
  String get apply;

  /// No description provided for @loading.
  ///
  /// In ar, this message translates to:
  /// **'جاري التحميل...'**
  String get loading;

  /// No description provided for @pleaseWait.
  ///
  /// In ar, this message translates to:
  /// **'يرجى الانتظار...'**
  String get pleaseWait;

  /// No description provided for @processing.
  ///
  /// In ar, this message translates to:
  /// **'جاري المعالجة...'**
  String get processing;

  /// No description provided for @success.
  ///
  /// In ar, this message translates to:
  /// **'نجاح'**
  String get success;

  /// No description provided for @error.
  ///
  /// In ar, this message translates to:
  /// **'خطأ'**
  String get error;

  /// No description provided for @warning.
  ///
  /// In ar, this message translates to:
  /// **'تحذير'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In ar, this message translates to:
  /// **'معلومات'**
  String get info;

  /// No description provided for @pending.
  ///
  /// In ar, this message translates to:
  /// **'قيد الانتظار'**
  String get pending;

  /// No description provided for @active.
  ///
  /// In ar, this message translates to:
  /// **'نشط'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In ar, this message translates to:
  /// **'غير نشط'**
  String get inactive;

  /// No description provided for @enabled.
  ///
  /// In ar, this message translates to:
  /// **'مفعّل'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In ar, this message translates to:
  /// **'معطّل'**
  String get disabled;

  /// No description provided for @online.
  ///
  /// In ar, this message translates to:
  /// **'متصل'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In ar, this message translates to:
  /// **'غير متصل'**
  String get offline;

  /// No description provided for @syncing.
  ///
  /// In ar, this message translates to:
  /// **'جاري المزامنة...'**
  String get syncing;

  /// No description provided for @synced.
  ///
  /// In ar, this message translates to:
  /// **'تمت المزامنة'**
  String get synced;

  /// No description provided for @notSynced.
  ///
  /// In ar, this message translates to:
  /// **'غير متزامن'**
  String get notSynced;

  /// No description provided for @errorOccurred.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ: {error}'**
  String errorOccurred(String error);

  /// No description provided for @errorUnknown.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير معروف'**
  String get errorUnknown;

  /// No description provided for @errorNetwork.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في الاتصال بالإنترنت'**
  String get errorNetwork;

  /// No description provided for @errorServer.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في الخادم'**
  String get errorServer;

  /// No description provided for @errorTimeout.
  ///
  /// In ar, this message translates to:
  /// **'انتهت مهلة الاتصال'**
  String get errorTimeout;

  /// No description provided for @errorNotFound.
  ///
  /// In ar, this message translates to:
  /// **'غير موجود'**
  String get errorNotFound;

  /// No description provided for @errorPermission.
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك الصلاحية'**
  String get errorPermission;

  /// No description provided for @errorRequired.
  ///
  /// In ar, this message translates to:
  /// **'هذا الحقل مطلوب'**
  String get errorRequired;

  /// No description provided for @errorInvalid.
  ///
  /// In ar, this message translates to:
  /// **'قيمة غير صالحة'**
  String get errorInvalid;

  /// No description provided for @errorMinLength.
  ///
  /// In ar, this message translates to:
  /// **'يجب أن يكون على الأقل {count} أحرف'**
  String errorMinLength(int count);

  /// No description provided for @errorMaxLength.
  ///
  /// In ar, this message translates to:
  /// **'يجب ألا يتجاوز {count} أحرف'**
  String errorMaxLength(int count);

  /// No description provided for @errorInvalidEmail.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني غير صالح'**
  String get errorInvalidEmail;

  /// No description provided for @errorInvalidPhone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف غير صالح'**
  String get errorInvalidPhone;

  /// No description provided for @errorInvalidPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور غير صالحة'**
  String get errorInvalidPassword;

  /// No description provided for @errorPasswordMismatch.
  ///
  /// In ar, this message translates to:
  /// **'كلمات المرور غير متطابقة'**
  String get errorPasswordMismatch;

  /// No description provided for @errorWeakPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور ضعيفة'**
  String get errorWeakPassword;

  /// No description provided for @errorEmailInUse.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني مستخدم مسبقاً'**
  String get errorEmailInUse;

  /// No description provided for @errorUserNotFound.
  ///
  /// In ar, this message translates to:
  /// **'المستخدم غير موجود'**
  String get errorUserNotFound;

  /// No description provided for @errorWrongPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور خاطئة'**
  String get errorWrongPassword;

  /// No description provided for @errorNoData.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات'**
  String get errorNoData;

  /// No description provided for @errorEmpty.
  ///
  /// In ar, this message translates to:
  /// **'فارغ'**
  String get errorEmpty;

  /// No description provided for @login.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout;

  /// No description provided for @register.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get register;

  /// No description provided for @signUp.
  ///
  /// In ar, this message translates to:
  /// **'التسجيل'**
  String get signUp;

  /// No description provided for @signIn.
  ///
  /// In ar, this message translates to:
  /// **'الدخول'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In ar, this message translates to:
  /// **'الخروج'**
  String get signOut;

  /// No description provided for @email.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get email;

  /// No description provided for @emailOrUsername.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني أو اسم المستخدم'**
  String get emailOrUsername;

  /// No description provided for @password.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور'**
  String get confirmPassword;

  /// No description provided for @currentPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الحالية'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الجديدة'**
  String get newPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور؟'**
  String get forgotPassword;

  /// No description provided for @resetPassword.
  ///
  /// In ar, this message translates to:
  /// **'إعادة تعيين كلمة المرور'**
  String get resetPassword;

  /// No description provided for @changePassword.
  ///
  /// In ar, this message translates to:
  /// **'تغيير كلمة المرور'**
  String get changePassword;

  /// No description provided for @rememberMe.
  ///
  /// In ar, this message translates to:
  /// **'تذكرني'**
  String get rememberMe;

  /// No description provided for @staySignedIn.
  ///
  /// In ar, this message translates to:
  /// **'البقاء مسجلاً'**
  String get staySignedIn;

  /// No description provided for @loginAsGuest.
  ///
  /// In ar, this message translates to:
  /// **'الدخول كزائر'**
  String get loginAsGuest;

  /// No description provided for @continueAsGuest.
  ///
  /// In ar, this message translates to:
  /// **'المتابعة كزائر'**
  String get continueAsGuest;

  /// No description provided for @createAccount.
  ///
  /// In ar, this message translates to:
  /// **'أنشئ حسابًا'**
  String get createAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In ar, this message translates to:
  /// **'لديك حساب بالفعل؟'**
  String get alreadyHaveAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك حساب؟'**
  String get dontHaveAccount;

  /// No description provided for @orContinueWith.
  ///
  /// In ar, this message translates to:
  /// **'أو المتابعة باستخدام'**
  String get orContinueWith;

  /// No description provided for @loginWithGoogle.
  ///
  /// In ar, this message translates to:
  /// **'الدخول بحساب Google'**
  String get loginWithGoogle;

  /// No description provided for @loginWithApple.
  ///
  /// In ar, this message translates to:
  /// **'الدخول بحساب Apple'**
  String get loginWithApple;

  /// No description provided for @loginWithFacebook.
  ///
  /// In ar, this message translates to:
  /// **'الدخول بحساب Facebook'**
  String get loginWithFacebook;

  /// No description provided for @verifyEmail.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد البريد الإلكتروني'**
  String get verifyEmail;

  /// No description provided for @emailVerificationSent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال رابط التأكيد'**
  String get emailVerificationSent;

  /// No description provided for @enterVerificationCode.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رمز التحقق'**
  String get enterVerificationCode;

  /// No description provided for @resendCode.
  ///
  /// In ar, this message translates to:
  /// **'إعادة إرسال الرمز'**
  String get resendCode;

  /// No description provided for @verificationCodeSent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال رمز التحقق'**
  String get verificationCodeSent;

  /// No description provided for @accountCreated.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء الحساب بنجاح'**
  String get accountCreated;

  /// No description provided for @welcomeBack.
  ///
  /// In ar, this message translates to:
  /// **'أهلاً بك 👋'**
  String get welcomeBack;

  /// No description provided for @welcomeUser.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً {name}'**
  String welcomeUser(String name);

  /// No description provided for @profile.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get profile;

  /// No description provided for @myProfile.
  ///
  /// In ar, this message translates to:
  /// **'ملفي الشخصي'**
  String get myProfile;

  /// No description provided for @editProfile.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الملف الشخصي'**
  String get editProfile;

  /// No description provided for @viewProfile.
  ///
  /// In ar, this message translates to:
  /// **'عرض الملف الشخصي'**
  String get viewProfile;

  /// No description provided for @name.
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get name;

  /// No description provided for @firstName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الأول'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الأخير'**
  String get lastName;

  /// No description provided for @fullName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل'**
  String get fullName;

  /// No description provided for @username.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستخدم'**
  String get username;

  /// No description provided for @phone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get phone;

  /// No description provided for @dateOfBirth.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الميلاد'**
  String get dateOfBirth;

  /// No description provided for @gender.
  ///
  /// In ar, this message translates to:
  /// **'الجنس'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In ar, this message translates to:
  /// **'ذكر'**
  String get male;

  /// No description provided for @female.
  ///
  /// In ar, this message translates to:
  /// **'أنثى'**
  String get female;

  /// No description provided for @country.
  ///
  /// In ar, this message translates to:
  /// **'الدولة'**
  String get country;

  /// No description provided for @city.
  ///
  /// In ar, this message translates to:
  /// **'المدينة'**
  String get city;

  /// No description provided for @address.
  ///
  /// In ar, this message translates to:
  /// **'العنوان'**
  String get address;

  /// No description provided for @bio.
  ///
  /// In ar, this message translates to:
  /// **'نبذة'**
  String get bio;

  /// No description provided for @avatar.
  ///
  /// In ar, this message translates to:
  /// **'الصورة الشخصية'**
  String get avatar;

  /// No description provided for @changeAvatar.
  ///
  /// In ar, this message translates to:
  /// **'تغيير الصورة'**
  String get changeAvatar;

  /// No description provided for @removeAvatar.
  ///
  /// In ar, this message translates to:
  /// **'إزالة الصورة'**
  String get removeAvatar;

  /// No description provided for @accountSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الحساب'**
  String get accountSettings;

  /// No description provided for @deleteAccount.
  ///
  /// In ar, this message translates to:
  /// **'حذف الحساب'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف حسابك؟ لا يمكن التراجع عن هذا الإجراء.'**
  String get deleteAccountConfirm;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @generalSettings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات العامة'**
  String get generalSettings;

  /// No description provided for @appearance.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In ar, this message translates to:
  /// **'السمة'**
  String get theme;

  /// No description provided for @lightMode.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الفاتح'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الداكن'**
  String get darkMode;

  /// No description provided for @systemMode.
  ///
  /// In ar, this message translates to:
  /// **'حسب النظام'**
  String get systemMode;

  /// No description provided for @language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @notifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notifications;

  /// No description provided for @notificationSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الإشعارات'**
  String get notificationSettings;

  /// No description provided for @enableNotifications.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل الإشعارات'**
  String get enableNotifications;

  /// No description provided for @disableNotifications.
  ///
  /// In ar, this message translates to:
  /// **'تعطيل الإشعارات'**
  String get disableNotifications;

  /// No description provided for @sound.
  ///
  /// In ar, this message translates to:
  /// **'الصوت'**
  String get sound;

  /// No description provided for @vibration.
  ///
  /// In ar, this message translates to:
  /// **'الاهتزاز'**
  String get vibration;

  /// No description provided for @privacy.
  ///
  /// In ar, this message translates to:
  /// **'الخصوصية'**
  String get privacy;

  /// No description provided for @privacyPolicy.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In ar, this message translates to:
  /// **'شروط الخدمة'**
  String get termsOfService;

  /// No description provided for @about.
  ///
  /// In ar, this message translates to:
  /// **'حول التطبيق'**
  String get about;

  /// No description provided for @version.
  ///
  /// In ar, this message translates to:
  /// **'الإصدار'**
  String get version;

  /// No description provided for @buildNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم البناء'**
  String get buildNumber;

  /// No description provided for @checkForUpdates.
  ///
  /// In ar, this message translates to:
  /// **'التحقق من التحديثات'**
  String get checkForUpdates;

  /// No description provided for @rateApp.
  ///
  /// In ar, this message translates to:
  /// **'تقييم التطبيق'**
  String get rateApp;

  /// No description provided for @shareApp.
  ///
  /// In ar, this message translates to:
  /// **'شارك التطبيق'**
  String get shareApp;

  /// No description provided for @contactUs.
  ///
  /// In ar, this message translates to:
  /// **'تواصل معنا'**
  String get contactUs;

  /// No description provided for @helpAndSupport.
  ///
  /// In ar, this message translates to:
  /// **'المساعدة والدعم'**
  String get helpAndSupport;

  /// No description provided for @faq.
  ///
  /// In ar, this message translates to:
  /// **'الأسئلة الشائعة'**
  String get faq;

  /// No description provided for @feedback.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظاتك'**
  String get feedback;

  /// No description provided for @reportBug.
  ///
  /// In ar, this message translates to:
  /// **'الإبلاغ عن خطأ'**
  String get reportBug;

  /// No description provided for @licenses.
  ///
  /// In ar, this message translates to:
  /// **'التراخيص'**
  String get licenses;

  /// No description provided for @home.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get home;

  /// No description provided for @dashboard.
  ///
  /// In ar, this message translates to:
  /// **'لوحة التحكم'**
  String get dashboard;

  /// No description provided for @overview.
  ///
  /// In ar, this message translates to:
  /// **'نظرة عامة'**
  String get overview;

  /// No description provided for @summary.
  ///
  /// In ar, this message translates to:
  /// **'ملخص'**
  String get summary;

  /// No description provided for @today.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In ar, this message translates to:
  /// **'أمس'**
  String get yesterday;

  /// No description provided for @tomorrow.
  ///
  /// In ar, this message translates to:
  /// **'غداً'**
  String get tomorrow;

  /// No description provided for @thisWeek.
  ///
  /// In ar, this message translates to:
  /// **'هذا الأسبوع'**
  String get thisWeek;

  /// No description provided for @lastWeek.
  ///
  /// In ar, this message translates to:
  /// **'الأسبوع الماضي'**
  String get lastWeek;

  /// No description provided for @nextWeek.
  ///
  /// In ar, this message translates to:
  /// **'الأسبوع القادم'**
  String get nextWeek;

  /// No description provided for @thisMonth.
  ///
  /// In ar, this message translates to:
  /// **'هذا الشهر'**
  String get thisMonth;

  /// No description provided for @lastMonth.
  ///
  /// In ar, this message translates to:
  /// **'الشهر الماضي'**
  String get lastMonth;

  /// No description provided for @nextMonth.
  ///
  /// In ar, this message translates to:
  /// **'الشهر القادم'**
  String get nextMonth;

  /// No description provided for @thisYear.
  ///
  /// In ar, this message translates to:
  /// **'هذه السنة'**
  String get thisYear;

  /// No description provided for @quickActions.
  ///
  /// In ar, this message translates to:
  /// **'إجراءات سريعة'**
  String get quickActions;

  /// No description provided for @recentActivity.
  ///
  /// In ar, this message translates to:
  /// **'النشاط الأخير'**
  String get recentActivity;

  /// No description provided for @statistics.
  ///
  /// In ar, this message translates to:
  /// **'الإحصائيات'**
  String get statistics;

  /// No description provided for @progress.
  ///
  /// In ar, this message translates to:
  /// **'التقدم'**
  String get progress;

  /// No description provided for @achievements.
  ///
  /// In ar, this message translates to:
  /// **'الإنجازات'**
  String get achievements;

  /// No description provided for @tasks.
  ///
  /// In ar, this message translates to:
  /// **'المهام'**
  String get tasks;

  /// No description provided for @task.
  ///
  /// In ar, this message translates to:
  /// **'مهمة'**
  String get task;

  /// No description provided for @myTasks.
  ///
  /// In ar, this message translates to:
  /// **'مهامي'**
  String get myTasks;

  /// No description provided for @allTasks.
  ///
  /// In ar, this message translates to:
  /// **'جميع المهام'**
  String get allTasks;

  /// No description provided for @addTask.
  ///
  /// In ar, this message translates to:
  /// **'إضافة المهمة'**
  String get addTask;

  /// No description provided for @newTask.
  ///
  /// In ar, this message translates to:
  /// **'مهمة جديدة'**
  String get newTask;

  /// No description provided for @editTask.
  ///
  /// In ar, this message translates to:
  /// **'تعديل المهمة'**
  String get editTask;

  /// No description provided for @deleteTask.
  ///
  /// In ar, this message translates to:
  /// **'حذف المهمة'**
  String get deleteTask;

  /// No description provided for @taskTitle.
  ///
  /// In ar, this message translates to:
  /// **'عنوان المهمة'**
  String get taskTitle;

  /// No description provided for @taskDescription.
  ///
  /// In ar, this message translates to:
  /// **'وصف المهمة'**
  String get taskDescription;

  /// No description provided for @taskDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل المهمة'**
  String get taskDetails;

  /// No description provided for @dueDate.
  ///
  /// In ar, this message translates to:
  /// **'الموعد'**
  String get dueDate;

  /// No description provided for @dueTime.
  ///
  /// In ar, this message translates to:
  /// **'وقت الاستحقاق'**
  String get dueTime;

  /// No description provided for @reminder.
  ///
  /// In ar, this message translates to:
  /// **'التذكير'**
  String get reminder;

  /// No description provided for @reminders.
  ///
  /// In ar, this message translates to:
  /// **'التذكيرات'**
  String get reminders;

  /// No description provided for @addReminder.
  ///
  /// In ar, this message translates to:
  /// **'إضافة تذكير'**
  String get addReminder;

  /// No description provided for @priority.
  ///
  /// In ar, this message translates to:
  /// **'الأولوية'**
  String get priority;

  /// No description provided for @highPriority.
  ///
  /// In ar, this message translates to:
  /// **'أولوية عالية'**
  String get highPriority;

  /// No description provided for @mediumPriority.
  ///
  /// In ar, this message translates to:
  /// **'أولوية متوسطة'**
  String get mediumPriority;

  /// No description provided for @lowPriority.
  ///
  /// In ar, this message translates to:
  /// **'أولوية منخفضة'**
  String get lowPriority;

  /// No description provided for @noPriority.
  ///
  /// In ar, this message translates to:
  /// **'بدون أولوية'**
  String get noPriority;

  /// No description provided for @status.
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get status;

  /// No description provided for @todo.
  ///
  /// In ar, this message translates to:
  /// **'للقيام به'**
  String get todo;

  /// No description provided for @inProgress.
  ///
  /// In ar, this message translates to:
  /// **'جاري العمل'**
  String get inProgress;

  /// No description provided for @completed.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل'**
  String get completed;

  /// No description provided for @cancelled.
  ///
  /// In ar, this message translates to:
  /// **'ملغى'**
  String get cancelled;

  /// No description provided for @overdue.
  ///
  /// In ar, this message translates to:
  /// **'متأخر'**
  String get overdue;

  /// No description provided for @markAsComplete.
  ///
  /// In ar, this message translates to:
  /// **'تحديد كمكتمل'**
  String get markAsComplete;

  /// No description provided for @markAsIncomplete.
  ///
  /// In ar, this message translates to:
  /// **'تحديد كغير مكتمل'**
  String get markAsIncomplete;

  /// No description provided for @taskCompleted.
  ///
  /// In ar, this message translates to:
  /// **'تم إكمال المهمة'**
  String get taskCompleted;

  /// No description provided for @taskDeleted.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف المهمة'**
  String get taskDeleted;

  /// No description provided for @noTasks.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مهام'**
  String get noTasks;

  /// No description provided for @noTasksToday.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مهام لليوم'**
  String get noTasksToday;

  /// No description provided for @noTasksThisWeek.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مهام لهذا الأسبوع'**
  String get noTasksThisWeek;

  /// No description provided for @tasksCompleted.
  ///
  /// In ar, this message translates to:
  /// **'{count} مهمة مكتملة'**
  String tasksCompleted(int count);

  /// No description provided for @tasksPending.
  ///
  /// In ar, this message translates to:
  /// **'{count} مهمة معلقة'**
  String tasksPending(int count);

  /// No description provided for @category.
  ///
  /// In ar, this message translates to:
  /// **'التصنيف'**
  String get category;

  /// No description provided for @categories.
  ///
  /// In ar, this message translates to:
  /// **'التصنيفات'**
  String get categories;

  /// No description provided for @addCategory.
  ///
  /// In ar, this message translates to:
  /// **'إضافة تصنيف'**
  String get addCategory;

  /// No description provided for @selectCategory.
  ///
  /// In ar, this message translates to:
  /// **'اختر التصنيف'**
  String get selectCategory;

  /// No description provided for @subtasks.
  ///
  /// In ar, this message translates to:
  /// **'المهام الفرعية'**
  String get subtasks;

  /// No description provided for @addSubtask.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مهمة فرعية'**
  String get addSubtask;

  /// No description provided for @attachments.
  ///
  /// In ar, this message translates to:
  /// **'المرفقات'**
  String get attachments;

  /// No description provided for @addAttachment.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مرفق'**
  String get addAttachment;

  /// No description provided for @notes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات'**
  String get notes;

  /// No description provided for @addNote.
  ///
  /// In ar, this message translates to:
  /// **'إضافة ملاحظة'**
  String get addNote;

  /// No description provided for @repeat.
  ///
  /// In ar, this message translates to:
  /// **'تكرار'**
  String get repeat;

  /// No description provided for @repeatDaily.
  ///
  /// In ar, this message translates to:
  /// **'يومياً'**
  String get repeatDaily;

  /// No description provided for @repeatWeekly.
  ///
  /// In ar, this message translates to:
  /// **'أسبوعياً'**
  String get repeatWeekly;

  /// No description provided for @repeatMonthly.
  ///
  /// In ar, this message translates to:
  /// **'شهرياً'**
  String get repeatMonthly;

  /// No description provided for @repeatYearly.
  ///
  /// In ar, this message translates to:
  /// **'سنوياً'**
  String get repeatYearly;

  /// No description provided for @repeatCustom.
  ///
  /// In ar, this message translates to:
  /// **'مخصص'**
  String get repeatCustom;

  /// No description provided for @noRepeat.
  ///
  /// In ar, this message translates to:
  /// **'بدون تكرار'**
  String get noRepeat;

  /// No description provided for @habits.
  ///
  /// In ar, this message translates to:
  /// **'العادات'**
  String get habits;

  /// No description provided for @habit.
  ///
  /// In ar, this message translates to:
  /// **'عادة'**
  String get habit;

  /// No description provided for @myHabits.
  ///
  /// In ar, this message translates to:
  /// **'عاداتي'**
  String get myHabits;

  /// No description provided for @addHabit.
  ///
  /// In ar, this message translates to:
  /// **'إضافة عادة'**
  String get addHabit;

  /// No description provided for @newHabit.
  ///
  /// In ar, this message translates to:
  /// **'عادة جديدة'**
  String get newHabit;

  /// No description provided for @editHabit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل العادة'**
  String get editHabit;

  /// No description provided for @deleteHabit.
  ///
  /// In ar, this message translates to:
  /// **'حذف العادة'**
  String get deleteHabit;

  /// No description provided for @habitName.
  ///
  /// In ar, this message translates to:
  /// **'اسم العادة'**
  String get habitName;

  /// No description provided for @habitDescription.
  ///
  /// In ar, this message translates to:
  /// **'وصف العادة'**
  String get habitDescription;

  /// No description provided for @streak.
  ///
  /// In ar, this message translates to:
  /// **'السلسلة'**
  String get streak;

  /// No description provided for @currentStreak.
  ///
  /// In ar, this message translates to:
  /// **'السلسلة الحالية'**
  String get currentStreak;

  /// No description provided for @longestStreak.
  ///
  /// In ar, this message translates to:
  /// **'أطول سلسلة'**
  String get longestStreak;

  /// No description provided for @streakDays.
  ///
  /// In ar, this message translates to:
  /// **'{count} يوم'**
  String streakDays(int count);

  /// No description provided for @habitCompleted.
  ///
  /// In ar, this message translates to:
  /// **'تم إكمال العادة'**
  String get habitCompleted;

  /// No description provided for @habitMissed.
  ///
  /// In ar, this message translates to:
  /// **'فاتتك العادة'**
  String get habitMissed;

  /// No description provided for @noHabits.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عادات'**
  String get noHabits;

  /// No description provided for @completionRate.
  ///
  /// In ar, this message translates to:
  /// **'نسبة الإكمال'**
  String get completionRate;

  /// No description provided for @dailyGoal.
  ///
  /// In ar, this message translates to:
  /// **'الهدف اليومي'**
  String get dailyGoal;

  /// No description provided for @weeklyGoal.
  ///
  /// In ar, this message translates to:
  /// **'الهدف الأسبوعي'**
  String get weeklyGoal;

  /// No description provided for @monthlyGoal.
  ///
  /// In ar, this message translates to:
  /// **'الهدف الشهري'**
  String get monthlyGoal;

  /// No description provided for @trackingDays.
  ///
  /// In ar, this message translates to:
  /// **'أيام التتبع'**
  String get trackingDays;

  /// No description provided for @selectDays.
  ///
  /// In ar, this message translates to:
  /// **'اختر الأيام'**
  String get selectDays;

  /// No description provided for @everyday.
  ///
  /// In ar, this message translates to:
  /// **'كل يوم'**
  String get everyday;

  /// No description provided for @weekdays.
  ///
  /// In ar, this message translates to:
  /// **'أيام الأسبوع'**
  String get weekdays;

  /// No description provided for @weekends.
  ///
  /// In ar, this message translates to:
  /// **'عطلة نهاية الأسبوع'**
  String get weekends;

  /// No description provided for @frequency.
  ///
  /// In ar, this message translates to:
  /// **'التكرار'**
  String get frequency;

  /// No description provided for @timesPerDay.
  ///
  /// In ar, this message translates to:
  /// **'{count} مرة في اليوم'**
  String timesPerDay(int count);

  /// No description provided for @timesPerWeek.
  ///
  /// In ar, this message translates to:
  /// **'{count} مرة في الأسبوع'**
  String timesPerWeek(int count);

  /// No description provided for @prayer.
  ///
  /// In ar, this message translates to:
  /// **'الصلاة'**
  String get prayer;

  /// No description provided for @prayers.
  ///
  /// In ar, this message translates to:
  /// **'الصلوات'**
  String get prayers;

  /// No description provided for @prayerTimes.
  ///
  /// In ar, this message translates to:
  /// **'أوقات الصلاة'**
  String get prayerTimes;

  /// No description provided for @nextPrayer.
  ///
  /// In ar, this message translates to:
  /// **'الصلاة القادمة'**
  String get nextPrayer;

  /// No description provided for @fajr.
  ///
  /// In ar, this message translates to:
  /// **'الفجر'**
  String get fajr;

  /// No description provided for @sunrise.
  ///
  /// In ar, this message translates to:
  /// **'الشروق'**
  String get sunrise;

  /// No description provided for @dhuhr.
  ///
  /// In ar, this message translates to:
  /// **'الظهر'**
  String get dhuhr;

  /// No description provided for @asr.
  ///
  /// In ar, this message translates to:
  /// **'العصر'**
  String get asr;

  /// No description provided for @maghrib.
  ///
  /// In ar, this message translates to:
  /// **'المغرب'**
  String get maghrib;

  /// No description provided for @isha.
  ///
  /// In ar, this message translates to:
  /// **'العشاء'**
  String get isha;

  /// No description provided for @timeRemaining.
  ///
  /// In ar, this message translates to:
  /// **'الوقت المتبقي'**
  String get timeRemaining;

  /// No description provided for @timeRemainingValue.
  ///
  /// In ar, this message translates to:
  /// **'{time} متبقي'**
  String timeRemainingValue(String time);

  /// No description provided for @prayerReminder.
  ///
  /// In ar, this message translates to:
  /// **'تذكير الصلاة'**
  String get prayerReminder;

  /// No description provided for @enablePrayerReminder.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل تذكير الصلاة'**
  String get enablePrayerReminder;

  /// No description provided for @reminderBefore.
  ///
  /// In ar, this message translates to:
  /// **'التذكير قبل'**
  String get reminderBefore;

  /// No description provided for @minutesBefore.
  ///
  /// In ar, this message translates to:
  /// **'{count} دقيقة قبل'**
  String minutesBefore(int count);

  /// No description provided for @atPrayerTime.
  ///
  /// In ar, this message translates to:
  /// **'وقت الصلاة'**
  String get atPrayerTime;

  /// No description provided for @qiblaDirection.
  ///
  /// In ar, this message translates to:
  /// **'اتجاه القبلة'**
  String get qiblaDirection;

  /// No description provided for @qibla.
  ///
  /// In ar, this message translates to:
  /// **'القبلة'**
  String get qibla;

  /// No description provided for @location.
  ///
  /// In ar, this message translates to:
  /// **'الموقع'**
  String get location;

  /// No description provided for @detectLocation.
  ///
  /// In ar, this message translates to:
  /// **'تحديد الموقع'**
  String get detectLocation;

  /// No description provided for @locationDetected.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديد الموقع'**
  String get locationDetected;

  /// No description provided for @locationError.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في تحديد الموقع'**
  String get locationError;

  /// No description provided for @calculationMethod.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الحساب'**
  String get calculationMethod;

  /// No description provided for @adjustments.
  ///
  /// In ar, this message translates to:
  /// **'التعديلات'**
  String get adjustments;

  /// No description provided for @hijriDate.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ الهجري'**
  String get hijriDate;

  /// No description provided for @gregorianDate.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ الميلادي'**
  String get gregorianDate;

  /// No description provided for @prayerTracker.
  ///
  /// In ar, this message translates to:
  /// **'متتبع الصلاة'**
  String get prayerTracker;

  /// No description provided for @prayedOnTime.
  ///
  /// In ar, this message translates to:
  /// **'صليت في الوقت'**
  String get prayedOnTime;

  /// No description provided for @prayedLate.
  ///
  /// In ar, this message translates to:
  /// **'صليت متأخراً'**
  String get prayedLate;

  /// No description provided for @missed.
  ///
  /// In ar, this message translates to:
  /// **'فاتتني'**
  String get missed;

  /// No description provided for @prayerLog.
  ///
  /// In ar, this message translates to:
  /// **'سجل الصلوات'**
  String get prayerLog;

  /// No description provided for @athkar.
  ///
  /// In ar, this message translates to:
  /// **'الأذكار'**
  String get athkar;

  /// No description provided for @morningAthkar.
  ///
  /// In ar, this message translates to:
  /// **'أذكار الصباح'**
  String get morningAthkar;

  /// No description provided for @eveningAthkar.
  ///
  /// In ar, this message translates to:
  /// **'أذكار المساء'**
  String get eveningAthkar;

  /// No description provided for @sleepAthkar.
  ///
  /// In ar, this message translates to:
  /// **'أذكار النوم'**
  String get sleepAthkar;

  /// No description provided for @wakeUpAthkar.
  ///
  /// In ar, this message translates to:
  /// **'أذكار الاستيقاظ'**
  String get wakeUpAthkar;

  /// No description provided for @afterPrayerAthkar.
  ///
  /// In ar, this message translates to:
  /// **'أذكار بعد الصلاة'**
  String get afterPrayerAthkar;

  /// No description provided for @generalAthkar.
  ///
  /// In ar, this message translates to:
  /// **'أذكار متنوعة'**
  String get generalAthkar;

  /// No description provided for @tasbih.
  ///
  /// In ar, this message translates to:
  /// **'التسبيح'**
  String get tasbih;

  /// No description provided for @counter.
  ///
  /// In ar, this message translates to:
  /// **'العداد'**
  String get counter;

  /// No description provided for @resetCounter.
  ///
  /// In ar, this message translates to:
  /// **'إعادة تعيين العداد'**
  String get resetCounter;

  /// No description provided for @count.
  ///
  /// In ar, this message translates to:
  /// **'العدد'**
  String get count;

  /// No description provided for @target.
  ///
  /// In ar, this message translates to:
  /// **'الهدف'**
  String get target;

  /// No description provided for @targetReached.
  ///
  /// In ar, this message translates to:
  /// **'تم الوصول للهدف'**
  String get targetReached;

  /// No description provided for @customThikr.
  ///
  /// In ar, this message translates to:
  /// **'ذكر مخصص'**
  String get customThikr;

  /// No description provided for @addThikr.
  ///
  /// In ar, this message translates to:
  /// **'إضافة ذكر'**
  String get addThikr;

  /// No description provided for @focus.
  ///
  /// In ar, this message translates to:
  /// **'التركيز'**
  String get focus;

  /// No description provided for @focusMode.
  ///
  /// In ar, this message translates to:
  /// **'تركيز'**
  String get focusMode;

  /// No description provided for @startFocus.
  ///
  /// In ar, this message translates to:
  /// **'بدء التركيز'**
  String get startFocus;

  /// No description provided for @endFocus.
  ///
  /// In ar, this message translates to:
  /// **'إنهاء التركيز'**
  String get endFocus;

  /// No description provided for @focusSession.
  ///
  /// In ar, this message translates to:
  /// **'جلسة تركيز'**
  String get focusSession;

  /// No description provided for @focusSessions.
  ///
  /// In ar, this message translates to:
  /// **'جلسات التركيز'**
  String get focusSessions;

  /// No description provided for @pomodoro.
  ///
  /// In ar, this message translates to:
  /// **'بومودورو'**
  String get pomodoro;

  /// No description provided for @pomodoroTimer.
  ///
  /// In ar, this message translates to:
  /// **'مؤقت بومودورو'**
  String get pomodoroTimer;

  /// No description provided for @workDuration.
  ///
  /// In ar, this message translates to:
  /// **'مدة العمل'**
  String get workDuration;

  /// No description provided for @breakDuration.
  ///
  /// In ar, this message translates to:
  /// **'مدة الاستراحة'**
  String get breakDuration;

  /// No description provided for @longBreakDuration.
  ///
  /// In ar, this message translates to:
  /// **'مدة الاستراحة الطويلة'**
  String get longBreakDuration;

  /// No description provided for @sessionsBeforeLongBreak.
  ///
  /// In ar, this message translates to:
  /// **'الجلسات قبل الاستراحة الطويلة'**
  String get sessionsBeforeLongBreak;

  /// No description provided for @focusTime.
  ///
  /// In ar, this message translates to:
  /// **'وقت التركيز'**
  String get focusTime;

  /// No description provided for @breakTime.
  ///
  /// In ar, this message translates to:
  /// **'وقت الاستراحة'**
  String get breakTime;

  /// No description provided for @minutes.
  ///
  /// In ar, this message translates to:
  /// **'دقائق'**
  String get minutes;

  /// No description provided for @minutesShort.
  ///
  /// In ar, this message translates to:
  /// **'د'**
  String get minutesShort;

  /// No description provided for @hours.
  ///
  /// In ar, this message translates to:
  /// **'ساعات'**
  String get hours;

  /// No description provided for @hoursShort.
  ///
  /// In ar, this message translates to:
  /// **'س'**
  String get hoursShort;

  /// No description provided for @seconds.
  ///
  /// In ar, this message translates to:
  /// **'ثواني'**
  String get seconds;

  /// No description provided for @secondsShort.
  ///
  /// In ar, this message translates to:
  /// **'ث'**
  String get secondsShort;

  /// No description provided for @totalFocusTime.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي وقت التركيز'**
  String get totalFocusTime;

  /// No description provided for @todayFocusTime.
  ///
  /// In ar, this message translates to:
  /// **'وقت التركيز اليوم'**
  String get todayFocusTime;

  /// No description provided for @sessionCompleted.
  ///
  /// In ar, this message translates to:
  /// **'🎉 أحسنت! أنهيت الجلسة'**
  String get sessionCompleted;

  /// No description provided for @takeABreak.
  ///
  /// In ar, this message translates to:
  /// **'خذ استراحة'**
  String get takeABreak;

  /// No description provided for @breakOver.
  ///
  /// In ar, this message translates to:
  /// **'انتهت الاستراحة'**
  String get breakOver;

  /// No description provided for @skipBreak.
  ///
  /// In ar, this message translates to:
  /// **'تخطي الاستراحة'**
  String get skipBreak;

  /// No description provided for @blockApps.
  ///
  /// In ar, this message translates to:
  /// **'حظر التطبيقات'**
  String get blockApps;

  /// No description provided for @blockedApps.
  ///
  /// In ar, this message translates to:
  /// **'التطبيقات المحظورة'**
  String get blockedApps;

  /// No description provided for @doNotDisturb.
  ///
  /// In ar, this message translates to:
  /// **'عدم الإزعاج'**
  String get doNotDisturb;

  /// No description provided for @health.
  ///
  /// In ar, this message translates to:
  /// **'الصحة'**
  String get health;

  /// No description provided for @healthTracker.
  ///
  /// In ar, this message translates to:
  /// **'متتبع الصحة'**
  String get healthTracker;

  /// No description provided for @medicines.
  ///
  /// In ar, this message translates to:
  /// **'الأدوية'**
  String get medicines;

  /// No description provided for @medicine.
  ///
  /// In ar, this message translates to:
  /// **'دواء'**
  String get medicine;

  /// No description provided for @addMedicine.
  ///
  /// In ar, this message translates to:
  /// **'إضافة دواء'**
  String get addMedicine;

  /// No description provided for @medicineName.
  ///
  /// In ar, this message translates to:
  /// **'اسم الدواء'**
  String get medicineName;

  /// No description provided for @dosage.
  ///
  /// In ar, this message translates to:
  /// **'الجرعة'**
  String get dosage;

  /// No description provided for @medicineReminder.
  ///
  /// In ar, this message translates to:
  /// **'تذكير الدواء'**
  String get medicineReminder;

  /// No description provided for @takeMedicine.
  ///
  /// In ar, this message translates to:
  /// **'تناول الدواء'**
  String get takeMedicine;

  /// No description provided for @medicineTaken.
  ///
  /// In ar, this message translates to:
  /// **'تم تناول الدواء'**
  String get medicineTaken;

  /// No description provided for @appointments.
  ///
  /// In ar, this message translates to:
  /// **'المواعيد'**
  String get appointments;

  /// No description provided for @appointment.
  ///
  /// In ar, this message translates to:
  /// **'موعد'**
  String get appointment;

  /// No description provided for @addAppointment.
  ///
  /// In ar, this message translates to:
  /// **'إضافة موعد'**
  String get addAppointment;

  /// No description provided for @doctorName.
  ///
  /// In ar, this message translates to:
  /// **'اسم الطبيب'**
  String get doctorName;

  /// No description provided for @specialty.
  ///
  /// In ar, this message translates to:
  /// **'التخصص'**
  String get specialty;

  /// No description provided for @clinic.
  ///
  /// In ar, this message translates to:
  /// **'العيادة'**
  String get clinic;

  /// No description provided for @hospital.
  ///
  /// In ar, this message translates to:
  /// **'المستشفى'**
  String get hospital;

  /// No description provided for @appointmentDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الموعد'**
  String get appointmentDate;

  /// No description provided for @appointmentTime.
  ///
  /// In ar, this message translates to:
  /// **'وقت الموعد'**
  String get appointmentTime;

  /// No description provided for @vitals.
  ///
  /// In ar, this message translates to:
  /// **'العلامات الحيوية'**
  String get vitals;

  /// No description provided for @weight.
  ///
  /// In ar, this message translates to:
  /// **'الوزن'**
  String get weight;

  /// No description provided for @height.
  ///
  /// In ar, this message translates to:
  /// **'الطول'**
  String get height;

  /// No description provided for @bloodPressure.
  ///
  /// In ar, this message translates to:
  /// **'ضغط الدم'**
  String get bloodPressure;

  /// No description provided for @heartRate.
  ///
  /// In ar, this message translates to:
  /// **'معدل ضربات القلب'**
  String get heartRate;

  /// No description provided for @bloodSugar.
  ///
  /// In ar, this message translates to:
  /// **'سكر الدم'**
  String get bloodSugar;

  /// No description provided for @temperature.
  ///
  /// In ar, this message translates to:
  /// **'درجة الحرارة'**
  String get temperature;

  /// No description provided for @sleep.
  ///
  /// In ar, this message translates to:
  /// **'النوم'**
  String get sleep;

  /// No description provided for @sleepTracker.
  ///
  /// In ar, this message translates to:
  /// **'متتبع النوم'**
  String get sleepTracker;

  /// No description provided for @sleepDuration.
  ///
  /// In ar, this message translates to:
  /// **'مدة النوم'**
  String get sleepDuration;

  /// No description provided for @bedtime.
  ///
  /// In ar, this message translates to:
  /// **'وقت النوم'**
  String get bedtime;

  /// No description provided for @wakeTime.
  ///
  /// In ar, this message translates to:
  /// **'وقت الاستيقاظ'**
  String get wakeTime;

  /// No description provided for @sleepQuality.
  ///
  /// In ar, this message translates to:
  /// **'جودة النوم'**
  String get sleepQuality;

  /// No description provided for @water.
  ///
  /// In ar, this message translates to:
  /// **'الماء'**
  String get water;

  /// No description provided for @waterIntake.
  ///
  /// In ar, this message translates to:
  /// **'شرب الماء'**
  String get waterIntake;

  /// No description provided for @glasses.
  ///
  /// In ar, this message translates to:
  /// **'أكواب'**
  String get glasses;

  /// No description provided for @glassesOfWater.
  ///
  /// In ar, this message translates to:
  /// **'{count} كوب ماء'**
  String glassesOfWater(int count);

  /// No description provided for @dailyWaterGoal.
  ///
  /// In ar, this message translates to:
  /// **'هدف الماء اليومي'**
  String get dailyWaterGoal;

  /// No description provided for @steps.
  ///
  /// In ar, this message translates to:
  /// **'الخطوات'**
  String get steps;

  /// No description provided for @stepsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} خطوة'**
  String stepsCount(int count);

  /// No description provided for @dailyStepsGoal.
  ///
  /// In ar, this message translates to:
  /// **'هدف الخطوات اليومي'**
  String get dailyStepsGoal;

  /// No description provided for @calories.
  ///
  /// In ar, this message translates to:
  /// **'السعرات'**
  String get calories;

  /// No description provided for @caloriesBurned.
  ///
  /// In ar, this message translates to:
  /// **'السعرات المحروقة'**
  String get caloriesBurned;

  /// No description provided for @caloriesConsumed.
  ///
  /// In ar, this message translates to:
  /// **'السعرات المستهلكة'**
  String get caloriesConsumed;

  /// No description provided for @spaces.
  ///
  /// In ar, this message translates to:
  /// **'المساحات'**
  String get spaces;

  /// No description provided for @space.
  ///
  /// In ar, this message translates to:
  /// **'مساحة'**
  String get space;

  /// No description provided for @mySpaces.
  ///
  /// In ar, this message translates to:
  /// **'مساحاتي'**
  String get mySpaces;

  /// No description provided for @addSpace.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مساحة'**
  String get addSpace;

  /// No description provided for @newSpace.
  ///
  /// In ar, this message translates to:
  /// **'مساحة جديدة'**
  String get newSpace;

  /// No description provided for @editSpace.
  ///
  /// In ar, this message translates to:
  /// **'تعديل المساحة'**
  String get editSpace;

  /// No description provided for @deleteSpace.
  ///
  /// In ar, this message translates to:
  /// **'حذف المساحة'**
  String get deleteSpace;

  /// No description provided for @spaceName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المساحة'**
  String get spaceName;

  /// No description provided for @spaceDescription.
  ///
  /// In ar, this message translates to:
  /// **'وصف المساحة'**
  String get spaceDescription;

  /// No description provided for @spaceMembers.
  ///
  /// In ar, this message translates to:
  /// **'أعضاء المساحة'**
  String get spaceMembers;

  /// No description provided for @addMember.
  ///
  /// In ar, this message translates to:
  /// **'إضافة عضو'**
  String get addMember;

  /// No description provided for @removeMember.
  ///
  /// In ar, this message translates to:
  /// **'إزالة عضو'**
  String get removeMember;

  /// No description provided for @inviteMember.
  ///
  /// In ar, this message translates to:
  /// **'دعوة عضو'**
  String get inviteMember;

  /// No description provided for @pendingInvitations.
  ///
  /// In ar, this message translates to:
  /// **'الدعوات المعلقة'**
  String get pendingInvitations;

  /// No description provided for @acceptInvitation.
  ///
  /// In ar, this message translates to:
  /// **'قبول الدعوة'**
  String get acceptInvitation;

  /// No description provided for @declineInvitation.
  ///
  /// In ar, this message translates to:
  /// **'رفض الدعوة'**
  String get declineInvitation;

  /// No description provided for @owner.
  ///
  /// In ar, this message translates to:
  /// **'المالك'**
  String get owner;

  /// No description provided for @admin.
  ///
  /// In ar, this message translates to:
  /// **'مدير'**
  String get admin;

  /// No description provided for @member.
  ///
  /// In ar, this message translates to:
  /// **'عضو'**
  String get member;

  /// No description provided for @viewer.
  ///
  /// In ar, this message translates to:
  /// **'مشاهد'**
  String get viewer;

  /// No description provided for @permissions.
  ///
  /// In ar, this message translates to:
  /// **'الصلاحيات'**
  String get permissions;

  /// No description provided for @sharedWith.
  ///
  /// In ar, this message translates to:
  /// **'مشترك مع'**
  String get sharedWith;

  /// No description provided for @private.
  ///
  /// In ar, this message translates to:
  /// **'خاص'**
  String get private;

  /// No description provided for @public.
  ///
  /// In ar, this message translates to:
  /// **'عام'**
  String get public;

  /// No description provided for @team.
  ///
  /// In ar, this message translates to:
  /// **'فريق'**
  String get team;

  /// No description provided for @personal.
  ///
  /// In ar, this message translates to:
  /// **'شخصي'**
  String get personal;

  /// No description provided for @work.
  ///
  /// In ar, this message translates to:
  /// **'عمل'**
  String get work;

  /// No description provided for @family.
  ///
  /// In ar, this message translates to:
  /// **'عائلة'**
  String get family;

  /// No description provided for @points.
  ///
  /// In ar, this message translates to:
  /// **'النقاط'**
  String get points;

  /// No description provided for @totalPoints.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي النقاط'**
  String get totalPoints;

  /// No description provided for @pointsEarned.
  ///
  /// In ar, this message translates to:
  /// **'+{count} نقطة'**
  String pointsEarned(int count);

  /// No description provided for @level.
  ///
  /// In ar, this message translates to:
  /// **'المستوى'**
  String get level;

  /// No description provided for @currentLevel.
  ///
  /// In ar, this message translates to:
  /// **'المستوى الحالي'**
  String get currentLevel;

  /// No description provided for @nextLevel.
  ///
  /// In ar, this message translates to:
  /// **'المستوى التالي'**
  String get nextLevel;

  /// No description provided for @levelUp.
  ///
  /// In ar, this message translates to:
  /// **'ترقية المستوى!'**
  String get levelUp;

  /// No description provided for @badges.
  ///
  /// In ar, this message translates to:
  /// **'الشارات'**
  String get badges;

  /// No description provided for @badge.
  ///
  /// In ar, this message translates to:
  /// **'شارة'**
  String get badge;

  /// No description provided for @newBadge.
  ///
  /// In ar, this message translates to:
  /// **'شارة جديدة!'**
  String get newBadge;

  /// No description provided for @badgeUnlocked.
  ///
  /// In ar, this message translates to:
  /// **'تم فتح شارة جديدة'**
  String get badgeUnlocked;

  /// No description provided for @rewards.
  ///
  /// In ar, this message translates to:
  /// **'المكافآت'**
  String get rewards;

  /// No description provided for @reward.
  ///
  /// In ar, this message translates to:
  /// **'مكافأة'**
  String get reward;

  /// No description provided for @claimReward.
  ///
  /// In ar, this message translates to:
  /// **'استلام المكافأة'**
  String get claimReward;

  /// No description provided for @dailyReward.
  ///
  /// In ar, this message translates to:
  /// **'المكافأة اليومية'**
  String get dailyReward;

  /// No description provided for @streakReward.
  ///
  /// In ar, this message translates to:
  /// **'مكافأة السلسلة'**
  String get streakReward;

  /// No description provided for @leaderboard.
  ///
  /// In ar, this message translates to:
  /// **'لوحة المتصدرين'**
  String get leaderboard;

  /// No description provided for @rank.
  ///
  /// In ar, this message translates to:
  /// **'الترتيب'**
  String get rank;

  /// No description provided for @yourRank.
  ///
  /// In ar, this message translates to:
  /// **'ترتيبك'**
  String get yourRank;

  /// No description provided for @topPlayers.
  ///
  /// In ar, this message translates to:
  /// **'أفضل اللاعبين'**
  String get topPlayers;

  /// No description provided for @challenges.
  ///
  /// In ar, this message translates to:
  /// **'التحديات'**
  String get challenges;

  /// No description provided for @challenge.
  ///
  /// In ar, this message translates to:
  /// **'تحدي'**
  String get challenge;

  /// No description provided for @dailyChallenge.
  ///
  /// In ar, this message translates to:
  /// **'التحدي اليومي'**
  String get dailyChallenge;

  /// No description provided for @weeklyChallenge.
  ///
  /// In ar, this message translates to:
  /// **'التحدي الأسبوعي'**
  String get weeklyChallenge;

  /// No description provided for @acceptChallenge.
  ///
  /// In ar, this message translates to:
  /// **'قبول التحدي'**
  String get acceptChallenge;

  /// No description provided for @challengeCompleted.
  ///
  /// In ar, this message translates to:
  /// **'تم إكمال التحدي'**
  String get challengeCompleted;

  /// No description provided for @sunday.
  ///
  /// In ar, this message translates to:
  /// **'الأحد'**
  String get sunday;

  /// No description provided for @monday.
  ///
  /// In ar, this message translates to:
  /// **'الإثنين'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In ar, this message translates to:
  /// **'الثلاثاء'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In ar, this message translates to:
  /// **'الأربعاء'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In ar, this message translates to:
  /// **'الخميس'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In ar, this message translates to:
  /// **'الجمعة'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In ar, this message translates to:
  /// **'السبت'**
  String get saturday;

  /// No description provided for @sundayShort.
  ///
  /// In ar, this message translates to:
  /// **'أحد'**
  String get sundayShort;

  /// No description provided for @mondayShort.
  ///
  /// In ar, this message translates to:
  /// **'إثن'**
  String get mondayShort;

  /// No description provided for @tuesdayShort.
  ///
  /// In ar, this message translates to:
  /// **'ثلا'**
  String get tuesdayShort;

  /// No description provided for @wednesdayShort.
  ///
  /// In ar, this message translates to:
  /// **'أرب'**
  String get wednesdayShort;

  /// No description provided for @thursdayShort.
  ///
  /// In ar, this message translates to:
  /// **'خمي'**
  String get thursdayShort;

  /// No description provided for @fridayShort.
  ///
  /// In ar, this message translates to:
  /// **'جمع'**
  String get fridayShort;

  /// No description provided for @saturdayShort.
  ///
  /// In ar, this message translates to:
  /// **'سبت'**
  String get saturdayShort;

  /// No description provided for @january.
  ///
  /// In ar, this message translates to:
  /// **'يناير'**
  String get january;

  /// No description provided for @february.
  ///
  /// In ar, this message translates to:
  /// **'فبراير'**
  String get february;

  /// No description provided for @march.
  ///
  /// In ar, this message translates to:
  /// **'مارس'**
  String get march;

  /// No description provided for @april.
  ///
  /// In ar, this message translates to:
  /// **'أبريل'**
  String get april;

  /// No description provided for @may.
  ///
  /// In ar, this message translates to:
  /// **'مايو'**
  String get may;

  /// No description provided for @june.
  ///
  /// In ar, this message translates to:
  /// **'يونيو'**
  String get june;

  /// No description provided for @july.
  ///
  /// In ar, this message translates to:
  /// **'يوليو'**
  String get july;

  /// No description provided for @august.
  ///
  /// In ar, this message translates to:
  /// **'أغسطس'**
  String get august;

  /// No description provided for @september.
  ///
  /// In ar, this message translates to:
  /// **'سبتمبر'**
  String get september;

  /// No description provided for @october.
  ///
  /// In ar, this message translates to:
  /// **'أكتوبر'**
  String get october;

  /// No description provided for @november.
  ///
  /// In ar, this message translates to:
  /// **'نوفمبر'**
  String get november;

  /// No description provided for @december.
  ///
  /// In ar, this message translates to:
  /// **'ديسمبر'**
  String get december;

  /// No description provided for @now.
  ///
  /// In ar, this message translates to:
  /// **'الآن'**
  String get now;

  /// No description provided for @justNow.
  ///
  /// In ar, this message translates to:
  /// **'الآن'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In ar, this message translates to:
  /// **'منذ {count} دقيقة'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In ar, this message translates to:
  /// **'منذ {count} ساعة'**
  String hoursAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In ar, this message translates to:
  /// **'منذ {count} يوم'**
  String daysAgo(int count);

  /// No description provided for @weeksAgo.
  ///
  /// In ar, this message translates to:
  /// **'منذ {count} أسبوع'**
  String weeksAgo(int count);

  /// No description provided for @monthsAgo.
  ///
  /// In ar, this message translates to:
  /// **'منذ {count} شهر'**
  String monthsAgo(int count);

  /// No description provided for @yearsAgo.
  ///
  /// In ar, this message translates to:
  /// **'منذ {count} سنة'**
  String yearsAgo(int count);

  /// No description provided for @inMinutes.
  ///
  /// In ar, this message translates to:
  /// **'بعد {count} دقيقة'**
  String inMinutes(int count);

  /// No description provided for @inHours.
  ///
  /// In ar, this message translates to:
  /// **'بعد {count} ساعة'**
  String inHours(int count);

  /// No description provided for @inDays.
  ///
  /// In ar, this message translates to:
  /// **'بعد {count} يوم'**
  String inDays(int count);

  /// No description provided for @confirmDelete.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الحذف'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف هذا العنصر؟'**
  String get confirmDeleteMessage;

  /// No description provided for @confirmLogout.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد تسجيل الخروج'**
  String get confirmLogout;

  /// No description provided for @confirmLogoutMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من تسجيل الخروج؟'**
  String get confirmLogoutMessage;

  /// No description provided for @discardChanges.
  ///
  /// In ar, this message translates to:
  /// **'تجاهل التغييرات'**
  String get discardChanges;

  /// No description provided for @discardChangesMessage.
  ///
  /// In ar, this message translates to:
  /// **'لديك تغييرات غير محفوظة. هل تريد تجاهلها؟'**
  String get discardChangesMessage;

  /// No description provided for @unsavedChanges.
  ///
  /// In ar, this message translates to:
  /// **'تغييرات غير محفوظة'**
  String get unsavedChanges;

  /// No description provided for @saveChanges.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التعديلات'**
  String get saveChanges;

  /// No description provided for @dontSave.
  ///
  /// In ar, this message translates to:
  /// **'عدم الحفظ'**
  String get dontSave;

  /// No description provided for @keepEditing.
  ///
  /// In ar, this message translates to:
  /// **'متابعة التحرير'**
  String get keepEditing;

  /// No description provided for @noResults.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج'**
  String get noResults;

  /// No description provided for @noResultsFor.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج لـ \"{query}\"'**
  String noResultsFor(String query);

  /// No description provided for @noItemsYet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عناصر بعد'**
  String get noItemsYet;

  /// No description provided for @startByAdding.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ بإضافة عنصر جديد'**
  String get startByAdding;

  /// No description provided for @nothingHere.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد شيء هنا'**
  String get nothingHere;

  /// No description provided for @emptyList.
  ///
  /// In ar, this message translates to:
  /// **'القائمة فارغة'**
  String get emptyList;

  /// No description provided for @getStarted.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ الآن'**
  String get getStarted;

  /// No description provided for @letsStart.
  ///
  /// In ar, this message translates to:
  /// **'هيا نبدأ'**
  String get letsStart;

  /// No description provided for @welcomeToApp.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بك في أثر'**
  String get welcomeToApp;

  /// No description provided for @onboardingCategory1.
  ///
  /// In ar, this message translates to:
  /// **'المهام والعادات'**
  String get onboardingCategory1;

  /// No description provided for @onboardingTitle1.
  ///
  /// In ar, this message translates to:
  /// **'يومك بيدك'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In ar, this message translates to:
  /// **'نظّم مهامك وعاداتك في مكان واحد.\nابدأ يومك بوضوح وأنهِه بفخر.'**
  String get onboardingDesc1;

  /// No description provided for @onboardingChip11.
  ///
  /// In ar, this message translates to:
  /// **'مهام ذكية'**
  String get onboardingChip11;

  /// No description provided for @onboardingChip12.
  ///
  /// In ar, this message translates to:
  /// **'عادات يومية'**
  String get onboardingChip12;

  /// No description provided for @onboardingChip13.
  ///
  /// In ar, this message translates to:
  /// **'تتبع التقدم'**
  String get onboardingChip13;

  /// No description provided for @onboardingCategory2.
  ///
  /// In ar, this message translates to:
  /// **'الصلاة والذكر'**
  String get onboardingCategory2;

  /// No description provided for @onboardingTitle2.
  ///
  /// In ar, this message translates to:
  /// **'لا يفوتك وقت صلاة'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In ar, this message translates to:
  /// **'أوقات صلاة دقيقة حسب موقعك،\nمع اتجاه القبلة وأذكار اليوم.'**
  String get onboardingDesc2;

  /// No description provided for @onboardingChip21.
  ///
  /// In ar, this message translates to:
  /// **'أوقات الصلاة'**
  String get onboardingChip21;

  /// No description provided for @onboardingChip22.
  ///
  /// In ar, this message translates to:
  /// **'القبلة'**
  String get onboardingChip22;

  /// No description provided for @onboardingChip23.
  ///
  /// In ar, this message translates to:
  /// **'الأذكار'**
  String get onboardingChip23;

  /// No description provided for @onboardingCategory3.
  ///
  /// In ar, this message translates to:
  /// **'التركيز والإنتاجية'**
  String get onboardingCategory3;

  /// No description provided for @onboardingTitle3.
  ///
  /// In ar, this message translates to:
  /// **'أنجز ما يهمّك فعلاً'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In ar, this message translates to:
  /// **'وضع التركيز يمنع المشتّتات\nويتتبّع وقتك لإنجاز حقيقي.'**
  String get onboardingDesc3;

  /// No description provided for @onboardingChip31.
  ///
  /// In ar, this message translates to:
  /// **'بومودورو'**
  String get onboardingChip31;

  /// No description provided for @onboardingChip32.
  ///
  /// In ar, this message translates to:
  /// **'حجب المشتّتات'**
  String get onboardingChip32;

  /// No description provided for @onboardingChip33.
  ///
  /// In ar, this message translates to:
  /// **'إحصاءات'**
  String get onboardingChip33;

  /// No description provided for @onboardingCategory4.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ الآن'**
  String get onboardingCategory4;

  /// No description provided for @onboardingTitle4.
  ///
  /// In ar, this message translates to:
  /// **'حياة أكثر أثراً'**
  String get onboardingTitle4;

  /// No description provided for @onboardingDesc4.
  ///
  /// In ar, this message translates to:
  /// **'انضم إلى من يبنون عادات صحية\nوحياة منتجة ومتوازنة كل يوم.'**
  String get onboardingDesc4;

  /// No description provided for @onboardingChip41.
  ///
  /// In ar, this message translates to:
  /// **'مجاني للبدء'**
  String get onboardingChip41;

  /// No description provided for @onboardingChip42.
  ///
  /// In ar, this message translates to:
  /// **'بدون إعلانات'**
  String get onboardingChip42;

  /// No description provided for @onboardingChip43.
  ///
  /// In ar, this message translates to:
  /// **'خصوصية تامة'**
  String get onboardingChip43;

  /// No description provided for @selectedCountLabel.
  ///
  /// In ar, this message translates to:
  /// **'{count} محدد'**
  String selectedCountLabel(int count);

  /// No description provided for @completeAll.
  ///
  /// In ar, this message translates to:
  /// **'إكمال الكل'**
  String get completeAll;

  /// No description provided for @postponeAll.
  ///
  /// In ar, this message translates to:
  /// **'تأجيل الكل'**
  String get postponeAll;

  /// No description provided for @assignAll.
  ///
  /// In ar, this message translates to:
  /// **'إسناد الكل'**
  String get assignAll;

  /// No description provided for @deleteAll.
  ///
  /// In ar, this message translates to:
  /// **'حذف الكل'**
  String get deleteAll;

  /// No description provided for @confirmDeleteCount.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف {count} عنصر؟'**
  String confirmDeleteCount(int count);

  /// No description provided for @readyTemplates.
  ///
  /// In ar, this message translates to:
  /// **'القوالب الجاهزة'**
  String get readyTemplates;

  /// No description provided for @noTemplatesSaved.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد قوالب محفوظة'**
  String get noTemplatesSaved;

  /// No description provided for @templatesAvailable.
  ///
  /// In ar, this message translates to:
  /// **'{count} قالب متاح'**
  String templatesAvailable(int count);

  /// No description provided for @noTemplatesYet.
  ///
  /// In ar, this message translates to:
  /// **'لم تقم بحفظ أي قوالب بعد'**
  String get noTemplatesYet;

  /// No description provided for @saveTaskAsTemplate.
  ///
  /// In ar, this message translates to:
  /// **'احفظ هذه المهمة كقالب'**
  String get saveTaskAsTemplate;

  /// No description provided for @createNewTemplate.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء قالب جديد'**
  String get createNewTemplate;

  /// No description provided for @saveAsTemplate.
  ///
  /// In ar, this message translates to:
  /// **'حفظ كقالب'**
  String get saveAsTemplate;

  /// No description provided for @templateNameRequired.
  ///
  /// In ar, this message translates to:
  /// **'اسم القالب *'**
  String get templateNameRequired;

  /// No description provided for @templateNameHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: اجتماع أسبوعي'**
  String get templateNameHint;

  /// No description provided for @defaultTaskTitleRequired.
  ///
  /// In ar, this message translates to:
  /// **'عنوان المهمة الافتراضي *'**
  String get defaultTaskTitleRequired;

  /// No description provided for @defaultTitleHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: اجتماع الفريق'**
  String get defaultTitleHint;

  /// No description provided for @descriptionOptional.
  ///
  /// In ar, this message translates to:
  /// **'وصف (اختياري)'**
  String get descriptionOptional;

  /// No description provided for @selectIcon.
  ///
  /// In ar, this message translates to:
  /// **'اختر أيقونة:'**
  String get selectIcon;

  /// No description provided for @priorityLabel.
  ///
  /// In ar, this message translates to:
  /// **'الأولوية:'**
  String get priorityLabel;

  /// No description provided for @urgent.
  ///
  /// In ar, this message translates to:
  /// **'عاجل'**
  String get urgent;

  /// No description provided for @important.
  ///
  /// In ar, this message translates to:
  /// **'مهم'**
  String get important;

  /// No description provided for @defaultDurationMinutes.
  ///
  /// In ar, this message translates to:
  /// **'المدة الافتراضية: {minutes} دقيقة'**
  String defaultDurationMinutes(int minutes);

  /// No description provided for @durationMinutesShort.
  ///
  /// In ar, this message translates to:
  /// **'{count} د'**
  String durationMinutesShort(int count);

  /// No description provided for @fillRequiredFields.
  ///
  /// In ar, this message translates to:
  /// **'يرجى ملء الحقول المطلوبة'**
  String get fillRequiredFields;

  /// No description provided for @recurrence.
  ///
  /// In ar, this message translates to:
  /// **'التكرار'**
  String get recurrence;

  /// No description provided for @enableRecurrence.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل التكرار'**
  String get enableRecurrence;

  /// No description provided for @recurrenceTypeLabel.
  ///
  /// In ar, this message translates to:
  /// **'التكرار:'**
  String get recurrenceTypeLabel;

  /// No description provided for @recurrenceDaily.
  ///
  /// In ar, this message translates to:
  /// **'يومي'**
  String get recurrenceDaily;

  /// No description provided for @recurrenceWeekly.
  ///
  /// In ar, this message translates to:
  /// **'أسبوعي'**
  String get recurrenceWeekly;

  /// No description provided for @recurrenceMonthly.
  ///
  /// In ar, this message translates to:
  /// **'شهري'**
  String get recurrenceMonthly;

  /// No description provided for @everyInterval.
  ///
  /// In ar, this message translates to:
  /// **'كل'**
  String get everyInterval;

  /// No description provided for @recurrenceDays.
  ///
  /// In ar, this message translates to:
  /// **'الأيام:'**
  String get recurrenceDays;

  /// No description provided for @recurrenceEnds.
  ///
  /// In ar, this message translates to:
  /// **'ينتهي:'**
  String get recurrenceEnds;

  /// No description provided for @recurrenceNever.
  ///
  /// In ar, this message translates to:
  /// **'أبداً'**
  String get recurrenceNever;

  /// No description provided for @recurrenceAfter.
  ///
  /// In ar, this message translates to:
  /// **'بعد'**
  String get recurrenceAfter;

  /// No description provided for @recurrenceTimes.
  ///
  /// In ar, this message translates to:
  /// **'مرة'**
  String get recurrenceTimes;

  /// No description provided for @recurrenceOn.
  ///
  /// In ar, this message translates to:
  /// **'في'**
  String get recurrenceOn;

  /// No description provided for @intervalDay.
  ///
  /// In ar, this message translates to:
  /// **'يوم'**
  String get intervalDay;

  /// No description provided for @intervalWeek.
  ///
  /// In ar, this message translates to:
  /// **'أسبوع'**
  String get intervalWeek;

  /// No description provided for @intervalMonth.
  ///
  /// In ar, this message translates to:
  /// **'شهر'**
  String get intervalMonth;

  /// No description provided for @intervalPeriod.
  ///
  /// In ar, this message translates to:
  /// **'فترة'**
  String get intervalPeriod;

  /// No description provided for @selectDate.
  ///
  /// In ar, this message translates to:
  /// **'اختر تاريخ'**
  String get selectDate;

  /// No description provided for @everyNDays.
  ///
  /// In ar, this message translates to:
  /// **'كل {count} أيام'**
  String everyNDays(int count);

  /// No description provided for @everyNWeeks.
  ///
  /// In ar, this message translates to:
  /// **'كل {count} أسابيع'**
  String everyNWeeks(int count);

  /// No description provided for @everyNMonths.
  ///
  /// In ar, this message translates to:
  /// **'كل {count} أشهر'**
  String everyNMonths(int count);

  /// No description provided for @everyDayNames.
  ///
  /// In ar, this message translates to:
  /// **'كل {days}'**
  String everyDayNames(String days);

  /// No description provided for @nTimesParenthetical.
  ///
  /// In ar, this message translates to:
  /// **'({count} مرة)'**
  String nTimesParenthetical(int count);

  /// No description provided for @untilDateParenthetical.
  ///
  /// In ar, this message translates to:
  /// **'(حتى {date})'**
  String untilDateParenthetical(String date);

  /// No description provided for @foreverParenthetical.
  ///
  /// In ar, this message translates to:
  /// **'(إلى الأبد)'**
  String get foreverParenthetical;

  /// No description provided for @wellDone.
  ///
  /// In ar, this message translates to:
  /// **'أحسنت! 🎉'**
  String get wellDone;

  /// No description provided for @reflectionPrompt.
  ///
  /// In ar, this message translates to:
  /// **'لقد أنجزت \"{taskTitle}\". كيف كان ذلك؟'**
  String reflectionPrompt(String taskTitle);

  /// No description provided for @addNoteOptionalHint.
  ///
  /// In ar, this message translates to:
  /// **'أضف ملاحظة (اختياري)...'**
  String get addNoteOptionalHint;

  /// No description provided for @categoryLabel.
  ///
  /// In ar, this message translates to:
  /// **'التصنيف:'**
  String get categoryLabel;

  /// No description provided for @deleteCategory.
  ///
  /// In ar, this message translates to:
  /// **'حذف التصنيف'**
  String get deleteCategory;

  /// No description provided for @confirmDeleteCategory.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف تصنيف \'{name}\'؟'**
  String confirmDeleteCategory(String name);

  /// No description provided for @urgentFire.
  ///
  /// In ar, this message translates to:
  /// **'عاجل 🔥'**
  String get urgentFire;

  /// No description provided for @importantStar.
  ///
  /// In ar, this message translates to:
  /// **'مهم ⭐'**
  String get importantStar;

  /// No description provided for @conflictWarningTitle.
  ///
  /// In ar, this message translates to:
  /// **'انتبه، يوجد تداخل زمني'**
  String get conflictWarningTitle;

  /// No description provided for @delayAfterFinish.
  ///
  /// In ar, this message translates to:
  /// **'تأجيل لما بعد الانتهاء'**
  String get delayAfterFinish;

  /// No description provided for @moveTimeTo.
  ///
  /// In ar, this message translates to:
  /// **'نقل الموعد إلى {time}'**
  String moveTimeTo(String time);

  /// No description provided for @saveAnyway.
  ///
  /// In ar, this message translates to:
  /// **'حفظ على أي حال'**
  String get saveAnyway;

  /// No description provided for @keepTimeAsIs.
  ///
  /// In ar, this message translates to:
  /// **'إبقاء الوقت كما هو'**
  String get keepTimeAsIs;

  /// No description provided for @cancelAndEditManually.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء وتعديل الوقت يدوياً'**
  String get cancelAndEditManually;

  /// No description provided for @expectedDuration.
  ///
  /// In ar, this message translates to:
  /// **'المدة المتوقعة:'**
  String get expectedDuration;

  /// No description provided for @durationHours.
  ///
  /// In ar, this message translates to:
  /// **'{count} س'**
  String durationHours(int count);

  /// No description provided for @noProject.
  ///
  /// In ar, this message translates to:
  /// **'بدون مشروع'**
  String get noProject;

  /// No description provided for @selectProject.
  ///
  /// In ar, this message translates to:
  /// **'اختر مشروعاً'**
  String get selectProject;

  /// No description provided for @projectLabel.
  ///
  /// In ar, this message translates to:
  /// **'مشروع'**
  String get projectLabel;

  /// No description provided for @correspondingDate.
  ///
  /// In ar, this message translates to:
  /// **'الموافق: {date}'**
  String correspondingDate(String date);

  /// No description provided for @myBoard.
  ///
  /// In ar, this message translates to:
  /// **'سبورتي 📝'**
  String get myBoard;

  /// No description provided for @teamBoardsCount.
  ///
  /// In ar, this message translates to:
  /// **'سبورات الفريق ({count})'**
  String teamBoardsCount(int count);

  /// No description provided for @lastUpdate.
  ///
  /// In ar, this message translates to:
  /// **'آخر تحديث: {time}'**
  String lastUpdate(String time);

  /// No description provided for @boardNoteHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب ملاحظاتك، شرح المشكلة، أو التحديثات هنا...'**
  String get boardNoteHint;

  /// No description provided for @boardUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث السبورة ✅'**
  String get boardUpdated;

  /// No description provided for @teamMember.
  ///
  /// In ar, this message translates to:
  /// **'عضو فريق'**
  String get teamMember;

  /// No description provided for @noTeamNotesYet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد ملاحظات من الفريق بعد'**
  String get noTeamNotesYet;

  /// No description provided for @unifiedOpsCenter.
  ///
  /// In ar, this message translates to:
  /// **'مركز العمليات الموحد'**
  String get unifiedOpsCenter;

  /// No description provided for @allInOnePlace.
  ///
  /// In ar, this message translates to:
  /// **'كل ما يهمك في مكان واحد'**
  String get allInOnePlace;

  /// No description provided for @deletedItem.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف: {title}'**
  String deletedItem(String title);

  /// No description provided for @undo.
  ///
  /// In ar, this message translates to:
  /// **'تراجع'**
  String get undo;

  /// No description provided for @noPermissionEdit.
  ///
  /// In ar, this message translates to:
  /// **'عذراً، لا تملك صلاحية تعديل هذا العنصر'**
  String get noPermissionEdit;

  /// No description provided for @dueAndOperations.
  ///
  /// In ar, this message translates to:
  /// **'المستحق والعمليات'**
  String get dueAndOperations;

  /// No description provided for @completedToday.
  ///
  /// In ar, this message translates to:
  /// **'المكتمل اليوم'**
  String get completedToday;

  /// No description provided for @postponeSelectedTasks.
  ///
  /// In ar, this message translates to:
  /// **'تأجيل المهام المحددة'**
  String get postponeSelectedTasks;

  /// No description provided for @afterOneWeek.
  ///
  /// In ar, this message translates to:
  /// **'بعد أسبوع'**
  String get afterOneWeek;

  /// No description provided for @assignSelectedTasks.
  ///
  /// In ar, this message translates to:
  /// **'إسناد المهام المحددة'**
  String get assignSelectedTasks;

  /// No description provided for @featureUnderDevelopment.
  ///
  /// In ar, this message translates to:
  /// **'الميزة قيد التطوير'**
  String get featureUnderDevelopment;

  /// No description provided for @workZone.
  ///
  /// In ar, this message translates to:
  /// **'منطقة العمل'**
  String get workZone;

  /// No description provided for @homeZone.
  ///
  /// In ar, this message translates to:
  /// **'وقت المنزل'**
  String get homeZone;

  /// No description provided for @quietZone.
  ///
  /// In ar, this message translates to:
  /// **'وقت الهدوء'**
  String get quietZone;

  /// No description provided for @freeTime.
  ///
  /// In ar, this message translates to:
  /// **'وقتك الحر'**
  String get freeTime;

  /// No description provided for @dayClearIdeal.
  ///
  /// In ar, this message translates to:
  /// **'يومك صافي ومثالي!'**
  String get dayClearIdeal;

  /// No description provided for @noTasksPending.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد مهام أو عمليات معلقة حالياً'**
  String get noTasksPending;

  /// No description provided for @yourAtharToday.
  ///
  /// In ar, this message translates to:
  /// **'أثرك اليوم'**
  String get yourAtharToday;

  /// No description provided for @focusOnWhatMatters.
  ///
  /// In ar, this message translates to:
  /// **'ركز على ما يهم'**
  String get focusOnWhatMatters;

  /// No description provided for @itemDeleted.
  ///
  /// In ar, this message translates to:
  /// **'تم الحذف'**
  String get itemDeleted;

  /// No description provided for @noPermissionDelete.
  ///
  /// In ar, this message translates to:
  /// **'عذراً، لا تملك صلاحية حذف هذه المهمة'**
  String get noPermissionDelete;

  /// No description provided for @listView.
  ///
  /// In ar, this message translates to:
  /// **'عرض القائمة'**
  String get listView;

  /// No description provided for @boardView.
  ///
  /// In ar, this message translates to:
  /// **'عرض اللوحة'**
  String get boardView;

  /// No description provided for @dayClear.
  ///
  /// In ar, this message translates to:
  /// **'يومك صافي!'**
  String get dayClear;

  /// No description provided for @addTasksToStart.
  ///
  /// In ar, this message translates to:
  /// **'أضف مهامك لتبدأ الأثر'**
  String get addTasksToStart;

  /// No description provided for @details.
  ///
  /// In ar, this message translates to:
  /// **'التفاصيل'**
  String get details;

  /// No description provided for @boardsAndTeam.
  ///
  /// In ar, this message translates to:
  /// **'السبورات & الفريق'**
  String get boardsAndTeam;

  /// No description provided for @taskTitleHint.
  ///
  /// In ar, this message translates to:
  /// **'عنوان المهمة'**
  String get taskTitleHint;

  /// No description provided for @statusWaiting.
  ///
  /// In ar, this message translates to:
  /// **'قائمة الانتظار'**
  String get statusWaiting;

  /// No description provided for @statusInProgress.
  ///
  /// In ar, this message translates to:
  /// **'جاري التنفيذ'**
  String get statusInProgress;

  /// No description provided for @statusCompleted.
  ///
  /// In ar, this message translates to:
  /// **'مكتملة'**
  String get statusCompleted;

  /// No description provided for @descriptionAndNotes.
  ///
  /// In ar, this message translates to:
  /// **'الوصف والملاحظات'**
  String get descriptionAndNotes;

  /// No description provided for @addDetailsHint.
  ///
  /// In ar, this message translates to:
  /// **'أضف تفاصيل، روابط، أو ملاحظات فرعية...'**
  String get addDetailsHint;

  /// No description provided for @generalCategory.
  ///
  /// In ar, this message translates to:
  /// **'عام'**
  String get generalCategory;

  /// No description provided for @classification.
  ///
  /// In ar, this message translates to:
  /// **'التصنيف'**
  String get classification;

  /// No description provided for @willRemindBeforeDue.
  ///
  /// In ar, this message translates to:
  /// **'سيتم تنبيهك قبل الموعد'**
  String get willRemindBeforeDue;

  /// No description provided for @noReminder.
  ///
  /// In ar, this message translates to:
  /// **'لن يتم تنبيهك'**
  String get noReminder;

  /// No description provided for @selectReminderTime.
  ///
  /// In ar, this message translates to:
  /// **'اختر وقت التذكير'**
  String get selectReminderTime;

  /// No description provided for @quickSuggestions.
  ///
  /// In ar, this message translates to:
  /// **'اقتراحات سريعة:'**
  String get quickSuggestions;

  /// No description provided for @tenMinutes.
  ///
  /// In ar, this message translates to:
  /// **'10 دقائق'**
  String get tenMinutes;

  /// No description provided for @thirtyMinutes.
  ///
  /// In ar, this message translates to:
  /// **'30 دقيقة'**
  String get thirtyMinutes;

  /// No description provided for @oneHour.
  ///
  /// In ar, this message translates to:
  /// **'ساعة'**
  String get oneHour;

  /// No description provided for @oneDay.
  ///
  /// In ar, this message translates to:
  /// **'يوم'**
  String get oneDay;

  /// No description provided for @beforeDuration.
  ///
  /// In ar, this message translates to:
  /// **'قبل {label}'**
  String beforeDuration(String label);

  /// No description provided for @cannotPickPastTime.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن اختيار وقت في الماضي'**
  String get cannotPickPastTime;

  /// No description provided for @reminderMustBeBeforeTask.
  ///
  /// In ar, this message translates to:
  /// **'يجب أن يكون التذكير قبل موعد المهمة'**
  String get reminderMustBeBeforeTask;

  /// No description provided for @whatToAccomplish.
  ///
  /// In ar, this message translates to:
  /// **'ماذا تريد أن تنجز؟'**
  String get whatToAccomplish;

  /// No description provided for @assignToMemberOptional.
  ///
  /// In ar, this message translates to:
  /// **'إسناد إلى عضو (اختياري)'**
  String get assignToMemberOptional;

  /// No description provided for @memberSelected.
  ///
  /// In ar, this message translates to:
  /// **'تم اختيار عضو'**
  String get memberSelected;

  /// No description provided for @newCategory.
  ///
  /// In ar, this message translates to:
  /// **'تصنيف جديد'**
  String get newCategory;

  /// No description provided for @categoryName.
  ///
  /// In ar, this message translates to:
  /// **'اسم التصنيف'**
  String get categoryName;

  /// No description provided for @appointmentTitle.
  ///
  /// In ar, this message translates to:
  /// **'عنوان الموعد'**
  String get appointmentTitle;

  /// No description provided for @required.
  ///
  /// In ar, this message translates to:
  /// **'مطلوب'**
  String get required;

  /// No description provided for @pills.
  ///
  /// In ar, this message translates to:
  /// **'حبوب'**
  String get pills;

  /// No description provided for @syrup.
  ///
  /// In ar, this message translates to:
  /// **'شراب'**
  String get syrup;

  /// No description provided for @injection.
  ///
  /// In ar, this message translates to:
  /// **'إبرة'**
  String get injection;

  /// No description provided for @drops.
  ///
  /// In ar, this message translates to:
  /// **'قطرة'**
  String get drops;

  /// No description provided for @ointment.
  ///
  /// In ar, this message translates to:
  /// **'مرهم'**
  String get ointment;

  /// No description provided for @spray.
  ///
  /// In ar, this message translates to:
  /// **'بخاخ'**
  String get spray;

  /// No description provided for @fixedTimes.
  ///
  /// In ar, this message translates to:
  /// **'أوقات ثابتة'**
  String get fixedTimes;

  /// No description provided for @repeatByHours.
  ///
  /// In ar, this message translates to:
  /// **'تكرار بالساعات'**
  String get repeatByHours;

  /// No description provided for @schedulePattern.
  ///
  /// In ar, this message translates to:
  /// **'نمط الجدولة'**
  String get schedulePattern;

  /// No description provided for @unit.
  ///
  /// In ar, this message translates to:
  /// **'الوحدة'**
  String get unit;

  /// No description provided for @selectIntakeTimes.
  ///
  /// In ar, this message translates to:
  /// **'حدد أوقات التناول:'**
  String get selectIntakeTimes;

  /// No description provided for @every.
  ///
  /// In ar, this message translates to:
  /// **'كل'**
  String get every;

  /// No description provided for @hoursCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} ساعات'**
  String hoursCount(int count);

  /// No description provided for @currentStock.
  ///
  /// In ar, this message translates to:
  /// **'المخزون الحالي'**
  String get currentStock;

  /// No description provided for @byDays.
  ///
  /// In ar, this message translates to:
  /// **'بالأيام'**
  String get byDays;

  /// No description provided for @byDate.
  ///
  /// In ar, this message translates to:
  /// **'بالتاريخ'**
  String get byDate;

  /// No description provided for @treatmentDuration.
  ///
  /// In ar, this message translates to:
  /// **'مدة العلاج'**
  String get treatmentDuration;

  /// No description provided for @daysCount.
  ///
  /// In ar, this message translates to:
  /// **'عدد الأيام'**
  String get daysCount;

  /// No description provided for @selectEndDate.
  ///
  /// In ar, this message translates to:
  /// **'حدد تاريخ النهاية'**
  String get selectEndDate;

  /// No description provided for @checkup.
  ///
  /// In ar, this message translates to:
  /// **'كشف'**
  String get checkup;

  /// No description provided for @labTest.
  ///
  /// In ar, this message translates to:
  /// **'تحليل'**
  String get labTest;

  /// No description provided for @vaccine.
  ///
  /// In ar, this message translates to:
  /// **'تطعيم'**
  String get vaccine;

  /// No description provided for @procedure.
  ///
  /// In ar, this message translates to:
  /// **'إجراء'**
  String get procedure;

  /// No description provided for @doctor.
  ///
  /// In ar, this message translates to:
  /// **'الطبيب'**
  String get doctor;

  /// No description provided for @locationClinic.
  ///
  /// In ar, this message translates to:
  /// **'المكان/العيادة'**
  String get locationClinic;

  /// No description provided for @appointmentNotes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات الموعد'**
  String get appointmentNotes;

  /// No description provided for @usageInstructions.
  ///
  /// In ar, this message translates to:
  /// **'تعليمات الاستخدام'**
  String get usageInstructions;

  /// No description provided for @beforeMeal.
  ///
  /// In ar, this message translates to:
  /// **'قبل الأكل'**
  String get beforeMeal;

  /// No description provided for @afterMeal.
  ///
  /// In ar, this message translates to:
  /// **'بعد الأكل'**
  String get afterMeal;

  /// No description provided for @withMeal.
  ///
  /// In ar, this message translates to:
  /// **'مع الأكل'**
  String get withMeal;

  /// No description provided for @anytime.
  ///
  /// In ar, this message translates to:
  /// **'في أي وقت'**
  String get anytime;

  /// No description provided for @smartRefill.
  ///
  /// In ar, this message translates to:
  /// **'إعادة التعبئة الذكية'**
  String get smartRefill;

  /// No description provided for @off.
  ///
  /// In ar, this message translates to:
  /// **'إيقاف'**
  String get off;

  /// No description provided for @byQuantity.
  ///
  /// In ar, this message translates to:
  /// **'حسب الكمية'**
  String get byQuantity;

  /// No description provided for @beforeCourseEnd.
  ///
  /// In ar, this message translates to:
  /// **'قبل انتهاء الكورس'**
  String get beforeCourseEnd;

  /// No description provided for @autoOrderMode.
  ///
  /// In ar, this message translates to:
  /// **'وضع الطلب التلقائي'**
  String get autoOrderMode;

  /// No description provided for @alertOnLowStock.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه عند نقص الكمية لـ'**
  String get alertOnLowStock;

  /// No description provided for @alertBeforeCourseEndDays.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه قبل انتهاء الكورس بـ (أيام)'**
  String get alertBeforeCourseEndDays;

  /// No description provided for @addToList.
  ///
  /// In ar, this message translates to:
  /// **'إضافة للقائمة'**
  String get addToList;

  /// No description provided for @createTask.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء مهمة'**
  String get createTask;

  /// No description provided for @bothTaskAndList.
  ///
  /// In ar, this message translates to:
  /// **'كلاهما (مهمة + قائمة)'**
  String get bothTaskAndList;

  /// No description provided for @action.
  ///
  /// In ar, this message translates to:
  /// **'الإجراء'**
  String get action;

  /// No description provided for @assignToMember.
  ///
  /// In ar, this message translates to:
  /// **'إسناد لعضو'**
  String get assignToMember;

  /// No description provided for @assigned.
  ///
  /// In ar, this message translates to:
  /// **'تم الإسناد'**
  String get assigned;

  /// No description provided for @saveItem.
  ///
  /// In ar, this message translates to:
  /// **'حفظ العنصر'**
  String get saveItem;

  /// No description provided for @deleteAccountConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد؟ سيتم حذف حسابك السحابي نهائياً.\nماذا تريد أن تفعل بالبيانات المحفوظة في جهازك؟'**
  String get deleteAccountConfirmMessage;

  /// No description provided for @deleteEverything.
  ///
  /// In ar, this message translates to:
  /// **'حذف كل شيء (فرمته)'**
  String get deleteEverything;

  /// No description provided for @deleteEverythingDesc.
  ///
  /// In ar, this message translates to:
  /// **'حذف السحابة + حذف بيانات الجهاز والبدء من الصفر.'**
  String get deleteEverythingDesc;

  /// No description provided for @keepLocalData.
  ///
  /// In ar, this message translates to:
  /// **'الاحتفاظ ببيانات الجهاز'**
  String get keepLocalData;

  /// No description provided for @keepLocalDataDesc.
  ///
  /// In ar, this message translates to:
  /// **'حذف السحابة فقط وتحويل الحساب لاستخدام محلي.'**
  String get keepLocalDataDesc;

  /// No description provided for @prayerTimesLocation.
  ///
  /// In ar, this message translates to:
  /// **'موقع المواقيت'**
  String get prayerTimesLocation;

  /// No description provided for @detectingLocation.
  ///
  /// In ar, this message translates to:
  /// **'جاري تحديد الموقع...'**
  String get detectingLocation;

  /// No description provided for @myCurrentLocation.
  ///
  /// In ar, this message translates to:
  /// **'موقعي الحالي'**
  String get myCurrentLocation;

  /// No description provided for @locationDetectionFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل تحديد الموقع: {error}'**
  String locationDetectionFailed(String error);

  /// No description provided for @searching.
  ///
  /// In ar, this message translates to:
  /// **'جاري البحث...'**
  String get searching;

  /// No description provided for @cityNotFound.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على المدينة'**
  String get cityNotFound;

  /// No description provided for @searchError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء البحث'**
  String get searchError;

  /// No description provided for @locationUpdatedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث الموقع بنجاح: {city} ✅'**
  String locationUpdatedSuccess(String city);

  /// No description provided for @useCurrentLocationGPS.
  ///
  /// In ar, this message translates to:
  /// **'استخدام الموقع الحالي (GPS)'**
  String get useCurrentLocationGPS;

  /// No description provided for @or.
  ///
  /// In ar, this message translates to:
  /// **'أو'**
  String get or;

  /// No description provided for @cityNameHint.
  ///
  /// In ar, this message translates to:
  /// **'اسم المدينة (مثلاً: الرياض، القاهرة)'**
  String get cityNameHint;

  /// No description provided for @smartZones.
  ///
  /// In ar, this message translates to:
  /// **'المناطق الذكية'**
  String get smartZones;

  /// No description provided for @familyTimeHome.
  ///
  /// In ar, this message translates to:
  /// **'وقت الأهل (المنزل)'**
  String get familyTimeHome;

  /// No description provided for @freeTimeZone.
  ///
  /// In ar, this message translates to:
  /// **'وقت حر'**
  String get freeTimeZone;

  /// No description provided for @quietZoneSettings.
  ///
  /// In ar, this message translates to:
  /// **'منطقة الهدوء'**
  String get quietZoneSettings;

  /// No description provided for @sleepZone.
  ///
  /// In ar, this message translates to:
  /// **'منطقة النوم'**
  String get sleepZone;

  /// No description provided for @smartModeDisabled.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الذكي معطل'**
  String get smartModeDisabled;

  /// No description provided for @enableSmartModeDesc.
  ///
  /// In ar, this message translates to:
  /// **'فعله ليقوم أثر بتنظيم وقتك تلقائياً'**
  String get enableSmartModeDesc;

  /// No description provided for @enableAutoMode.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل الوضع التلقائي'**
  String get enableAutoMode;

  /// No description provided for @changeContextByTime.
  ///
  /// In ar, this message translates to:
  /// **'تغيير السياق بناءً على الوقت'**
  String get changeContextByTime;

  /// No description provided for @periodStartTime.
  ///
  /// In ar, this message translates to:
  /// **'وقت بداية الفترة'**
  String get periodStartTime;

  /// No description provided for @periodEndTime.
  ///
  /// In ar, this message translates to:
  /// **'وقت نهاية الفترة'**
  String get periodEndTime;

  /// No description provided for @addPeriod.
  ///
  /// In ar, this message translates to:
  /// **'إضافة فترة'**
  String get addPeriod;

  /// No description provided for @workDays.
  ///
  /// In ar, this message translates to:
  /// **'أيام العمل:'**
  String get workDays;

  /// No description provided for @noTimesSetYet.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم تحديد أوقات بعد'**
  String get noTimesSetYet;

  /// No description provided for @noCategory.
  ///
  /// In ar, this message translates to:
  /// **'بدون تصنيف'**
  String get noCategory;

  /// No description provided for @customizeCategory.
  ///
  /// In ar, this message translates to:
  /// **'تخصيص التصنيف'**
  String get customizeCategory;

  /// No description provided for @biometricLogin.
  ///
  /// In ar, this message translates to:
  /// **'الدخول بالبصمة'**
  String get biometricLogin;

  /// No description provided for @biometricLoginDesc.
  ///
  /// In ar, this message translates to:
  /// **'حماية التطبيق ببصمة الوجه أو الأصبع'**
  String get biometricLoginDesc;

  /// No description provided for @biometricVerificationFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل التحقق من البصمة'**
  String get biometricVerificationFailed;

  /// No description provided for @loginOrCreateAccount.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول / إنشاء حساب'**
  String get loginOrCreateAccount;

  /// No description provided for @forSyncAndFamilySharing.
  ///
  /// In ar, this message translates to:
  /// **'للمزامنة والمشاركة العائلية'**
  String get forSyncAndFamilySharing;

  /// No description provided for @syncAndData.
  ///
  /// In ar, this message translates to:
  /// **'المزامنة والبيانات'**
  String get syncAndData;

  /// No description provided for @autoSync.
  ///
  /// In ar, this message translates to:
  /// **'المزامنة التلقائية'**
  String get autoSync;

  /// No description provided for @autoSyncDesc.
  ///
  /// In ar, this message translates to:
  /// **'حفظ بياناتك في السحابة تلقائياً'**
  String get autoSyncDesc;

  /// No description provided for @loginRequired.
  ///
  /// In ar, this message translates to:
  /// **'مطلوب تسجيل الدخول'**
  String get loginRequired;

  /// No description provided for @syncRequiresAccount.
  ///
  /// In ar, this message translates to:
  /// **'المزامنة السحابية تتطلب حساباً.\nهل تود تسجيل الدخول الآن؟'**
  String get syncRequiresAccount;

  /// No description provided for @smartFeatures.
  ///
  /// In ar, this message translates to:
  /// **'الذكاء والميزات'**
  String get smartFeatures;

  /// No description provided for @smartZonesDesc.
  ///
  /// In ar, this message translates to:
  /// **'تخصيص أوقات العمل والمنزل'**
  String get smartZonesDesc;

  /// No description provided for @prayerSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الصلاة'**
  String get prayerSettings;

  /// No description provided for @enablePrayerTimes.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل مواقيت الصلاة'**
  String get enablePrayerTimes;

  /// No description provided for @enablePrayerTimesDesc.
  ///
  /// In ar, this message translates to:
  /// **'البطاقات، التنبيهات، والتعارضات'**
  String get enablePrayerTimesDesc;

  /// No description provided for @notSet.
  ///
  /// In ar, this message translates to:
  /// **'غير محدد'**
  String get notSet;

  /// No description provided for @prayerCardLocations.
  ///
  /// In ar, this message translates to:
  /// **'أماكن ظهور بطاقة الصلاة:'**
  String get prayerCardLocations;

  /// No description provided for @dashboardOnly.
  ///
  /// In ar, this message translates to:
  /// **'الداشبورد فقط'**
  String get dashboardOnly;

  /// No description provided for @dashboardAndTasks.
  ///
  /// In ar, this message translates to:
  /// **'الداشبورد وصفحة المهام'**
  String get dashboardAndTasks;

  /// No description provided for @allPages.
  ///
  /// In ar, this message translates to:
  /// **'جميع الصفحات'**
  String get allPages;

  /// No description provided for @preferences.
  ///
  /// In ar, this message translates to:
  /// **'التفضيلات'**
  String get preferences;

  /// No description provided for @hijriCalendar.
  ///
  /// In ar, this message translates to:
  /// **'التقويم الهجري'**
  String get hijriCalendar;

  /// No description provided for @hijriCalendarDesc.
  ///
  /// In ar, this message translates to:
  /// **'استخدام التاريخ الهجري كافتراضي'**
  String get hijriCalendarDesc;

  /// No description provided for @morningEveningAthkar.
  ///
  /// In ar, this message translates to:
  /// **'أذكار الصباح والمساء'**
  String get morningEveningAthkar;

  /// No description provided for @morningEveningAthkarDesc.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل نظام الأذكار اليومي'**
  String get morningEveningAthkarDesc;

  /// No description provided for @displayMode.
  ///
  /// In ar, this message translates to:
  /// **'طريقة العرض:'**
  String get displayMode;

  /// No description provided for @cards.
  ///
  /// In ar, this message translates to:
  /// **'بطاقات'**
  String get cards;

  /// No description provided for @compact.
  ///
  /// In ar, this message translates to:
  /// **'مدمجة'**
  String get compact;

  /// No description provided for @sessionDisplayMode.
  ///
  /// In ar, this message translates to:
  /// **'طريقة عرض الجلسة:'**
  String get sessionDisplayMode;

  /// No description provided for @listMode.
  ///
  /// In ar, this message translates to:
  /// **'قائمة'**
  String get listMode;

  /// No description provided for @aboutApp.
  ///
  /// In ar, this message translates to:
  /// **'عن التطبيق'**
  String get aboutApp;

  /// No description provided for @aboutAthar.
  ///
  /// In ar, this message translates to:
  /// **'عن أثر'**
  String get aboutAthar;

  /// No description provided for @whatToAdd.
  ///
  /// In ar, this message translates to:
  /// **'ماذا تريد أن تضيف؟'**
  String get whatToAdd;

  /// No description provided for @project.
  ///
  /// In ar, this message translates to:
  /// **'مشروع'**
  String get project;

  /// No description provided for @myHabitsToday.
  ///
  /// In ar, this message translates to:
  /// **'عاداتي اليوم'**
  String get myHabitsToday;

  /// No description provided for @greatJobCompletedCurrentTasks.
  ///
  /// In ar, this message translates to:
  /// **'أنت رائع! أكملت مهام الوقت الحالي.'**
  String get greatJobCompletedCurrentTasks;

  /// No description provided for @athar.
  ///
  /// In ar, this message translates to:
  /// **'أثر'**
  String get athar;

  /// No description provided for @leaveYourMark.
  ///
  /// In ar, this message translates to:
  /// **'اترك أثراً في يومك'**
  String get leaveYourMark;

  /// No description provided for @biometricLoginFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل الدخول البيومتري، يرجى تسجيل الدخول'**
  String get biometricLoginFailed;

  /// No description provided for @greetingName.
  ///
  /// In ar, this message translates to:
  /// **'، {name}'**
  String greetingName(Object name);

  /// No description provided for @goodMorning.
  ///
  /// In ar, this message translates to:
  /// **'صباح الخير{name} ☀️'**
  String goodMorning(Object name);

  /// No description provided for @goodAfternoon.
  ///
  /// In ar, this message translates to:
  /// **'طاب يومك{name} ✨'**
  String goodAfternoon(Object name);

  /// No description provided for @goodEvening.
  ///
  /// In ar, this message translates to:
  /// **'مساء النور{name} 🌙'**
  String goodEvening(Object name);

  /// No description provided for @goodNight.
  ///
  /// In ar, this message translates to:
  /// **'ليلة هادئة{name} ⭐️'**
  String goodNight(Object name);

  /// No description provided for @syncSuccessful.
  ///
  /// In ar, this message translates to:
  /// **'تمت المزامنة بنجاح'**
  String get syncSuccessful;

  /// No description provided for @sync.
  ///
  /// In ar, this message translates to:
  /// **'مزامنة'**
  String get sync;

  /// No description provided for @goodMorningChamp.
  ///
  /// In ar, this message translates to:
  /// **'صباح الخير، يا بطل ☀️'**
  String get goodMorningChamp;

  /// No description provided for @haveANiceDay.
  ///
  /// In ar, this message translates to:
  /// **'طاب يومك 🌤️'**
  String get haveANiceDay;

  /// No description provided for @goodEveningSimple.
  ///
  /// In ar, this message translates to:
  /// **'مساء الخير 🌙'**
  String get goodEveningSimple;

  /// No description provided for @settingsComingSoon.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات قادمة قريباً...'**
  String get settingsComingSoon;

  /// No description provided for @drawerWelcomeGreeting.
  ///
  /// In ar, this message translates to:
  /// **'أهلاً بك 👋'**
  String get drawerWelcomeGreeting;

  /// No description provided for @drawerMotivationalSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'لنجعل يومك مثمراً'**
  String get drawerMotivationalSubtitle;

  /// No description provided for @drawerSmartZones.
  ///
  /// In ar, this message translates to:
  /// **'المناطق الذكية'**
  String get drawerSmartZones;

  /// No description provided for @drawerSmartZonesSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اضبط أوقات العمل والراحة'**
  String get drawerSmartZonesSubtitle;

  /// No description provided for @drawerHabitTracker.
  ///
  /// In ar, this message translates to:
  /// **'متتبع العادات'**
  String get drawerHabitTracker;

  /// No description provided for @drawerHabitTrackerSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'ابنِ عاداتك واستمر عليها'**
  String get drawerHabitTrackerSubtitle;

  /// No description provided for @drawerFocusTimer.
  ///
  /// In ar, this message translates to:
  /// **'مؤقت التركيز'**
  String get drawerFocusTimer;

  /// No description provided for @drawerFocusTimerSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تقنية بومودورو (25 دقيقة)'**
  String get drawerFocusTimerSubtitle;

  /// No description provided for @drawerStatistics.
  ///
  /// In ar, this message translates to:
  /// **'الإحصائيات'**
  String get drawerStatistics;

  /// No description provided for @drawerStatisticsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'راقب إنجازك الأسبوعي'**
  String get drawerStatisticsSubtitle;

  /// No description provided for @drawerGeneralSettings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات العامة'**
  String get drawerGeneralSettings;

  /// No description provided for @drawerVersionLabel.
  ///
  /// In ar, this message translates to:
  /// **'الإصدار {version}'**
  String drawerVersionLabel(Object version);

  /// No description provided for @timelineDoseTakenSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل الجرعة ✅'**
  String get timelineDoseTakenSuccess;

  /// No description provided for @timelineTaskCompletedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إنجاز المهمة 💪'**
  String get timelineTaskCompletedSuccess;

  /// No description provided for @timelineEmptyMessage.
  ///
  /// In ar, this message translates to:
  /// **'يومك صافٍ! لا توجد مهام أو أدوية حالياً 🌿'**
  String get timelineEmptyMessage;

  /// No description provided for @habitsHeaderQuote.
  ///
  /// In ar, this message translates to:
  /// **'وَأَن لَّيْسَ لِلْإِنسَانِ إِلَّا مَا سَعَىٰ'**
  String get habitsHeaderQuote;

  /// No description provided for @habitsViewCompact.
  ///
  /// In ar, this message translates to:
  /// **'مختصر'**
  String get habitsViewCompact;

  /// No description provided for @habitsViewDetailed.
  ///
  /// In ar, this message translates to:
  /// **'مفصل (أثر)'**
  String get habitsViewDetailed;

  /// No description provided for @habitsSectionFajr.
  ///
  /// In ar, this message translates to:
  /// **'الفجر'**
  String get habitsSectionFajr;

  /// No description provided for @habitsSectionBakur.
  ///
  /// In ar, this message translates to:
  /// **'البكور'**
  String get habitsSectionBakur;

  /// No description provided for @habitsSectionMorning.
  ///
  /// In ar, this message translates to:
  /// **'الضحى والصباح'**
  String get habitsSectionMorning;

  /// No description provided for @habitsSectionNoon.
  ///
  /// In ar, this message translates to:
  /// **'الظهيرة'**
  String get habitsSectionNoon;

  /// No description provided for @habitsSectionAsr.
  ///
  /// In ar, this message translates to:
  /// **'العصر'**
  String get habitsSectionAsr;

  /// No description provided for @habitsSectionMaghrib.
  ///
  /// In ar, this message translates to:
  /// **'المغرب'**
  String get habitsSectionMaghrib;

  /// No description provided for @habitsSectionIsha.
  ///
  /// In ar, this message translates to:
  /// **'العشاء'**
  String get habitsSectionIsha;

  /// No description provided for @habitsSectionNightPrayer.
  ///
  /// In ar, this message translates to:
  /// **'قيام الليل'**
  String get habitsSectionNightPrayer;

  /// No description provided for @habitsSectionLastThird.
  ///
  /// In ar, this message translates to:
  /// **'الثلث الأخير'**
  String get habitsSectionLastThird;

  /// No description provided for @habitsSectionAnytime.
  ///
  /// In ar, this message translates to:
  /// **'في أي وقت'**
  String get habitsSectionAnytime;

  /// No description provided for @habitsSectionDayStart.
  ///
  /// In ar, this message translates to:
  /// **'بداية اليوم'**
  String get habitsSectionDayStart;

  /// No description provided for @habitsSectionProductivity.
  ///
  /// In ar, this message translates to:
  /// **'وقت الإنتاجية'**
  String get habitsSectionProductivity;

  /// No description provided for @habitsSectionDayEnd.
  ///
  /// In ar, this message translates to:
  /// **'ختام اليوم'**
  String get habitsSectionDayEnd;

  /// No description provided for @habitsSectionFlexible.
  ///
  /// In ar, this message translates to:
  /// **'عادات مرنة'**
  String get habitsSectionFlexible;

  /// No description provided for @habitsWellDone.
  ///
  /// In ar, this message translates to:
  /// **'أحسنت! 👏'**
  String get habitsWellDone;

  /// No description provided for @habitsCompletedHabit.
  ///
  /// In ar, this message translates to:
  /// **'أتممت {title}'**
  String habitsCompletedHabit(Object title);

  /// No description provided for @habitsProgressLabel.
  ///
  /// In ar, this message translates to:
  /// **'{current} / {target} منجز'**
  String habitsProgressLabel(Object current, Object target);

  /// No description provided for @habitsStartButton.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ'**
  String get habitsStartButton;

  /// Empty state title
  ///
  /// In ar, this message translates to:
  /// **'ابدأ رحلة العادات'**
  String get habitsEmptyTitle;

  /// No description provided for @habitsEmptySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أضف عادة جديدة من الزر أدناه'**
  String get habitsEmptySubtitle;

  /// No description provided for @habitsCannotCompleteFuture.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن إنجاز عادات المستقبل!'**
  String get habitsCannotCompleteFuture;

  /// No description provided for @habitsEditComingSoon.
  ///
  /// In ar, this message translates to:
  /// **'تعديل العادة (قريباً)'**
  String get habitsEditComingSoon;

  /// No description provided for @habitsDeleteTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف العادة؟'**
  String get habitsDeleteTitle;

  /// No description provided for @habitsDeleteConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف \'{title}\'؟'**
  String habitsDeleteConfirm(Object title);

  /// No description provided for @habitsDeleteCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get habitsDeleteCancel;

  /// No description provided for @habitsDeleteAction.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get habitsDeleteAction;

  /// No description provided for @athkarResetTooltip.
  ///
  /// In ar, this message translates to:
  /// **'تحديث الأذكار'**
  String get athkarResetTooltip;

  /// No description provided for @athkarProgressPercent.
  ///
  /// In ar, this message translates to:
  /// **'{percent}% مكتمل'**
  String athkarProgressPercent(Object percent);

  /// No description provided for @athkarResetDialogTitle.
  ///
  /// In ar, this message translates to:
  /// **'تحديث قائمة الأذكار؟'**
  String get athkarResetDialogTitle;

  /// No description provided for @athkarResetDialogContent.
  ///
  /// In ar, this message translates to:
  /// **'سيقوم هذا بتحديث نصوص الأذكار إلى النسخة الأصح والأحدث، ولكنه سيعيد تعيين تقدمك في هذا الورد إلى الصفر.\n\nهل أنت متأكد؟'**
  String get athkarResetDialogContent;

  /// No description provided for @athkarResetCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get athkarResetCancel;

  /// No description provided for @athkarResetConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تحديث'**
  String get athkarResetConfirm;

  /// No description provided for @athkarWellDone.
  ///
  /// In ar, this message translates to:
  /// **'أحسنت!'**
  String get athkarWellDone;

  /// No description provided for @athkarTapToCount.
  ///
  /// In ar, this message translates to:
  /// **'اضغط للعد'**
  String get athkarTapToCount;

  /// No description provided for @habitFormEditTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل العادة'**
  String get habitFormEditTitle;

  /// No description provided for @habitFormAddTitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة عادة جديدة 💪'**
  String get habitFormAddTitle;

  /// No description provided for @habitFormNameHint.
  ///
  /// In ar, this message translates to:
  /// **'ما هي عادتك القادمة؟'**
  String get habitFormNameHint;

  /// No description provided for @habitFormFrequency.
  ///
  /// In ar, this message translates to:
  /// **'التكرار'**
  String get habitFormFrequency;

  /// No description provided for @habitFormPreferredPeriod.
  ///
  /// In ar, this message translates to:
  /// **'الفترة المفضلة'**
  String get habitFormPreferredPeriod;

  /// No description provided for @habitFormTargetLabel.
  ///
  /// In ar, this message translates to:
  /// **'الهدف التكراري'**
  String get habitFormTargetLabel;

  /// No description provided for @habitFormTargetHint.
  ///
  /// In ar, this message translates to:
  /// **'عدد المرات'**
  String get habitFormTargetHint;

  /// No description provided for @habitFormSaveEdits.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التعديلات'**
  String get habitFormSaveEdits;

  /// No description provided for @habitFormStartNow.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ العادة الآن'**
  String get habitFormStartNow;

  /// No description provided for @habitFormFreqDaily.
  ///
  /// In ar, this message translates to:
  /// **'يومي'**
  String get habitFormFreqDaily;

  /// No description provided for @habitFormFreqWeekly.
  ///
  /// In ar, this message translates to:
  /// **'أسبوعي'**
  String get habitFormFreqWeekly;

  /// No description provided for @habitFormFreqMonthly.
  ///
  /// In ar, this message translates to:
  /// **'شهري'**
  String get habitFormFreqMonthly;

  /// No description provided for @habitFormPeriodMorning.
  ///
  /// In ar, this message translates to:
  /// **'صباحاً'**
  String get habitFormPeriodMorning;

  /// No description provided for @habitFormPeriodAfternoon.
  ///
  /// In ar, this message translates to:
  /// **'عصراً'**
  String get habitFormPeriodAfternoon;

  /// No description provided for @habitFormPeriodNight.
  ///
  /// In ar, this message translates to:
  /// **'ليلاً'**
  String get habitFormPeriodNight;

  /// No description provided for @habitFormPeriodAnytime.
  ///
  /// In ar, this message translates to:
  /// **'أي وقت'**
  String get habitFormPeriodAnytime;

  /// No description provided for @habitTileDeleteConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الحذف'**
  String get habitTileDeleteConfirmTitle;

  /// No description provided for @habitTileDeleteConfirmContent.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف هذه العادة؟'**
  String get habitTileDeleteConfirmContent;

  /// No description provided for @habitTileDeleteCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get habitTileDeleteCancel;

  /// No description provided for @habitTileDeleteAction.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get habitTileDeleteAction;

  /// No description provided for @habitDetailsCurrentStreak.
  ///
  /// In ar, this message translates to:
  /// **'السلسلة الحالية'**
  String get habitDetailsCurrentStreak;

  /// No description provided for @habitDetailsStreakDays.
  ///
  /// In ar, this message translates to:
  /// **'{count} يوم'**
  String habitDetailsStreakDays(Object count);

  /// No description provided for @habitDetailsTotalCompleted.
  ///
  /// In ar, this message translates to:
  /// **'مجموع الإنجاز'**
  String get habitDetailsTotalCompleted;

  /// No description provided for @habitDetailsCompletedTimes.
  ///
  /// In ar, this message translates to:
  /// **'{count} مرة'**
  String habitDetailsCompletedTimes(Object count);

  /// No description provided for @habitDetailsCommitmentLog.
  ///
  /// In ar, this message translates to:
  /// **'سجل الالتزام (آخر 30 يوم)'**
  String get habitDetailsCommitmentLog;

  /// No description provided for @habitDetailsMotivationalMessage.
  ///
  /// In ar, this message translates to:
  /// **'كل يوم تلتزم فيه هو خطوة نحو شخصيتك الجديدة. استمر يا بطل! 🚀'**
  String get habitDetailsMotivationalMessage;

  /// No description provided for @habitHeatmapTitle.
  ///
  /// In ar, this message translates to:
  /// **'خارطة الالتزام'**
  String get habitHeatmapTitle;

  /// No description provided for @habitHeatmapDayAchievements.
  ///
  /// In ar, this message translates to:
  /// **'إنجازات يوم: {day}/{month}'**
  String habitHeatmapDayAchievements(Object day, Object month);

  /// No description provided for @healthQuickAccess.
  ///
  /// In ar, this message translates to:
  /// **'الوصول السريع'**
  String get healthQuickAccess;

  /// No description provided for @healthBloodType.
  ///
  /// In ar, this message translates to:
  /// **'فصيلة الدم: {type}'**
  String healthBloodType(Object type);

  /// No description provided for @healthAllergy.
  ///
  /// In ar, this message translates to:
  /// **'حساسية: {allergies}'**
  String healthAllergy(Object allergies);

  /// No description provided for @healthMedicines.
  ///
  /// In ar, this message translates to:
  /// **'الأدوية'**
  String get healthMedicines;

  /// No description provided for @healthAppointments.
  ///
  /// In ar, this message translates to:
  /// **'المواعيد'**
  String get healthAppointments;

  /// No description provided for @healthVitals.
  ///
  /// In ar, this message translates to:
  /// **'المؤشرات'**
  String get healthVitals;

  /// No description provided for @healthTimeline.
  ///
  /// In ar, this message translates to:
  /// **'السجل'**
  String get healthTimeline;

  /// No description provided for @healthTodaySchedule.
  ///
  /// In ar, this message translates to:
  /// **'جدولي اليوم'**
  String get healthTodaySchedule;

  /// No description provided for @healthMedFixedTimes.
  ///
  /// In ar, this message translates to:
  /// **'أوقات ثابتة'**
  String get healthMedFixedTimes;

  /// No description provided for @healthMedEveryHours.
  ///
  /// In ar, this message translates to:
  /// **'كل {hours} ساعات'**
  String healthMedEveryHours(Object hours);

  /// No description provided for @healthNoAppointmentsToday.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مواعيد اليوم، صحتك تمام! 🌟'**
  String get healthNoAppointmentsToday;

  /// No description provided for @vitalSheetUnitLabel.
  ///
  /// In ar, this message translates to:
  /// **'الوحدة'**
  String get vitalSheetUnitLabel;

  /// No description provided for @healthRecords.
  ///
  /// In ar, this message translates to:
  /// **'السجل'**
  String get healthRecords;

  /// No description provided for @healthFixedTimes.
  ///
  /// In ar, this message translates to:
  /// **'أوقات ثابتة'**
  String get healthFixedTimes;

  /// No description provided for @healthEveryHours.
  ///
  /// In ar, this message translates to:
  /// **'كل {hours} ساعات'**
  String healthEveryHours(Object hours);

  /// No description provided for @vitalSheetTitle.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل جديد 📈'**
  String get vitalSheetTitle;

  /// No description provided for @vitalSheetVitalSign.
  ///
  /// In ar, this message translates to:
  /// **'مؤشر حيوي'**
  String get vitalSheetVitalSign;

  /// No description provided for @vitalSheetGeneralNote.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة عامة'**
  String get vitalSheetGeneralNote;

  /// No description provided for @vitalSheetVitalType.
  ///
  /// In ar, this message translates to:
  /// **'نوع المؤشر:'**
  String get vitalSheetVitalType;

  /// No description provided for @vitalSheetWeight.
  ///
  /// In ar, this message translates to:
  /// **'وزن'**
  String get vitalSheetWeight;

  /// No description provided for @vitalSheetTemperature.
  ///
  /// In ar, this message translates to:
  /// **'حرارة'**
  String get vitalSheetTemperature;

  /// No description provided for @vitalSheetPressure.
  ///
  /// In ar, this message translates to:
  /// **'ضغط'**
  String get vitalSheetPressure;

  /// No description provided for @vitalSheetSugar.
  ///
  /// In ar, this message translates to:
  /// **'سكر'**
  String get vitalSheetSugar;

  /// No description provided for @vitalSheetValue.
  ///
  /// In ar, this message translates to:
  /// **'القيمة'**
  String get vitalSheetValue;

  /// No description provided for @vitalSheetValueHint.
  ///
  /// In ar, this message translates to:
  /// **'مثلاً: 70'**
  String get vitalSheetValueHint;

  /// No description provided for @vitalSheetUnit.
  ///
  /// In ar, this message translates to:
  /// **'الوحدة'**
  String get vitalSheetUnit;

  /// No description provided for @vitalSheetNoteLabel.
  ///
  /// In ar, this message translates to:
  /// **'نص الملاحظة'**
  String get vitalSheetNoteLabel;

  /// No description provided for @vitalSheetNoteHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب ملاحظاتك الطبية هنا...'**
  String get vitalSheetNoteHint;

  /// No description provided for @vitalSheetSaveButton.
  ///
  /// In ar, this message translates to:
  /// **'حفظ السجل'**
  String get vitalSheetSaveButton;

  /// No description provided for @medicineEditTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الدواء ✏️'**
  String get medicineEditTitle;

  /// No description provided for @medicineAddTitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة دواء جديد 💊'**
  String get medicineAddTitle;

  /// No description provided for @medicineRequired.
  ///
  /// In ar, this message translates to:
  /// **'مطلوب'**
  String get medicineRequired;

  /// No description provided for @medicineDosageForm.
  ///
  /// In ar, this message translates to:
  /// **'الشكل الدوائي:'**
  String get medicineDosageForm;

  /// No description provided for @medicineTypePill.
  ///
  /// In ar, this message translates to:
  /// **'حبوب'**
  String get medicineTypePill;

  /// No description provided for @medicineTypeSyrup.
  ///
  /// In ar, this message translates to:
  /// **'شراب'**
  String get medicineTypeSyrup;

  /// No description provided for @medicineTypeInjection.
  ///
  /// In ar, this message translates to:
  /// **'إبرة'**
  String get medicineTypeInjection;

  /// No description provided for @medicineTypeDrops.
  ///
  /// In ar, this message translates to:
  /// **'قطرة'**
  String get medicineTypeDrops;

  /// No description provided for @medicineTypeOintment.
  ///
  /// In ar, this message translates to:
  /// **'مرهم'**
  String get medicineTypeOintment;

  /// No description provided for @medicineTypeSpray.
  ///
  /// In ar, this message translates to:
  /// **'بخاخ'**
  String get medicineTypeSpray;

  /// No description provided for @medicineDoseAmount.
  ///
  /// In ar, this message translates to:
  /// **'مقدار الجرعة'**
  String get medicineDoseAmount;

  /// No description provided for @medicineDoseUnit.
  ///
  /// In ar, this message translates to:
  /// **'الوحدة'**
  String get medicineDoseUnit;

  /// No description provided for @medicineInstructions.
  ///
  /// In ar, this message translates to:
  /// **'تعليمات الاستخدام'**
  String get medicineInstructions;

  /// No description provided for @medicineBeforeMeal.
  ///
  /// In ar, this message translates to:
  /// **'قبل الأكل'**
  String get medicineBeforeMeal;

  /// No description provided for @medicineAfterMeal.
  ///
  /// In ar, this message translates to:
  /// **'بعد الأكل'**
  String get medicineAfterMeal;

  /// No description provided for @medicineWithMeal.
  ///
  /// In ar, this message translates to:
  /// **'مع الأكل'**
  String get medicineWithMeal;

  /// No description provided for @medicineAnytime.
  ///
  /// In ar, this message translates to:
  /// **'في أي وقت'**
  String get medicineAnytime;

  /// No description provided for @medicineFixedTimes.
  ///
  /// In ar, this message translates to:
  /// **'أوقات ثابتة'**
  String get medicineFixedTimes;

  /// No description provided for @medicineIntervalHours.
  ///
  /// In ar, this message translates to:
  /// **'تكرار بالساعات'**
  String get medicineIntervalHours;

  /// No description provided for @medicineStock.
  ///
  /// In ar, this message translates to:
  /// **'المخزون'**
  String get medicineStock;

  /// No description provided for @medicineTreatmentDuration.
  ///
  /// In ar, this message translates to:
  /// **'مدة العلاج:'**
  String get medicineTreatmentDuration;

  /// No description provided for @medicineSwitchToDate.
  ///
  /// In ar, this message translates to:
  /// **'تحديد بالتاريخ؟'**
  String get medicineSwitchToDate;

  /// No description provided for @medicineSwitchToDays.
  ///
  /// In ar, this message translates to:
  /// **'تحديد بالأيام؟'**
  String get medicineSwitchToDays;

  /// No description provided for @medicineDaysCount.
  ///
  /// In ar, this message translates to:
  /// **'عدد الأيام'**
  String get medicineDaysCount;

  /// No description provided for @medicinePickEndDate.
  ///
  /// In ar, this message translates to:
  /// **'اختر تاريخ النهاية'**
  String get medicinePickEndDate;

  /// No description provided for @medicineAutoRefill.
  ///
  /// In ar, this message translates to:
  /// **'إعادة التعبئة التلقائية'**
  String get medicineAutoRefill;

  /// No description provided for @medicineRefillWhen.
  ///
  /// In ar, this message translates to:
  /// **'متى يتم الطلب؟'**
  String get medicineRefillWhen;

  /// No description provided for @medicineRefillOff.
  ///
  /// In ar, this message translates to:
  /// **'إيقاف (يدوي)'**
  String get medicineRefillOff;

  /// No description provided for @medicineRefillOnLowStock.
  ///
  /// In ar, this message translates to:
  /// **'عند نقص الكمية'**
  String get medicineRefillOnLowStock;

  /// No description provided for @medicineRefillBeforeEnd.
  ///
  /// In ar, this message translates to:
  /// **'قبل انتهاء الكورس'**
  String get medicineRefillBeforeEnd;

  /// No description provided for @medicineRefillAtQuantity.
  ///
  /// In ar, this message translates to:
  /// **'عند الوصول لـ (كمية)'**
  String get medicineRefillAtQuantity;

  /// No description provided for @medicineRefillBeforeDays.
  ///
  /// In ar, this message translates to:
  /// **'قبل الانتهاء بـ (أيام)'**
  String get medicineRefillBeforeDays;

  /// No description provided for @medicineRefillQuantityHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: اطلب عندما يتبقى 5 حبات'**
  String get medicineRefillQuantityHint;

  /// No description provided for @medicineRefillDaysHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: اطلب قبل 3 أيام من النهاية'**
  String get medicineRefillDaysHint;

  /// No description provided for @medicineRefillAction.
  ///
  /// In ar, this message translates to:
  /// **'الإجراء المطلوب'**
  String get medicineRefillAction;

  /// No description provided for @medicineRefillActionList.
  ///
  /// In ar, this message translates to:
  /// **'إضافة لقائمة المشتريات'**
  String get medicineRefillActionList;

  /// No description provided for @medicineRefillActionTask.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء مهمة متابعة'**
  String get medicineRefillActionTask;

  /// No description provided for @medicineRefillActionBoth.
  ///
  /// In ar, this message translates to:
  /// **'كلاهما (مهمة + قائمة)'**
  String get medicineRefillActionBoth;

  /// No description provided for @medicineSaveEdits.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التعديلات'**
  String get medicineSaveEdits;

  /// No description provided for @medicineSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ الدواء'**
  String get medicineSave;

  /// No description provided for @medicineSelectTimes.
  ///
  /// In ar, this message translates to:
  /// **'حدد أوقات التناول:'**
  String get medicineSelectTimes;

  /// No description provided for @medicineEvery.
  ///
  /// In ar, this message translates to:
  /// **'كل'**
  String get medicineEvery;

  /// No description provided for @medicineHoursUnit.
  ///
  /// In ar, this message translates to:
  /// **'{count} ساعات'**
  String medicineHoursUnit(Object count);

  /// No description provided for @healthTimelineTitle.
  ///
  /// In ar, this message translates to:
  /// **'Complete Medical Record'**
  String get healthTimelineTitle;

  /// No description provided for @healthTimelineAddRecord.
  ///
  /// In ar, this message translates to:
  /// **'Add Record'**
  String get healthTimelineAddRecord;

  /// No description provided for @healthTimelineFilterAll.
  ///
  /// In ar, this message translates to:
  /// **'All'**
  String get healthTimelineFilterAll;

  /// No description provided for @healthTimelineFilterVisits.
  ///
  /// In ar, this message translates to:
  /// **'Visits'**
  String get healthTimelineFilterVisits;

  /// No description provided for @healthTimelineFilterVitals.
  ///
  /// In ar, this message translates to:
  /// **'Vitals'**
  String get healthTimelineFilterVitals;

  /// No description provided for @healthTimelineFilterDocs.
  ///
  /// In ar, this message translates to:
  /// **'Documents'**
  String get healthTimelineFilterDocs;

  /// No description provided for @healthTimelineMedicalVisit.
  ///
  /// In ar, this message translates to:
  /// **'Medical Visit'**
  String get healthTimelineMedicalVisit;

  /// No description provided for @healthTimelineDoctorPrefix.
  ///
  /// In ar, this message translates to:
  /// **'Dr.'**
  String get healthTimelineDoctorPrefix;

  /// No description provided for @healthTimelineNoteDoc.
  ///
  /// In ar, this message translates to:
  /// **'Note/Document'**
  String get healthTimelineNoteDoc;

  /// No description provided for @healthTimelineVitalSign.
  ///
  /// In ar, this message translates to:
  /// **'Vital Sign'**
  String get healthTimelineVitalSign;

  /// No description provided for @healthTimelineNoTitle.
  ///
  /// In ar, this message translates to:
  /// **'Untitled'**
  String get healthTimelineNoTitle;

  /// No description provided for @healthTimelineEmpty.
  ///
  /// In ar, this message translates to:
  /// **'Medical record is empty'**
  String get healthTimelineEmpty;

  /// No description provided for @appointmentsTitle.
  ///
  /// In ar, this message translates to:
  /// **'Appointments Center'**
  String get appointmentsTitle;

  /// No description provided for @appointmentsTabUpcoming.
  ///
  /// In ar, this message translates to:
  /// **'Upcoming'**
  String get appointmentsTabUpcoming;

  /// No description provided for @appointmentsTabArchive.
  ///
  /// In ar, this message translates to:
  /// **'Previous (Archive)'**
  String get appointmentsTabArchive;

  /// No description provided for @appointmentsNewButton.
  ///
  /// In ar, this message translates to:
  /// **'New Appointment'**
  String get appointmentsNewButton;

  /// No description provided for @appointmentsEmptyUpcoming.
  ///
  /// In ar, this message translates to:
  /// **'No upcoming appointments'**
  String get appointmentsEmptyUpcoming;

  /// No description provided for @appointmentsEmptyArchive.
  ///
  /// In ar, this message translates to:
  /// **'Visit history is empty'**
  String get appointmentsEmptyArchive;

  /// No description provided for @appointmentsTypeLab.
  ///
  /// In ar, this message translates to:
  /// **'Lab Test'**
  String get appointmentsTypeLab;

  /// No description provided for @appointmentsTypeVaccine.
  ///
  /// In ar, this message translates to:
  /// **'Vaccination'**
  String get appointmentsTypeVaccine;

  /// No description provided for @appointmentsTypeProcedure.
  ///
  /// In ar, this message translates to:
  /// **'Procedure/Surgery'**
  String get appointmentsTypeProcedure;

  /// No description provided for @appointmentsTypeCheckup.
  ///
  /// In ar, this message translates to:
  /// **'Checkup'**
  String get appointmentsTypeCheckup;

  /// No description provided for @appointmentsDeleteAction.
  ///
  /// In ar, this message translates to:
  /// **'Delete Appointment'**
  String get appointmentsDeleteAction;

  /// No description provided for @medicinesPageTitle.
  ///
  /// In ar, this message translates to:
  /// **'خزانة الأدوية'**
  String get medicinesPageTitle;

  /// No description provided for @medicinesTabActive.
  ///
  /// In ar, this message translates to:
  /// **'الأدوية الحالية'**
  String get medicinesTabActive;

  /// No description provided for @medicinesTabArchive.
  ///
  /// In ar, this message translates to:
  /// **'الأرشيف'**
  String get medicinesTabArchive;

  /// No description provided for @medicinesNewButton.
  ///
  /// In ar, this message translates to:
  /// **'دواء جديد'**
  String get medicinesNewButton;

  /// No description provided for @medicinesEmptyActive.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أدوية نشطة حالياً'**
  String get medicinesEmptyActive;

  /// No description provided for @medicinesEmptyArchive.
  ///
  /// In ar, this message translates to:
  /// **'الأرشيف فارغ'**
  String get medicinesEmptyArchive;

  /// No description provided for @medicinesEveryHours.
  ///
  /// In ar, this message translates to:
  /// **'كل {hours} ساعات'**
  String medicinesEveryHours(Object hours);

  /// No description provided for @medicinesMenuEdit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get medicinesMenuEdit;

  /// No description provided for @medicinesMenuArchive.
  ///
  /// In ar, this message translates to:
  /// **'نقل للأرشيف (إيقاف)'**
  String get medicinesMenuArchive;

  /// No description provided for @medicinesMenuReactivate.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل مجدداً'**
  String get medicinesMenuReactivate;

  /// No description provided for @medicinesMenuDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف نهائي'**
  String get medicinesMenuDelete;

  /// No description provided for @vitalsPageTitle.
  ///
  /// In ar, this message translates to:
  /// **'المؤشرات والأرشيف'**
  String get vitalsPageTitle;

  /// No description provided for @vitalsNewButton.
  ///
  /// In ar, this message translates to:
  /// **'قراءة جديدة'**
  String get vitalsNewButton;

  /// No description provided for @vitalsEmptyState.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد سجلات'**
  String get vitalsEmptyState;

  /// No description provided for @vitalsFilterAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get vitalsFilterAll;

  /// No description provided for @vitalsFilterWeight.
  ///
  /// In ar, this message translates to:
  /// **'الوزن'**
  String get vitalsFilterWeight;

  /// No description provided for @vitalsFilterTemp.
  ///
  /// In ar, this message translates to:
  /// **'الحرارة'**
  String get vitalsFilterTemp;

  /// No description provided for @vitalsFilterPressure.
  ///
  /// In ar, this message translates to:
  /// **'الضغط'**
  String get vitalsFilterPressure;

  /// No description provided for @vitalsFilterSugar.
  ///
  /// In ar, this message translates to:
  /// **'السكر'**
  String get vitalsFilterSugar;

  /// No description provided for @vitalsFilterDocuments.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات/وثائق'**
  String get vitalsFilterDocuments;

  /// No description provided for @vitalsIndicatorGeneric.
  ///
  /// In ar, this message translates to:
  /// **'مؤشر'**
  String get vitalsIndicatorGeneric;

  /// No description provided for @vitalsNoteDocument.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة/وثيقة'**
  String get vitalsNoteDocument;

  /// No description provided for @vitalsNoTitle.
  ///
  /// In ar, this message translates to:
  /// **'بدون عنوان'**
  String get vitalsNoTitle;

  /// No description provided for @appointmentSheetTitle.
  ///
  /// In ar, this message translates to:
  /// **'حجز موعد جديد 🗓️'**
  String get appointmentSheetTitle;

  /// No description provided for @appointmentTitleLabel.
  ///
  /// In ar, this message translates to:
  /// **'عنوان الموعد (مطلوب)'**
  String get appointmentTitleLabel;

  /// No description provided for @appointmentTitleHint.
  ///
  /// In ar, this message translates to:
  /// **'مثلاً: فحص نظر، تطعيم 6 شهور'**
  String get appointmentTitleHint;

  /// No description provided for @appointmentVisitType.
  ///
  /// In ar, this message translates to:
  /// **'نوع الزيارة:'**
  String get appointmentVisitType;

  /// No description provided for @appointmentTypeCheckup.
  ///
  /// In ar, this message translates to:
  /// **'كشف'**
  String get appointmentTypeCheckup;

  /// No description provided for @appointmentTypeLab.
  ///
  /// In ar, this message translates to:
  /// **'تحليل'**
  String get appointmentTypeLab;

  /// No description provided for @appointmentTypeVaccine.
  ///
  /// In ar, this message translates to:
  /// **'تطعيم'**
  String get appointmentTypeVaccine;

  /// No description provided for @appointmentTypeProcedure.
  ///
  /// In ar, this message translates to:
  /// **'إجراء'**
  String get appointmentTypeProcedure;

  /// No description provided for @appointmentDateLabel.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ'**
  String get appointmentDateLabel;

  /// No description provided for @appointmentTimeLabel.
  ///
  /// In ar, this message translates to:
  /// **'الوقت'**
  String get appointmentTimeLabel;

  /// No description provided for @appointmentDoctorLabel.
  ///
  /// In ar, this message translates to:
  /// **'الطبيب'**
  String get appointmentDoctorLabel;

  /// No description provided for @appointmentLocationLabel.
  ///
  /// In ar, this message translates to:
  /// **'العيادة/المكان'**
  String get appointmentLocationLabel;

  /// No description provided for @appointmentNotesLabel.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات'**
  String get appointmentNotesLabel;

  /// No description provided for @appointmentSaveButton.
  ///
  /// In ar, this message translates to:
  /// **'حفظ الموعد'**
  String get appointmentSaveButton;

  /// No description provided for @projectDetailsError.
  ///
  /// In ar, this message translates to:
  /// **'خطأ: {message}'**
  String projectDetailsError(Object message);

  /// No description provided for @projectDetailsNewTask.
  ///
  /// In ar, this message translates to:
  /// **'مهمة جديدة'**
  String get projectDetailsNewTask;

  /// No description provided for @projectDetailsViewList.
  ///
  /// In ar, this message translates to:
  /// **'عرض القائمة'**
  String get projectDetailsViewList;

  /// No description provided for @projectDetailsViewBoard.
  ///
  /// In ar, this message translates to:
  /// **'عرض اللوحة'**
  String get projectDetailsViewBoard;

  /// No description provided for @projectDetailsSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات المشروع'**
  String get projectDetailsSettings;

  /// No description provided for @projectDetailsTaskCount.
  ///
  /// In ar, this message translates to:
  /// **'المهام ({count})'**
  String projectDetailsTaskCount(Object count);

  /// No description provided for @projectDetailsSortManual.
  ///
  /// In ar, this message translates to:
  /// **'ترتيب يدوي'**
  String get projectDetailsSortManual;

  /// No description provided for @projectDetailsSortEisenhower.
  ///
  /// In ar, this message translates to:
  /// **'الأهمية (ايزنهاور)'**
  String get projectDetailsSortEisenhower;

  /// No description provided for @projectDetailsSortTime.
  ///
  /// In ar, this message translates to:
  /// **'الأقرب وقتاً'**
  String get projectDetailsSortTime;

  /// No description provided for @projectDetailsTimeExpired.
  ///
  /// In ar, this message translates to:
  /// **'انتهى الوقت'**
  String get projectDetailsTimeExpired;

  /// No description provided for @projectDetailsDaysLeft.
  ///
  /// In ar, this message translates to:
  /// **'باقي {days} يوم'**
  String projectDetailsDaysLeft(Object days);

  /// No description provided for @projectDetailsShowMore.
  ///
  /// In ar, this message translates to:
  /// **'المزيد...'**
  String get projectDetailsShowMore;

  /// No description provided for @projectDetailsProgressLabel.
  ///
  /// In ar, this message translates to:
  /// **'نسبة الإنجاز'**
  String get projectDetailsProgressLabel;

  /// No description provided for @projectDetailsNameLabel.
  ///
  /// In ar, this message translates to:
  /// **'اسم المشروع'**
  String get projectDetailsNameLabel;

  /// No description provided for @projectDetailsDescLabel.
  ///
  /// In ar, this message translates to:
  /// **'وصف المشروع (اختياري)'**
  String get projectDetailsDescLabel;

  /// No description provided for @projectDetailsStartDate.
  ///
  /// In ar, this message translates to:
  /// **'البداية'**
  String get projectDetailsStartDate;

  /// No description provided for @projectDetailsEndDate.
  ///
  /// In ar, this message translates to:
  /// **'النهاية (Deadline)'**
  String get projectDetailsEndDate;

  /// No description provided for @projectDetailsUpdateSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث بيانات المشروع بنجاح ✅'**
  String get projectDetailsUpdateSuccess;

  /// No description provided for @projectDetailsSaveChanges.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التغييرات'**
  String get projectDetailsSaveChanges;

  /// No description provided for @projectDetailsRestore.
  ///
  /// In ar, this message translates to:
  /// **'استعادة المشروع'**
  String get projectDetailsRestore;

  /// No description provided for @projectDetailsArchive.
  ///
  /// In ar, this message translates to:
  /// **'أرشفة المشروع'**
  String get projectDetailsArchive;

  /// No description provided for @projectDetailsRestoreDesc.
  ///
  /// In ar, this message translates to:
  /// **'سيعود للقائمة الرئيسية'**
  String get projectDetailsRestoreDesc;

  /// No description provided for @projectDetailsArchiveDesc.
  ///
  /// In ar, this message translates to:
  /// **'سيتم إخفاؤه من القائمة الرئيسية (نسبة الإنجاز محفوظة)'**
  String get projectDetailsArchiveDesc;

  /// No description provided for @projectDetailsArchived.
  ///
  /// In ar, this message translates to:
  /// **'تم أرشفة المشروع'**
  String get projectDetailsArchived;

  /// No description provided for @projectDetailsNotSet.
  ///
  /// In ar, this message translates to:
  /// **'غير محدد'**
  String get projectDetailsNotSet;

  /// No description provided for @projectDetailsTaskDeleted.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف المهمة'**
  String get projectDetailsTaskDeleted;

  /// No description provided for @projectDetailsNoDeletePermission.
  ///
  /// In ar, this message translates to:
  /// **'عذراً، لا تملك صلاحية حذف هذه المهمة 🚫'**
  String get projectDetailsNoDeletePermission;

  /// No description provided for @projectDetailsEmptyState.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ مشروعك بإضافة مهمة'**
  String get projectDetailsEmptyState;

  /// No description provided for @spaceSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات المساحة'**
  String get spaceSettings;

  /// No description provided for @spacePermissionSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الصلاحيات'**
  String get spacePermissionSettings;

  /// No description provided for @spaceDeleteAction.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get spaceDeleteAction;

  /// No description provided for @spaceDeleteModuleTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف العنصر'**
  String get spaceDeleteModuleTitle;

  /// No description provided for @spaceDeleteModuleContent.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف \'{name}\'؟\nيمكنك استعادته لاحقاً من الأرشيف (قريباً).'**
  String spaceDeleteModuleContent(Object name);

  /// No description provided for @spaceModuleDeletedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف العنصر بنجاح 🗑️'**
  String get spaceModuleDeletedSuccess;

  /// No description provided for @spaceCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get spaceCancel;

  /// No description provided for @spaceEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'المساحة فارغة'**
  String get spaceEmptyTitle;

  /// No description provided for @spaceEmptySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أضف مشاريع أو قوائم أو خزينة أصول'**
  String get spaceEmptySubtitle;

  /// No description provided for @spaceAddNewTitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة جديد'**
  String get spaceAddNewTitle;

  /// No description provided for @spaceModuleNameHint.
  ///
  /// In ar, this message translates to:
  /// **'الاسم (مثلاً: عزبة البر)'**
  String get spaceModuleNameHint;

  /// No description provided for @spacePrivateModule.
  ///
  /// In ar, this message translates to:
  /// **'موديول خاص (Private)'**
  String get spacePrivateModule;

  /// No description provided for @spacePrivateModuleDesc.
  ///
  /// In ar, this message translates to:
  /// **'لا يراه إلا من تقوم بدعوته'**
  String get spacePrivateModuleDesc;

  /// No description provided for @spaceCreateAction.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء'**
  String get spaceCreateAction;

  /// No description provided for @spaceCopyFromTemplate.
  ///
  /// In ar, this message translates to:
  /// **'نسخ من قائمة سابقة (اختياري)'**
  String get spaceCopyFromTemplate;

  /// No description provided for @spaceEmptyList.
  ///
  /// In ar, this message translates to:
  /// **'قائمة فارغة'**
  String get spaceEmptyList;

  /// No description provided for @spaceListCopiedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء القائمة ونسخ العناصر بنجاح ✅'**
  String get spaceListCopiedSuccess;

  /// No description provided for @moduleTypeProject.
  ///
  /// In ar, this message translates to:
  /// **'مشروع'**
  String get moduleTypeProject;

  /// No description provided for @moduleTypeList.
  ///
  /// In ar, this message translates to:
  /// **'قائمة'**
  String get moduleTypeList;

  /// No description provided for @moduleTypeHealth.
  ///
  /// In ar, this message translates to:
  /// **'ملف صحي'**
  String get moduleTypeHealth;

  /// No description provided for @moduleTypeAssets.
  ///
  /// In ar, this message translates to:
  /// **'خزينة أصول'**
  String get moduleTypeAssets;

  /// No description provided for @moduleTypeGeneral.
  ///
  /// In ar, this message translates to:
  /// **'عام'**
  String get moduleTypeGeneral;

  /// No description provided for @listPurchaseHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل المشتريات'**
  String get listPurchaseHistory;

  /// No description provided for @listCopyAsTemplate.
  ///
  /// In ar, this message translates to:
  /// **'نسخ القائمة (حفظ كقالب)'**
  String get listCopyAsTemplate;

  /// No description provided for @listResetTitle.
  ///
  /// In ar, this message translates to:
  /// **'إعادة تصفير القائمة'**
  String get listResetTitle;

  /// No description provided for @listAdvancedOptions.
  ///
  /// In ar, this message translates to:
  /// **'خيارات متقدمة (كمية، تكرار)'**
  String get listAdvancedOptions;

  /// No description provided for @listQuickAddHint.
  ///
  /// In ar, this message translates to:
  /// **'إضافة سريعة...'**
  String get listQuickAddHint;

  /// No description provided for @listEmptyState.
  ///
  /// In ar, this message translates to:
  /// **'القائمة فارغة'**
  String get listEmptyState;

  /// No description provided for @listResetContent.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد إلغاء تحديد جميع العناصر؟'**
  String get listResetContent;

  /// No description provided for @listResetAction.
  ///
  /// In ar, this message translates to:
  /// **'تصفير'**
  String get listResetAction;

  /// No description provided for @listDuplicateTitle.
  ///
  /// In ar, this message translates to:
  /// **'تكرار القائمة'**
  String get listDuplicateTitle;

  /// No description provided for @listDuplicateDesc.
  ///
  /// In ar, this message translates to:
  /// **'سيتم إنشاء قائمة جديدة تحتوي على نفس العناصر.'**
  String get listDuplicateDesc;

  /// No description provided for @listNewListName.
  ///
  /// In ar, this message translates to:
  /// **'اسم القائمة الجديدة'**
  String get listNewListName;

  /// No description provided for @listCopyAction.
  ///
  /// In ar, this message translates to:
  /// **'نسخ'**
  String get listCopyAction;

  /// No description provided for @listCopiedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم نسخ القائمة بنجاح ✅'**
  String get listCopiedSuccess;

  /// No description provided for @listCopyOfName.
  ///
  /// In ar, this message translates to:
  /// **'نسخة من {name}'**
  String listCopyOfName(Object name);

  /// No description provided for @listRepeatEveryDays.
  ///
  /// In ar, this message translates to:
  /// **' كل {days} يوم'**
  String listRepeatEveryDays(Object days);

  /// No description provided for @moduleTypeAssetsShort.
  ///
  /// In ar, this message translates to:
  /// **'أصول'**
  String get moduleTypeAssetsShort;

  /// No description provided for @moduleTypeHealthShort.
  ///
  /// In ar, this message translates to:
  /// **'صحي'**
  String get moduleTypeHealthShort;

  /// No description provided for @listPageHistoryTooltip.
  ///
  /// In ar, this message translates to:
  /// **'سجل المشتريات'**
  String get listPageHistoryTooltip;

  /// No description provided for @listPageDuplicateOption.
  ///
  /// In ar, this message translates to:
  /// **'نسخ القائمة (حفظ كقالب)'**
  String get listPageDuplicateOption;

  /// No description provided for @listPageResetOption.
  ///
  /// In ar, this message translates to:
  /// **'إعادة تصفير القائمة'**
  String get listPageResetOption;

  /// No description provided for @listPageRepeatEvery.
  ///
  /// In ar, this message translates to:
  /// **' كل {days} يوم'**
  String listPageRepeatEvery(Object days);

  /// No description provided for @listPageAdvancedTooltip.
  ///
  /// In ar, this message translates to:
  /// **'خيارات متقدمة (كمية، تكرار)'**
  String get listPageAdvancedTooltip;

  /// No description provided for @listPageQuickAddHint.
  ///
  /// In ar, this message translates to:
  /// **'إضافة سريعة...'**
  String get listPageQuickAddHint;

  /// No description provided for @listPageEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'القائمة فارغة'**
  String get listPageEmptyTitle;

  /// No description provided for @listPageResetTitle.
  ///
  /// In ar, this message translates to:
  /// **'إعادة تصفير القائمة'**
  String get listPageResetTitle;

  /// No description provided for @listPageResetMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد إلغاء تحديد جميع العناصر؟'**
  String get listPageResetMessage;

  /// No description provided for @listPageCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get listPageCancel;

  /// No description provided for @listPageResetAction.
  ///
  /// In ar, this message translates to:
  /// **'تصفير'**
  String get listPageResetAction;

  /// No description provided for @listPageDuplicateDefaultName.
  ///
  /// In ar, this message translates to:
  /// **'نسخة من {name}'**
  String listPageDuplicateDefaultName(Object name);

  /// No description provided for @listPageDuplicateTitle.
  ///
  /// In ar, this message translates to:
  /// **'تكرار القائمة'**
  String get listPageDuplicateTitle;

  /// No description provided for @listPageDuplicateDescription.
  ///
  /// In ar, this message translates to:
  /// **'سيتم إنشاء قائمة جديدة تحتوي على نفس العناصر.'**
  String get listPageDuplicateDescription;

  /// No description provided for @listPageNewListNameLabel.
  ///
  /// In ar, this message translates to:
  /// **'اسم القائمة الجديدة'**
  String get listPageNewListNameLabel;

  /// No description provided for @listPageDuplicateSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم نسخ القائمة بنجاح ✅'**
  String get listPageDuplicateSuccess;

  /// No description provided for @listPageDuplicateAction.
  ///
  /// In ar, this message translates to:
  /// **'نسخ'**
  String get listPageDuplicateAction;

  /// No description provided for @spaceListTitle.
  ///
  /// In ar, this message translates to:
  /// **'مساحاتي 🪐'**
  String get spaceListTitle;

  /// No description provided for @spaceListInboxTooltip.
  ///
  /// In ar, this message translates to:
  /// **'الدعوات'**
  String get spaceListInboxTooltip;

  /// No description provided for @spaceListNewSpace.
  ///
  /// In ar, this message translates to:
  /// **'مساحة جديدة'**
  String get spaceListNewSpace;

  /// No description provided for @spaceListPersonalSpace.
  ///
  /// In ar, this message translates to:
  /// **'مساحة خاصة'**
  String get spaceListPersonalSpace;

  /// No description provided for @spaceListSharedSpace.
  ///
  /// In ar, this message translates to:
  /// **'مساحة مشتركة'**
  String get spaceListSharedSpace;

  /// No description provided for @spaceListDeleteTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف المساحة'**
  String get spaceListDeleteTitle;

  /// No description provided for @spaceListDeleteMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف مساحة \'{name}\'؟\nسيؤدي هذا لحذف جميع المشاريع والمهام بداخلها.'**
  String spaceListDeleteMessage(String name);

  /// No description provided for @spaceListCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get spaceListCancel;

  /// No description provided for @spaceListDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get spaceListDelete;

  /// No description provided for @spaceListEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مساحات بعد'**
  String get spaceListEmptyTitle;

  /// No description provided for @spaceListCreateTitle.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء مساحة جديدة'**
  String get spaceListCreateTitle;

  /// No description provided for @spaceListNameLabel.
  ///
  /// In ar, this message translates to:
  /// **'اسم المساحة (البيت، العمل...)'**
  String get spaceListNameLabel;

  /// No description provided for @spaceListSharedQuestion.
  ///
  /// In ar, this message translates to:
  /// **'مساحة مشتركة؟'**
  String get spaceListSharedQuestion;

  /// No description provided for @spaceListSharedSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'سيتمكن الآخرون من الانضمام'**
  String get spaceListSharedSubtitle;

  /// No description provided for @spaceListPrivateSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'خاصة بك فقط'**
  String get spaceListPrivateSubtitle;

  /// No description provided for @spaceListCreate.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء'**
  String get spaceListCreate;

  /// No description provided for @moduleSettingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الموديول'**
  String get moduleSettingsTitle;

  /// No description provided for @moduleSettingsContextHealth.
  ///
  /// In ar, this message translates to:
  /// **'صلاحيات متابعة الأدوية والمهام الصحية'**
  String get moduleSettingsContextHealth;

  /// No description provided for @moduleSettingsContextAssets.
  ///
  /// In ar, this message translates to:
  /// **'صلاحيات تعيين مسؤوليات الصيانة والجرد'**
  String get moduleSettingsContextAssets;

  /// No description provided for @moduleSettingsContextList.
  ///
  /// In ar, this message translates to:
  /// **'صلاحيات قائمة المشتريات والمهام'**
  String get moduleSettingsContextList;

  /// No description provided for @moduleSettingsContextProject.
  ///
  /// In ar, this message translates to:
  /// **'صلاحيات إسناد وتفويض مهام المشروع'**
  String get moduleSettingsContextProject;

  /// No description provided for @moduleSettingsDelegationLabel.
  ///
  /// In ar, this message translates to:
  /// **'نظام التفويض (Delegation):'**
  String get moduleSettingsDelegationLabel;

  /// No description provided for @moduleSettingsModeInherit.
  ///
  /// In ar, this message translates to:
  /// **'افتراضي (يتبع المساحة)'**
  String get moduleSettingsModeInherit;

  /// No description provided for @moduleSettingsModeInheritDesc.
  ///
  /// In ar, this message translates to:
  /// **'تطبق إعدادات المساحة العامة'**
  String get moduleSettingsModeInheritDesc;

  /// No description provided for @moduleSettingsModeEnabled.
  ///
  /// In ar, this message translates to:
  /// **'مسموح دائماً'**
  String get moduleSettingsModeEnabled;

  /// No description provided for @moduleSettingsModeEnabledDesc.
  ///
  /// In ar, this message translates to:
  /// **'يستطيع الأعضاء سحب وإسناد المهام بحرية'**
  String get moduleSettingsModeEnabledDesc;

  /// No description provided for @moduleSettingsModeDisabled.
  ///
  /// In ar, this message translates to:
  /// **'محمي (ممنوع)'**
  String get moduleSettingsModeDisabled;

  /// No description provided for @moduleSettingsModeDisabledDesc.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن للأعضاء تغيير المسؤولين (للمدراء فقط)'**
  String get moduleSettingsModeDisabledDesc;

  /// No description provided for @moduleSettingsCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get moduleSettingsCancel;

  /// No description provided for @moduleSettingsSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get moduleSettingsSave;

  /// No description provided for @moduleSettingsSaveSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث الصلاحيات بنجاح ✅'**
  String get moduleSettingsSaveSuccess;

  /// No description provided for @addModuleTitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة موديول'**
  String get addModuleTitle;

  /// No description provided for @addModuleNewProject.
  ///
  /// In ar, this message translates to:
  /// **'مشروع جديد 🚀'**
  String get addModuleNewProject;

  /// No description provided for @addModuleEditProject.
  ///
  /// In ar, this message translates to:
  /// **'تعديل المشروع'**
  String get addModuleEditProject;

  /// No description provided for @addModuleProjectNameLabel.
  ///
  /// In ar, this message translates to:
  /// **'اسم المشروع'**
  String get addModuleProjectNameLabel;

  /// No description provided for @addModuleNameLabel.
  ///
  /// In ar, this message translates to:
  /// **'اسم الموديول'**
  String get addModuleNameLabel;

  /// No description provided for @addModuleDeadlineHint.
  ///
  /// In ar, this message translates to:
  /// **'موعد التسليم (اختياري)'**
  String get addModuleDeadlineHint;

  /// No description provided for @addModuleSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get addModuleSave;

  /// No description provided for @addListItemEditTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الغرض ✏️'**
  String get addListItemEditTitle;

  /// No description provided for @addListItemAddTitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة غرض جديد 🛒'**
  String get addListItemAddTitle;

  /// No description provided for @addListItemNameLabel.
  ///
  /// In ar, this message translates to:
  /// **'اسم الغرض'**
  String get addListItemNameLabel;

  /// No description provided for @addListItemQuantityLabel.
  ///
  /// In ar, this message translates to:
  /// **'الكمية'**
  String get addListItemQuantityLabel;

  /// No description provided for @addListItemUnitLabel.
  ///
  /// In ar, this message translates to:
  /// **'الوحدة'**
  String get addListItemUnitLabel;

  /// No description provided for @addListItemRepeatTitle.
  ///
  /// In ar, this message translates to:
  /// **'التكرار التلقائي'**
  String get addListItemRepeatTitle;

  /// No description provided for @addListItemRepeatDaysLabel.
  ///
  /// In ar, this message translates to:
  /// **'يتكرر كل (أيام)'**
  String get addListItemRepeatDaysLabel;

  /// No description provided for @addListItemRepeatDaysHelper.
  ///
  /// In ar, this message translates to:
  /// **'مثال: 7 لأسبوع'**
  String get addListItemRepeatDaysHelper;

  /// No description provided for @addListItemAutoUncheck.
  ///
  /// In ar, this message translates to:
  /// **'إعادة تلقائية'**
  String get addListItemAutoUncheck;

  /// No description provided for @addListItemAutoUncheckDesc.
  ///
  /// In ar, this message translates to:
  /// **'يعود للقائمة'**
  String get addListItemAutoUncheckDesc;

  /// No description provided for @addListItemSaveEdits.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التعديلات'**
  String get addListItemSaveEdits;

  /// No description provided for @addListItemAddToList.
  ///
  /// In ar, this message translates to:
  /// **'إضافة للقائمة'**
  String get addListItemAddToList;

  /// No description provided for @inboxTitle.
  ///
  /// In ar, this message translates to:
  /// **'صندوق الدعوات'**
  String get inboxTitle;

  /// No description provided for @inboxNewInvite.
  ///
  /// In ar, this message translates to:
  /// **'دعوة جديدة'**
  String get inboxNewInvite;

  /// No description provided for @inboxInviteMessage.
  ///
  /// In ar, this message translates to:
  /// **'لقد تمت دعوتك للانضمام إلى مساحة عمل جديدة.\nانقر قبول للبدء بالتعاون.'**
  String get inboxInviteMessage;

  /// No description provided for @inboxJoiningSpace.
  ///
  /// In ar, this message translates to:
  /// **'جاري الانضمام للمساحة... 🚀'**
  String get inboxJoiningSpace;

  /// No description provided for @inboxAcceptInvite.
  ///
  /// In ar, this message translates to:
  /// **'قبول الدعوة'**
  String get inboxAcceptInvite;

  /// No description provided for @inboxEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد دعوات جديدة'**
  String get inboxEmptyTitle;

  /// No description provided for @inboxEmptySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أنت جاهز تماماً! استمتع بوقتك'**
  String get inboxEmptySubtitle;

  /// No description provided for @spaceSettingsDialogTitle.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات المساحة'**
  String get spaceSettingsDialogTitle;

  /// No description provided for @spaceSettingsDialogDesc.
  ///
  /// In ar, this message translates to:
  /// **'التحكم في صلاحيات الأعضاء العامة داخل \'{name}\''**
  String spaceSettingsDialogDesc(String name);

  /// No description provided for @spaceSettingsDelegationToggle.
  ///
  /// In ar, this message translates to:
  /// **'السماح بالتفويض (Delegation)'**
  String get spaceSettingsDelegationToggle;

  /// No description provided for @spaceSettingsDelegationOnDesc.
  ///
  /// In ar, this message translates to:
  /// **'يستطيع الأعضاء تمرير المهام لبعضهم'**
  String get spaceSettingsDelegationOnDesc;

  /// No description provided for @spaceSettingsDelegationOffDesc.
  ///
  /// In ar, this message translates to:
  /// **'يمنع أي عضو من سحب أو تمرير المهام'**
  String get spaceSettingsDelegationOffDesc;

  /// No description provided for @spaceSettingsUpdateSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث إعدادات المساحة ✅'**
  String get spaceSettingsUpdateSuccess;

  /// No description provided for @listHistoryTitle.
  ///
  /// In ar, this message translates to:
  /// **'سجل مشتريات: {name}'**
  String listHistoryTitle(String name);

  /// No description provided for @listHistoryEmpty.
  ///
  /// In ar, this message translates to:
  /// **'السجل فارغ'**
  String get listHistoryEmpty;

  /// No description provided for @joinSpaceSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم الانضمام للمساحة بنجاح! 🎉'**
  String get joinSpaceSuccess;

  /// No description provided for @joinSpaceLoading.
  ///
  /// In ar, this message translates to:
  /// **'جاري الانضمام للمساحة...'**
  String get joinSpaceLoading;

  /// No description provided for @joinSpaceBackHome.
  ///
  /// In ar, this message translates to:
  /// **'العودة للرئيسية'**
  String get joinSpaceBackHome;

  /// No description provided for @spaceMembersTitle.
  ///
  /// In ar, this message translates to:
  /// **'أعضاء المساحة'**
  String get spaceMembersTitle;

  /// No description provided for @spaceMembersTotalLabel.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الأعضاء'**
  String get spaceMembersTotalLabel;

  /// No description provided for @spaceMembersAddButton.
  ///
  /// In ar, this message translates to:
  /// **'إضافة عضو'**
  String get spaceMembersAddButton;

  /// No description provided for @spaceMembersDefaultName.
  ///
  /// In ar, this message translates to:
  /// **'مستخدم أثر'**
  String get spaceMembersDefaultName;

  /// No description provided for @spaceMembersRoleOwner.
  ///
  /// In ar, this message translates to:
  /// **'المالك'**
  String get spaceMembersRoleOwner;

  /// No description provided for @spaceMembersRoleAdmin.
  ///
  /// In ar, this message translates to:
  /// **'مدير'**
  String get spaceMembersRoleAdmin;

  /// No description provided for @spaceMembersRoleMember.
  ///
  /// In ar, this message translates to:
  /// **'عضو'**
  String get spaceMembersRoleMember;

  /// No description provided for @spaceMembersRoleFounder.
  ///
  /// In ar, this message translates to:
  /// **'مؤسس المساحة'**
  String get spaceMembersRoleFounder;

  /// No description provided for @spaceMembersSearchTitle.
  ///
  /// In ar, this message translates to:
  /// **'بحث عن أعضاء'**
  String get spaceMembersSearchTitle;

  /// No description provided for @spaceMembersSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني أو اسم المستخدم'**
  String get spaceMembersSearchHint;

  /// No description provided for @spaceMembersSearchPrompt.
  ///
  /// In ar, this message translates to:
  /// **'ابحث لإضافة أعضاء'**
  String get spaceMembersSearchPrompt;

  /// No description provided for @spaceMembersInviteSent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال الدعوة'**
  String get spaceMembersInviteSent;

  /// No description provided for @spaceMembersPromoteAdmin.
  ///
  /// In ar, this message translates to:
  /// **'ترقية إلى مدير'**
  String get spaceMembersPromoteAdmin;

  /// No description provided for @spaceMembersDemoteMember.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الصلاحية (تخفيض لعضو)'**
  String get spaceMembersDemoteMember;

  /// No description provided for @spaceMembersKick.
  ///
  /// In ar, this message translates to:
  /// **'طرد من المساحة'**
  String get spaceMembersKick;

  /// No description provided for @spaceMembersConfirmPrompt.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد؟'**
  String get spaceMembersConfirmPrompt;

  /// No description provided for @memberSelectorTitle.
  ///
  /// In ar, this message translates to:
  /// **'إسناد المهمة إلى...'**
  String get memberSelectorTitle;

  /// No description provided for @memberSelectorEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد أعضاء في هذه المساحة'**
  String get memberSelectorEmpty;

  /// No description provided for @memberSelectorDefaultName.
  ///
  /// In ar, this message translates to:
  /// **'مستخدم'**
  String get memberSelectorDefaultName;

  /// No description provided for @memberSelectorUnassign.
  ///
  /// In ar, this message translates to:
  /// **'إعادتها للمجموعة (إلغاء الإسناد)'**
  String get memberSelectorUnassign;

  /// No description provided for @assetsPageTitle.
  ///
  /// In ar, this message translates to:
  /// **'خزينة الأصول'**
  String get assetsPageTitle;

  /// No description provided for @assetsAddButton.
  ///
  /// In ar, this message translates to:
  /// **'إضافة أصل'**
  String get assetsAddButton;

  /// No description provided for @assetsNoSearchResults.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أصول للبحث عنها'**
  String get assetsNoSearchResults;

  /// No description provided for @assetsEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'خزينتك فارغة'**
  String get assetsEmptyTitle;

  /// No description provided for @assetsEmptySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أضف فواتيرك وضماناتك لترتاح بالك'**
  String get assetsEmptySubtitle;

  /// No description provided for @assetsSearchNoMatch.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج مطابقة'**
  String get assetsSearchNoMatch;

  /// No description provided for @serviceLogsTitle.
  ///
  /// In ar, this message translates to:
  /// **'سجل: {name}'**
  String serviceLogsTitle(String name);

  /// No description provided for @serviceLogsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد سجلات سابقة'**
  String get serviceLogsEmpty;

  /// No description provided for @serviceLogsCost.
  ///
  /// In ar, this message translates to:
  /// **'{cost} ريال'**
  String serviceLogsCost(num cost);

  /// No description provided for @serviceLogsOdometer.
  ///
  /// In ar, this message translates to:
  /// **'{reading} كم'**
  String serviceLogsOdometer(num reading);

  /// No description provided for @assetStatusActive.
  ///
  /// In ar, this message translates to:
  /// **'ساري'**
  String get assetStatusActive;

  /// No description provided for @assetStatusExpiringSoon.
  ///
  /// In ar, this message translates to:
  /// **'قارب على الانتهاء'**
  String get assetStatusExpiringSoon;

  /// No description provided for @assetStatusExpired.
  ///
  /// In ar, this message translates to:
  /// **'منتهي'**
  String get assetStatusExpired;

  /// No description provided for @assetDaysRemaining.
  ///
  /// In ar, this message translates to:
  /// **'{count} يوم'**
  String assetDaysRemaining(int count);

  /// No description provided for @assetDetailsNotFound.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على الأصل'**
  String get assetDetailsNotFound;

  /// No description provided for @comingSoon.
  ///
  /// In ar, this message translates to:
  /// **'قريباً...'**
  String get comingSoon;

  /// No description provided for @assetDetailsTabOverview.
  ///
  /// In ar, this message translates to:
  /// **'نظرة عامة'**
  String get assetDetailsTabOverview;

  /// No description provided for @assetDetailsTabMaintenance.
  ///
  /// In ar, this message translates to:
  /// **'سجل الصيانة'**
  String get assetDetailsTabMaintenance;

  /// No description provided for @assetWarrantyActive.
  ///
  /// In ar, this message translates to:
  /// **'الضمان ساري'**
  String get assetWarrantyActive;

  /// No description provided for @assetWarrantyExpiringSoon.
  ///
  /// In ar, this message translates to:
  /// **'ينتهي قريباً!'**
  String get assetWarrantyExpiringSoon;

  /// No description provided for @assetWarrantyExpired.
  ///
  /// In ar, this message translates to:
  /// **'الضمان منتهي'**
  String get assetWarrantyExpired;

  /// No description provided for @assetDetailsInvoicesPhotos.
  ///
  /// In ar, this message translates to:
  /// **'الفواتير والصور'**
  String get assetDetailsInvoicesPhotos;

  /// No description provided for @assetDetailsAddPhoto.
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get assetDetailsAddPhoto;

  /// No description provided for @assetDetailsNoAttachments.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد صور للفاتورة أو الجهاز'**
  String get assetDetailsNoAttachments;

  /// No description provided for @assetDetailsInfo.
  ///
  /// In ar, this message translates to:
  /// **'التفاصيل'**
  String get assetDetailsInfo;

  /// No description provided for @assetDetailsCategory.
  ///
  /// In ar, this message translates to:
  /// **'الفئة'**
  String get assetDetailsCategory;

  /// No description provided for @assetDetailsVendor.
  ///
  /// In ar, this message translates to:
  /// **'المتجر/البائع'**
  String get assetDetailsVendor;

  /// No description provided for @assetDetailsPrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر'**
  String get assetDetailsPrice;

  /// No description provided for @assetDetailsNotes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات'**
  String get assetDetailsNotes;

  /// No description provided for @assetDetailsDefineService.
  ///
  /// In ar, this message translates to:
  /// **'تعريف خدمة جديدة'**
  String get assetDetailsDefineService;

  /// No description provided for @assetServiceStatusPending.
  ///
  /// In ar, this message translates to:
  /// **'غير محدد (بانتظار أول سجل)'**
  String get assetServiceStatusPending;

  /// No description provided for @assetServiceOverdue.
  ///
  /// In ar, this message translates to:
  /// **'متأخر بـ {days} يوم!'**
  String assetServiceOverdue(int days);

  /// No description provided for @assetServiceAtOdometer.
  ///
  /// In ar, this message translates to:
  /// **'عند عداد: {reading} كم'**
  String assetServiceAtOdometer(num reading);

  /// No description provided for @assetServiceLogButton.
  ///
  /// In ar, this message translates to:
  /// **'السجل'**
  String get assetServiceLogButton;

  /// No description provided for @assetServiceRecordButton.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل صيانة'**
  String get assetServiceRecordButton;

  /// No description provided for @assetServicesEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم تعريف أي خدمات صيانة'**
  String get assetServicesEmpty;

  /// No description provided for @assetServicesDefineExample.
  ///
  /// In ar, this message translates to:
  /// **'تعريف خدمة (مثل: غيار زيت)'**
  String get assetServicesDefineExample;

  /// No description provided for @assetDeleteTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف الأصل'**
  String get assetDeleteTitle;

  /// No description provided for @assetDeleteConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد؟ سيتم حذف جميع الفواتير والسجلات المرتبطة.'**
  String get assetDeleteConfirm;

  /// No description provided for @assetDeleteSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم الحذف'**
  String get assetDeleteSuccess;

  /// No description provided for @addAssetTitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة أصل جديد 💎'**
  String get addAssetTitle;

  /// No description provided for @addAssetNameLabel.
  ///
  /// In ar, this message translates to:
  /// **'اسم الجهاز/الأصل'**
  String get addAssetNameLabel;

  /// No description provided for @addAssetNameRequired.
  ///
  /// In ar, this message translates to:
  /// **'الاسم مطلوب'**
  String get addAssetNameRequired;

  /// No description provided for @addAssetCategoryLabel.
  ///
  /// In ar, this message translates to:
  /// **'الفئة (مثلاً: جوال)'**
  String get addAssetCategoryLabel;

  /// No description provided for @addAssetPriceLabel.
  ///
  /// In ar, this message translates to:
  /// **'السعر'**
  String get addAssetPriceLabel;

  /// No description provided for @addAssetPurchaseDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الشراء: {date}'**
  String addAssetPurchaseDate(String date);

  /// No description provided for @addAssetWarrantyLabel.
  ///
  /// In ar, this message translates to:
  /// **'مدة الضمان (بالأشهر)'**
  String get addAssetWarrantyLabel;

  /// No description provided for @addAssetWarrantyHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: 12 لسنة واحدة، 24 لسنتين'**
  String get addAssetWarrantyHint;

  /// No description provided for @addAssetShowAdvanced.
  ///
  /// In ar, this message translates to:
  /// **'إضافة تفاصيل (البائع، السيريال، ملاحظات)'**
  String get addAssetShowAdvanced;

  /// No description provided for @addAssetHideAdvanced.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء التفاصيل الإضافية'**
  String get addAssetHideAdvanced;

  /// No description provided for @addAssetVendorLabel.
  ///
  /// In ar, this message translates to:
  /// **'المتجر / البائع'**
  String get addAssetVendorLabel;

  /// No description provided for @addAssetSerialLabel.
  ///
  /// In ar, this message translates to:
  /// **'الرقم التسلسلي (S/N)'**
  String get addAssetSerialLabel;

  /// No description provided for @addAssetNotesLabel.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات إضافية'**
  String get addAssetNotesLabel;

  /// No description provided for @addAssetSaveButton.
  ///
  /// In ar, this message translates to:
  /// **'حفظ الأصل'**
  String get addAssetSaveButton;

  /// No description provided for @addAssetSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تمت إضافة الأصل بنجاح ✅'**
  String get addAssetSuccess;

  /// No description provided for @addServiceTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعريف خدمة صيانة جديدة 🛠️'**
  String get addServiceTitle;

  /// No description provided for @addServiceSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'حدد نوع الصيانة وقواعد تكرارها ليقوم النظام بتذكيرك.'**
  String get addServiceSubtitle;

  /// No description provided for @addServiceNameLabel.
  ///
  /// In ar, this message translates to:
  /// **'اسم الخدمة (مثلاً: غيار زيت)'**
  String get addServiceNameLabel;

  /// No description provided for @addServiceNameRequired.
  ///
  /// In ar, this message translates to:
  /// **'الاسم مطلوب'**
  String get addServiceNameRequired;

  /// No description provided for @addServiceRepeatLabel.
  ///
  /// In ar, this message translates to:
  /// **'تتكرر هذه الصيانة كل:'**
  String get addServiceRepeatLabel;

  /// No description provided for @addServiceDaysLabel.
  ///
  /// In ar, this message translates to:
  /// **'عدد الأيام'**
  String get addServiceDaysLabel;

  /// No description provided for @addServiceDaysSuffix.
  ///
  /// In ar, this message translates to:
  /// **'يوم'**
  String get addServiceDaysSuffix;

  /// No description provided for @addServiceKmLabel.
  ///
  /// In ar, this message translates to:
  /// **'المسافة'**
  String get addServiceKmLabel;

  /// No description provided for @addServiceKmSuffix.
  ///
  /// In ar, this message translates to:
  /// **'كم'**
  String get addServiceKmSuffix;

  /// No description provided for @addServiceRepeatHint.
  ///
  /// In ar, this message translates to:
  /// **'* يمكنك تعبئة الحقلين معاً، وسينبهك النظام أيهما يأتي أولاً.'**
  String get addServiceRepeatHint;

  /// No description provided for @addServiceRepeatRequired.
  ///
  /// In ar, this message translates to:
  /// **'يجب تحديد قاعدة تكرار واحدة على الأقل (أيام أو كم)'**
  String get addServiceRepeatRequired;

  /// No description provided for @addServiceSaveButton.
  ///
  /// In ar, this message translates to:
  /// **'حفظ الخدمة'**
  String get addServiceSaveButton;

  /// No description provided for @addServiceLogTitle.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل تنفيذ: {name} ✅'**
  String addServiceLogTitle(String name);

  /// No description provided for @addServiceLogSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'سيتم تحديث موعد الصيانة القادم تلقائياً بناءً على هذه البيانات.'**
  String get addServiceLogSubtitle;

  /// No description provided for @addServiceLogDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ التنفيذ: {date}'**
  String addServiceLogDate(String date);

  /// No description provided for @addServiceLogOdometerLabel.
  ///
  /// In ar, this message translates to:
  /// **'قراءة العداد'**
  String get addServiceLogOdometerLabel;

  /// No description provided for @addServiceLogOdometerHint.
  ///
  /// In ar, this message translates to:
  /// **'كم الحالي'**
  String get addServiceLogOdometerHint;

  /// No description provided for @addServiceLogCostLabel.
  ///
  /// In ar, this message translates to:
  /// **'التكلفة'**
  String get addServiceLogCostLabel;

  /// No description provided for @addServiceLogCostHint.
  ///
  /// In ar, this message translates to:
  /// **'اختياري'**
  String get addServiceLogCostHint;

  /// No description provided for @addServiceLogNotesLabel.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات (مثلاً: نوع الزيت)'**
  String get addServiceLogNotesLabel;

  /// No description provided for @addServiceLogSaveButton.
  ///
  /// In ar, this message translates to:
  /// **'حفظ وتحديث الموعد القادم'**
  String get addServiceLogSaveButton;

  /// No description provided for @addServiceLogSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل الصيانة وتحديث التوقعات ✅'**
  String get addServiceLogSuccess;

  /// No description provided for @prayerTimesTitle.
  ///
  /// In ar, this message translates to:
  /// **'مواقيت الصلاة'**
  String get prayerTimesTitle;

  /// No description provided for @prayerTimesSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إن الصلاة كانت على المؤمنين كتاباً موقوتاً'**
  String get prayerTimesSubtitle;

  /// No description provided for @prayerTabToday.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get prayerTabToday;

  /// No description provided for @prayerTabWeek.
  ///
  /// In ar, this message translates to:
  /// **'أسبوع'**
  String get prayerTabWeek;

  /// No description provided for @prayerTabMonth.
  ///
  /// In ar, this message translates to:
  /// **'شهر'**
  String get prayerTabMonth;

  /// No description provided for @prayerMonthComingSoon.
  ///
  /// In ar, this message translates to:
  /// **'التقويم الشهري قادم قريباً'**
  String get prayerMonthComingSoon;

  /// No description provided for @prayerFajrShort.
  ///
  /// In ar, this message translates to:
  /// **'فجر'**
  String get prayerFajrShort;

  /// No description provided for @prayerDhuhrShort.
  ///
  /// In ar, this message translates to:
  /// **'ظهر'**
  String get prayerDhuhrShort;

  /// No description provided for @prayerAsrShort.
  ///
  /// In ar, this message translates to:
  /// **'عصر'**
  String get prayerAsrShort;

  /// No description provided for @prayerMaghribShort.
  ///
  /// In ar, this message translates to:
  /// **'مغرب'**
  String get prayerMaghribShort;

  /// No description provided for @prayerIshaShort.
  ///
  /// In ar, this message translates to:
  /// **'عشاء'**
  String get prayerIshaShort;

  /// No description provided for @prayerSunrise.
  ///
  /// In ar, this message translates to:
  /// **'الشروق'**
  String get prayerSunrise;

  /// No description provided for @calendarTitle.
  ///
  /// In ar, this message translates to:
  /// **'التقويم'**
  String get calendarTitle;

  /// No description provided for @calendarDayEvents.
  ///
  /// In ar, this message translates to:
  /// **'أحداث هذا اليوم'**
  String get calendarDayEvents;

  /// No description provided for @calendarNoTasks.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مهام في هذا اليوم'**
  String get calendarNoTasks;

  /// No description provided for @weekdaySunAbbr.
  ///
  /// In ar, this message translates to:
  /// **'ح'**
  String get weekdaySunAbbr;

  /// No description provided for @weekdayMonAbbr.
  ///
  /// In ar, this message translates to:
  /// **'ن'**
  String get weekdayMonAbbr;

  /// No description provided for @weekdayTueAbbr.
  ///
  /// In ar, this message translates to:
  /// **'ث'**
  String get weekdayTueAbbr;

  /// No description provided for @weekdayWedAbbr.
  ///
  /// In ar, this message translates to:
  /// **'ر'**
  String get weekdayWedAbbr;

  /// No description provided for @weekdayThuAbbr.
  ///
  /// In ar, this message translates to:
  /// **'خ'**
  String get weekdayThuAbbr;

  /// No description provided for @weekdayFriAbbr.
  ///
  /// In ar, this message translates to:
  /// **'ج'**
  String get weekdayFriAbbr;

  /// No description provided for @weekdaySatAbbr.
  ///
  /// In ar, this message translates to:
  /// **'س'**
  String get weekdaySatAbbr;

  /// No description provided for @focusNowOn.
  ///
  /// In ar, this message translates to:
  /// **'أركز الآن على'**
  String get focusNowOn;

  /// No description provided for @focusStatusRunning.
  ///
  /// In ar, this message translates to:
  /// **'⏱ جارٍ التركيز'**
  String get focusStatusRunning;

  /// No description provided for @focusStatusPaused.
  ///
  /// In ar, this message translates to:
  /// **'⏸ متوقف مؤقتاً'**
  String get focusStatusPaused;

  /// No description provided for @focusStatusReady.
  ///
  /// In ar, this message translates to:
  /// **'جاهز للبدء'**
  String get focusStatusReady;

  /// No description provided for @focusPause.
  ///
  /// In ar, this message translates to:
  /// **'إيقاف مؤقت'**
  String get focusPause;

  /// No description provided for @focusStop.
  ///
  /// In ar, this message translates to:
  /// **'إنهاء'**
  String get focusStop;

  /// No description provided for @focusResume.
  ///
  /// In ar, this message translates to:
  /// **'استئناف'**
  String get focusResume;

  /// No description provided for @focusReset.
  ///
  /// In ar, this message translates to:
  /// **'إعادة'**
  String get focusReset;

  /// No description provided for @notificationsTitle.
  ///
  /// In ar, this message translates to:
  /// **'مركز التنبيهات'**
  String get notificationsTitle;

  /// No description provided for @notificationsClearAll.
  ///
  /// In ar, this message translates to:
  /// **'مسح الكل'**
  String get notificationsClearAll;

  /// No description provided for @notificationsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تنبيهات حالياً'**
  String get notificationsEmpty;

  /// No description provided for @statsPageTitle.
  ///
  /// In ar, this message translates to:
  /// **'لوحة الإنجاز'**
  String get statsPageTitle;

  /// No description provided for @statsFocusPerformance.
  ///
  /// In ar, this message translates to:
  /// **'أداء التركيز'**
  String get statsFocusPerformance;

  /// No description provided for @statsHabitCommitment.
  ///
  /// In ar, this message translates to:
  /// **'التزام العادات'**
  String get statsHabitCommitment;

  /// No description provided for @statsWelcome.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بك، يا بطل! 👋'**
  String get statsWelcome;

  /// No description provided for @statsMotivation.
  ///
  /// In ar, this message translates to:
  /// **'استمر في صناعة الأثر.'**
  String get statsMotivation;

  /// No description provided for @statsWeeklyFocusTitle.
  ///
  /// In ar, this message translates to:
  /// **'تركيزي هذا الأسبوع'**
  String get statsWeeklyFocusTitle;

  /// No description provided for @statsWeeklyFocusTotal.
  ///
  /// In ar, this message translates to:
  /// **'{minutes} دقيقة إجمالية'**
  String statsWeeklyFocusTotal(int minutes);

  /// No description provided for @statsMinutesAbbr.
  ///
  /// In ar, this message translates to:
  /// **'{count} د'**
  String statsMinutesAbbr(int count);

  /// No description provided for @statsRange7Days.
  ///
  /// In ar, this message translates to:
  /// **'٧ أيام'**
  String get statsRange7Days;

  /// No description provided for @statsRange30Days.
  ///
  /// In ar, this message translates to:
  /// **'٣٠ يوماً'**
  String get statsRange30Days;

  /// No description provided for @statsTodaySection.
  ///
  /// In ar, this message translates to:
  /// **'يومك اليوم'**
  String get statsTodaySection;

  /// No description provided for @statsTodayTasks.
  ///
  /// In ar, this message translates to:
  /// **'{done}/{total} مهمة'**
  String statsTodayTasks(int done, int total);

  /// No description provided for @statsTodayHabits.
  ///
  /// In ar, this message translates to:
  /// **'{done}/{total} عادة'**
  String statsTodayHabits(int done, int total);

  /// No description provided for @statsTodayFocus.
  ///
  /// In ar, this message translates to:
  /// **'{minutes} د تركيز'**
  String statsTodayFocus(int minutes);

  /// No description provided for @statsTasksSection.
  ///
  /// In ar, this message translates to:
  /// **'المهام'**
  String get statsTasksSection;

  /// No description provided for @statsCompletionRate.
  ///
  /// In ar, this message translates to:
  /// **'{pct}% مُنجز'**
  String statsCompletionRate(int pct);

  /// No description provided for @statsOverdueTasks.
  ///
  /// In ar, this message translates to:
  /// **'{count} متأخرة'**
  String statsOverdueTasks(int count);

  /// No description provided for @statsAvgDelay.
  ///
  /// In ar, this message translates to:
  /// **'متوسط التأخير {days} يوم'**
  String statsAvgDelay(int days);

  /// No description provided for @statsTasksByPriority.
  ///
  /// In ar, this message translates to:
  /// **'حسب الأولوية'**
  String get statsTasksByPriority;

  /// No description provided for @statsPriorityHigh.
  ///
  /// In ar, this message translates to:
  /// **'عالية'**
  String get statsPriorityHigh;

  /// No description provided for @statsPriorityMedium.
  ///
  /// In ar, this message translates to:
  /// **'متوسطة'**
  String get statsPriorityMedium;

  /// No description provided for @statsPriorityLow.
  ///
  /// In ar, this message translates to:
  /// **'منخفضة'**
  String get statsPriorityLow;

  /// No description provided for @statsDailyCompletion.
  ///
  /// In ar, this message translates to:
  /// **'الإنجاز اليومي'**
  String get statsDailyCompletion;

  /// No description provided for @statsHabitsSection.
  ///
  /// In ar, this message translates to:
  /// **'العادات'**
  String get statsHabitsSection;

  /// No description provided for @statsConsistency.
  ///
  /// In ar, this message translates to:
  /// **'{pct}% استمرارية'**
  String statsConsistency(int pct);

  /// No description provided for @statsTopStreaks.
  ///
  /// In ar, this message translates to:
  /// **'أفضل السلاسل'**
  String get statsTopStreaks;

  /// No description provided for @statsStreakDays.
  ///
  /// In ar, this message translates to:
  /// **'{days} يوم'**
  String statsStreakDays(int days);

  /// No description provided for @statsHeatmapTitle.
  ///
  /// In ar, this message translates to:
  /// **'خريطة العادات'**
  String get statsHeatmapTitle;

  /// No description provided for @statsFocusSection.
  ///
  /// In ar, this message translates to:
  /// **'التركيز'**
  String get statsFocusSection;

  /// No description provided for @statsFocusTotal.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي التركيز'**
  String get statsFocusTotal;

  /// No description provided for @statsFocusHours.
  ///
  /// In ar, this message translates to:
  /// **'{h}س {m}د'**
  String statsFocusHours(int h, int m);

  /// No description provided for @statsPeriodsSection.
  ///
  /// In ar, this message translates to:
  /// **'الإنتاجية حسب الوقت'**
  String get statsPeriodsSection;

  /// No description provided for @statsDomainsSection.
  ///
  /// In ar, this message translates to:
  /// **'المجالات'**
  String get statsDomainsSection;

  /// No description provided for @statsDomainNeglected.
  ///
  /// In ar, this message translates to:
  /// **'يحتاج اهتماماً'**
  String get statsDomainNeglected;

  /// No description provided for @statsDomainOverloaded.
  ///
  /// In ar, this message translates to:
  /// **'محمّل بكثير'**
  String get statsDomainOverloaded;

  /// No description provided for @statsInsightsSection.
  ///
  /// In ar, this message translates to:
  /// **'التحليلات'**
  String get statsInsightsSection;

  /// No description provided for @statsNoData.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات كافية للعرض'**
  String get statsNoData;

  /// No description provided for @statsNoDataSub.
  ///
  /// In ar, this message translates to:
  /// **'أضف مهاماً وعادات لرؤية تحليل شامل'**
  String get statsNoDataSub;

  /// No description provided for @statsUpgradeTitle.
  ///
  /// In ar, this message translates to:
  /// **'إحصائيات تفصيلية'**
  String get statsUpgradeTitle;

  /// No description provided for @statsUpgradeBody.
  ///
  /// In ar, this message translates to:
  /// **'اشترك للوصول إلى التقارير الكاملة والتحليلات المتقدمة'**
  String get statsUpgradeBody;

  /// No description provided for @statsUpgradeCta.
  ///
  /// In ar, this message translates to:
  /// **'اشترك الآن'**
  String get statsUpgradeCta;

  /// No description provided for @statsCardTitle.
  ///
  /// In ar, this message translates to:
  /// **'إحصائيات الأثر'**
  String get statsCardTitle;

  /// No description provided for @statsCardSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'شاهد ملخص أدائك وتركيزك'**
  String get statsCardSubtitle;

  /// No description provided for @reminderToggleLabel.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل التذكير'**
  String get reminderToggleLabel;

  /// No description provided for @reminderTimeLabel.
  ///
  /// In ar, this message translates to:
  /// **'وقت التذكير'**
  String get reminderTimeLabel;

  /// No description provided for @reminderChooseTime.
  ///
  /// In ar, this message translates to:
  /// **'اختر الوقت'**
  String get reminderChooseTime;

  /// No description provided for @datePickerGregorian.
  ///
  /// In ar, this message translates to:
  /// **'ميلادي'**
  String get datePickerGregorian;

  /// No description provided for @datePickerHijri.
  ///
  /// In ar, this message translates to:
  /// **'هجري'**
  String get datePickerHijri;

  /// No description provided for @datePickerCorresponding.
  ///
  /// In ar, this message translates to:
  /// **'الموافق: {date}'**
  String datePickerCorresponding(String date);

  /// No description provided for @datePickerConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد التاريخ'**
  String get datePickerConfirm;

  /// No description provided for @timelineTypeTask.
  ///
  /// In ar, this message translates to:
  /// **'مهمة'**
  String get timelineTypeTask;

  /// No description provided for @timelineTypeMedicine.
  ///
  /// In ar, this message translates to:
  /// **'دواء'**
  String get timelineTypeMedicine;

  /// No description provided for @timelineTypeAppointment.
  ///
  /// In ar, this message translates to:
  /// **'موعد'**
  String get timelineTypeAppointment;

  /// No description provided for @kanbanTodo.
  ///
  /// In ar, this message translates to:
  /// **'للقيام به'**
  String get kanbanTodo;

  /// No description provided for @kanbanInProgress.
  ///
  /// In ar, this message translates to:
  /// **'جاري العمل'**
  String get kanbanInProgress;

  /// No description provided for @kanbanDone.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل'**
  String get kanbanDone;

  /// No description provided for @kanbanDragHere.
  ///
  /// In ar, this message translates to:
  /// **'اسحب المهام هنا'**
  String get kanbanDragHere;

  /// No description provided for @appBarSettingsTooltip.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get appBarSettingsTooltip;

  /// No description provided for @appBarCalendarTooltip.
  ///
  /// In ar, this message translates to:
  /// **'التقويم'**
  String get appBarCalendarTooltip;

  /// No description provided for @appBarFocusTooltip.
  ///
  /// In ar, this message translates to:
  /// **'وضع التركيز'**
  String get appBarFocusTooltip;

  /// No description provided for @prayerCardTimePrefix.
  ///
  /// In ar, this message translates to:
  /// **'المتبقي: '**
  String get prayerCardTimePrefix;

  /// No description provided for @prayerCardDuhaTime.
  ///
  /// In ar, this message translates to:
  /// **'وقت صلاة الضحى متاح الآن'**
  String get prayerCardDuhaTime;

  /// No description provided for @prayerCardQiyamTime.
  ///
  /// In ar, this message translates to:
  /// **'وقت قيام الليل - الثلث الأخير'**
  String get prayerCardQiyamTime;

  /// No description provided for @prayerCardSetLocation.
  ///
  /// In ar, this message translates to:
  /// **'تحديد الموقع'**
  String get prayerCardSetLocation;

  /// No description provided for @prayerCardChangeLocation.
  ///
  /// In ar, this message translates to:
  /// **'تغيير الموقع'**
  String get prayerCardChangeLocation;

  /// No description provided for @taskRibbonInProgress.
  ///
  /// In ar, this message translates to:
  /// **'جاري العمل'**
  String get taskRibbonInProgress;

  /// No description provided for @taskRibbonNew.
  ///
  /// In ar, this message translates to:
  /// **'جديد'**
  String get taskRibbonNew;

  /// No description provided for @taskStatusOptions.
  ///
  /// In ar, this message translates to:
  /// **'خيارات الحالة'**
  String get taskStatusOptions;

  /// No description provided for @taskStatusWaiting.
  ///
  /// In ar, this message translates to:
  /// **'الانتظار'**
  String get taskStatusWaiting;

  /// No description provided for @taskStatusExecuting.
  ///
  /// In ar, this message translates to:
  /// **'التنفيذ'**
  String get taskStatusExecuting;

  /// No description provided for @taskStatusCompleted.
  ///
  /// In ar, this message translates to:
  /// **'مكتملة'**
  String get taskStatusCompleted;

  /// No description provided for @taskAssignToMember.
  ///
  /// In ar, this message translates to:
  /// **'إسناد لموظف'**
  String get taskAssignToMember;

  /// No description provided for @taskPickedUp.
  ///
  /// In ar, this message translates to:
  /// **'💪 كفو! المهمة صارت عندك'**
  String get taskPickedUp;

  /// No description provided for @taskPickupLabel.
  ///
  /// In ar, this message translates to:
  /// **'أنا لها'**
  String get taskPickupLabel;

  /// No description provided for @taskAssignedToYou.
  ///
  /// In ar, this message translates to:
  /// **'مسندة إليك'**
  String get taskAssignedToYou;

  /// No description provided for @taskAssignedToOther.
  ///
  /// In ar, this message translates to:
  /// **'مسندة لعضو آخر'**
  String get taskAssignedToOther;

  /// No description provided for @textFieldEmailLabel.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get textFieldEmailLabel;

  /// No description provided for @textFieldPasswordLabel.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get textFieldPasswordLabel;

  /// No description provided for @textFieldPhoneLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get textFieldPhoneLabel;

  /// No description provided for @textFieldSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'بحث...'**
  String get textFieldSearchHint;

  /// No description provided for @dialogConfirmLabel.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get dialogConfirmLabel;

  /// No description provided for @dialogCancelLabel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get dialogCancelLabel;

  /// No description provided for @dialogOkLabel.
  ///
  /// In ar, this message translates to:
  /// **'حسناً'**
  String get dialogOkLabel;

  /// No description provided for @emptyStateNoData.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات'**
  String get emptyStateNoData;

  /// No description provided for @emptyStateNoResults.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج'**
  String get emptyStateNoResults;

  /// No description provided for @emptyStateNoResultsMessage.
  ///
  /// In ar, this message translates to:
  /// **'جرب البحث بكلمات مختلفة'**
  String get emptyStateNoResultsMessage;

  /// No description provided for @emptyStateError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ'**
  String get emptyStateError;

  /// No description provided for @emptyStateErrorMessage.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير متوقع'**
  String get emptyStateErrorMessage;

  /// No description provided for @emptyStateRetry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get emptyStateRetry;

  /// No description provided for @emptyStateNoConnection.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد اتصال'**
  String get emptyStateNoConnection;

  /// No description provided for @emptyStateNoConnectionMessage.
  ///
  /// In ar, this message translates to:
  /// **'تحقق من اتصالك بالإنترنت'**
  String get emptyStateNoConnectionMessage;

  /// No description provided for @attachmentImage.
  ///
  /// In ar, this message translates to:
  /// **'صورة'**
  String get attachmentImage;

  /// No description provided for @attachmentFile.
  ///
  /// In ar, this message translates to:
  /// **'ملف (PDF/Doc)'**
  String get attachmentFile;

  /// No description provided for @fileExpiredTitle.
  ///
  /// In ar, this message translates to:
  /// **'الملف منتهي الصلاحية'**
  String get fileExpiredTitle;

  /// No description provided for @fileArchivedMessage.
  ///
  /// In ar, this message translates to:
  /// **'هذا الملف تم أرشفته سحابياً. هل تود إرسال إشعار للمالك لإعادة رفعه؟'**
  String get fileArchivedMessage;

  /// No description provided for @requestReupload.
  ///
  /// In ar, this message translates to:
  /// **'طلب إعادة الرفع'**
  String get requestReupload;

  /// No description provided for @requestSentToOwner.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال الطلب للمالك ✅'**
  String get requestSentToOwner;

  /// No description provided for @downloadingFromCloud.
  ///
  /// In ar, this message translates to:
  /// **'جاري التحميل من السحابة...'**
  String get downloadingFromCloud;

  /// No description provided for @noAttachments.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مرفقات'**
  String get noAttachments;

  /// No description provided for @logoutSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل الخروج بنجاح'**
  String get logoutSuccess;

  /// No description provided for @usernameLabel.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستخدم (Username)'**
  String get usernameLabel;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث البيانات بنجاح'**
  String get profileUpdatedSuccess;

  /// No description provided for @updateAthkarListTitle.
  ///
  /// In ar, this message translates to:
  /// **'تحديث قائمة الأذكار؟'**
  String get updateAthkarListTitle;

  /// No description provided for @updateAthkarDescription.
  ///
  /// In ar, this message translates to:
  /// **'سيقوم هذا بتحديث نصوص الأذكار إلى النسخة الأصح والأحدث، ولكنه سيعيد تعيين تقدمك في هذا القسم.'**
  String get updateAthkarDescription;

  /// No description provided for @updateAthkar.
  ///
  /// In ar, this message translates to:
  /// **'تحديث الأذكار'**
  String get updateAthkar;

  /// No description provided for @tapToCount.
  ///
  /// In ar, this message translates to:
  /// **'اضغط للتسبيح'**
  String get tapToCount;

  /// No description provided for @achievementDone.
  ///
  /// In ar, this message translates to:
  /// **'تم الإنجاز ✅'**
  String get achievementDone;

  /// No description provided for @progressPercent.
  ///
  /// In ar, this message translates to:
  /// **'{count}% مكتمل'**
  String progressPercent(Object count);

  /// No description provided for @welcomeToAthar.
  ///
  /// In ar, this message translates to:
  /// **'أهلاً بك في أثر'**
  String get welcomeToAthar;

  /// No description provided for @loginSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'سجل دخولك لتزامن مساحاتك المشتركة'**
  String get loginSubtitle;

  /// No description provided for @passwordTooShort.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور قصيرة'**
  String get passwordTooShort;

  /// No description provided for @skipContinueAsGuest.
  ///
  /// In ar, this message translates to:
  /// **'تخطي (المتابعة كضيف)'**
  String get skipContinueAsGuest;

  /// No description provided for @noAccountCreateNew.
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك حساب؟ أنشئ حساباً جديداً'**
  String get noAccountCreateNew;

  /// No description provided for @dataSyncTitle.
  ///
  /// In ar, this message translates to:
  /// **'تزامن البيانات'**
  String get dataSyncTitle;

  /// No description provided for @dataSyncConflictMessage.
  ///
  /// In ar, this message translates to:
  /// **'توجد بيانات محفوظة على جهازك وأخرى في السحابة.\nكيف تود المتابعة؟'**
  String get dataSyncConflictMessage;

  /// No description provided for @restoreCloudData.
  ///
  /// In ar, this message translates to:
  /// **'استرجاع السحابة (مسح المحلي)'**
  String get restoreCloudData;

  /// No description provided for @syncKeepLocal.
  ///
  /// In ar, this message translates to:
  /// **'اعتماد المحلي (مسح السحابة)'**
  String get syncKeepLocal;

  /// No description provided for @mergeDataBest.
  ///
  /// In ar, this message translates to:
  /// **'دمج البيانات (الأفضل)'**
  String get mergeDataBest;

  /// No description provided for @joinAtharFamily.
  ///
  /// In ar, this message translates to:
  /// **'انضم لعائلة أثر'**
  String get joinAtharFamily;

  /// No description provided for @minThreeChars.
  ///
  /// In ar, this message translates to:
  /// **'3 أحرف على الأقل'**
  String get minThreeChars;

  /// No description provided for @minSixChars.
  ///
  /// In ar, this message translates to:
  /// **'6 خانات على الأقل'**
  String get minSixChars;

  /// No description provided for @completeProfile.
  ///
  /// In ar, this message translates to:
  /// **'إكمال الملف الشخصي'**
  String get completeProfile;

  /// No description provided for @welcomeCompleteProfile.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بك! يرجى إكمال بياناتك للمتابعة'**
  String get welcomeCompleteProfile;

  /// No description provided for @saveAndContinue.
  ///
  /// In ar, this message translates to:
  /// **'حفظ ومتابعة'**
  String get saveAndContinue;

  /// No description provided for @projects.
  ///
  /// In ar, this message translates to:
  /// **'المشاريع'**
  String get projects;

  /// No description provided for @kanbanComingSoon.
  ///
  /// In ar, this message translates to:
  /// **'نظام كانبان قريباً...'**
  String get kanbanComingSoon;

  /// No description provided for @chooseIcon.
  ///
  /// In ar, this message translates to:
  /// **'اختر أيقونة'**
  String get chooseIcon;

  /// No description provided for @searchIcons.
  ///
  /// In ar, this message translates to:
  /// **'البحث في الأيقونات...'**
  String get searchIcons;

  /// No description provided for @icon.
  ///
  /// In ar, this message translates to:
  /// **'الأيقونة'**
  String get icon;

  /// No description provided for @color.
  ///
  /// In ar, this message translates to:
  /// **'اللون'**
  String get color;

  /// No description provided for @tapToChangeIcon.
  ///
  /// In ar, this message translates to:
  /// **'اضغط لتغيير الأيقونة'**
  String get tapToChangeIcon;

  /// No description provided for @skipAsGuest.
  ///
  /// In ar, this message translates to:
  /// **'تخطي (المتابعة كضيف)'**
  String get skipAsGuest;

  /// No description provided for @noAccount.
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك حساب؟'**
  String get noAccount;

  /// No description provided for @syncConflict.
  ///
  /// In ar, this message translates to:
  /// **'تزامن البيانات'**
  String get syncConflict;

  /// No description provided for @syncConflictMessage.
  ///
  /// In ar, this message translates to:
  /// **'توجد بيانات على جهازك وأخرى في السحابة. كيف تود المتابعة؟'**
  String get syncConflictMessage;

  /// No description provided for @keepLocal.
  ///
  /// In ar, this message translates to:
  /// **'الاحتفاظ بالمحلي'**
  String get keepLocal;

  /// No description provided for @keepCloud.
  ///
  /// In ar, this message translates to:
  /// **'الاحتفاظ بالسحابة'**
  String get keepCloud;

  /// No description provided for @mergeBoth.
  ///
  /// In ar, this message translates to:
  /// **'دمج البيانات (الأفضل)'**
  String get mergeBoth;

  /// No description provided for @navigationSettings.
  ///
  /// In ar, this message translates to:
  /// **'التنقل'**
  String get navigationSettings;

  /// No description provided for @hideNavOnScroll.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء شريط التنقل عند التمرير'**
  String get hideNavOnScroll;

  /// No description provided for @hideNavOnScrollDesc.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء الشريط السفلي تلقائياً عند التمرير للأسفل'**
  String get hideNavOnScrollDesc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
