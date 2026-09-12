import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/config/app_config.dart';
import '../../../app/router/app_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: AppSpacing.xxxl),
              Center(
                child: Column(
                  children: <Widget>[
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.accentFaint,
                        border: Border.all(color: AppColors.accent.withAlpha(100)),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: const Icon(
                        Icons.search,
                        size: 32,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      AppConfig.appName,
                      style: AppTypography.displayLarge.copyWith(
                        color: AppColors.textPrimary,
                        letterSpacing: 2.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      AppConfig.tagline.toUpperCase(),
                      style: AppTypography.overline.copyWith(
                        color: AppColors.textSecondary,
                        letterSpacing: 2.0,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const _TodayCaseCard(),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _QuickStat(
                      label: 'Streak',
                      value: '0',
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _QuickStat(
                      label: 'Solved',
                      value: '0',
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayCaseCard extends StatelessWidget {
  const _TodayCaseCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.borderStrong),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('TODAY\'S CASE', style: AppTypography.overline),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Case #001',
            style: AppTypography.title,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'You have 60 seconds to solve this mystery.',
            style: AppTypography.caption,
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.go(AppRoute.mystery.path);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.textOnAccent,
                minimumSize: const Size(0, 48),
              ),
              child: Text(
                'BEGIN INVESTIGATION',
                style: AppTypography.button,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  const _QuickStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label.toUpperCase(), style: AppTypography.overline),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.displayMedium.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}