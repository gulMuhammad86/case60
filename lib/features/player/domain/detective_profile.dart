import 'dart:math';

/// Immutable snapshot of a detective's persistent progress.
///
/// Only raw, persistable facts live here — level, XP-in-level and the
/// effective streak are *derived* by services ([LevelService], [StreakService])
/// at read time, so the stored shape never goes stale.
final class DetectiveProfile {
  const DetectiveProfile({
    this.totalXp = 0,
    this.streakDays = 0,
    this.lastCompletedDate,
    this.casesSolved = 0,
    this.casesFailed = 0,
    this.bestTimeSeconds,
    this.totalTimeSeconds = 0,
  });

  /// Cumulative XP earned across all attempts.
  final int totalXp;

  /// Consecutive days with a solved case, ending on [lastCompletedDate].
  final int streakDays;

  /// The last day (`yyyy-MM-dd`, local) a case was solved, if any.
  final String? lastCompletedDate;

  /// Cases solved correctly.
  final int casesSolved;

  /// Cases that ended in a wrong answer or a timeout.
  final int casesFailed;

  /// Fastest solve time in seconds, `null` until the first solve.
  final int? bestTimeSeconds;

  /// Sum of solve-time seconds across every attempt (for averages).
  final int totalTimeSeconds;

  /// Whether a best time has been recorded yet.
  bool get hasRecordedBestTime => bestTimeSeconds != null;

  /// Total attempts that count toward the solve-rate statistics.
  int get totalAttempts => casesSolved + casesFailed;

  /// Average solve-time in seconds, or `null` when there are no attempts.
  double? get averageTimeSeconds {
    if (totalAttempts <= 0) {
      return null;
    }
    return totalTimeSeconds / totalAttempts;
  }

  DetectiveProfile copyWith({
    int? totalXp,
    int? streakDays,
    String? lastCompletedDate,
    bool clearLastCompletedDate = false,
    int? casesSolved,
    int? casesFailed,
    int? bestTimeSeconds,
    bool clearBestTimeSeconds = false,
    int? totalTimeSeconds,
  }) {
    return DetectiveProfile(
      totalXp: totalXp ?? this.totalXp,
      streakDays: streakDays ?? this.streakDays,
      lastCompletedDate: clearLastCompletedDate
          ? null
          : (lastCompletedDate ?? this.lastCompletedDate),
      casesSolved: casesSolved ?? this.casesSolved,
      casesFailed: casesFailed ?? this.casesFailed,
      bestTimeSeconds: clearBestTimeSeconds
          ? null
          : (bestTimeSeconds ?? this.bestTimeSeconds),
      totalTimeSeconds: totalTimeSeconds ?? this.totalTimeSeconds,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is! DetectiveProfile) {
      return false;
    }
    return totalXp == other.totalXp &&
        streakDays == other.streakDays &&
        lastCompletedDate == other.lastCompletedDate &&
        casesSolved == other.casesSolved &&
        casesFailed == other.casesFailed &&
        bestTimeSeconds == other.bestTimeSeconds &&
        totalTimeSeconds == other.totalTimeSeconds;
  }

  @override
  int get hashCode {
    return Object.hash(
      totalXp,
      streakDays,
      lastCompletedDate,
      casesSolved,
      casesFailed,
      bestTimeSeconds,
      totalTimeSeconds,
    );
  }

  /// `${seconds} sec`, rounding fractional averages to whole seconds.
  static String formatSeconds(double seconds) {
    return '${max(0, seconds.round())} sec';
  }
}

/// The profile combined with its resolved rank/XP/streak display values.
///
/// Built by [detectiveStandingProvider] so widgets never run level/streak
/// math themselves.
final class DetectiveStanding {
  const DetectiveStanding({
    required this.profile,
    required this.level,
    required this.title,
    required this.xpIntoLevel,
    required this.xpForNextLevel,
    required this.streakDays,
  });

  final DetectiveProfile profile;

  /// 1-based detective level.
  final int level;

  /// Current rank title, e.g. `Detective`.
  final String title;

  /// XP earned inside the current level.
  final int xpIntoLevel;

  /// XP needed to reach the next level.
  final int xpForNextLevel;

  /// Displayed streak (survives until a full day is missed).
  final int streakDays;

  /// Fraction of the current level earned, clamped to `0..1`.
  double get xpProgress {
    if (xpForNextLevel <= 0) {
      return 0;
    }
    return (xpIntoLevel / xpForNextLevel).clamp(0.0, 1.0).toDouble();
  }
}