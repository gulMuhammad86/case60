import 'package:flutter/material.dart';

/// Central animation and transition durations for CASE 60.
///
/// Widgets should reference these tokens instead of raw millisecond values so
/// motion stays consistent across the app.
final class AppDurations {
  const AppDurations._();

  static const Duration fastest = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 600);

  static const Duration pageTransition = Duration(milliseconds: 300);
  static const Duration fadeTransition = Duration(milliseconds: 250);
}

/// Spring presets for implicit animations.
final class AppCurves {
  const AppCurves._();

  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeInOutCubic;
}