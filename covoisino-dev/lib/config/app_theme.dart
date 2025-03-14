// app_theme.dart
import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF6C63FF);
  static const secondary = Color(0xFFFF6B6B);
  static const accent = Color(0xFF4ECDC4);
  static const background = Color(0xFFF7F7FF);
  static const surface = Colors.white;
  static const error = Color(0xFFFF4757);

  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF7E76FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const secondaryGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        background: AppColors.background,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
      useMaterial3: true,
    );
  }
}

class AppRoutes {
  static const String onboarding = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String ride = '/ride';
  static const String emergency = '/emergency';
}