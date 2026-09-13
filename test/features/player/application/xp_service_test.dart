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
}