import 'package:flutter/material.dart';

import '../../../app/theme/app_typography.dart';

/// Placeholder for ad/offer wall integration.
class AdsPlaceholderScreen extends StatelessWidget {
  const AdsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'ADS',
          style: AppTypography.overline.copyWith(letterSpacing: 3.0),
        ),
      ),
    );
  }
}