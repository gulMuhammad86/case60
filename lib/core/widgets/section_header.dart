import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_durations.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';

/// Elegant section title with an optional overline kicker and a subtle
/// gold hairline beneath it — evokes a case-file dossier heading.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.kicker,
    this.action,
  });

  final String title;
  final String? kicker;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (kicker != null) ...<Widget>[
          Text(kicker!, style: AppTypography.overline),
          const SizedBox(height: AppSpacing.xs),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: AppDurations.fastest,
                style: AppTypography.headline,
                child: Text(title),
              ),
            ),
            ?action,
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        const SizedBox(
          width: 48,
          height: 2,
          child: DecoratedBox(
            decoration: BoxDecoration(color: AppColors.accent),
          ),
        ),
      ],
    );
  }
}