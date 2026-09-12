import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';

/// Centered loading indicator with optional inline message.
class LoadingState extends StatelessWidget {
  const LoadingState({
    super.key,
    this.message = 'Retrieving case file…',
    this.compact = false,
  });

  final String message;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(message, style: AppTypography.caption),
      ],
    );

    if (compact) return content;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: content,
      ),
    );
  }
}