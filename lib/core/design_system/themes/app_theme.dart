import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,

      // إعداد الخط الافتراضي (Cairo ممتاز للعربي)
      fontFamily: GoogleFonts.cairo().fontFamily,

      // ثيم النصوص
      textTheme: TextTheme(
        displayLarge: GoogleFonts.cairo(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.cairo(
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.cairo(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),

      // ثيم الألوان
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        surface: AppColors.surface,
      ),
    );
  }
}
