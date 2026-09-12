import 'package:flutter/material.dart';

/// Small ergonomic helpers for [BuildContext] used across CASE 60.
extension ContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
}