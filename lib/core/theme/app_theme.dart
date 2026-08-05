import 'package:flutter/material.dart';
import 'package:halkaarzbilgi/core/theme/app_colors.dart';
import 'package:halkaarzbilgi/core/theme/app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primaryGreen,
      cardColor: AppColors.surface,
      dividerColor: AppColors.border,
      textTheme: TextTheme(
        displayLarge: AppTextStyles.headline.copyWith(color: AppColors.textPrimary),
        titleLarge: AppTextStyles.title.copyWith(color: AppColors.textPrimary),
        bodyMedium: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
        labelLarge: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
        bodySmall: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.textSecondary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.title.copyWith(color: AppColors.textPrimary),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      primaryColor: AppColors.lightPrimaryGreen,
      cardColor: AppColors.lightSurface,
      dividerColor: AppColors.lightBorder,
      textTheme: TextTheme(
        displayLarge: AppTextStyles.headline.copyWith(color: AppColors.lightTextPrimary),
        titleLarge: AppTextStyles.title.copyWith(color: AppColors.lightTextPrimary),
        bodyMedium: AppTextStyles.body.copyWith(color: AppColors.lightTextPrimary),
        labelLarge: AppTextStyles.label.copyWith(color: AppColors.lightTextPrimary),
        bodySmall: AppTextStyles.caption.copyWith(color: AppColors.lightTextSecondary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: AppColors.lightPrimaryGreen,
        unselectedItemColor: AppColors.lightTextSecondary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.title.copyWith(color: AppColors.lightTextPrimary),
        iconTheme: const IconThemeData(color: AppColors.lightTextPrimary),
      ),
    );
  }
}
