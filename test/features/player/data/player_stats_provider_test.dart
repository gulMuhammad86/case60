import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:case60/features/player/application/xp_service.dart';
import 'package:case60/features/player/data/player_stats_provider.dart';
import 'package:case60/features/player/domain/player_stats.dart';

void main() {
  // A flat 100 XP-per-level curve so boundaries are trivial to assert.
  ProviderContainer buildContainer({
    PlayerStats initial = const PlayerStats(
      streakDays: 0,
      level: 1,
      xpCurrent: 95,
      xpForNextLevel: 100,
    ),
  }) {
    return ProviderContainer(
      overrides: [
        xpServiceProvider.overrideWithValue(
          const XPService(XPConfig(baseXpForLevel: 100, levelGrowth: 1.0)),
        ),
        playerStatsProvider.overrideWith(
          () => PlayerStatsController(initial: initial),
        ),
      ],
    );
  }

  test('awardXp accumulates XP and crosses level boundaries', () {
    final ProviderContainer container = buildContainer();
    addTearDown(container.dispose);
    final PlayerStatsController controller =
        container.read(playerStatsProvider.notifier);

    controller.awardXp(10);

    PlayerStats stats = container.read(playerStatsProvider);
    expect(stats.level, 2);
    expect(stats.xpCurrent, 5);
    expect(stats.xpForNextLevel, 100);

    controller.awardXp(250);

    stats = container.read(playerStatsProvider);
    expect(stats.level, 4);
    expect(stats.xpCurrent, 55);
    expect(stats.xpForNextLevel, 100);
  });

  test('awardXp ignores zero and negative amounts', () {
    final ProviderContainer container = buildContainer();
    addTearDown(container.dispose);
    final PlayerStatsController controller =
        container.read(playerStatsProvider.notifier);

    controller.awardXp(0);
    controller.awardXp(-20);

    final PlayerStats stats = container.read(playerStatsProvider);
    expect(stats.level, 1);
    expect(stats.xpCurrent, 95);
  });

  test('preserves unrelated progression fields while awarding', () {
    final ProviderContainer container = buildContainer(
      initial: const PlayerStats(
        streakDays: 12,
        level: 3,
        xpCurrent: 40,
        xpForNextLevel: 100,
      ),
    );
    addTearDown(container.dispose);
    container.read(playerStatsProvider.notifier).awardXp(10);

    final PlayerStats stats = container.read(playerStatsProvider);
    expect(stats.streakDays, 12);
    expect(stats.level, 3);
    expect(stats.xpCurrent, 50);
  });
}