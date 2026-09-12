import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import 'app_buttons.dart';

/// Full-area failure state with a controlled danger tint and retry action.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.onRetry,
    this.message = 'Something went wrong.',
    this.details,
  });

  final VoidCallback onRetry;
  final String message;
  final String? details;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.gpp_bad_outlined, size: 36, color: AppColors.danger),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.subtitle,
            ),
            if (details != null) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Text(
                details!,
                textAlign: TextAlign.center,
                style: AppTypography.caption,
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            SecondaryButton(
              label: 'RETRY',
              icon: Icons.refresh,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}