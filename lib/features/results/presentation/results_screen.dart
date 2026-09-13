import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_durations.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/section_header.dart';
import '../../mystery/application/case_controller.dart';
import '../../mystery/domain/case_session.dart';
import '../../mystery/domain/models/answer_option.dart';
import '../../mystery/domain/models/mystery.dart';
import '../../mystery/presentation/widgets/case_number_badge.dart';
import 'widgets/explanation_section.dart';

/// Post-case verdict screen: outcome → answers → explanation → XP → actions.
///
/// A single finite [AnimationController] staggers the reveal (stamp → answers
/// → explanation → XP → buttons) so the resolution feels earned without ever
/// looping. Honors the OS "disable animations" setting.
class ResultsScreen extends ConsumerStatefulWidget {
  const ResultsScreen({super.key});

  static const double _contentMaxWidth = 600;

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _stage;
  late final Animation<double> _answers;
  late final Animation<double> _explanation;
  late final Animation<double> _xp;
  late final Animation<double> _actions;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.slow * 3,
    );
    _stage = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOutCubic),
    );
    _answers = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.30, 0.55, curve: Curves.easeOutCubic),
    );
    _explanation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.50, 0.75, curve: Curves.easeOutCubic),
    );
    _xp = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.70, 0.95, curve: Curves.easeOutCubic),
    );
    _actions = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.85, 1.0, curve: Curves.easeOutCubic),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1.0;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CaseSession session = ref.watch(caseControllerProvider);
    final Mystery? mystery = session.mystery;

    if (mystery == null || !session.isTerminal) {
      return Scaffold(
        body: SafeArea(
          child: EmptyState(
            title: 'No Case In Progress',
            subtitle: 'Start a case from the home screen to see your result.',
            icon: Icons.folder_open_outlined,
          ),
        ),
      );
    }

    final bool timeout = session.phase == CasePhase.timeout;
    final bool correct = session.isCorrect ?? false;

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
                          maxWidth: ResultsScreen._contentMaxWidth,
                        ),
                        child: _Verdict(
                          timeout: timeout,
                          correct: correct,
                          mystery: mystery,
                          session: session,
                          stage: _stage,
                          answersAnim: _answers,
                          explanationAnim: _explanation,
                          xpAnim: _xp,
                          actionsAnim: _actions,
                          onBack: () => context.go(AppRoute.home.path),
                          onTryAgain: () {
                            ref.read(caseControllerProvider.notifier).reset();
                            context.go(AppRoute.mystery.path);
                          },
                          onReturnHome: () => context.go(AppRoute.home.path),
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

class _Verdict extends StatelessWidget {
  const _Verdict({
    required this.timeout,
    required this.correct,
    required this.mystery,
    required this.session,
    required this.stage,
    required this.answersAnim,
    required this.explanationAnim,
    required this.xpAnim,
    required this.actionsAnim,
    required this.onBack,
    required this.onTryAgain,
    required this.onReturnHome,
  });

  final bool timeout;
  final bool correct;
  final Mystery mystery;
  final CaseSession session;
  final Animation<double> stage;
  final Animation<double> answersAnim;
  final Animation<double> explanationAnim;
  final Animation<double> xpAnim;
  final Animation<double> actionsAnim;
  final VoidCallback onBack;
  final VoidCallback onTryAgain;
  final VoidCallback onReturnHome;

  @override
  Widget build(BuildContext context) {
    final IconData icon = timeout
        ? Icons.timer_off_outlined
        : correct
            ? Icons.check_circle_outline
            : Icons.gpp_bad_outlined;
    final Color color = timeout
        ? AppColors.textMuted
        : correct
            ? AppColors.success
            : AppColors.danger;
    final String headline = timeout ? "TIME'S UP" : 'CASE CLOSED';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _Reveal(animation: stage, scale: true, child: _HeaderPart(
          icon: icon,
          color: color,
          headline: headline,
          timeout: timeout,
          correct: correct,
          mystery: mystery,
          onBack: onBack,
        )),
        const SizedBox(height: AppSpacing.xl),
        _Reveal(animation: answersAnim, child: _AnswersPart(
          timeout: timeout,
          correct: correct,
          mystery: mystery,
          session: session,
        )),
        const SizedBox(height: AppSpacing.xl),
        _Reveal(animation: explanationAnim, child: ExplanationSection(
          explanation: mystery.explanation,
          clues: mystery.clues,
        )),
        const SizedBox(height: AppSpacing.xl),
        _Reveal(animation: xpAnim, scale: true, child: _XpPart(
          xp: session.xpReward,
          animation: xpAnim,
          timeout: timeout,
        )),
        const SizedBox(height: AppSpacing.xl),
        _Reveal(animation: actionsAnim, child: _ActionsPart(
          onTryAgain: onTryAgain,
          onReturnHome: onReturnHome,
        )),
      ],
    );
  }
}

class _HeaderPart extends StatelessWidget {
  const _HeaderPart({
    required this.icon,
    required this.color,
    required this.headline,
    required this.timeout,
    required this.correct,
    required this.mystery,
    required this.onBack,
  });

