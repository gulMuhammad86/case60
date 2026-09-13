import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/timer/case_countdown.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../core/widgets/section_header.dart';
import '../application/case_controller.dart';
import '../data/mystery_providers.dart';
import '../domain/case_session.dart';
import '../domain/models/clue.dart';
import '../domain/models/mystery.dart';
import '../../player/data/detective_profile_provider.dart';
import 'widgets/answer_option_tile.dart';
import 'widgets/case_number_badge.dart';
import 'widgets/daily_lock_view.dart';

/// The active case experience presented as a detective's case file.
class InvestigationScreen extends ConsumerWidget {
  const InvestigationScreen({super.key});

  static const double _contentMaxWidth = 600;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Mystery> todayCase = ref.watch(todayMysteryProvider);
    final CaseSession session = ref.watch(caseControllerProvider);

    ref.listen<AsyncValue<Mystery>>(todayMysteryProvider, (
      AsyncValue<Mystery>? previous,
      AsyncValue<Mystery> next,
    ) {
      next.whenData(
        (Mystery mystery) => ref.read(caseControllerProvider.notifier).begin(mystery),
      );
    });

    ref.listen<CaseSession>(caseControllerProvider, (
      CaseSession? previous,
      CaseSession next,
    ) {
      final bool finished =
          next.phase == CasePhase.completed || next.phase == CasePhase.timeout;
      if (finished && next.phase != previous?.phase) {
        context.go(AppRoute.results.path);
      }
    });

    if (todayCase.hasValue && _shouldStartFresh(session.phase)) {
      _scheduleBegin(context, ref, todayCase.requireValue);
    }

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
          child: _buildBody(context, ref, todayCase, session),
        ),
      ),
    );
  }

  bool _shouldStartFresh(CasePhase phase) {
    return phase == CasePhase.initial || phase == CasePhase.timeout ||
        phase == CasePhase.completed || phase == CasePhase.error;
  }

  void _scheduleBegin(
    BuildContext context,
    WidgetRef ref,
    Mystery mystery,
  ) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) {
        return;
      }
      ref.read(caseControllerProvider.notifier).begin(mystery);
    });
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<Mystery> todayCase,
    CaseSession session,
  ) {
    final CasePhase phase = session.phase;
    final bool lockedToday = ref.watch(caseLockedTodayProvider);

    if (lockedToday && !session.isActive) {
      return DailyLockView(
        caseNumber: todayCase.hasValue
            ? todayCase.requireValue.caseNumber
            : null,
      );
    }

    if (todayCase.isLoading ||
        phase == CasePhase.initial ||
        phase == CasePhase.loading ||
        phase == CasePhase.ready) {
      return const LoadingState(message: 'Opening case file…');
    }

    if (todayCase.hasError && !todayCase.hasValue) {
      return ErrorState(
        message: "Couldn't open today's case.",
        onRetry: () => ref.invalidate(todayMysteryProvider),
      );
    }

    final Mystery mystery = todayCase.requireValue;
    return _CaseFile(
      mystery: mystery,
      session: session,
      onSelect: (String answerId) {
        ref.read(caseControllerProvider.notifier).selectAnswer(answerId);
      },
      onSubmit: phase == CasePhase.inProgress &&
              session.selectedAnswerId != null
          ? () => ref.read(caseControllerProvider.notifier).submit()
          : null,
    );
  }
}

class _CaseFile extends StatelessWidget {
  const _CaseFile({
    required this.mystery,
    required this.session,
    required this.onSelect,
    this.onSubmit,
  });

  final Mystery mystery;
  final CaseSession session;
  final void Function(String answerId) onSelect;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    final List<Clue> clues = List<Clue>.of(mystery.clues)
      ..sort((Clue a, Clue b) => a.orderIndex.compareTo(b.orderIndex));
    final bool active = session.phase == CasePhase.inProgress;

