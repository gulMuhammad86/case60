import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../mystery/domain/models/clue.dart';

/// The "why" behind a case resolution.
///
/// Shows the resolution itself and then the [clues] in reading order, each
/// highlighted as evidence — so the player can connect the dots instead of
/// just reading "Correct answer: B".
class ExplanationSection extends StatelessWidget {
  const ExplanationSection({
    super.key,
    required this.explanation,
    required this.clues,
  });

  final String explanation;
  final List<Clue> clues;

  @override
  Widget build(BuildContext context) {
    final List<Clue> ordered = List<Clue>.of(clues)
      ..sort((Clue a, Clue b) => a.orderIndex.compareTo(b.orderIndex));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SectionHeader(title: 'EXPLANATION', kicker: 'WHY THIS ANSWER'),
        const SizedBox(height: AppSpacing.md),
        Text(explanation, style: AppTypography.body),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'THE EVIDENCE',
          style: AppTypography.overline.copyWith(color: AppColors.accent),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Let the clues connect the dots:',
          style: AppTypography.caption,
        ),
        const SizedBox(height: AppSpacing.md),
        for (int i = 0; i < ordered.length; i++) ...<Widget>[
          _EvidenceRow(
            number: (i + 1).toString().padLeft(2, '0'),
            text: ordered[i].text,
          ),
          if (i < ordered.length - 1) const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _EvidenceRow extends StatelessWidget {
  const _EvidenceRow({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.accentSoft),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 28,
            padding: const EdgeInsets.symmetric(vertical: 2),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.accentFaint,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              number,
              style: AppTypography.overline.copyWith(color: AppColors.accent),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text(text, style: AppTypography.bodySecondary),
            ),
          ),
        ],
      ),
    );
  }
}