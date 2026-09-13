import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/mystery_difficulty.dart';

/// Configurable scoring rules for a finished case.
///
/// Kept in one place so tuning numbers never scatters into widgets. Every
/// field can be overridden through [scoringConfigProvider] in tests.
final class ScoringConfig {
  const ScoringConfig({
    this.basePointsByDifficulty = const <MysteryDifficulty, int>{
      MysteryDifficulty.easy: 50,
      MysteryDifficulty.medium: 75,
      MysteryDifficulty.hard: 100,
    },
    this.incorrectFactor = 0.25,
    this.minTimeMultiplier = 0.5,
    this.hintPenaltyPerUse = 0.15,
    this.maxHintPenalty = 0.6,
  });

  /// Base points awarded for a correct solve, per [MysteryDifficulty].
  final Map<MysteryDifficulty, int> basePointsByDifficulty;

  /// Fraction of the base points kept when the wrong answer is submitted.
  final double incorrectFactor;

  /// Lowest possible time multiplier (`1.0` for an instant solve).
  final double minTimeMultiplier;

  /// Fraction of the score lost per hint used.
  final double hintPenaltyPerUse;

  /// Ceiling on the accumulated hint penalty.
  final double maxHintPenalty;

  int basePointsFor(MysteryDifficulty difficulty) {
    return basePointsByDifficulty[difficulty] ?? 50;
  }
}

/// Computes the score for a finished case from the configured rules.
final class ScoringService {
  const ScoringService(this.config);

  final ScoringConfig config;

  /// Scores a submitted case.
  ///
  /// [remainingSecondsAfterSolve] is the time left on the clock the moment the
  /// answer was submitted; [timeLimitSeconds] is the case budget. A timeout
  /// (no submission) scores `0` and never reaches this service.
  int score({
    required bool correct,
    required MysteryDifficulty difficulty,
    required int remainingSecondsAfterSolve,
    required int timeLimitSeconds,
    required int hintsUsed,
  }) {
    final double base = config.basePointsFor(difficulty).toDouble();
    final double correctnessFactor = correct ? 1.0 : config.incorrectFactor;

    double timeFactor = 1.0;
    if (timeLimitSeconds > 0) {
      final double left =
          (remainingSecondsAfterSolve / timeLimitSeconds).clamp(
            config.minTimeMultiplier,
            1.0,
          );
      timeFactor = left;
    }

    final double penalty =
        (hintsUsed * config.hintPenaltyPerUse).clamp(
          0.0,
          config.maxHintPenalty,
        );
    final double hintFactor = 1.0 - penalty;

    final double raw = base * correctnessFactor * timeFactor * hintFactor;
    if (raw <= 0) {
      return 0;
    }
    return raw.round();
  }
}

/// The active [ScoringConfig] for the app.
final Provider<ScoringConfig> scoringConfigProvider =
    Provider<ScoringConfig>((Ref ref) => const ScoringConfig());

/// The active [ScoringService], bound to [scoringConfigProvider].
final Provider<ScoringService> scoringServiceProvider =
    Provider<ScoringService>((Ref ref) {
  return ScoringService(ref.watch(scoringConfigProvider));
});