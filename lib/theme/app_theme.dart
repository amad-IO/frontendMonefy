import 'package:flutter/material.dart';
import 'colors.dart';
import 'text_style.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    // FONT
    fontFamily: 'Nunito',

    // BACKGROUND
    scaffoldBackgroundColor: AppColors.backgroundWhite,

    // PRIMARY COLOR
    primaryColor: AppColors.primaryPurple,

    // OLOR SCHEME (Material 3)
    colorScheme: ColorScheme.light(
      primary: AppColors.primaryPurple,
      secondary: AppColors.primaryPurple,
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
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: Colors.white,
        textStyle: AppTextStyle.button,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    ),

    // APPBAR THEME
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundWhite,
      elevation: 0,
      titleTextStyle: AppTextStyle.title,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    ),
  );
}