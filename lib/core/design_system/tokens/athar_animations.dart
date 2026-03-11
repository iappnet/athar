import 'package:flutter/material.dart';

/// ===================================================================
/// ATHAR ANIMATIONS - Design System Animation Tokens
/// ===================================================================
/// نظام الحركات والانتقالات الموحد لتطبيق أثر
/// يُستخدم للـ Duration و Curve
/// ===================================================================

/// قيم الحركات والانتقالات الثابتة
///
/// مثال الاستخدام:
/// ```dart
/// AnimatedContainer(
///   duration: AtharAnimations.normal,
///   curve: AtharAnimations.defaultCurve,
///   // ...
/// )
/// ```
abstract class AtharAnimations {
  // ─────────────────────────────────────────────────────────────────
  // DURATIONS - المدد الزمنية
  // ─────────────────────────────────────────────────────────────────

  /// 50ms - فوري تقريباً
  static const Duration instant = Duration(milliseconds: 50);

  /// 100ms - سريع جداً (micro interactions)
  static const Duration fastest = Duration(milliseconds: 100);

  /// 150ms - سريع (hover, focus)
  static const Duration fast = Duration(milliseconds: 150);

  /// 200ms - عادي سريع
  static const Duration normalFast = Duration(milliseconds: 200);

  /// 250ms - عادي (الافتراضي)
  static const Duration normal = Duration(milliseconds: 250);

  /// 300ms - عادي بطيء
  static const Duration normalSlow = Duration(milliseconds: 300);

  /// 350ms - بطيء
  static const Duration slow = Duration(milliseconds: 350);

  /// 400ms - بطيء قليلاً
  static const Duration slower = Duration(milliseconds: 400);

  /// 500ms - بطيء جداً
  static const Duration slowest = Duration(milliseconds: 500);

  /// 700ms - للانتقالات الكبيرة
  static const Duration extended = Duration(milliseconds: 700);

  /// 1000ms - للانتقالات الطويلة
  static const Duration long = Duration(milliseconds: 1000);

  // ─────────────────────────────────────────────────────────────────
  // CURVES - منحنيات الحركة
  // ─────────────────────────────────────────────────────────────────

  /// المنحنى الافتراضي - سلس
  static const Curve defaultCurve = Curves.easeInOut;

  /// للدخول - يبدأ بطيء وينتهي سريع
  static const Curve enter = Curves.easeOut;

  /// للخروج - يبدأ سريع وينتهي بطيء
  static const Curve exit = Curves.easeIn;

  /// للارتداد - يرتد في النهاية
  static const Curve bounce = Curves.bounceOut;

  /// مرن - يتجاوز ثم يعود
  static const Curve elastic = Curves.elasticOut;

  /// سلس جداً - الأكثر طبيعية
  static const Curve smooth = Curves.fastOutSlowIn;

  /// خطي - سرعة ثابتة
  static const Curve linear = Curves.linear;

  /// تسارع - يبدأ بطيء
  static const Curve accelerate = Curves.easeIn;

  /// تباطؤ - ينتهي بطيء
  static const Curve decelerate = Curves.easeOut;

  /// تسارع حاد
  static const Curve accelerateFast = Curves.easeInCubic;

  /// تباطؤ حاد
  static const Curve decelerateFast = Curves.easeOutCubic;

  /// تأخير ثم سرعة
  static const Curve anticipate = Curves.easeInBack;

  /// سرعة ثم ارتداد
  static const Curve overshoot = Curves.easeOutBack;

  // ─────────────────────────────────────────────────────────────────
  // USE CASE ANIMATIONS - حركات حسب الاستخدام
  // ─────────────────────────────────────────────────────────────────

  // === Theme ===

  /// لتغيير الثيم
  static const Duration themeDuration = slow;
  static const Curve themeCurve = defaultCurve;

  // === Buttons ===

  /// للأزرار (hover, press)
  static const Duration buttonDuration = fast;
  static const Curve buttonCurve = defaultCurve;

  /// للأزرار - ripple effect
  static const Duration buttonRippleDuration = normalFast;

  // === Cards ===

  /// للبطاقات (expand, collapse)
  static const Duration cardDuration = normal;
  static const Curve cardCurve = smooth;

  /// للبطاقات عند الضغط
  static const Duration cardPressDuration = fastest;
  static const Curve cardPressCurve = decelerate;

  // === Pages ===

  /// للصفحات (navigation)
  static const Duration pageDuration = normalSlow;
  static const Curve pageCurve = smooth;

  /// للصفحات - fade
  static const Duration pageFadeDuration = normalFast;

