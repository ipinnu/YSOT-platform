import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF000066); // Deep Purple
  static const Color secondary = Color(0xFFFFC107); // Amber
  static const Color background = Color(0xFFF5F5F5); // Light Grey
  static const Color surface = Color(0xFFFFFFFF); // Pure White
  static const Color error = Color(0xFF1E1F22); // Red
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.black;
  static const Color onBackground = Colors.black;
  static const Color onSurface = Colors.black;
  static const Color onError = Colors.white;
}

final ThemeData appTheme = ThemeData(
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    background: AppColors.background,
    onBackground: AppColors.onBackground,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
    error: AppColors.error,
    onError: AppColors.onError,
  ),
  fontFamily: 'Poppins',
  scaffoldBackgroundColor: AppColors.background,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.onPrimary,
    elevation: 0,
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Colors.black87),
    headlineSmall: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
  ),
);