import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';

/// Central shadow definitions for CASE 60.
///
/// Shadows are restrained and low-contrast; excessive elevation is avoided to
/// preserve the flat, deliberate case-file look.
final class AppShadows {
  const AppShadows._();

  static const List<BoxShadow> none = [];

  static const List<BoxShadow> card = [
    BoxShadow(
      color: AppColors.shadow,
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: AppColors.shadow,
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  /// The decoration applied to every card-style surface.
  static BoxDecoration cardDecoration({
    Color color = AppColors.surface,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(AppRadius.md)),
    List<BoxShadow> boxShadow = AppShadows.card,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: borderRadius,
      boxShadow: boxShadow,
      border: Border.all(color: AppColors.border),
    );
  }
}