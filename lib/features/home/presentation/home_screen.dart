import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/config/app_config.dart';
import '../../../app/router/app_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../core/widgets/section_header.dart';
import '../../mystery/data/mystery_providers.dart';
import '../../mystery/domain/models/mystery.dart';
import '../../mystery/presentation/widgets/case_card.dart';
import '../../player/data/player_stats_provider.dart';
import '../../player/domain/player_stats.dart';
import '../../player/presentation/widgets/detective_level_badge.dart';
import '../../player/presentation/widgets/streak_badge.dart';
import '../../player/presentation/widgets/xp_progress_bar.dart';

/// The landing screen: today's case plus the detective's standing.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const double _contentMaxWidth = 600;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Mystery> todayCase = ref.watch(todayMysteryProvider);
    final PlayerStats stats = ref.watch(playerStatsProvider);

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
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.lg,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: _contentMaxWidth,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const _BrandHeader(),
                            const SizedBox(height: AppSpacing.xl),
                            const SectionHeader(
                              title: "TODAY'S CASE",
                              kicker: 'DAILY BRIEFING',
                            ),
                            const SizedBox(height: AppSpacing.md),
                            todayCase.when(
                              loading: () => const Center(
                                child: LoadingState(
                                  message: 'Reviewing evidence…',
                                ),
                              ),
                              error: (Object error, StackTrace stackTrace) =>
                                  ErrorState(
                                message: "Couldn't load today's case.",
                                onRetry: () =>
                                    ref.invalidate(todayMysteryProvider),
                              ),
                              data: (Mystery mystery) => CaseCard(
                                mystery: mystery,
                                onStart: () =>
                                    context.go(AppRoute.mystery.path),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            XPProgressBar(stats: stats),
                            const SizedBox(height: AppSpacing.md),
                            SizedBox(
                              width: double.infinity,
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: StreakBadge(days: stats.streakDays),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: DetectiveLevelBadge(
                                      level: stats.level,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.accentFaint,
                border: Border.all(color: AppColors.accent.withAlpha(100)),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: const Icon(Icons.search, size: 22, color: AppColors.accent),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                AppConfig.appName,
                style: AppTypography.displayMedium.copyWith(letterSpacing: 2.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Container(height: 1, color: AppColors.divider),
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
    );
  }
}