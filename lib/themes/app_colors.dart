import 'package:flutter/material.dart';

class AppColors {
  // Primary brand
  static const Color primaryPurple = Color(0xFF6C63FF);
  static const Color primaryBlue = Color(0xFF2196F3);

  // Dark theme
  static const Color darkBg = Color(0xFF0F0F1A);
  static const Color darkCard = Color(0xFF1A1A2E);
  static const Color darkCardAlt = Color(0xFF16213E);
  static const Color darkSurface = Color(0xFF1E1E2E);

  // Light theme
  static const Color lightBg = Color(0xFFF5F5FF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF0F0FF);

  // Semantic
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);
  static const Color errorLight = Color(0xFFFFEBEE);

  // Text
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0C8);
  static const Color textPrimaryLight = Color(0xFF1A1A2E);
  static const Color textSecondaryLight = Color(0xFF6B6B8E);

  // Glass
  static const Color glassBorder = Color(0x14FFFFFF);
  static const Color glassFill = Color(0x0DFFFFFF);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF2196F3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient1 = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF9C5AF5)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient cardGradient2 = LinearGradient(
    colors: [Color(0xFF2196F3), Color(0xFF0D47A1)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient cardGradient3 = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF1B5E20)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient cardGradient4 = LinearGradient(
    colors: [Color(0xFFFF9800), Color(0xFFE65100)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient cardGradient5 = LinearGradient(
    colors: [Color(0xFFE91E63), Color(0xFF880E4F)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient cardGradient6 = LinearGradient(
    colors: [Color(0xFF009688), Color(0xFF004D40)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );

  // Chart colors
  static const List<Color> chartColors = [
    Color(0xFF6C63FF), Color(0xFF2196F3), Color(0xFF4CAF50),
    Color(0xFFFF9800), Color(0xFFE91E63), Color(0xFF009688),
  ];

  static Color textPrimary({required bool isDark}) =>
      isDark ? textPrimaryDark : textPrimaryLight;

  static Color textSecondary({required bool isDark}) =>
      isDark ? textSecondaryDark : textSecondaryLight;
}
