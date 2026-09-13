import 'package:flutter_test/flutter_test.dart';

import 'package:case60/features/player/application/level_service.dart';

void main() {
  const LevelService service = LevelService(LevelConfig());

  group('progressForXp', () {
    test('a fresh detective starts on level one', () {
      final LevelProgress progress = service.progressForXp(0);
      expect(progress.level, 1);
      expect(progress.xpIntoLevel, 0);
      expect(progress.xpForNextLevel, 300);
    });

    test('hitting the next threshold exactly lands on the next level', () {
      final LevelProgress progress = service.progressForXp(300);
      expect(progress.level, 2);
      expect(progress.xpIntoLevel, 0);
      expect(progress.xpForNextLevel, 450);
    });

    test('reports XP within the current band', () {
      final LevelProgress progress = service.progressForXp(1240);
      expect(progress.level, 3);
      expect(progress.xpIntoLevel, 490);
      expect(progress.xpForNextLevel, 650);
    });

    test('continues past the last configured tier', () {
      final LevelProgress progress = service.progressForXp(5000);
      expect(progress.level, 7);
      expect(progress.xpIntoLevel, 0);
      expect(progress.xpForNextLevel, 1500);
    });

    test('negative XP is clamped to zero', () {
      expect(service.progressForXp(-50).level, 1);
      expect(service.progressForXp(-50).xpIntoLevel, 0);
    });

    test('progress fraction clamps into the band', () {
      expect(service.progressForXp(150).progress, 0.5);
      expect(service.progressForXp(0).progress, 0);
    });
  });

  group('titles', () {
    test('maps levels to ranked titles', () {
      expect(service.titleForLevel(1), 'Rookie');
      expect(service.titleForLevel(4), 'Senior Inspector');
      expect(service.titleForLevel(7), 'Legendary Detective');
    });

    test('beyond the last tier keeps the top title', () {
      expect(service.titleForLevel(12), 'Legendary Detective');
    });
  });

  group('configurability', () {
    test('honours a custom threshold ladder', () {
      const LevelConfig custom = LevelConfig(
        tiers: <LevelTier>[
          LevelTier(xpThreshold: 0, title: 'Cadet'),
          LevelTier(xpThreshold: 100, title: 'Veteran'),
        ],
      );
      const LevelService customService = LevelService(custom);

      expect(customService.progressForXp(0).level, 1);
      expect(customService.progressForXp(100).level, 2);
      expect(customService.titleForLevel(1), 'Cadet');
      expect(customService.titleForLevel(2), 'Veteran');
    });

    test('a single-tier config never divides by zero', () {
      const LevelConfig single = LevelConfig(
        tiers: <LevelTier>[LevelTier(xpThreshold: 0, title: 'Solo')],
      );
      const LevelService singleService = LevelService(single);
      final LevelProgress progress = singleService.progressForXp(42);
      expect(progress.level, 1);
      expect(progress.xpForNextLevel, 1);
    });
  });
}