import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/loading_state.dart';

/// Placeholder for the mystery/case-playing experience.
class MysteryPlaceholderScreen extends StatelessWidget {
  const MysteryPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Mystery', style: AppTypography.headline),
            const SizedBox(height: AppSpacing.md),
            const LoadingState(
              message: 'Awaiting evidence…',
              compact: true,
            ),
          ],
        ),
      ),
    );
  }
}