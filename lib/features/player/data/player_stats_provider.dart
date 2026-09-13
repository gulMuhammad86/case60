import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/xp_service.dart';
import '../domain/player_stats.dart';

/// Mutable detective progression; the home screen's read API is unchanged.
///
/// In-memory on purpose until real persistence lands — swap `build()` for a
/// storage-backed read later without touching callers.
final class PlayerStatsController extends Notifier<PlayerStats> {
  PlayerStatsController({
    this.initial = const PlayerStats(
      streakDays: 7,
      level: 12,
      xpCurrent: 1380,
      xpForNextLevel: 2400,
    ),
  });

  /// Starting snapshot (override in tests through `overrideWith`).
  final PlayerStats initial;

  @override
  PlayerStats build() => initial;

  /// Adds [amount] XP, crossing level boundaries via the [XPService] curve.
  ///
  /// Non-positive amounts are ignored so a `0`-XP timeout is never recorded.
  void awardXp(int amount) {
    if (amount <= 0) {
      return;
    }
    final XPService xp = ref.read(xpServiceProvider);
    final PlayerStats current = state;

    int level = current.level;
    int xpIntoLevel = current.xpCurrent + amount;
    int needed = xp.xpNeededForLevel(level);
    while (xpIntoLevel >= needed) {
      xpIntoLevel -= needed;
      level++;
      needed = xp.xpNeededForLevel(level);
    }

    state = PlayerStats(
      streakDays: current.streakDays,
      level: level,
      xpCurrent: xpIntoLevel,
      xpForNextLevel: needed,
    );
  }
}

/// Single source of truth for the detective's progression.
final NotifierProvider<PlayerStatsController, PlayerStats>
playerStatsProvider =
    NotifierProvider<PlayerStatsController, PlayerStats>(
      PlayerStatsController.new,
    );