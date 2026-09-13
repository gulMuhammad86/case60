import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/app_clock.dart';
import '../../../core/timer/case_countdown.dart';
import '../../history/data/history_provider.dart';
import '../../player/application/case_outcome_recorder.dart';
import '../../player/application/streak_service.dart';
import '../../player/application/xp_service.dart';
import '../../player/data/detective_profile_provider.dart';
import '../../player/domain/detective_profile.dart';
import '../domain/case_session.dart';
import '../domain/models/answer_option.dart';
import '../domain/models/mystery.dart';
import 'scoring.dart';

/// Single source of truth for the active case-playing session.
///
/// Holds the countdown timer, so the session — and the timer — survive widget
/// rebuilds and route navigation. All timer business logic lives here, never
/// in a widget.
final NotifierProvider<CaseController, CaseSession> caseControllerProvider =
    NotifierProvider<CaseController, CaseSession>(CaseController.new);

/// Drives the state machine (`initial → loading → ready → inProgress →
/// submitted → completed`, plus `timeout` and `error`).
final class CaseController extends Notifier<CaseSession> {
  CaseCountdown? _countdown;

  @override
  CaseSession build() {
    ref.onDispose(() => _countdown?.dispose());
    return const CaseSession();
  }

  /// Starts a fresh session for [mystery].
  ///
  /// Refuses to start when the case's day has already been solved (the daily
  /// lock prevents replaying today's case for another score). Resumes an
  /// already-active session unchanged (and never starts a second timer). After
  /// a terminal phase it clears the slate for a new attempt.
  void begin(Mystery mystery) {
    final CasePhase phase = state.phase;
    final bool locked = ref.read(streakServiceProvider).completedOn(
      ref.read(detectiveProfileProvider).lastCompletedDate,
      mystery.availableDate,
    );
    if (locked) {
      return;
    }
    if (phase == CasePhase.inProgress ||
        phase == CasePhase.submitted ||
        phase == CasePhase.loading ||
        phase == CasePhase.ready) {
      return;
    }

    _countdown?.dispose();
    _countdown = null;

    state = CaseSession(
      phase: CasePhase.loading,
      mystery: mystery,
      remainingSeconds: mystery.timeLimitSeconds,
    );
    state = state.copyWith(phase: CasePhase.ready);
    _startCountdown(mystery.timeLimitSeconds);
    state = state.copyWith(phase: CasePhase.inProgress);
  }

  /// Selects an answer option while the case is in progress.
  ///
  /// Ignores unknown ids and any selection outside of active gameplay.
  void selectAnswer(String answerId) {
    final CaseSession current = state;
    final Mystery? mystery = current.mystery;
    if (mystery == null || current.phase != CasePhase.inProgress) {
      return;
    }
    final bool known = mystery.answers.any(
      (AnswerOption answer) => answer.id == answerId,
    );
    if (!known) {
      return;
    }
    state = current.copyWith(selectedAnswerId: answerId);
  }

  /// Submits the selected answer, freezing the timer, scoring the attempt,
  /// and recording the outcome (XP, stats, streak, history) exactly once.
  ///
  /// Safe against duplicate submissions: once the phase leaves `inProgress`,
  /// further calls are ignored. The outcome is applied to player progression
  /// and history here so finishing a case banks everything once per attempt.
  void submit() {
    final CaseSession current = state;
    final Mystery? mystery = current.mystery;
    final String? selected = current.selectedAnswerId;
    if (mystery == null ||
        current.phase != CasePhase.inProgress ||
        selected == null) {
      return;
    }

    _countdown?.stop();
    final int remainingNow =
        _countdown?.remaining.inSeconds ?? current.remainingSeconds;
    int solved = mystery.timeLimitSeconds - remainingNow;
    if (solved < 0) {
      solved = 0;
    }
    if (solved > mystery.timeLimitSeconds) {
      solved = mystery.timeLimitSeconds;
    }

    final bool correct = selected == mystery.correctAnswerId;

    final int score = ref.read(scoringServiceProvider).score(
      correct: correct,
      difficulty: mystery.difficulty,
      remainingSecondsAfterSolve: remainingNow,
      timeLimitSeconds: mystery.timeLimitSeconds,
      hintsUsed: current.hintsUsed,
    );
    final int xpReward = ref
        .read(xpServiceProvider)
        .award(
          correct: correct,
          difficulty: mystery.difficulty,
          remainingSecondsAfterSolve: remainingNow,
          timeLimitSeconds: mystery.timeLimitSeconds,
          hintsUsed: current.hintsUsed,
        )
        .xp;

    state = current.copyWith(
      phase: CasePhase.submitted,
      submittedAnswerId: selected,
      isCorrect: correct,
      solveTimeSeconds: solved,
      score: score,
      xpReward: xpReward,
    );

    _recordOutcome(
      mystery: mystery,
      solved: correct,
      solveTimeSeconds: solved,
      xpReward: xpReward,
    );

    state = state.copyWith(phase: CasePhase.completed, outcomeRecorded: true);
  }

  /// Consumes the next hint while solving.
  ///
  /// Deductions flow into [ScoringService]/[XPService]; capped by the number
  /// of hints the case actually has, and a no-op outside active gameplay.
  void useHint() {
    final CaseSession current = state;
    final Mystery? mystery = current.mystery;
    if (mystery == null || current.phase != CasePhase.inProgress) {
      return;
    }
    if (current.hintsUsed >= mystery.hints.length) {
      return;
    }
    state = current.copyWith(hintsUsed: current.hintsUsed + 1);
  }

  /// Returns the session to its idle state and halts the timer.
  void reset() {
    _countdown?.dispose();
    _countdown = null;
    state = const CaseSession();
  }

  void _recordOutcome({
    required Mystery mystery,
    required bool solved,
    required int solveTimeSeconds,
    required int xpReward,
  }) {
    if (state.outcomeRecorded) {
      return;
    }
    final DateTime now = ref.read(appClockProvider).now();
    final DetectiveProfile profile = ref.read(detectiveProfileProvider);
    final RecordedCaseOutcome outcome = ref.read(caseOutcomeRecorderProvider).record(
      profile: profile,
      solved: solved,
      solveTimeSeconds: solveTimeSeconds,
      xpReward: xpReward,
      caseNumber: mystery.caseNumber,
      now: now,
    );
    ref.read(detectiveProfileProvider.notifier).replace(outcome.profile);
    ref.read(historyProvider.notifier).add(outcome.entry);
  }

  void _startCountdown(int seconds) {
    final CaseCountdown countdown = CaseCountdown(
      duration: Duration(seconds: seconds < 0 ? 0 : seconds),
      onTick: (Duration remaining) {
        state = state.copyWith(remainingSeconds: remaining.inSeconds);
      },
      onComplete: _handleTimeout,
    );
    _countdown = countdown;
    countdown.start();
  }

  void _handleTimeout() {
    _countdown?.dispose();
    _countdown = null;
    state = CaseSession(
      phase: CasePhase.timeout,
      mystery: state.mystery,
      remainingSeconds: 0,
    );
    final Mystery? mystery = state.mystery;
    if (mystery != null) {
      _recordOutcome(
        mystery: mystery,
        solved: false,
        solveTimeSeconds: mystery.timeLimitSeconds,
        xpReward: 0,
      );
    }
    state = state.copyWith(outcomeRecorded: true);
  }
}