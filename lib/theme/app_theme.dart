import 'package:flutter/material.dart';
import 'colors.dart';
import 'text_style.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    // FONT
    fontFamily: 'Nunito',

    // BACKGROUND
    scaffoldBackgroundColor: AppColors.background,

    // PRIMARY COLOR
    primaryColor: AppColors.primary,

    // OLOR SCHEME (Material 3)
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.primary,
      surface: AppColors.surface,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSurface: AppColors.textPrimary,
    ),

    // TEXT THEME
    textTheme: const TextTheme(
      headlineMedium: AppTextStyle.heading,
      titleMedium: AppTextStyle.title,
      bodyMedium: AppTextStyle.body,
      bodySmall: AppTextStyle.caption,
    ),

    // BUTTON THEME
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        textStyle: AppTextStyle.button,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    ),

    // APPBAR THEME
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      titleTextStyle: AppTextStyle.title,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    ),
  );
}