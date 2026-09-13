import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';

/// Visual state of a single multiple-choice option.
enum AnswerOptionState {
  /// Not yet chosen and still selectable.
  unselected,

  /// Chosen by the player during active play.
  selected,

  /// Revealed correct after submission/timeout.
  correct,

  /// Revealed as the player's wrong submission.
  incorrect,

  /// Locked out (after the case ended); rendered muted and non-tappable.
  disabled,
}

/// A reusable, state-driven multiple-choice row.
///
/// Presentation only — selection logic stays in the caller/controller.
class AnswerOptionTile extends StatelessWidget {
  const AnswerOptionTile({
    super.key,
    required this.text,
    required this.state,
    this.onPressed,
    this.letter,
  });

  final String text;
  final AnswerOptionState state;
  final VoidCallback? onPressed;
  final String? letter;

  @override
  Widget build(BuildContext context) {
    final bool tappable =
        state != AnswerOptionState.disabled && onPressed != null;

    final Color border;
    final Color background;
    final Color contentColor;
    final Color accentColor;
    final IconData? trailingIcon;

    switch (state) {
      case AnswerOptionState.selected:
        border = AppColors.accent;
        background = AppColors.accentFaint;
        contentColor = AppColors.textPrimary;
        accentColor = AppColors.accent;
        trailingIcon = Icons.check;
      case AnswerOptionState.correct:
        border = AppColors.success;
        background = AppColors.successFaint;
        contentColor = AppColors.textPrimary;
        accentColor = AppColors.success;
        trailingIcon = Icons.check;
      case AnswerOptionState.incorrect:
        border = AppColors.danger;
        background = AppColors.dangerFaint;
        contentColor = AppColors.textPrimary;
        accentColor = AppColors.danger;
        trailingIcon = Icons.close;
      case AnswerOptionState.disabled:
        border = AppColors.border;
        background = AppColors.surfaceMuted;
        contentColor = AppColors.textMuted;
        accentColor = AppColors.textMuted;
        trailingIcon = null;
      case AnswerOptionState.unselected:
        border = AppColors.border;
        background = AppColors.surface;
        contentColor = AppColors.textPrimary;
        accentColor = AppColors.textSecondary;
        trailingIcon = null;
    }

    final TextStyle textStyle = AppTypography.body.copyWith(color: contentColor);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: tappable ? onPressed : null,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Ink(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: border),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: <Widget>[
              if (letter != null) ...<Widget>[
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: accentColor),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    letter!,
                    style: AppTypography.overline.copyWith(color: accentColor),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: Text(
                  text,
                  style: textStyle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trailingIcon != null) ...<Widget>[
                const SizedBox(width: AppSpacing.md),
                Icon(trailingIcon, size: 20, color: accentColor),
              ],
            ],
          ),
        ),
      ),
    );
  }
}