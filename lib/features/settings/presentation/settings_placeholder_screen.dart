import 'package:flutter/material.dart';

import '../../../app/theme/app_typography.dart';

/// Placeholder for app settings.
class SettingsPlaceholderScreen extends StatelessWidget {
  const SettingsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'SETTINGS',
          style: AppTypography.overline.copyWith(letterSpacing: 3.0),
        ),
      ),
    );
  }
}