    return LayoutBuilder(
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
                    maxWidth: InvestigationScreen._contentMaxWidth,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
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
                          CaseNumberBadge(caseNumber: mystery.caseNumber),
                          const Spacer(),
                          Flexible(
                            child: Text(
                              '${mystery.category.label.toUpperCase()}  •  ${mystery.difficulty.label.toUpperCase()}',
                              textAlign: TextAlign.right,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.overline,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(mystery.title, style: AppTypography.displayLarge),
                      const SizedBox(height: AppSpacing.xl),
                      const SectionHeader(title: 'STORY'),
                      const SizedBox(height: AppSpacing.md),
                      Text(mystery.story, style: AppTypography.body),
                      const SizedBox(height: AppSpacing.xl),
                      const SectionHeader(title: 'CLUES'),
                      const SizedBox(height: AppSpacing.md),
                      for (int i = 0; i < clues.length; i++) ...<Widget>[
                        _ClueRow(
                          number: (i + 1).toString().padLeft(2, '0'),
                          text: clues[i].text,
                        ),
                        if (i < clues.length - 1)
                          const SizedBox(height: AppSpacing.md),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                      const SectionHeader(title: 'TIME REMAINING'),
                      const SizedBox(height: AppSpacing.md),
                      _CountdownPanel(
                        remaining: session.remaining,
                        timeLimit: Duration(seconds: mystery.timeLimitSeconds),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      const SectionHeader(title: 'ANSWER'),
                      const SizedBox(height: AppSpacing.md),
                      for (int i = 0;
                          i < mystery.answers.length;
                          i++) ...<Widget>[
                        AnswerOptionTile(
                          key: ValueKey<String>(
                            'answer-${mystery.answers[i].id}',
                          ),
                          letter: String.fromCharCode(65 + i),
                          text: mystery.answers[i].text,
                          state: _stateFor(mystery, mystery.answers[i].id),
                          onPressed: active
                              ? () => onSelect(mystery.answers[i].id)
                              : null,
                        ),
                        if (i < mystery.answers.length - 1)
                          const SizedBox(height: AppSpacing.sm),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      PrimaryButton(
                        label: 'SUBMIT ANSWER',
                        icon: Icons.gavel,
                        expanded: true,
                        onPressed: onSubmit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  AnswerOptionState _stateFor(Mystery current, String answerId) {
    if (session.phase == CasePhase.inProgress) {
      return session.selectedAnswerId == answerId
          ? AnswerOptionState.selected
          : AnswerOptionState.unselected;
    }
    if (answerId == current.correctAnswerId) {
      return AnswerOptionState.correct;
    }
    if (answerId == session.submittedAnswerId) {
      return AnswerOptionState.incorrect;
    }
    return AnswerOptionState.disabled;
  }
}

class _ClueRow extends StatelessWidget {
  const _ClueRow({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 28,
          child: Text(
            number,
            textAlign: TextAlign.right,
            style: AppTypography.overline.copyWith(color: AppColors.accent),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(text, style: AppTypography.bodySecondary),
        ),
      ],
    );
  }
}

class _CountdownPanel extends StatelessWidget {
  const _CountdownPanel({required this.remaining, required this.timeLimit});

  final Duration remaining;
  final Duration timeLimit;

  @override
  Widget build(BuildContext context) {
    final int remainingSeconds = remaining.inSeconds;
    final bool urgent =
        remainingSeconds > 0 && remainingSeconds <= 10;
    final bool expired = remainingSeconds <= 0;

    final Color numberColor = expired || urgent
        ? AppColors.danger
        : AppColors.accent;

    final double totalSeconds = timeLimit.inSeconds.toDouble();
    final double value =
        totalSeconds <= 0 ? 0 : (totalSeconds - remainingSeconds) / totalSeconds;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderStrong),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: <Widget>[
          Text(
            CaseCountdown.format(remaining),
            style: AppTypography.displayLarge.copyWith(
              color: numberColor,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0).toDouble(),
              minHeight: 6,
              backgroundColor: AppColors.surfaceElevated,
              color: expired || urgent ? AppColors.danger : AppColors.accent,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            expired
                ? 'TIME EXPIRED'
                : urgent
                    ? 'HURRY — TIME IS ALMOST UP'
                    : 'SOLVE THE CASE BEFORE TIME RUNS OUT',
            style: AppTypography.overline.copyWith(
              color: expired || urgent
                  ? AppColors.danger
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}