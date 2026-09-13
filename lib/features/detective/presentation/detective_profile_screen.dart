import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_typography.dart';
import '../../player/data/detective_profile_provider.dart';
import '../../player/domain/detective_profile.dart';
import '../../player/presentation/widgets/detective_level_badge.dart';
import '../../player/presentation/widgets/streak_badge.dart';
import '../../player/presentation/widgets/xp_progress_bar.dart';

/// The detective's local profile: rank, XP, streak and case statistics.
class DetectiveProfileScreen extends ConsumerWidget {
  const DetectiveProfileScreen({super.key});

  static const double _contentMaxWidth = 600;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DetectiveStanding standing = ref.watch(detectiveStandingProvider);
    final DetectiveProfile profile = standing.profile;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[AppColors.backgroundElevated, AppColors.background],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: _contentMaxWidth,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              IconButton(
                                onPressed: () =>
                                    context.go(AppRoute.home.path),
                                icon: const Icon(Icons.arrow_back),
                                color: AppColors.textSecondary,
                                tooltip: 'Back to HQ',
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                'DETECTIVE PROFILE',
                                style: AppTypography.headline.copyWith(
                                  letterSpacing: 2.0,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          _RankCard(standing: standing),
                          const SizedBox(height: AppSpacing.lg),
                          XPProgressBar(standing: standing),
                          const SizedBox(height: AppSpacing.md),
                          SizedBox(
                            width: double.infinity,
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: StreakBadge(
                                    days: standing.streakDays,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: DetectiveLevelBadge(
                                    level: standing.level,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          const _StatisticsHeader(),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: _StatTile(
                                  icon: Icons.check_circle_outline,
                                  label: 'CASES SOLVED',
                                  value: _formatNumber(profile.casesSolved),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: _StatTile(
                                  icon: Icons.cancel_outlined,
                                  label: 'CASES FAILED',
                                  value: _formatNumber(profile.casesFailed),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: _StatTile(
                                  icon: Icons.timer_outlined,
                                  label: 'BEST TIME',
                                  value: profile.hasRecordedBestTime
                                      ? DetectiveProfile.formatSeconds(
                                          profile.bestTimeSeconds!
                                              .toDouble(),
                                        )
                                      : '—',
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: _StatTile(
                                  icon: Icons.av_timer_outlined,
                                  label: 'AVERAGE TIME',
                                  value: profile.averageTimeSeconds == null
                                      ? '—'
                                      : DetectiveProfile.formatSeconds(
                                          profile.averageTimeSeconds!,
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  static String _formatNumber(int value) {
    final String raw = value.toString();
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      if (i > 0 && (raw.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(raw[i]);
    }
    return buffer.toString();
  }
}

class _RankCard extends StatelessWidget {
  const _RankCard({required this.standing});

  final DetectiveStanding standing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.accent.withAlpha(100)),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.accentFaint,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accent.withAlpha(120)),
            ),
            child: const Icon(
              Icons.workspace_premium,
              size: 36,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            standing.title.toUpperCase(),
            textAlign: TextAlign.center,
            style: AppTypography.displayMedium.copyWith(
              color: AppColors.accent,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'LEVEL ${standing.level}',
            style: AppTypography.overline.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 2.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatisticsHeader extends StatelessWidget {
  const _StatisticsHeader();

  @override
  Widget build(BuildContext context) {
    return Text(
      'STATISTICS',
      style: AppTypography.overline.copyWith(
        color: AppColors.textSecondary,
        letterSpacing: 2.0,
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderStrong),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: 18, color: AppColors.accent),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.overline.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    letterSpacing: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: AppTypography.title.copyWith(
              color: AppColors.textPrimary,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}