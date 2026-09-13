import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../domain/models/mystery.dart';
import 'case_number_badge.dart';

/// Hero card presenting the case of the day.
class CaseCard extends StatelessWidget {
  const CaseCard({super.key, required this.mystery, this.onStart});

  final Mystery mystery;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[AppColors.surfaceElevated, AppColors.surface],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderStrong),
        boxShadow: AppShadows.elevated,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(height: 3, color: AppColors.accent),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    CaseNumberBadge(caseNumber: mystery.caseNumber),
                    const Spacer(),
                    Flexible(
                      child: Text(
                        '${mystery.category.label.toUpperCase()}  •  ${mystery.difficulty.label.toUpperCase()}',
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.overline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(mystery.title, style: AppTypography.displayMedium),
                const SizedBox(height: AppSpacing.sm),
                Text('Can you solve it?', style: AppTypography.subtitle),
                const SizedBox(height: AppSpacing.lg),
                Container(height: 1, color: AppColors.divider),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: Text(
                        '${mystery.timeLimitSeconds} SECOND CHALLENGE',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.overline.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: 'START CASE',
                  icon: Icons.arrow_forward,
                  expanded: true,
                  onPressed: onStart,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}