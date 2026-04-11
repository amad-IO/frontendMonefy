import 'package:flutter/material.dart';
import 'colors.dart';
import 'text_style.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Nunito',
    scaffoldBackgroundColor: AppColors.backgroundWhite,
    cardColor: AppColors.panelWhite,
    shadowColor: AppColors.panelShadow,
    primaryColor: AppColors.primaryPurple,
    colorScheme: ColorScheme.light(
      primary: AppColors.primaryPurple,
      secondary: AppColors.primaryPurple,
      surface: AppColors.surface,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSurface: AppColors.textPrimary,
    ),
    textTheme: const TextTheme(
      headlineMedium: AppTextStyle.heading,
      titleMedium: AppTextStyle.title,
      bodyMedium: AppTextStyle.body,
      bodySmall: AppTextStyle.caption,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: Colors.white,
        textStyle: AppTextStyle.button,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundWhite,
      elevation: 0,
      titleTextStyle: AppTextStyle.title,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    ),
  );
}