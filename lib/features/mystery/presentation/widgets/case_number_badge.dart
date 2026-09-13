import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';

/// Gold dossier pill showing a case reference number (e.g. `CASE #042`).
class CaseNumberBadge extends StatelessWidget {
  const CaseNumberBadge({super.key, required this.caseNumber});

  final int caseNumber;

  @override
  Widget build(BuildContext context) {
    final String reference = 'CASE #${caseNumber.toString().padLeft(3, '0')}';
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentFaint,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.accent.withAlpha(90)),
      ),
      child: Text(
        reference,
        style: AppTypography.overline.copyWith(
          color: AppColors.accent,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}