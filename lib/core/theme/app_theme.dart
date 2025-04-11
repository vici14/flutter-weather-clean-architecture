import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        error: AppColors.error,
        background: AppColors.background,
        surface: AppColors.cardBackground,
      ),
      scaffoldBackgroundColor: AppColors.background,
      dividerColor: AppColors.divider,

      // Text themes
      textTheme: TextTheme(
        displayLarge: AppTextStyles.temperatureStyle,
        headlineMedium: AppTextStyles.cityNameStyle,
        titleLarge: AppTextStyles.headerStyle,
        bodyLarge: AppTextStyles.bodyStyle,
        bodyMedium: AppTextStyles.dayForecastStyle,
      ),

      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),

      // Card theme
      cardTheme: CardTheme(
        color: AppColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    // For future implementation
    return lightTheme;
  }
}