  // === Modals ===

  /// للـ Bottom Sheet
  static const Duration bottomSheetDuration = normal;
  static const Curve bottomSheetCurve = decelerate;

  /// للـ Dialog
  static const Duration dialogDuration = normalFast;
  static const Curve dialogCurve = decelerate;

  /// للـ Modal - scale
  static const Duration modalScaleDuration = normalFast;
  static const Curve modalScaleCurve = overshoot;

  // === Feedback ===

  /// للـ Snackbar
  static const Duration snackbarDuration = fast;
  static const Curve snackbarCurve = decelerate;

  /// للـ Toast
  static const Duration toastDuration = fast;
  static const Curve toastCurve = decelerate;

  /// للـ Tooltip
  static const Duration tooltipDuration = fast;
  static const Curve tooltipCurve = decelerate;

  // === Lists ===

  /// للقوائم - stagger delay بين العناصر
  static const Duration listStaggerDelay = Duration(milliseconds: 50);

  /// للقوائم - مدة ظهور كل عنصر
  static const Duration listItemDuration = normal;
  static const Curve listItemCurve = decelerate;

  // === Forms ===

  /// لحقول الإدخال
  static const Duration inputDuration = fast;
  static const Curve inputCurve = defaultCurve;

  /// للتحقق من الصحة
  static const Duration validationDuration = fastest;

  // === Loading ===

  /// للـ Shimmer
  static const Duration shimmerDuration = Duration(milliseconds: 1500);

  /// للـ Loading spinner
  static const Duration spinnerDuration = Duration(milliseconds: 1200);

  /// للـ Progress
  static const Duration progressDuration = slow;
  static const Curve progressCurve = defaultCurve;

  // === Icons ===

  /// لتحويل الأيقونات
  static const Duration iconDuration = normalFast;
  static const Curve iconCurve = defaultCurve;

  /// لتدوير الأيقونات
  static const Duration iconRotateDuration = normal;
  static const Curve iconRotateCurve = smooth;

  // === Tabs ===

  /// للتبويبات
  static const Duration tabDuration = normal;
  static const Curve tabCurve = defaultCurve;

  // === Drawer ===

  /// للـ Drawer
  static const Duration drawerDuration = normalSlow;
  static const Curve drawerCurve = decelerate;

  // === FAB ===

  /// للـ FAB
  static const Duration fabDuration = normalFast;
  static const Curve fabCurve = overshoot;

  // ─────────────────────────────────────────────────────────────────
  // VISIBILITY DURATIONS - مدد الظهور
  // ─────────────────────────────────────────────────────────────────

  /// مدة إظهار الـ Snackbar
  static const Duration snackbarVisible = Duration(seconds: 4);

  /// مدة إظهار الـ Snackbar القصير
  static const Duration snackbarVisibleShort = Duration(seconds: 2);

  /// مدة إظهار الـ Snackbar الطويل
  static const Duration snackbarVisibleLong = Duration(seconds: 6);

  /// مدة إظهار الـ Toast
  static const Duration toastVisible = Duration(seconds: 3);

  /// مدة إظهار الـ Tooltip
  static const Duration tooltipVisible = Duration(seconds: 2);

  /// مدة إظهار رسالة النجاح
  static const Duration successVisible = Duration(seconds: 3);

  /// مدة إظهار رسالة الخطأ
  static const Duration errorVisible = Duration(seconds: 5);

  // ─────────────────────────────────────────────────────────────────
  // DELAY DURATIONS - مدد التأخير
  // ─────────────────────────────────────────────────────────────────

  /// تأخير قبل إظهار الـ Tooltip
  static const Duration tooltipDelay = Duration(milliseconds: 500);

  /// تأخير قبل البحث (debounce)
  static const Duration searchDebounce = Duration(milliseconds: 300);

  /// تأخير قبل التحقق من الصحة
  static const Duration validationDebounce = Duration(milliseconds: 500);

  /// تأخير splash screen
  static const Duration splashDelay = Duration(seconds: 2);

  // ─────────────────────────────────────────────────────────────────
  // HELPER METHODS - دوال مساعدة
  // ─────────────────────────────────────────────────────────────────

  /// الحصول على تأخير للـ stagger animation
  ///
  /// مثال:
  /// ```dart
  /// for (int i = 0; i < items.length; i++) {
  ///   await Future.delayed(AtharAnimations.staggerDelay(i));
  ///   // animate item
  /// }
  /// ```
  static Duration staggerDelay(int index, {Duration delay = listStaggerDelay}) {
    return delay * index;
  }

