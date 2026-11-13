import 'package:flutter/material.dart';

/// Centralized application color palette and design tokens.
class AppColors {
  AppColors._();

  // Brand Primaries
  static const Color primary = Color(0xFF6C4AB6);
  static const Color primaryDark = Color(0xFF4D2D8F);
  static const Color primaryLight = Color(0xFFF7F5FC);
  static const Color primaryTint = Color(0xFFEFEBF9);

  // Borders & Dividers
  static const Color border = Color(0xFFE2DDF4);
  static const Color borderLight = Color(0xFFEDE9FE);

  // Backgrounds & Surfaces
  static const Color background = Color(0xFFF7F5FC);
  static const Color surface = Colors.white;
  static const Color surfaceMuted = Color(0xFFF9FAFB);

  // Text
  static const Color textPrimary = Color(0xFF1E1E2D);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  // Feedback & Accents
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);

  // Coins & Wallet
  static const Color coinGold = Color(0xFFF59E0B);
}
