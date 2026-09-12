import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';

/// Muted empty state used when there is no data to show (e.g. empty history).
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
  });

  final String title;
  final String? subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 40, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: AppTypography.title,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle!,
                style: AppTypography.bodySecondary,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}