  /// إنشاء AnimationController بالإعدادات الافتراضية
  ///
  /// ملاحظة: يجب استدعاء dispose() على الـ controller
  static AnimationController createController(
    TickerProvider vsync, {
    Duration duration = normal,
  }) {
    return AnimationController(duration: duration, vsync: vsync);
  }

  /// إنشاء CurvedAnimation
  static CurvedAnimation createCurvedAnimation(
    Animation<double> parent, {
    Curve curve = defaultCurve,
    Curve? reverseCurve,
  }) {
    return CurvedAnimation(
      parent: parent,
      curve: curve,
      reverseCurve: reverseCurve,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// TWEEN HELPERS - مساعدات الـ Tween
// ═══════════════════════════════════════════════════════════════════════

/// Tweens مسبقة التعريف
class AtharTweens {
  AtharTweens._();

  /// Fade in - من شفاف إلى مرئي
  static final Tween<double> fadeIn = Tween<double>(begin: 0.0, end: 1.0);

  /// Fade out - من مرئي إلى شفاف
  static final Tween<double> fadeOut = Tween<double>(begin: 1.0, end: 0.0);

  /// Scale up - من صغير إلى كبير
  static final Tween<double> scaleUp = Tween<double>(begin: 0.0, end: 1.0);

  /// Scale down - من كبير إلى صغير
  static final Tween<double> scaleDown = Tween<double>(begin: 1.0, end: 0.0);

  /// Scale slight - تكبير طفيف
  static final Tween<double> scaleSlight = Tween<double>(begin: 0.95, end: 1.0);

  /// Scale press - تصغير عند الضغط
  static final Tween<double> scalePress = Tween<double>(begin: 1.0, end: 0.95);

  /// Slide up - من الأسفل
  static final Tween<Offset> slideUp = Tween<Offset>(
    begin: const Offset(0, 1),
    end: Offset.zero,
  );

  /// Slide down - من الأعلى
  static final Tween<Offset> slideDown = Tween<Offset>(
    begin: const Offset(0, -1),
    end: Offset.zero,
  );

  /// Slide left - من اليمين
  static final Tween<Offset> slideLeft = Tween<Offset>(
    begin: const Offset(1, 0),
    end: Offset.zero,
  );

  /// Slide right - من اليسار
  static final Tween<Offset> slideRight = Tween<Offset>(
    begin: const Offset(-1, 0),
    end: Offset.zero,
  );

  /// Slide slight up - انزلاق طفيف للأعلى
  static final Tween<Offset> slideSlightUp = Tween<Offset>(
    begin: const Offset(0, 0.1),
    end: Offset.zero,
  );

  /// Rotate full - دورة كاملة
  static final Tween<double> rotateFull = Tween<double>(begin: 0, end: 1);

  /// Rotate half - نصف دورة
  static final Tween<double> rotateHalf = Tween<double>(begin: 0, end: 0.5);

  /// Rotate quarter - ربع دورة
  static final Tween<double> rotateQuarter = Tween<double>(begin: 0, end: 0.25);
}

// ═══════════════════════════════════════════════════════════════════════
// EXTENSION - للاستخدام مع BuildContext
// ═══════════════════════════════════════════════════════════════════════

/// Extension للوصول السهل للحركات
extension AtharAnimationsExtension on BuildContext {
  /// الوصول للحركات
  AtharAnimationsHelper get animations => const AtharAnimationsHelper();
}

/// Helper class للوصول للحركات
///
/// ملاحظة: هذا الـ class عام (public) لأنه يُستخدم في public API
class AtharAnimationsHelper {
  const AtharAnimationsHelper();

  // Durations
  Duration get fastest => AtharAnimations.fastest;
  Duration get fast => AtharAnimations.fast;
  Duration get normal => AtharAnimations.normal;
  Duration get slow => AtharAnimations.slow;
  Duration get slower => AtharAnimations.slower;
  Duration get slowest => AtharAnimations.slowest;

  // Curves
  Curve get defaultCurve => AtharAnimations.defaultCurve;
  Curve get enter => AtharAnimations.enter;
  Curve get exit => AtharAnimations.exit;
  Curve get bounce => AtharAnimations.bounce;
  Curve get smooth => AtharAnimations.smooth;

  // Use cases
  Duration get buttonDuration => AtharAnimations.buttonDuration;
  Duration get cardDuration => AtharAnimations.cardDuration;
  Duration get pageDuration => AtharAnimations.pageDuration;
  Duration get dialogDuration => AtharAnimations.dialogDuration;
  Duration get snackbarVisible => AtharAnimations.snackbarVisible;
}
