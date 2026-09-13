import 'package:flutter_test/flutter_test.dart';

import 'package:case60/features/mystery/domain/mystery_difficulty.dart';
import 'package:case60/features/player/application/xp_service.dart';

void main() {
  const XPService service = XPService(XPConfig());

  group('XPService.award', () {
    test('rewards the difficulty base plus full speed bonus when instant', () {
      final XpAward award = service.award(
        correct: true,
        difficulty: MysteryDifficulty.medium,
        remainingSecondsAfterSolve: 60,
        timeLimitSeconds: 60,
        hintsUsed: 0,
      );
      expect(award.xp, 130);
    });

    test('scales the speed bonus with time remaining', () {
      final XpAward award = service.award(
        correct: true,
        difficulty: MysteryDifficulty.medium,
        remainingSecondsAfterSolve: 30,
        timeLimitSeconds: 60,
        hintsUsed: 0,
      );
      expect(award.xp, 120);
    });

    test('hard difficulty earns more than easy', () {
      int easy = service
          .award(
            correct: true,
            difficulty: MysteryDifficulty.easy,
            remainingSecondsAfterSolve: 60,
            timeLimitSeconds: 60,
            hintsUsed: 0,
          )
          .xp;
      int hard = service
          .award(
            correct: true,
            difficulty: MysteryDifficulty.hard,
            remainingSecondsAfterSolve: 60,
            timeLimitSeconds: 60,
            hintsUsed: 0,
          )
          .xp;
      expect(easy, 100);
      expect(hard, 170);
      expect(hard, greaterThan(easy));
    });

    test('deducts XP per hint used and caps the deduction', () {
      int one = service
          .award(
            correct: true,
            difficulty: MysteryDifficulty.medium,
            remainingSecondsAfterSolve: 60,
            timeLimitSeconds: 60,
            hintsUsed: 1,
          )
          .xp;
      expect(one, 120);

      int many = service
          .award(
            correct: true,
            difficulty: MysteryDifficulty.medium,
            remainingSecondsAfterSolve: 60,
            timeLimitSeconds: 60,
            hintsUsed: 5,
          )
          .xp;
      expect(many, 90);
    });

    test('incorrect answers earn a small flat reward', () {
      final XpAward award = service.award(
        correct: false,
        difficulty: MysteryDifficulty.hard,
        remainingSecondsAfterSolve: 60,
        timeLimitSeconds: 60,
        hintsUsed: 0,
      );
      expect(award.xp, 15);
    });

    test('incorrect rewards can be wiped out by hints but never go negative',
        () {
      final XpAward award = service.award(
        correct: false,
        difficulty: MysteryDifficulty.medium,
        remainingSecondsAfterSolve: 60,
        timeLimitSeconds: 60,
        hintsUsed: 2,
      );
      expect(award.xp, 0);
    });

    test('a timeout is configured to award nothing', () {
      expect(const XPConfig().timeoutXp, 0);
    });

    test('honours a custom configuration', () {
      final XPService custom = XPService(
        const XPConfig(
          baseXpByDifficulty: <MysteryDifficulty, int>{
            MysteryDifficulty.medium: 100,
          },
          speedBonusMax: 0,
          incorrectXp: 10,
          hintPenaltyXp: 0,
        ),
      );
      int correct = custom
          .award(
            correct: true,
            difficulty: MysteryDifficulty.medium,
            remainingSecondsAfterSolve: 60,
            timeLimitSeconds: 60,
            hintsUsed: 0,
          )
          .xp;
      int wrong = custom
          .award(
            correct: false,
            difficulty: MysteryDifficulty.hard,
            remainingSecondsAfterSolve: 0,
            timeLimitSeconds: 60,
            hintsUsed: 0,
          )
          .xp;
      expect(correct, 100);
      expect(wrong, 10);
    });
  });

  group('XPService level progression', () {
    test('level boundaries follow the growth curve', () {
      expect(service.xpNeededForLevel(1), 200);
      expect(service.xpNeededForLevel(2), 230);
      // 200 * 1.15^2 = 264.5, rounded down by floating-point (see 264.499).
      expect(service.xpNeededForLevel(3), 264);
      expect(service.xpNeededForLevel(3), greaterThan(service.xpNeededForLevel(2)));
    });

    test('progressForTotal maps total XP to a level', () {
      final LevelProgress zero =
          service.progressForTotal(0);
      expect(zero.level, 1);
      expect(zero.xpIntoLevel, 0);
      expect(zero.xpForNextLevel, 200);

      final LevelProgress partial = service.progressForTotal(220);
      expect(partial.level, 2);
      expect(partial.xpIntoLevel, 20);
      expect(partial.xpForNextLevel, 230);

      final LevelProgress exactBang = service.progressForTotal(200);
      expect(exactBang.level, 2);
      expect(exactBang.xpIntoLevel, 0);
    });

    test('progress fraction clamps to its level band', () {
      expect(service.progressForTotal(100).progress, 0.5);
      expect(service.progressForTotal(0).progress, 0);
    });
  });
}