import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../mystery/domain/mystery_difficulty.dart';

/// Configurable XP rewards for finishing a case.
///
/// All tuning numbers live here (and in [XPConfig.levelGrowth]) so widgets and
/// controllers never hard-code XP values. Overridable via [xpConfigProvider].
final class XPConfig {
  const XPConfig({
    this.baseXpByDifficulty = const <MysteryDifficulty, int>{
      MysteryDifficulty.easy: 80,
      MysteryDifficulty.medium: 110,
      MysteryDifficulty.hard: 150,
    },
    this.speedBonusMax = 20,
    this.incorrectXp = 15,
    this.timeoutXp = 0,
    this.hintPenaltyXp = 10,
    this.maxHintPenaltyXp = 40,
    this.baseXpForLevel = 200,
    this.levelGrowth = 1.15,
  });

  /// XP awarded for a correct solve, per [MysteryDifficulty].
  final Map<MysteryDifficulty, int> baseXpByDifficulty;

  /// Extra XP scaled by how much of the clock remained at submission.
  final int speedBonusMax;

  /// Flat XP for an incorrect submission (before hint deductions).
  final int incorrectXp;

  /// XP for a timeout (no submission).
  final int timeoutXp;

  /// XP deducted per hint used while solving.
  final int hintPenaltyXp;

  /// Ceiling on total XP deducted for hints.
  final int maxHintPenaltyXp;

  /// XP needed to pass from level 1 to 2; later levels grow by [levelGrowth].
  final int baseXpForLevel;

  /// Per-level XP growth factor, keeping the curve configurable and extensible.
  final double levelGrowth;

  int baseXpFor(MysteryDifficulty difficulty) {
    return baseXpByDifficulty[difficulty] ?? 80;
  }
}

/// A single rewarded amount, kept explicit so call sites stay readable.
final class XpAward {
  const XpAward({required this.xp});

  final int xp;
}

/// Placement within the level progression for a total-XP amount.
final class LevelProgress {
  const LevelProgress({
    required this.level,
    required this.xpIntoLevel,
    required this.xpForNextLevel,
  });

  final int level;
  final int xpIntoLevel;
  final int xpForNextLevel;

  /// Fraction of the current level earned, clamped to `0..1`.
  double get progress {
    if (xpForNextLevel <= 0) {
      return 0;
    }
    return (xpIntoLevel / xpForNextLevel).clamp(0.0, 1.0).toDouble();
  }
}

/// Computes XP rewards and level progression from the configured rules.
///
/// Stateless on purpose: the delta stays pure and testable; applying it to
/// persistent stats is the player controller's job.
final class XPService {
  const XPService(this.config);

  final XPConfig config;

  /// The XP reward for finishing a case.
  ///
  /// * correct  → difficulty base + speed bonus (scaled by clock left),
  ///   minus hint deductions;
  /// * incorrect → flat [XPConfig.incorrectXp], minus hint deductions;
  /// * timeout is never submitted here (the controller uses `timeoutXp`).
  XpAward award({
    required bool correct,
    required MysteryDifficulty difficulty,
    required int remainingSecondsAfterSolve,
    required int timeLimitSeconds,
    required int hintsUsed,
  }) {
    if (!correct) {
      return XpAward(xp: max(0, config.incorrectXp - _hintDeduction(hintsUsed)));
    }

    final double remainingFraction =
        timeLimitSeconds > 0
            ? (remainingSecondsAfterSolve / timeLimitSeconds).clamp(0.0, 1.0)
            : 1.0;
    final int speedBonus = (config.speedBonusMax * remainingFraction).round();
    final int xp =
        config.baseXpFor(difficulty) + speedBonus - _hintDeduction(hintsUsed);
    return XpAward(xp: max(0, xp));
  }

  /// XP needed to go from [level] to the next level.
  ///
  /// Empty/harmless onboarding values are clamped to at least `1` XP so the
  /// award loop can never stall.
  int xpNeededForLevel(int level) {
    final int safeLevel = max(1, level);
    final int needed =
        (config.baseXpForLevel * pow(config.levelGrowth, safeLevel - 1))
            .round();
    return max(1, needed);
  }

  /// Maps an absolute XP total onto a (level, in-level) [LevelProgress].
  ///
  /// Useful for persistence/restores; live play uses `xpNeededForLevel` so it
  /// can continue from a snapshot.
  LevelProgress progressForTotal(int totalXp) {
    int level = 1;
    int remaining = max(0, totalXp);
    int needed = xpNeededForLevel(level);
    while (remaining >= needed) {
      remaining -= needed;
      level++;
      needed = xpNeededForLevel(level);
    }
    return LevelProgress(
      level: level,
      xpIntoLevel: remaining,
      xpForNextLevel: needed,
    );
  }

  int _hintDeduction(int hintsUsed) {
    return min(hintsUsed * config.hintPenaltyXp, config.maxHintPenaltyXp);
  }
}

/// The active [XPConfig] for the app.
final Provider<XPConfig> xpConfigProvider = Provider<XPConfig>((Ref ref) {
  return const XPConfig();
});

/// The active [XPService], bound to [xpConfigProvider].
final Provider<XPService> xpServiceProvider = Provider<XPService>((Ref ref) {
  return XPService(ref.watch(xpConfigProvider));
});