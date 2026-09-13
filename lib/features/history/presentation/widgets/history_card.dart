import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_typography.dart';
import '../../domain/history_entry.dart';

/// A single row in the case history: case number, outcome, time and XP.
class HistoryCard extends StatelessWidget {
  const HistoryCard({super.key, required this.entry});

  final HistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final bool solved = entry.solved;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: solved ? AppColors.accentFaint : AppColors.borderStrong),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: solved
                  ? AppColors.accentFaint
                  : AppColors.danger.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(
              solved ? Icons.check : Icons.close,
              size: 20,
              color: solved ? AppColors.accent : AppColors.danger,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(entry.caseLabel, style: AppTypography.title),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${entry.statusLabel}  •  ${entry.timeSeconds} SEC',
                  style: AppTypography.overline.copyWith(
                    color: solved
                        ? AppColors.accent
                        : AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (solved && entry.xpEarned > 0) ...<Widget>[
            Text(
              '+${entry.xpEarned} XP',
              style: AppTypography.bodySecondary.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}