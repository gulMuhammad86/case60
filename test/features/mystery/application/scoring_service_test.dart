import 'package:flutter_test/flutter_test.dart';

import 'package:case60/features/mystery/application/scoring.dart';
import 'package:case60/features/mystery/domain/mystery_difficulty.dart';

void main() {
  const ScoringService service = ScoringService(ScoringConfig());

  group('ScoringService.score', () {
    test('gives the full base for a perfect correct solve', () {
      final int score = service.score(
        correct: true,
        difficulty: MysteryDifficulty.medium,
        remainingSecondsAfterSolve: 60,
        timeLimitSeconds: 60,
        hintsUsed: 0,
      );
      expect(score, 75);
    });

    test('scales by the time remaining at submission', () {
      int score = service.score(
        correct: true,
        difficulty: MysteryDifficulty.medium,
        remainingSecondsAfterSolve: 30,
        timeLimitSeconds: 60,
        hintsUsed: 0,
      );
      expect(score, 38);

      score = service.score(
        correct: true,
        difficulty: MysteryDifficulty.medium,
        remainingSecondsAfterSolve: 0,
        timeLimitSeconds: 60,
        hintsUsed: 0,
      );
      expect(score, 38);
    });

    test('applies the low-time floor multiplier', () {
      final int score = service.score(
        correct: true,
        difficulty: MysteryDifficulty.hard,
        remainingSecondsAfterSolve: 0,
        timeLimitSeconds: 60,
        hintsUsed: 0,
      );
      expect(score, 50);
    });

    test('a hard case scores more than an easy one', () {
      int easy = service.score(
        correct: true,
        difficulty: MysteryDifficulty.easy,
        remainingSecondsAfterSolve: 60,
        timeLimitSeconds: 60,
        hintsUsed: 0,
      );
      int hard = service.score(
        correct: true,
        difficulty: MysteryDifficulty.hard,
        remainingSecondsAfterSolve: 60,
        timeLimitSeconds: 60,
        hintsUsed: 0,
      );
      expect(easy, 50);
      expect(hard, 100);
      expect(hard, greaterThan(easy));
    });

    test('incorrect solves keep only the incorrect factor', () {
      final int score = service.score(
        correct: false,
        difficulty: MysteryDifficulty.medium,
        remainingSecondsAfterSolve: 60,
        timeLimitSeconds: 60,
        hintsUsed: 0,
      );
      expect(score, 19);
    });

    test('each hint used eats into the score', () {
      int score = service.score(
        correct: true,
        difficulty: MysteryDifficulty.medium,
        remainingSecondsAfterSolve: 60,
        timeLimitSeconds: 60,
        hintsUsed: 1,
      );
      expect(score, 64);
    });

    test('hint penalties are capped', () {
      int score = service.score(
        correct: true,
        difficulty: MysteryDifficulty.medium,
        remainingSecondsAfterSolve: 60,
        timeLimitSeconds: 60,
        hintsUsed: 4,
      );
      expect(score, 30);

      final int sameAtFive = service.score(
        correct: true,
        difficulty: MysteryDifficulty.medium,
        remainingSecondsAfterSolve: 60,
        timeLimitSeconds: 60,
        hintsUsed: 5,
      );
      expect(sameAtFive, score);
    });

    test('a degenerate time limit falls back to a full multiplier', () {
      final int score = service.score(
        correct: true,
        difficulty: MysteryDifficulty.easy,
        remainingSecondsAfterSolve: 0,
        timeLimitSeconds: 0,
        hintsUsed: 0,
      );
      expect(score, 50);
    });

    test('honours a custom configuration', () {
      final ScoringService custom = ScoringService(
        const ScoringConfig(
          basePointsByDifficulty: <MysteryDifficulty, int>{
            MysteryDifficulty.medium: 100,
          },
          incorrectFactor: 0.5,
          minTimeMultiplier: 0.25,
          hintPenaltyPerUse: 0.1,
          maxHintPenalty: 0.5,
        ),
      );
      final int score = custom.score(
        correct: true,
        difficulty: MysteryDifficulty.medium,
        remainingSecondsAfterSolve: 60,
        timeLimitSeconds: 60,
        hintsUsed: 0,
      );
      expect(score, 100);
    });
  });
}