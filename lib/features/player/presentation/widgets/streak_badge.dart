import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';

/// Compact pill showing the detective's current solve streak.
class StreakBadge extends StatelessWidget {
  const StreakBadge({super.key, required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.successFaint,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.success.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.local_fire_department,
            size: 16,
            color: AppColors.success,
          ),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              '$days DAY STREAK',
              textAlign: TextAlign.center,
              style: AppTypography.overline.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}