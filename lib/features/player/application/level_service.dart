import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A named detective rank with the total XP required to reach it.
final class LevelTier {
  const LevelTier({required this.xpThreshold, required this.title});

  /// Total XP at which this rank is reached (cumulative).
  final int xpThreshold;

  /// Display name for the rank, e.g. `Rookie` or `Legendary Detective`.
  final String title;
}

/// Configurable level/rank ladder driven by total XP.
///
/// Defaults follow the classic progression (Rookie → Legendary Detective);
/// override via [levelConfigProvider] to tune the curve.
final class LevelConfig {
  const LevelConfig({this.tiers = defaultTiers});

  /// Rank tiers, ordered by ascending [LevelTier.xpThreshold].
  final List<LevelTier> tiers;

  static const List<LevelTier> defaultTiers = <LevelTier>[
    LevelTier(xpThreshold: 0, title: 'Rookie'),
    LevelTier(xpThreshold: 300, title: 'Detective'),
    LevelTier(xpThreshold: 750, title: 'Inspector'),
    LevelTier(xpThreshold: 1400, title: 'Senior Inspector'),
    LevelTier(xpThreshold: 2300, title: 'Chief Inspector'),
    LevelTier(xpThreshold: 3500, title: 'Master Detective'),
    LevelTier(xpThreshold: 5000, title: 'Legendary Detective'),
  ];
}

/// Placement within the level progression for a total-XP amount.
final class LevelProgress {
  const LevelProgress({
    required this.level,
    required this.xpIntoLevel,
    required this.xpForNextLevel,
  });

  /// 1-based level number.
  final int level;

  /// XP earned inside the current level.
  final int xpIntoLevel;

  /// XP needed to leave the current level and reach the next one.
  final int xpForNextLevel;

  /// Fraction of the current level earned, clamped to `0..1`.
  double get progress {
    if (xpForNextLevel <= 0) {
      return 0;
    }
    return (xpIntoLevel / xpForNextLevel).clamp(0.0, 1.0).toDouble();
  }
}

/// Maps a total-XP amount onto the configured rank ladder.
///
/// Stateless on purpose: level derivation stays pure and testable; persisting
/// the XP total is the player controller's job.
final class LevelService {
  const LevelService(this.config);

  final LevelConfig config;

  /// The level reached at [totalXp] (1-based).
  int levelForXp(int totalXp) => progressForXp(totalXp).level;

  /// The rank title shown for [level].
  String titleForLevel(int level) {
    final List<LevelTier> tiers = config.tiers;
    final int index = level - 1;
    if (index < tiers.length) {
      return tiers[index].title;
    }
    return tiers.last.title;
  }

  /// Resolves (level, in-level XP, next-level XP) for a total-XP amount.
  LevelProgress progressForXp(int totalXp) {
    final List<LevelTier> tiers = config.tiers;
    final int effective = totalXp < 0 ? 0 : totalXp;

    int index = 0;
    for (int i = 0; i < tiers.length; i++) {
      if (tiers[i].xpThreshold <= effective) {
        index = i;
      }
    }

    final LevelTier current = tiers[index];
    return LevelProgress(
      level: index + 1,
      xpIntoLevel: effective - current.xpThreshold,
      xpForNextLevel: _gapForLevel(index),
    );
  }

  int _gapForLevel(int index) {
    final List<LevelTier> tiers = config.tiers;
    if (index + 1 < tiers.length) {
      return tiers[index + 1].xpThreshold - tiers[index].xpThreshold;
    }
    if (index > 0) {
      return tiers[index].xpThreshold - tiers[index - 1].xpThreshold;
    }
    return 1;
  }
}

/// The active [LevelConfig] for the app.
final Provider<LevelConfig> levelConfigProvider = Provider<LevelConfig>((_) {
  return const LevelConfig();
});

/// The active [LevelService], bound to [levelConfigProvider].
final Provider<LevelService> levelServiceProvider = Provider<LevelService>((
  Ref ref,
) {
  return LevelService(ref.watch(levelConfigProvider));
});