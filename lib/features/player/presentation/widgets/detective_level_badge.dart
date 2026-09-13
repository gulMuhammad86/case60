import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';

/// Compact pill showing the detective's current rank level.
class DetectiveLevelBadge extends StatelessWidget {
  const DetectiveLevelBadge({super.key, required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentFaint,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.borderStrong),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.shield_outlined, size: 16, color: AppColors.accent),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              'DETECTIVE LEVEL $level',
              textAlign: TextAlign.center,
              style: AppTypography.overline.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}