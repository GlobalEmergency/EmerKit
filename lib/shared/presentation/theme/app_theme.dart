import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static const _textThemeLight = TextTheme(
    displayLarge: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary),
    displayMedium: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary),
    displaySmall: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary),
    headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary),
    headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary),
    headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary),
    titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary),
    titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary),
    titleSmall: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary),
    bodyLarge: TextStyle(fontSize: 14, color: AppColors.textPrimary),
    bodyMedium: TextStyle(fontSize: 13, color: AppColors.textSecondary),
    bodySmall: TextStyle(fontSize: 12, color: AppColors.textSecondary),
    labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary),
    labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary),
    labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary),
  );

  static const _textThemeDark = TextTheme(
    displayLarge: TextStyle(
        fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
    displayMedium: TextStyle(
        fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
    displaySmall: TextStyle(
        fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
    headlineLarge: TextStyle(
        fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
    headlineMedium: TextStyle(
        fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
    headlineSmall: TextStyle(
        fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
    titleLarge: TextStyle(
        fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
    titleMedium: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
    titleSmall: TextStyle(
        fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
    bodyLarge: TextStyle(fontSize: 14, color: Colors.white),
    bodyMedium: TextStyle(fontSize: 13, color: AppColors.textOnDarkSecondary),
    bodySmall: TextStyle(fontSize: 12, color: AppColors.textOnDarkSecondary),
    labelLarge: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
    labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textOnDarkSecondary),
    labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textOnDarkSecondary),
  );

  static final light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: AppColors.primary,
    scaffoldBackgroundColor: AppColors.surfaceLight,
    textTheme: _textThemeLight,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: AppColors.primaryDark,
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      shadowColor: AppColors.primary.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.accent,
      foregroundColor: Colors.white,
    ),
  );

  static final dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorSchemeSeed: AppColors.primary,
    scaffoldBackgroundColor: AppColors.surfaceDark,
    textTheme: _textThemeDark,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: AppColors.primaryDark,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.accent,
      foregroundColor: Colors.white,
    ),
  );
}
