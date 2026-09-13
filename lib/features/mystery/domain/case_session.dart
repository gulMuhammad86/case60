import '../../../core/constants/app_constants.dart';
import 'models/mystery.dart';

/// Explicit life-cycle of a single case-solving session.
///
/// Prefer a phase switch over boolean flags everywhere a session is discussed.
enum CasePhase {
  /// No case has been started (idle / after a reset).
  initial,

  /// The case is being prepared (e.g. pulled from storage).
  loading,

  /// The case is loaded and about to make the timer visible.
  ready,

  /// The player is actively investigating; the timer is running.
  inProgress,

  /// An answer was submitted; the verdict is being compiled.
  submitted,

  /// The case finished with an answer submitted.
  completed,

  /// The timer expired before a submission.
  timeout,

  /// The session failed unexpectedly.
  error,
}

/// Immutable snapshot of a case-playing session.
final class CaseSession {
  const CaseSession({
    this.phase = CasePhase.initial,
    this.mystery,
    this.remainingSeconds = 0,
    this.selectedAnswerId,
    this.submittedAnswerId,
    this.isCorrect,
    this.solveTimeSeconds,
    this.hintsUsed = 0,
    this.score = 0,
    this.xpReward = 0,
    this.outcomeRecorded = false,
    this.error,
  });

  final CasePhase phase;
  final Mystery? mystery;
  final int remainingSeconds;
  final String? selectedAnswerId;
  final String? submittedAnswerId;
  final bool? isCorrect;
  final int? solveTimeSeconds;

  /// Number of hints consumed while solving (feeds score/XP penalties).
  final int hintsUsed;

  /// Points earned for this attempt, computed from [ScoringService].
  final int score;

  /// XP reward carried on completion, ready to display on the results screen.
  final int xpReward;

  /// Whether the final outcome (profile + history) has been applied.
  final bool outcomeRecorded;

  final Object? error;

  /// Effective time budget, falling back to the core default.
  int get timeLimitSeconds => mystery?.timeLimitSeconds ?? AppConstants.caseSeconds;

  Duration get timeLimit => Duration(seconds: timeLimitSeconds);

  Duration get remaining => Duration(seconds: remainingSeconds);

  Duration? get solveTime {
    final int? seconds = solveTimeSeconds;
    return seconds == null ? null : Duration(seconds: seconds);
  }

  /// Whether the player is mid-case (allowed to interact).
  bool get isActive =>
      phase == CasePhase.inProgress || phase == CasePhase.submitted;

  /// Whether the case is finished and can only be replayed.
  bool get isTerminal =>
      phase == CasePhase.completed || phase == CasePhase.timeout;

  CaseSession copyWith({
    CasePhase? phase,
    Mystery? mystery,
    int? remainingSeconds,
    String? selectedAnswerId,
    String? submittedAnswerId,
    bool? isCorrect,
    int? solveTimeSeconds,
    int? hintsUsed,
    int? score,
    int? xpReward,
    bool? outcomeRecorded,
    Object? error,
    bool clearError = false,
  }) {
    return CaseSession(
      phase: phase ?? this.phase,
      mystery: mystery ?? this.mystery,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      selectedAnswerId: selectedAnswerId ?? this.selectedAnswerId,
      submittedAnswerId: submittedAnswerId ?? this.submittedAnswerId,
      isCorrect: isCorrect ?? this.isCorrect,
      solveTimeSeconds: solveTimeSeconds ?? this.solveTimeSeconds,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      score: score ?? this.score,
      xpReward: xpReward ?? this.xpReward,
      outcomeRecorded: outcomeRecorded ?? this.outcomeRecorded,
      error: clearError ? null : (error ?? this.error),
    );
  }
}