import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/services/app_clock.dart';
import '../../../../core/timer/case_countdown.dart';
import '../../../../core/widgets/app_buttons.dart';

/// Full-day lock shown when today's case has already been solved.
///
/// Replacing the case file with this view means a solved case can never be
/// replayed for another score; the next slot unlocks at the following local
/// midnight (a live [NextCaseCountdown] shows how long that takes).
final class DailyLockView extends ConsumerWidget {
  const DailyLockView({super.key, this.caseNumber});

  /// The number of today's concluded case, when known.
  final int? caseNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String detail = caseNumber == null
        ? 'Next case available tomorrow.'
        : 'CASE #${caseNumber.toString().padLeft(3, '0')} concluded — next case available tomorrow.';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: AppColors.accent.withAlpha(80)),
              boxShadow: AppShadows.card,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.accentFaint,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.accent.withAlpha(120),
                    ),
                  ),
                  child: const Icon(
                    Icons.lock_clock,
                    size: 30,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'CASE SOLVED',
                  style: AppTypography.displayMedium.copyWith(
                    color: AppColors.accent,
                    letterSpacing: 2.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  detail,
                  style: AppTypography.bodySecondary,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                const NextCaseCountdown(),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  label: 'RETURN TO HQ',
                  icon: Icons.home_outlined,
                  onPressed: () => context.go(AppRoute.home.path),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Live `hh:mm:ss` countdown until the next local midnight.
///
/// Recomputes against the injected [AppClock] every second, so it stays exact
/// across DST transitions and never drifts with stale deltas.
final class NextCaseCountdown extends ConsumerStatefulWidget {
  const NextCaseCountdown({super.key});

  @override
  ConsumerState<NextCaseCountdown> createState() => _NextCaseCountdownState();
}

final class _NextCaseCountdownState extends ConsumerState<NextCaseCountdown> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = ref.watch(appClockProvider).now();
    final Duration remaining = _nextMidnight(now).difference(now);
    return Column(
      children: <Widget>[
        Text(
          CaseCountdown.formatHms(remaining),
          style: AppTypography.displayLarge.copyWith(
            color: AppColors.accent,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'UNTIL THE NEXT CASE',
          style: AppTypography.overline.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }

  static DateTime _nextMidnight(DateTime now) {
    return DateTime(now.year, now.month, now.day + 1);
  }
}