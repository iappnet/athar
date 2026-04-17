import 'package:flutter/material.dart';

/// ===================================================================
/// ATHAR COLORS - Design System Color Tokens
/// ===================================================================
/// نظام الألوان الموحد لتطبيق أثر
/// يدعم Light Mode و Dark Mode
/// ===================================================================

class AtharColors extends ThemeExtension<AtharColors> {
  // ─────────────────────────────────────────────────────────────────
  // PRIMARY COLORS - الألوان الأساسية
  // ─────────────────────────────────────────────────────────────────
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color onPrimary;

  // ─────────────────────────────────────────────────────────────────
  // SECONDARY COLORS - الألوان الثانوية
  // ─────────────────────────────────────────────────────────────────
  final Color secondary;
  final Color secondaryLight;
  final Color secondaryDark;
  final Color onSecondary;

  // ─────────────────────────────────────────────────────────────────
  // BACKGROUND COLORS - ألوان الخلفية
  // ─────────────────────────────────────────────────────────────────
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerLow;
  final Color scaffoldBackground;

  // ─────────────────────────────────────────────────────────────────
  // TEXT COLORS - ألوان النصوص
  // ─────────────────────────────────────────────────────────────────
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDisabled;
  final Color textOnPrimary;
  final Color textOnSecondary;

  // ─────────────────────────────────────────────────────────────────
  // STATUS COLORS - ألوان الحالات
  // ─────────────────────────────────────────────────────────────────
  // Success
  final Color success;
  final Color successLight;
  final Color onSuccess;

  // Warning
  final Color warning;
  final Color warningLight;
  final Color onWarning;

  // Error
  final Color error;
  final Color errorLight;
  final Color onError;

  // Info
  final Color info;
  final Color infoLight;
  final Color onInfo;

  // ─────────────────────────────────────────────────────────────────
  // BORDER COLORS - ألوان الحدود
  // ─────────────────────────────────────────────────────────────────
  final Color border;
  final Color borderLight;
  final Color borderFocused;
  final Color divider;

  // ─────────────────────────────────────────────────────────────────
  // SHADOW COLORS - ألوان الظلال
  // ─────────────────────────────────────────────────────────────────
  final Color shadow;
  final Color shadowLight;

  // ─────────────────────────────────────────────────────────────────
  // SHIMMER COLORS - ألوان التحميل
  // ─────────────────────────────────────────────────────────────────
  final Color shimmerBase;
  final Color shimmerHighlight;

  // ─────────────────────────────────────────────────────────────────
  // OVERLAY COLORS - ألوان التغطية
  // ─────────────────────────────────────────────────────────────────
  final Color overlay;
  final Color overlayLight;

  // ─────────────────────────────────────────────────────────────────
  // GRADIENTS - التدرجات اللونية
  // ─────────────────────────────────────────────────────────────────
  final LinearGradient primaryGradient;
  final LinearGradient secondaryGradient;
  final LinearGradient surfaceGradient;

  // ─────────────────────────────────────────────────────────────────
  // ISLAMIC CARD GRADIENTS - تدرجات البطاقات الإسلامية
  // ثابتة دائماً (لا تتغير بين الوضع الفاتح والداكن)
  // ─────────────────────────────────────────────────────────────────

  /// تدرج بطاقة الصلاة — سماء الليل الإسلامية
  static const LinearGradient prayerCardGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// ظل بطاقة الصلاة
  static const Color prayerCardShadow = Color(0xFF0F172A);

  // ═══════════════════════════════════════════════════════════════════
  // CONSTRUCTOR
  // ═══════════════════════════════════════════════════════════════════
  const AtharColors({
    // Primary
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.onPrimary,
    // Secondary
    required this.secondary,
    required this.secondaryLight,
    required this.secondaryDark,
    required this.onSecondary,
    // Background
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerLow,
    required this.scaffoldBackground,
    // Text
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.textOnPrimary,
    required this.textOnSecondary,
    // Status - Success
    required this.success,
    required this.successLight,
    required this.onSuccess,
    // Status - Warning
    required this.warning,
    required this.warningLight,
    required this.onWarning,
    // Status - Error
    required this.error,
    required this.errorLight,
    required this.onError,
    // Status - Info
    required this.info,
    required this.infoLight,
    required this.onInfo,
    // Border
    required this.border,
    required this.borderLight,
    required this.borderFocused,
    required this.divider,
    // Shadow
    required this.shadow,
    required this.shadowLight,
    // Shimmer
    required this.shimmerBase,
    required this.shimmerHighlight,
    // Overlay
    required this.overlay,
    required this.overlayLight,
    // Gradients
    required this.primaryGradient,
    required this.secondaryGradient,
    required this.surfaceGradient,
  });

