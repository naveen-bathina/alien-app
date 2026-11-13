import 'package:flutter/material.dart';

/// Centralized design tokens following modern SaaS standards (Linear, Vercel, Notion).
class AppTokens {
  AppTokens._();

  // Spacing Scale (4/8px Grid)
  static const double space1 = 4.0;
  static const double space2 = 8.0;
  static const double space3 = 12.0;
  static const double space4 = 16.0;
  static const double space5 = 20.0;
  static const double space6 = 24.0;
  static const double space8 = 32.0;
  static const double space10 = 40.0;
  static const double space12 = 48.0;
  static const double space16 = 64.0;

  // Radii
  static const double radiusSm = 6.0;
  static const double radiusMd = 8.0; // Buttons, inputs, chips
  static const double radiusLg = 12.0; // Cards, modals, panels
  static const double radiusXl = 16.0;
  static const double radiusFull = 9999.0;

  // Max Viewport Widths
  static const double maxContentWidth = 1240.0;
  static const double sidebarExpandedWidth = 240.0;
  static const double sidebarCollapsedWidth = 68.0;
  static const double topBarHeight = 56.0;

  // Brand Accent
  static const Color brandPrimary = Color(0xFF6C4AB6);
  static const Color brandPrimaryHover = Color(0xFF7C5AC4);
  static const Color brandPrimaryDark = Color(0xFF4D2D8F);
  static const Color brandPrimaryLight = Color(0xFF8F6EE0);

  // Semantics
  static const Color success = Color(0xFF10B981);
  static const Color successBgLight = Color(0xFFECFDF5);
  static const Color successBgDark = Color(0xFF064E3B);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningBgLight = Color(0xFFFFFBEB);
  static const Color warningBgDark = Color(0xFF78350F);

  static const Color error = Color(0xFFEF4444);
  static const Color errorBgLight = Color(0xFFFEF2F2);
  static const Color errorBgDark = Color(0xFF7F1D1D);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoBgLight = Color(0xFFEFF6FF);
  static const Color infoBgDark = Color(0xFF1E3A8A);

  // Transitions
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 220);
  static const Curve curveStandard = Curves.easeOutCubic;
}

/// Dynamic theme token access helper based on brightness.
class AppColorTokens {
  const AppColorTokens({
    required this.bgBase,
    required this.bgSurface,
    required this.bgElevated,
    required this.bgSubtle,
    required this.borderLow,
    required this.borderFocus,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.brandAccent,
    required this.brandAccentSubtle,
    required this.brandAccentBorder,
    required this.success,
    required this.successBg,
    required this.warning,
    required this.warningBg,
    required this.error,
    required this.errorBg,
  });

  final Color bgBase;
  final Color bgSurface;
  final Color bgElevated;
  final Color bgSubtle;
  final Color borderLow;
  final Color borderFocus;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color brandAccent;
  final Color brandAccentSubtle;
  final Color brandAccentBorder;
  final Color success;
  final Color successBg;
  final Color warning;
  final Color warningBg;
  final Color error;
  final Color errorBg;

  static const AppColorTokens light = AppColorTokens(
    bgBase: Color(0xFFF9FAFB),
    bgSurface: Color(0xFFFFFFFF),
    bgElevated: Color(0xFFFFFFFF),
    bgSubtle: Color(0xFFF3F4F6),
    borderLow: Color(0xFFE5E7EB),
    borderFocus: AppTokens.brandPrimary,
    textPrimary: Color(0xFF111827),
    textSecondary: Color(0xFF4B5563),
    textMuted: Color(0xFF9CA3AF),
    brandAccent: AppTokens.brandPrimary,
    brandAccentSubtle: Color(0xFFF7F5FC),
    brandAccentBorder: Color(0xFFE2DDF4),
    success: Color(0xFF16A34A),
    successBg: Color(0xFFF0FDF4),
    warning: Color(0xFFF59E0B),
    warningBg: Color(0xFFFFFBEB),
    error: Color(0xFFEF4444),
    errorBg: Color(0xFFFEF2F2),
  );

  static const AppColorTokens dark = AppColorTokens(
    bgBase: Color(0xFF0E0F12),
    bgSurface: Color(0xFF16171B),
    bgElevated: Color(0xFF1E2026),
    bgSubtle: Color(0xFF22242B),
    borderLow: Color(0xFF262830),
    borderFocus: AppTokens.brandPrimaryLight,
    textPrimary: Color(0xFFF3F4F6),
    textSecondary: Color(0xFF9CA3AF),
    textMuted: Color(0xFF6B7280),
    brandAccent: AppTokens.brandPrimaryLight,
    brandAccentSubtle: Color(0xFF221C35),
    brandAccentBorder: Color(0xFF3E335E),
    success: Color(0xFF22C55E),
    successBg: Color(0xFF0D2818),
    warning: Color(0xFFFBBF24),
    warningBg: Color(0xFF332005),
    error: Color(0xFFF87171),
    errorBg: Color(0xFF371314),
  );

  static AppColorTokens of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }
}
