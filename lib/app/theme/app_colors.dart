import 'package:flutter/material.dart';

/// Central color palette for the CASE 60 detective/mystery aesthetic.
///
/// Extremely dark backgrounds, warm off-white text, a muted gold accent,
/// subtle card surfaces and restrained semantic colors. Raw color literals
/// should never be scattered across the app — always reference these tokens.
final class AppColors {
  const AppColors._();

  // Backgrounds.
  static const Color background = Color(0xFF0D0D0D);
  static const Color backgroundElevated = Color(0xFF141414);

  // Surfaces.
  static const Color surface = Color(0xFF1A1A1A);
  static const Color surfaceElevated = Color(0xFF222222);
  static const Color surfaceMuted = Color(0xFF161616);

  // Borders & dividers.
  static const Color border = Color(0xFF2A2A2A);
  static const Color borderStrong = Color(0xFF3A3324);
  static const Color divider = Color(0xFF1E1E1E);

  // Text.
  static const Color textPrimary = Color(0xFFF5F0E8);
  static const Color textSecondary = Color(0xFFB3A98F);
  static const Color textMuted = Color(0xFF6E6757);
  static const Color textOnAccent = Color(0xFF171204);

  // Accent.
  static const Color accent = Color(0xFFC9A84C);
  static const Color accentSoft = Color(0xFFA9893F);
  static const Color accentFaint = Color(0xFF2C2617);

  // Semantic.
  static const Color danger = Color(0xFFC44040);
  static const Color dangerFaint = Color(0xFF2A1616);
  static const Color success = Color(0xFF4CAF50);
  static const Color successFaint = Color(0xFF16271A);

  // Elevation shadows.
  static const Color shadow = Color(0x99000000);
}