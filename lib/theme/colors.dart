import 'package:flutter/material.dart';

class AppColors {
  // PRIMARY
  static const primaryPurple = Color(0xFF694EDA);
  static const primary = primaryPurple; //alias

  // BACKGROUND & SURFACE
  static const backgroundWhite = Color(0xFFF1F1F1);
  static const white2 = Color(0xFFF6F7FB); 
  static const surface = Color(0xFFF2F2F2);
  static const background = backgroundWhite; //alias

  // TEXT
  static const textPrimary = Color(0xFF1C1C1E); 
  static const textSecondary = Color(0xFF6D6D6D); 

  //  STATE
  static const success = Color(0xFF2DCC70);
  static const error = Color(0xFFFF2452); 
  static const disabled = Color(0xFFB2B2B2);

  //  Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFF9079ED), 
      Color(0xFF694EDA),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}