  // ═══════════════════════════════════════════════════════════════════
  // LIGHT THEME - الوضع الفاتح
  // ═══════════════════════════════════════════════════════════════════
  static const AtharColors light = AtharColors(
    // Primary
    primary: Color(0xFF6C63FF),
    primaryLight: Color(0xFF9D97FF),
    primaryDark: Color(0xFF4A42DB),
    onPrimary: Color(0xFFFFFFFF),

    // Secondary
    secondary: Color(0xFF03DAC6),
    secondaryLight: Color(0xFF66FFF8),
    secondaryDark: Color(0xFF00A896),
    onSecondary: Color(0xFF000000),

    // Background
    background: Color(0xFFF8F9FA),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFF5F5F5),
    surfaceContainer: Color(0xFFEEEEEE),
    surfaceContainerHigh: Color(0xFFE0E0E0),
    surfaceContainerLow: Color(0xFFFAFAFA),
    scaffoldBackground: Color(0xFFF8F9FA),

    // Text
    textPrimary: Color(0xFF2D3436),
    textSecondary: Color(0xFF636E72),
    textTertiary: Color(0xFF95A5A6),
    textDisabled: Color(0xFFBDC3C7),
    textOnPrimary: Color(0xFFFFFFFF),
    textOnSecondary: Color(0xFF000000),

    // Status - Success
    success: Color(0xFF00B894),
    successLight: Color(0xFFE8F8F5),
    onSuccess: Color(0xFFFFFFFF),

    // Status - Warning
    warning: Color(0xFFFDCB6E),
    warningLight: Color(0xFFFEF9E7),
    onWarning: Color(0xFF000000),

    // Status - Error
    error: Color(0xFFFF7675),
    errorLight: Color(0xFFFDEDED),
    onError: Color(0xFFFFFFFF),

    // Status - Info
    info: Color(0xFF74B9FF),
    infoLight: Color(0xFFEBF5FB),
    onInfo: Color(0xFFFFFFFF),

    // Border
    border: Color(0xFFDFE6E9),
    borderLight: Color(0xFFECF0F1),
    borderFocused: Color(0xFF6C63FF),
    divider: Color(0xFFECF0F1),

    // Shadow
    shadow: Color(0x1A000000),
    shadowLight: Color(0x0D000000),

    // Shimmer
    shimmerBase: Color(0xFFE0E0E0),
    shimmerHighlight: Color(0xFFF5F5F5),

    // Overlay
    overlay: Color(0x80000000),
    overlayLight: Color(0x40000000),

