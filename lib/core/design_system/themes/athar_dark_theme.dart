import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_system.dart';

/// ===================================================================
/// ATHAR DARK THEME - الثيم الداكن
/// ===================================================================
/// ثيم الوضع الداكن الكامل لتطبيق أثر
/// ===================================================================

class AtharDarkTheme {
  AtharDarkTheme._();

  /// ألوان الوضع الداكن
  static const AtharColors colors = AtharColors.dark;

  /// الثيم الداكن الكامل
  static ThemeData get theme {
    return ThemeData(
      // ─────────────────────────────────────────────────────────────
      // GENERAL
      // ─────────────────────────────────────────────────────────────
      useMaterial3: true,
      brightness: Brightness.dark,

      // ─────────────────────────────────────────────────────────────
      // COLORS
      // ─────────────────────────────────────────────────────────────
      primaryColor: colors.primary,
      primaryColorLight: colors.primaryLight,
      primaryColorDark: colors.primaryDark,
      scaffoldBackgroundColor: colors.scaffoldBackground,
      canvasColor: colors.surface,
      cardColor: colors.surface,
      dividerColor: colors.divider,
      focusColor: colors.primary.withValues(alpha: 0.12),
      hoverColor: colors.primary.withValues(alpha: 0.08),
      highlightColor: colors.primary.withValues(alpha: 0.12),
      splashColor: colors.primary.withValues(alpha: 0.12),
      shadowColor: colors.shadow,

      // ─────────────────────────────────────────────────────────────
      // COLOR SCHEME
      // ─────────────────────────────────────────────────────────────
      colorScheme: ColorScheme.dark(
        primary: colors.primary,
        onPrimary: colors.onPrimary,
        primaryContainer: colors.primaryDark,
        onPrimaryContainer: colors.primaryLight,
        secondary: colors.secondary,
        onSecondary: colors.onSecondary,
        secondaryContainer: colors.secondaryDark,
        onSecondaryContainer: colors.secondaryLight,
        tertiary: colors.info,
        onTertiary: colors.onInfo,
        error: colors.error,
        onError: colors.onError,
        errorContainer: colors.errorLight,
        surface: colors.surface,
        onSurface: colors.textPrimary,
        surfaceContainerHighest: colors.surfaceVariant,
        onSurfaceVariant: colors.textSecondary,
        outline: colors.border,
        outlineVariant: colors.borderLight,
        shadow: colors.shadow,
        scrim: colors.overlay,
        inverseSurface: const Color(0xFFE4E4E4),
        onInverseSurface: const Color(0xFF121212),
        inversePrimary: colors.primaryDark,
      ),

      // ─────────────────────────────────────────────────────────────
      // EXTENSIONS
      // ─────────────────────────────────────────────────────────────
      extensions: const <ThemeExtension<dynamic>>[AtharColors.dark],

      // ─────────────────────────────────────────────────────────────
      // TYPOGRAPHY
      // ─────────────────────────────────────────────────────────────
      fontFamily: AtharTypography.fontFamilyAr,
      textTheme: _buildTextTheme(colors),

      // ─────────────────────────────────────────────────────────────
      // APP BAR
      // ─────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
        surfaceTintColor: Colors.transparent,
        shadowColor: colors.shadow,
        iconTheme: IconThemeData(color: colors.textPrimary, size: 24),
        actionsIconTheme: IconThemeData(color: colors.textPrimary, size: 24),
        titleTextStyle: AtharTypography.appBarTitle.copyWith(
          color: colors.textPrimary,
          fontFamily: AtharTypography.fontFamilyAr,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: colors.surface,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),

      // ─────────────────────────────────────────────────────────────
      // BOTTOM NAVIGATION BAR
      // ─────────────────────────────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        backgroundColor: colors.surface,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.textTertiary,
        selectedIconTheme: IconThemeData(color: colors.primary, size: 24),
        unselectedIconTheme: IconThemeData(
          color: colors.textTertiary,
          size: 24,
        ),
        selectedLabelStyle: AtharTypography.labelSmall.copyWith(
          color: colors.primary,
          fontFamily: AtharTypography.fontFamilyAr,
        ),
        unselectedLabelStyle: AtharTypography.labelSmall.copyWith(
          color: colors.textTertiary,
          fontFamily: AtharTypography.fontFamilyAr,
        ),
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),

      // ─────────────────────────────────────────────────────────────
      // NAVIGATION BAR (Material 3)
      // ─────────────────────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colors.primaryDark.withValues(alpha: 0.3),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colors.primary, size: 24);
          }
          return IconThemeData(color: colors.textTertiary, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AtharTypography.labelSmall.copyWith(
              color: colors.primary,
              fontFamily: AtharTypography.fontFamilyAr,
            );
          }
          return AtharTypography.labelSmall.copyWith(
            color: colors.textTertiary,
            fontFamily: AtharTypography.fontFamilyAr,
          );
        }),
      ),

      // ─────────────────────────────────────────────────────────────
      // CARD
      // ─────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: 0,
        color: colors.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: colors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: AtharRadii.card,
          side: BorderSide(color: colors.borderLight),
        ),
        margin: AtharSpacing.allSm,
      ),

      // ─────────────────────────────────────────────────────────────
      // ELEVATED BUTTON
      // ─────────────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          disabledBackgroundColor: colors.surfaceContainer,
          disabledForegroundColor: colors.textDisabled,
          shadowColor: colors.shadow,
          padding: AtharSpacing.button,
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(borderRadius: AtharRadii.button),
          textStyle: AtharTypography.button.copyWith(
            fontFamily: AtharTypography.fontFamilyAr,
          ),
        ),
      ),

      // ─────────────────────────────────────────────────────────────
      // FILLED BUTTON
      // ─────────────────────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          disabledBackgroundColor: colors.surfaceContainer,
          disabledForegroundColor: colors.textDisabled,
          padding: AtharSpacing.button,
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(borderRadius: AtharRadii.button),
          textStyle: AtharTypography.button.copyWith(
            fontFamily: AtharTypography.fontFamilyAr,
          ),
        ),
      ),

      // ─────────────────────────────────────────────────────────────
      // OUTLINED BUTTON
      // ─────────────────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          disabledForegroundColor: colors.textDisabled,
          padding: AtharSpacing.button,
          minimumSize: const Size(64, 48),
          side: BorderSide(color: colors.primary),
          shape: RoundedRectangleBorder(borderRadius: AtharRadii.button),
          textStyle: AtharTypography.button.copyWith(
            fontFamily: AtharTypography.fontFamilyAr,
          ),
        ),
      ),

      // ─────────────────────────────────────────────────────────────
      // TEXT BUTTON
      // ─────────────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          disabledForegroundColor: colors.textDisabled,
          padding: AtharSpacing.buttonSmall,
          minimumSize: const Size(64, 40),
          shape: RoundedRectangleBorder(borderRadius: AtharRadii.button),
          textStyle: AtharTypography.button.copyWith(
            fontFamily: AtharTypography.fontFamilyAr,
          ),
        ),
      ),

      // ─────────────────────────────────────────────────────────────
      // ICON BUTTON
      // ─────────────────────────────────────────────────────────────
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: colors.textPrimary,
          disabledForegroundColor: colors.textDisabled,
          highlightColor: colors.primary.withValues(alpha: 0.12),
          minimumSize: const Size(48, 48),
          padding: AtharSpacing.allSm,
          shape: RoundedRectangleBorder(borderRadius: AtharRadii.radiusFull),
        ),
      ),

      // ─────────────────────────────────────────────────────────────
      // FLOATING ACTION BUTTON
      // ─────────────────────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        focusElevation: 6,
        hoverElevation: 8,
        highlightElevation: 6,
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        splashColor: colors.onPrimary.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(borderRadius: AtharRadii.fab),
      ),

      // ─────────────────────────────────────────────────────────────
      // INPUT DECORATION (Text Fields)
      // ─────────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceContainerLow,
        contentPadding: AtharSpacing.input,
        border: OutlineInputBorder(
          borderRadius: AtharRadii.input,
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AtharRadii.input,
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AtharRadii.input,
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AtharRadii.input,
          borderSide: BorderSide(color: colors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AtharRadii.input,
          borderSide: BorderSide(color: colors.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AtharRadii.input,
          borderSide: BorderSide(color: colors.borderLight),
        ),
        labelStyle: AtharTypography.bodyMedium.copyWith(
          color: colors.textSecondary,
          fontFamily: AtharTypography.fontFamilyAr,
        ),
        floatingLabelStyle: AtharTypography.labelMedium.copyWith(
          color: colors.primary,
          fontFamily: AtharTypography.fontFamilyAr,
        ),
        hintStyle: AtharTypography.bodyMedium.copyWith(
          color: colors.textTertiary,
          fontFamily: AtharTypography.fontFamilyAr,
        ),
        errorStyle: AtharTypography.caption.copyWith(
          color: colors.error,
          fontFamily: AtharTypography.fontFamilyAr,
        ),
        helperStyle: AtharTypography.caption.copyWith(
          color: colors.textTertiary,
          fontFamily: AtharTypography.fontFamilyAr,
        ),
        prefixIconColor: colors.textSecondary,
        suffixIconColor: colors.textSecondary,
      ),

      // ─────────────────────────────────────────────────────────────
      // CHECKBOX
      // ─────────────────────────────────────────────────────────────
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(colors.onPrimary),
        side: BorderSide(color: colors.border, width: 2),
        shape: RoundedRectangleBorder(borderRadius: AtharRadii.radiusXxs),
      ),

      // ─────────────────────────────────────────────────────────────
      // RADIO
      // ─────────────────────────────────────────────────────────────
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primary;
          }
          return colors.border;
        }),
      ),

      // ─────────────────────────────────────────────────────────────
      // SWITCH
      // ─────────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primary;
          }
          return colors.surfaceContainerHigh;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primaryDark;
          }
          return colors.surfaceContainer;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.transparent;
          }
          return colors.border;
        }),
      ),

      // ─────────────────────────────────────────────────────────────
      // SLIDER
      // ─────────────────────────────────────────────────────────────
      sliderTheme: SliderThemeData(
        activeTrackColor: colors.primary,
        inactiveTrackColor: colors.surfaceContainer,
        thumbColor: colors.primary,
        overlayColor: colors.primary.withValues(alpha: 0.12),
        valueIndicatorColor: colors.primary,
        valueIndicatorTextStyle: AtharTypography.labelSmall.copyWith(
          color: colors.onPrimary,
          fontFamily: AtharTypography.fontFamilyAr,
        ),
      ),

      // ─────────────────────────────────────────────────────────────
      // PROGRESS INDICATOR
      // ─────────────────────────────────────────────────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.primary,
        linearTrackColor: colors.surfaceContainer,
        circularTrackColor: colors.surfaceContainer,
      ),

      // ─────────────────────────────────────────────────────────────
      // CHIP
      // ─────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceContainer,
        selectedColor: colors.primaryDark,
        disabledColor: colors.surfaceContainerLow,
        labelStyle: AtharTypography.chip.copyWith(
          color: colors.textPrimary,
          fontFamily: AtharTypography.fontFamilyAr,
        ),
        secondaryLabelStyle: AtharTypography.chip.copyWith(
          color: colors.primary,
          fontFamily: AtharTypography.fontFamilyAr,
        ),
        padding: AtharSpacing.chip,
        shape: RoundedRectangleBorder(
          borderRadius: AtharRadii.chip,
          side: BorderSide(color: colors.borderLight),
        ),
        side: BorderSide(color: colors.borderLight),
      ),

      // ─────────────────────────────────────────────────────────────
      // DIALOG
      // ─────────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        elevation: 8,
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: colors.shadow,
        shape: RoundedRectangleBorder(borderRadius: AtharRadii.dialog),
        titleTextStyle: AtharTypography.dialogTitle.copyWith(
          color: colors.textPrimary,
          fontFamily: AtharTypography.fontFamilyAr,
        ),
        contentTextStyle: AtharTypography.bodyMedium.copyWith(
          color: colors.textSecondary,
          fontFamily: AtharTypography.fontFamilyAr,
        ),
      ),

      // ─────────────────────────────────────────────────────────────
      // BOTTOM SHEET
      // ─────────────────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        elevation: 8,
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: colors.shadow,
        modalElevation: 8,
        modalBackgroundColor: colors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: AtharRadii.bottomSheet,
        ),
        dragHandleColor: colors.surfaceContainerHigh,
        dragHandleSize: const Size(32, 4),
      ),

      // ─────────────────────────────────────────────────────────────
      // SNACK BAR
      // ─────────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        elevation: 4,
        backgroundColor: colors.surfaceContainerHigh,
        contentTextStyle: AtharTypography.bodyMedium.copyWith(
          color: colors.textPrimary,
          fontFamily: AtharTypography.fontFamilyAr,
        ),
        shape: RoundedRectangleBorder(borderRadius: AtharRadii.snackbar),
        behavior: SnackBarBehavior.floating,
        insetPadding: AtharSpacing.allLg,
      ),

      // ─────────────────────────────────────────────────────────────
      // TAB BAR
      // ─────────────────────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: colors.primary,
        unselectedLabelColor: colors.textTertiary,
        labelStyle: AtharTypography.tab.copyWith(
          fontFamily: AtharTypography.fontFamilyAr,
        ),
        unselectedLabelStyle: AtharTypography.tab.copyWith(
          fontFamily: AtharTypography.fontFamilyAr,
          fontWeight: FontWeight.w400,
        ),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: colors.primary, width: 2),
          borderRadius: AtharRadii.tabIndicator,
        ),
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: colors.divider,
      ),

      // ─────────────────────────────────────────────────────────────
      // DRAWER
      // ─────────────────────────────────────────────────────────────
      drawerTheme: DrawerThemeData(
        elevation: 16,
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: colors.shadow,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(0),
            bottomLeft: Radius.circular(0),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      ),

      // ─────────────────────────────────────────────────────────────
      // LIST TILE
      // ─────────────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: AtharSpacing.listItem,
        horizontalTitleGap: AtharSpacing.md,
        minVerticalPadding: AtharSpacing.sm,
        iconColor: colors.textSecondary,
        textColor: colors.textPrimary,
        titleTextStyle: AtharTypography.listItemTitle.copyWith(
          fontFamily: AtharTypography.fontFamilyAr,
        ),
        subtitleTextStyle: AtharTypography.listItemSubtitle.copyWith(
          color: colors.textSecondary,
          fontFamily: AtharTypography.fontFamilyAr,
        ),
        shape: RoundedRectangleBorder(borderRadius: AtharRadii.radiusSm),
      ),

      // ─────────────────────────────────────────────────────────────
      // DIVIDER
      // ─────────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: colors.divider,
        thickness: 1,
        space: 1,
      ),

      // ─────────────────────────────────────────────────────────────
      // TOOLTIP
      // ─────────────────────────────────────────────────────────────
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: AtharRadii.tooltip,
        ),
        textStyle: AtharTypography.caption.copyWith(
          color: colors.textPrimary,
          fontFamily: AtharTypography.fontFamilyAr,
        ),
        padding: AtharSpacing.tooltip,
        waitDuration: AtharAnimations.tooltipDelay,
      ),

      // ─────────────────────────────────────────────────────────────
      // POPUP MENU
      // ─────────────────────────────────────────────────────────────
      popupMenuTheme: PopupMenuThemeData(
        elevation: 8,
        color: colors.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: colors.shadow,
        shape: RoundedRectangleBorder(borderRadius: AtharRadii.popupMenu),
        textStyle: AtharTypography.bodyMedium.copyWith(
          color: colors.textPrimary,
          fontFamily: AtharTypography.fontFamilyAr,
        ),
      ),

      // ─────────────────────────────────────────────────────────────
      // DROPDOWN MENU
      // ─────────────────────────────────────────────────────────────
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: AtharTypography.bodyMedium.copyWith(
          color: colors.textPrimary,
          fontFamily: AtharTypography.fontFamilyAr,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: colors.surfaceContainerLow,
          border: OutlineInputBorder(
            borderRadius: AtharRadii.input,
            borderSide: BorderSide(color: colors.border),
          ),
        ),
      ),

      // ─────────────────────────────────────────────────────────────
      // DATE PICKER
      // ─────────────────────────────────────────────────────────────
      datePickerTheme: DatePickerThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: colors.primary,
        headerForegroundColor: colors.onPrimary,
        dayStyle: AtharTypography.bodyMedium.copyWith(
          fontFamily: AtharTypography.fontFamilyAr,
        ),
        todayBorder: BorderSide(color: colors.primary),
        shape: RoundedRectangleBorder(borderRadius: AtharRadii.dialog),
      ),

      // ─────────────────────────────────────────────────────────────
      // TIME PICKER
      // ─────────────────────────────────────────────────────────────
      timePickerTheme: TimePickerThemeData(
        backgroundColor: colors.surface,
        hourMinuteColor: colors.surfaceContainer,
        hourMinuteTextColor: colors.textPrimary,
        dialBackgroundColor: colors.surfaceContainer,
        dialHandColor: colors.primary,
        dialTextColor: colors.textPrimary,
        entryModeIconColor: colors.textSecondary,
        shape: RoundedRectangleBorder(borderRadius: AtharRadii.dialog),
      ),

      // ─────────────────────────────────────────────────────────────
      // BADGE
      // ─────────────────────────────────────────────────────────────
      badgeTheme: BadgeThemeData(
        backgroundColor: colors.error,
        textColor: colors.onError,
        textStyle: AtharTypography.badge.copyWith(
          fontFamily: AtharTypography.fontFamilyAr,
        ),
      ),

      // ─────────────────────────────────────────────────────────────
      // EXPANSION TILE
      // ─────────────────────────────────────────────────────────────
      expansionTileTheme: ExpansionTileThemeData(
        backgroundColor: colors.surface,
        collapsedBackgroundColor: colors.surface,
        textColor: colors.textPrimary,
        collapsedTextColor: colors.textPrimary,
        iconColor: colors.textSecondary,
        collapsedIconColor: colors.textSecondary,
        shape: RoundedRectangleBorder(borderRadius: AtharRadii.radiusMd),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: AtharRadii.radiusMd,
        ),
      ),

      // ─────────────────────────────────────────────────────────────
      // SCROLL BAR
      // ─────────────────────────────────────────────────────────────
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(colors.textDisabled),
        trackColor: WidgetStateProperty.all(colors.surfaceContainer),
        radius: const Radius.circular(4),
        thickness: WidgetStateProperty.all(6),
      ),
    );
  }

  /// بناء TextTheme
  static TextTheme _buildTextTheme(AtharColors colors) {
    return TextTheme(
      // Display
      displayLarge: AtharTypography.displayLarge.copyWith(
        color: colors.textPrimary,
        fontFamily: AtharTypography.fontFamilyAr,
      ),
      displayMedium: AtharTypography.displayMedium.copyWith(
        color: colors.textPrimary,
        fontFamily: AtharTypography.fontFamilyAr,
      ),
      displaySmall: AtharTypography.displaySmall.copyWith(
        color: colors.textPrimary,
        fontFamily: AtharTypography.fontFamilyAr,
      ),
      // Headline
      headlineLarge: AtharTypography.headlineLarge.copyWith(
        color: colors.textPrimary,
        fontFamily: AtharTypography.fontFamilyAr,
      ),
      headlineMedium: AtharTypography.headlineMedium.copyWith(
        color: colors.textPrimary,
        fontFamily: AtharTypography.fontFamilyAr,
      ),
      headlineSmall: AtharTypography.headlineSmall.copyWith(
        color: colors.textPrimary,
        fontFamily: AtharTypography.fontFamilyAr,
      ),
      // Title
      titleLarge: AtharTypography.titleLarge.copyWith(
        color: colors.textPrimary,
        fontFamily: AtharTypography.fontFamilyAr,
      ),
      titleMedium: AtharTypography.titleMedium.copyWith(
        color: colors.textPrimary,
        fontFamily: AtharTypography.fontFamilyAr,
      ),
      titleSmall: AtharTypography.titleSmall.copyWith(
        color: colors.textPrimary,
        fontFamily: AtharTypography.fontFamilyAr,
      ),
      // Body
      bodyLarge: AtharTypography.bodyLarge.copyWith(
        color: colors.textPrimary,
        fontFamily: AtharTypography.fontFamilyAr,
      ),
      bodyMedium: AtharTypography.bodyMedium.copyWith(
        color: colors.textPrimary,
        fontFamily: AtharTypography.fontFamilyAr,
      ),
      bodySmall: AtharTypography.bodySmall.copyWith(
        color: colors.textSecondary,
        fontFamily: AtharTypography.fontFamilyAr,
      ),
      // Label
      labelLarge: AtharTypography.labelLarge.copyWith(
        color: colors.textPrimary,
        fontFamily: AtharTypography.fontFamilyAr,
      ),
      labelMedium: AtharTypography.labelMedium.copyWith(
        color: colors.textSecondary,
        fontFamily: AtharTypography.fontFamilyAr,
      ),
      labelSmall: AtharTypography.labelSmall.copyWith(
        color: colors.textTertiary,
        fontFamily: AtharTypography.fontFamilyAr,
      ),
    );
  }
}
