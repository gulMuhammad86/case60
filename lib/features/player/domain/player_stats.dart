/// Immutable snapshot of a detective's progression.
///
/// Currently placeholder-only until a real progression and persistence layer
/// is introduced; the fields mirror what the home screen surfaces today.
final class PlayerStats {
  const PlayerStats({
    required this.streakDays,
    required this.level,
    required this.xpCurrent,
    required this.xpForNextLevel,
  });

  final int streakDays;
  final int level;
  final int xpCurrent;
  final int xpForNextLevel;

  /// Fraction of the current level's XP earned, clamped to `0..1`.
  double get xpProgress {
    if (xpForNextLevel <= 0) {
      return 0;
    }
    return (xpCurrent / xpForNextLevel).clamp(0.0, 1.0).toDouble();
  }
}