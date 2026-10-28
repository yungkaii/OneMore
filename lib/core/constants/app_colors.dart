import 'package:flutter/material.dart';

/// Design tokens for One More.
/// Restrained, warm dark-first palette prioritizing readability and intentional visual hierarchy.
class AppColors {
  AppColors._();

  // Dark Theme Base Surfaces
  static const Color darkBackground = Color(0xFF15171D);
  static const Color darkSurface = Color(0xFF20232B);
  static const Color darkSurfaceElevated = Color(0xFF292D37);
  static const Color darkBorder = Color(0xFF333844);

  // Light Theme Base Surfaces (for full dual theme support)
  static const Color lightBackground = Color(0xFFF7F8FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFEEF0F4);
  static const Color lightBorder = Color(0xFFDCE0E8);

  // Typography Tokens
  static const Color darkTextPrimary = Color(0xFFF4F1E8);
  static const Color darkTextSecondary = Color(0xFFA5A7B0);
  static const Color darkTextTertiary = Color(0xFF70737E);

  static const Color lightTextPrimary = Color(0xFF1B1D22);
  static const Color lightTextSecondary = Color(0xFF5A5E6B);
  static const Color lightTextTertiary = Color(0xFF8F93A0);

  // Brand Accents
  /// Progress & completion accent: Calming, organic green
  static const Color accentGreen = Color(0xFFA8DDA0);
  static const Color accentGreenDark = Color(0xFF4C8D44);

  /// XP, level badges & milestone highlights: Soft futuristic periwinkle
  static const Color accentXp = Color(0xFFB9C9FF);
  static const Color accentXpDark = Color(0xFF4B61AA);

  /// Streaks & fire highlights: Warm, encouraging amber
  static const Color accentStreak = Color(0xFFF6A65A);
  static const Color accentStreakDark = Color(0xFF9E5412);

  // Feedback Tokens
  static const Color error = Color(0xFFFF6B6B);
  static const Color errorContainer = Color(0xFF3C1F22);
  static const Color success = Color(0xFFA8DDA0);
  static const Color warning = Color(0xFFF6C95A);
  static const Color info = Color(0xFF80B5FF);

  // Habit Category Accents
  static const Map<String, Color> categoryColors = {
    'health': Color(0xFFA8DDA0),
    'learning': Color(0xFFB9C9FF),
    'mindfulness': Color(0xFFD6B5FF),
    'productivity': Color(0xFFF6A65A),
    'routine': Color(0xFF8DE0E0),
  };
}

