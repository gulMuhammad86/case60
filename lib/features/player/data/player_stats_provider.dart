import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/player_stats.dart';

/// Placeholder local stats until real progression and persistence lands.
///
/// Synchronous on purpose so the home screen renders without a loading flash;
/// swap the body for storage-backed reads once progression ships.
final Provider<PlayerStats> playerStatsProvider = Provider<PlayerStats>((
  Ref ref,
) {
  return const PlayerStats(
    streakDays: 7,
    level: 12,
    xpCurrent: 1380,
    xpForNextLevel: 2400,
  );
});