import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Central typography scale for CASE 60.
///
/// Headings use a slightly letter-spaced, uppercase treatment to evoke a
/// premium case-file dossier. All text styles are derived from the warm
/// off-white palette and should be referenced instead of ad-hoc inline styles.
final class AppTypography {
  const AppTypography._();

  static const String displayFamily = 'Georgia';
  static const String bodyFamily = 'Helvetica';

  static const TextStyle displayLarge = TextStyle(
    fontFamily: displayFamily,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: displayFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle headline = TextStyle(
    fontFamily: displayFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: 0.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle title = TextStyle(
    fontFamily: displayFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: 0.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: displayFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0.2,
    color: AppColors.textSecondary,
  );

  static const TextStyle body = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.1,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.2,
    color: AppColors.textSecondary,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 1.5,
    color: AppColors.textMuted,
  );

  static const TextStyle button = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.8,
    color: AppColors.textOnAccent,
  );

  /// Maps the custom scale into a [TextTheme] used by the app theme.
  static TextTheme toTextTheme() {
    return const TextTheme(
      displayLarge: displayLarge,
      displayMedium: displayMedium,
      headlineLarge: headline,
      headlineMedium: title,
      titleLarge: title,
      titleMedium: subtitle,
      bodyLarge: body,
      bodyMedium: bodySecondary,
      bodySmall: caption,
      labelSmall: overline,
      labelLarge: button,
    );
  }
}