  final IconData icon;
  final Color color;
  final String headline;
  final bool timeout;
  final bool correct;
  final Mystery mystery;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Row(
          children: <Widget>[
            IconButton(
              onPressed: onBack,
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
        const SizedBox(height: AppSpacing.xl),
        Icon(icon, size: 56, color: color),
        const SizedBox(height: AppSpacing.md),
        Text(
          headline,
          textAlign: TextAlign.center,
          style: AppTypography.displayLarge.copyWith(color: color),
        ),
        if (!timeout) ...<Widget>[
          const SizedBox(height: AppSpacing.sm),
          Text(
            correct ? '✓ SOLVED' : '✕ CASE UNSOLVED',
            textAlign: TextAlign.center,
            style: AppTypography.title.copyWith(color: color),
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        Text(
          mystery.title,
          textAlign: TextAlign.center,
          style: AppTypography.subtitle,
        ),
      ],
    );
  }
}

class _AnswersPart extends StatelessWidget {
  const _AnswersPart({
    required this.timeout,
    required this.correct,
    required this.mystery,
    required this.session,
  });

  final bool timeout;
  final bool correct;
  final Mystery mystery;
  final CaseSession session;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SectionHeader(title: 'RESULT'),
        const SizedBox(height: AppSpacing.md),
        _ResultLine(
          icon: Icons.schedule,
          color: timeout ? AppColors.textMuted : AppColors.accent,
          text: correct
              ? 'Solved in ${_secondsText(session.solveTimeSeconds ?? 0)}.'
              : timeout
                  ? 'No answer was submitted — time ran out.'
                  : 'You were close.',
        ),
        const SizedBox(height: AppSpacing.xl),
        if (correct) ...<Widget>[
          const SectionHeader(title: 'CORRECT ANSWER'),
          const SizedBox(height: AppSpacing.md),
          _AnswerRow(
            text: _answerText(mystery.correctAnswerId),
            ok: true,
          ),
        ],
        if (!correct && !timeout) ...<Widget>[
          const SectionHeader(title: 'YOUR ANSWER'),
          const SizedBox(height: AppSpacing.md),
          _AnswerRow(text: _answerText(session.submittedAnswerId), ok: false),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'CORRECT ANSWER'),
          const SizedBox(height: AppSpacing.md),
          _AnswerRow(text: _answerText(mystery.correctAnswerId), ok: true),
        ],
        if (timeout) ...<Widget>[
          const SectionHeader(title: 'CORRECT ANSWER'),
          const SizedBox(height: AppSpacing.md),
          _AnswerRow(text: _answerText(mystery.correctAnswerId), ok: true),
        ],
      ],
    );
  }

  String? _answerText(String? answerId) {
    if (answerId == null) {
      return null;
    }
    for (final AnswerOption option in mystery.answers) {
      if (option.id == answerId) {
        return option.text;
      }
    }
    return null;
  }

  String _secondsText(int seconds) => seconds == 1 ? '1 second' : '$seconds seconds';
}

class _AnswerRow extends StatelessWidget {
  const _AnswerRow({required this.text, required this.ok});

  final String? text;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    final Color color = ok ? AppColors.success : AppColors.danger;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: ok ? AppColors.successFaint : AppColors.dangerFaint,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.55)),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: <Widget>[
          Icon(ok ? Icons.check : Icons.close, color: color),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              ok
                  ? text ?? '—'
                  : (text ?? 'No answer was submitted.'),
              style: AppTypography.body.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultLine extends StatelessWidget {
  const _ResultLine({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 18, color: color),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Text(text, style: AppTypography.bodySecondary),
          ),
        ),
      ],
    );
  }
}

class _XpPart extends StatelessWidget {
  const _XpPart({
    required this.xp,
    required this.animation,
    required this.timeout,
  });

  final int xp;
  final Animation<double> animation;
  final bool timeout;

  @override
  Widget build(BuildContext context) {
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
          Text('XP EARNED', style: AppTypography.overline),
          const SizedBox(height: AppSpacing.md),
          AnimatedBuilder(
            animation: animation,
            builder: (BuildContext context, Widget? child) {
              final int shown = (animation.value * xp).round();
              return Text(
                '+$shown XP',
                style: AppTypography.displayMedium.copyWith(
                  color: timeout ? AppColors.textMuted : AppColors.accent,
                  letterSpacing: 1.0,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ActionsPart extends StatelessWidget {
  const _ActionsPart({
    required this.onTryAgain,
    required this.onReturnHome,
  });

  final VoidCallback onTryAgain;
  final VoidCallback onReturnHome;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PrimaryButton(
          label: 'RETURN TO HQ',
          icon: Icons.home_outlined,
          expanded: true,
          onPressed: onReturnHome,
        ),
        const SizedBox(height: AppSpacing.sm),
        SecondaryButton(
          label: 'TRY AGAIN',
          icon: Icons.replay,
          expanded: true,
          onPressed: onTryAgain,
        ),
      ],
    );
  }
}

/// Subtle fade (+ optional scale) reveal for a staggered section.
class _Reveal extends StatelessWidget {
  const _Reveal({
    required this.animation,
    required this.child,
    this.scale = false,
  });

  final Animation<double> animation;
  final Widget child;
  final bool scale;

  @override
  Widget build(BuildContext context) {
    Widget result = FadeTransition(opacity: animation, child: child);
    if (scale) {
      result = ScaleTransition(
        scale: Tween<double>(begin: 0.88, end: 1.0).animate(animation),
        child: result,
      );
    }
    result = SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.06),
        end: Offset.zero,
      ).animate(animation),
      child: result,
    );
    return result;
  }
}