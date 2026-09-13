import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../domain/player_stats.dart';

/// Level-up progress toward the next detective rank.
class XPProgressBar extends StatelessWidget {
  const XPProgressBar({super.key, required this.stats});

  final PlayerStats stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text('XP', style: AppTypography.overline.copyWith(color: AppColors.accent)),
            const Spacer(),
            Text(
              '${stats.xpCurrent} / ${stats.xpForNextLevel}',
              style: AppTypography.caption,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: LinearProgressIndicator(
            value: stats.xpProgress,
            minHeight: 10,
            backgroundColor: AppColors.surfaceElevated,
            color: AppColors.accent,
          ),
        ),
      ],
    );
  }
}