    // Gradients
    primaryGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF6C63FF), Color(0xFF4A42DB)],
    ),
    secondaryGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF03DAC6), Color(0xFF00A896)],
    ),
    surfaceGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FA)],
    ),
  );

  // ═══════════════════════════════════════════════════════════════════
  // DARK THEME - الوضع الداكن
  // ═══════════════════════════════════════════════════════════════════
  static const AtharColors dark = AtharColors(
    // Primary
    primary: Color(0xFF8B85FF),
    primaryLight: Color(0xFFB8B4FF),
    primaryDark: Color(0xFF6C63FF),
    onPrimary: Color(0xFF000000),

    // Secondary
    secondary: Color(0xFF03DAC6),
    secondaryLight: Color(0xFF66FFF8),
    secondaryDark: Color(0xFF00A896),
    onSecondary: Color(0xFF000000),

    // Background
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    surfaceVariant: Color(0xFF2D2D2D),
    surfaceContainer: Color(0xFF252525),
    surfaceContainerHigh: Color(0xFF353535),
    surfaceContainerLow: Color(0xFF1A1A1A),
    scaffoldBackground: Color(0xFF121212),

    // Text
    textPrimary: Color(0xFFE4E4E4),
    textSecondary: Color(0xFFB0B0B0),
    textTertiary: Color(0xFF808080),
    textDisabled: Color(0xFF5C5C5C),
    textOnPrimary: Color(0xFF000000),
    textOnSecondary: Color(0xFF000000),

    // Status - Success
    success: Color(0xFF00D9A5),
    successLight: Color(0xFF1A3D34),
    onSuccess: Color(0xFF000000),

    // Status - Warning
    warning: Color(0xFFFFD93D),
    warningLight: Color(0xFF3D3A1A),
    onWarning: Color(0xFF000000),

    // Status - Error
    error: Color(0xFFFF8A80),
    errorLight: Color(0xFF3D1A1A),
    onError: Color(0xFF000000),

    // Status - Info
    info: Color(0xFF82B1FF),
    infoLight: Color(0xFF1A2D3D),
    onInfo: Color(0xFF000000),

    // Border
    border: Color(0xFF404040),
    borderLight: Color(0xFF333333),
    borderFocused: Color(0xFF8B85FF),
    divider: Color(0xFF333333),

    // Shadow
    shadow: Color(0x40000000),
    shadowLight: Color(0x20000000),

    // Shimmer
    shimmerBase: Color(0xFF2D2D2D),
    shimmerHighlight: Color(0xFF404040),

    // Overlay
    overlay: Color(0xCC000000),
    overlayLight: Color(0x80000000),

    // Gradients
    primaryGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF8B85FF), Color(0xFF6C63FF)],
    ),
    secondaryGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF03DAC6), Color(0xFF00A896)],
    ),
    surfaceGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF1E1E1E), Color(0xFF121212)],
    ),
  );

  // ═══════════════════════════════════════════════════════════════════
  // COPY WITH - نسخ مع تعديل
  // ═══════════════════════════════════════════════════════════════════
  @override
  AtharColors copyWith({
    // Primary
    Color? primary,
    Color? primaryLight,
    Color? primaryDark,
    Color? onPrimary,
    // Secondary
    Color? secondary,
    Color? secondaryLight,
    Color? secondaryDark,
    Color? onSecondary,
    // Background
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? surfaceContainer,
    Color? surfaceContainerHigh,
    Color? surfaceContainerLow,
    Color? scaffoldBackground,
    // Text
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textDisabled,
    Color? textOnPrimary,
    Color? textOnSecondary,
    // Status - Success
    Color? success,
    Color? successLight,
    Color? onSuccess,
    // Status - Warning
    Color? warning,
    Color? warningLight,
    Color? onWarning,
    // Status - Error
    Color? error,
    Color? errorLight,
    Color? onError,
    // Status - Info
    Color? info,
    Color? infoLight,
    Color? onInfo,
    // Border
    Color? border,
    Color? borderLight,
    Color? borderFocused,
    Color? divider,
    // Shadow
    Color? shadow,
    Color? shadowLight,
    // Shimmer
    Color? shimmerBase,
    Color? shimmerHighlight,
    // Overlay
    Color? overlay,
    Color? overlayLight,
    // Gradients
    LinearGradient? primaryGradient,
    LinearGradient? secondaryGradient,
    LinearGradient? surfaceGradient,
  }) {
    return AtharColors(
      // Primary
      primary: primary ?? this.primary,
      primaryLight: primaryLight ?? this.primaryLight,
      primaryDark: primaryDark ?? this.primaryDark,
      onPrimary: onPrimary ?? this.onPrimary,
      // Secondary
      secondary: secondary ?? this.secondary,
      secondaryLight: secondaryLight ?? this.secondaryLight,
      secondaryDark: secondaryDark ?? this.secondaryDark,
      onSecondary: onSecondary ?? this.onSecondary,
      // Background
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh ?? this.surfaceContainerHigh,
      surfaceContainerLow: surfaceContainerLow ?? this.surfaceContainerLow,
      scaffoldBackground: scaffoldBackground ?? this.scaffoldBackground,
      // Text
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textDisabled: textDisabled ?? this.textDisabled,
      textOnPrimary: textOnPrimary ?? this.textOnPrimary,
      textOnSecondary: textOnSecondary ?? this.textOnSecondary,
      // Status - Success
      success: success ?? this.success,
      successLight: successLight ?? this.successLight,
      onSuccess: onSuccess ?? this.onSuccess,
      // Status - Warning
      warning: warning ?? this.warning,
      warningLight: warningLight ?? this.warningLight,
      onWarning: onWarning ?? this.onWarning,
      // Status - Error
      error: error ?? this.error,
      errorLight: errorLight ?? this.errorLight,
      onError: onError ?? this.onError,
      // Status - Info
      info: info ?? this.info,
      infoLight: infoLight ?? this.infoLight,
      onInfo: onInfo ?? this.onInfo,
      // Border
      border: border ?? this.border,
      borderLight: borderLight ?? this.borderLight,
      borderFocused: borderFocused ?? this.borderFocused,
      divider: divider ?? this.divider,
      // Shadow
      shadow: shadow ?? this.shadow,
      shadowLight: shadowLight ?? this.shadowLight,
      // Shimmer
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
      // Overlay
      overlay: overlay ?? this.overlay,
      overlayLight: overlayLight ?? this.overlayLight,
      // Gradients
      primaryGradient: primaryGradient ?? this.primaryGradient,
      secondaryGradient: secondaryGradient ?? this.secondaryGradient,
      surfaceGradient: surfaceGradient ?? this.surfaceGradient,
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // LERP - للانتقال السلس بين الثيمات
  // ═══════════════════════════════════════════════════════════════════
  @override
  AtharColors lerp(ThemeExtension<AtharColors>? other, double t) {
    if (other is! AtharColors) {
      return this;
    }
    return AtharColors(
      // Primary
      primary: Color.lerp(primary, other.primary, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      // Secondary
      secondary: Color.lerp(secondary, other.secondary, t)!,
      secondaryLight: Color.lerp(secondaryLight, other.secondaryLight, t)!,
      secondaryDark: Color.lerp(secondaryDark, other.secondaryDark, t)!,
      onSecondary: Color.lerp(onSecondary, other.onSecondary, t)!,
      // Background
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      surfaceContainer: Color.lerp(
        surfaceContainer,
        other.surfaceContainer,
        t,
      )!,
      surfaceContainerHigh: Color.lerp(
        surfaceContainerHigh,
        other.surfaceContainerHigh,
        t,
      )!,
      surfaceContainerLow: Color.lerp(
        surfaceContainerLow,
        other.surfaceContainerLow,
        t,
      )!,
      scaffoldBackground: Color.lerp(
        scaffoldBackground,
        other.scaffoldBackground,
        t,
      )!,
      // Text
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      textOnPrimary: Color.lerp(textOnPrimary, other.textOnPrimary, t)!,
      textOnSecondary: Color.lerp(textOnSecondary, other.textOnSecondary, t)!,
      // Status - Success
      success: Color.lerp(success, other.success, t)!,
      successLight: Color.lerp(successLight, other.successLight, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      // Status - Warning
      warning: Color.lerp(warning, other.warning, t)!,
      warningLight: Color.lerp(warningLight, other.warningLight, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      // Status - Error
      error: Color.lerp(error, other.error, t)!,
      errorLight: Color.lerp(errorLight, other.errorLight, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
      // Status - Info
      info: Color.lerp(info, other.info, t)!,
      infoLight: Color.lerp(infoLight, other.infoLight, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      // Border
      border: Color.lerp(border, other.border, t)!,
      borderLight: Color.lerp(borderLight, other.borderLight, t)!,
      borderFocused: Color.lerp(borderFocused, other.borderFocused, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      // Shadow
      shadow: Color.lerp(shadow, other.shadow, t)!,
      shadowLight: Color.lerp(shadowLight, other.shadowLight, t)!,
      // Shimmer
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight: Color.lerp(
        shimmerHighlight,
        other.shimmerHighlight,
        t,
      )!,
      // Overlay
      overlay: Color.lerp(overlay, other.overlay, t)!,
      overlayLight: Color.lerp(overlayLight, other.overlayLight, t)!,
      // Gradients - لا يمكن عمل lerp للـ gradients بشكل مباشر
      primaryGradient: t < 0.5 ? primaryGradient : other.primaryGradient,
      secondaryGradient: t < 0.5 ? secondaryGradient : other.secondaryGradient,
      surfaceGradient: t < 0.5 ? surfaceGradient : other.surfaceGradient,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// EXTENSION - للوصول السهل من أي مكان
// ═══════════════════════════════════════════════════════════════════════

/// Extension للوصول السهل للألوان من BuildContext
///
/// مثال الاستخدام:
/// ```dart
/// Container(
///   color: context.colors.primary,
///   child: Text(
///     'مرحباً',
///     style: TextStyle(color: context.colors.textPrimary),
///   ),
/// )
/// ```
extension AtharColorsExtension on BuildContext {
  /// الوصول لألوان أثر
  AtharColors get colors {
    final extension = Theme.of(this).extension<AtharColors>();
    // إرجاع Light theme كـ fallback إذا لم يتم تعيين الألوان
    return extension ?? AtharColors.light;
  }
}
