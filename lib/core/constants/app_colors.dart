import 'package:flutter/material.dart';

/// Design tokens matching the One More visual identity from the design brief.
/// Dark-first aesthetic with glowing neon-mint green, vibrant flame orange, and sky blue accents.
class AppColors {
  AppColors._();

  // Dark Theme Base Surfaces (Matching design image #0B0E14 / #161B26)
  static const Color darkBackground = Color(0xFF0B0E14);
  static const Color darkSurface = Color(0xFF161B26);
  static const Color darkSurfaceElevated = Color(0xFF1F2636);
  static const Color darkBorder = Color(0xFF262E40);

  // Light Theme Base Surfaces
  static const Color lightBackground = Color(0xFFF6F8FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFEEF2F6);
  static const Color lightBorder = Color(0xFFDCE2EC);

  // Typography Tokens
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextTertiary = Color(0xFF64748B);

  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextTertiary = Color(0xFF94A3B8);

  // Brand Accents
  /// Signature vibrant emerald/mint green from the design image
  static const Color accentGreen = Color(0xFF00E575);
  static const Color accentGreenDark = Color(0xFF059669);
  static const Color accentGreenLight = Color(0xFF6EE7B7);

  /// XP, level badges & sky blue highlights
  static const Color accentXp = Color(0xFF38BDF8);
  static const Color accentBlue = Color(0xFF60A5FA);

  /// Fiery streak accent
  static const Color accentStreak = Color(0xFFFF7A18);
  static const Color accentStreakDark = Color(0xFFEA580C);
  static const Color streakOrange = Color(0xFFFF7A18);

  /// Achievement Gold & Purple
  static const Color gold = Color(0xFFFBBF24);
  static const Color purple = Color(0xFFA855F7);

  // Feedback Tokens
  static const Color error = Color(0xFFEF4444);
  static const Color errorContainer = Color(0xFF3B181E);
  static const Color success = Color(0xFF00E575);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF38BDF8);

  // Category Accents (from the design)
  static const Map<String, Color> categoryColors = {
    'kesehatan': Color(0xFF38BDF8),
    'produktivitas': Color(0xFF818CF8),
    'diri': Color(0xFFA855F7),
    'hiburan': Color(0xFFFF7A18),
    'health': Color(0xFF38BDF8),
    'learning': Color(0xFF818CF8),
    'mindfulness': Color(0xFFA855F7),
    'productivity': Color(0xFF818CF8),
    'routine': Color(0xFF34D399),
  };
}
