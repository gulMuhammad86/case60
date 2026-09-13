import 'package:flutter_test/flutter_test.dart';

import 'package:case60/features/player/application/case_outcome_recorder.dart';
import 'package:case60/features/player/application/streak_service.dart';
import 'package:case60/features/player/domain/detective_profile.dart';

void main() {
  const CaseOutcomeRecorder recorder = CaseOutcomeRecorder(
    streaks: StreakService(),
  );
  final DateTime now = DateTime(2026, 9, 13, 12, 0);

  group('solved attempts', () {
    test('a first solve starts the streak, banks XP and locks the day', () {
      final RecordedCaseOutcome outcome = recorder.record(
        profile: const DetectiveProfile(),
        solved: true,
        solveTimeSeconds: 18,
        xpReward: 100,
        caseNumber: 42,
        now: now,
      );

      final DetectiveProfile profile = outcome.profile;
      expect(profile.totalXp, 100);
      expect(profile.casesSolved, 1);
      expect(profile.casesFailed, 0);
      expect(profile.streakDays, 1);
      expect(profile.lastCompletedDate, '2026-09-13');
      expect(profile.bestTimeSeconds, 18);
      expect(profile.totalTimeSeconds, 18);

      expect(outcome.entry.solved, isTrue);
      expect(outcome.entry.caseNumber, 42);
      expect(outcome.entry.timeSeconds, 18);
      expect(outcome.entry.xpEarned, 100);
    });

    test('a consecutive solve extends the streak', () {
      final RecordedCaseOutcome outcome = recorder.record(
        profile: const DetectiveProfile(
          totalXp: 500,
          streakDays: 5,
          lastCompletedDate: '2026-09-12',
          casesSolved: 5,
          bestTimeSeconds: 30,
          totalTimeSeconds: 200,
        ),
        solved: true,
        solveTimeSeconds: 18,
        xpReward: 100,
        caseNumber: 43,
        now: now,
      );

      expect(outcome.profile.streakDays, 6);
      expect(outcome.profile.lastCompletedDate, '2026-09-13');
      expect(outcome.profile.totalXp, 600);
      expect(outcome.profile.casesSolved, 6);
      expect(outcome.profile.bestTimeSeconds, 18);
      expect(outcome.profile.totalTimeSeconds, 218);
    });

    test('a slower solve never worsens the best time', () {
      final RecordedCaseOutcome outcome = recorder.record(
        profile: const DetectiveProfile(bestTimeSeconds: 18),
        solved: true,
        solveTimeSeconds: 40,
        xpReward: 80,
        caseNumber: 44,
        now: now,
      );

      expect(outcome.profile.bestTimeSeconds, 18);
    });
  });

  group('unsolved attempts', () {
    test('a wrong answer counts a failure but never touches streak or lock', () {
      final RecordedCaseOutcome outcome = recorder.record(
        profile: const DetectiveProfile(
          totalXp: 500,
          streakDays: 5,
          lastCompletedDate: '2026-09-12',
          casesSolved: 5,
          bestTimeSeconds: 18,
          totalTimeSeconds: 200,
        ),
        solved: false,
        solveTimeSeconds: 25,
        xpReward: 15,
        caseNumber: 45,
        now: now,
      );

      final DetectiveProfile profile = outcome.profile;
      expect(profile.totalXp, 515);
      expect(profile.casesFailed, 1);
      expect(profile.casesSolved, 5);
      expect(profile.streakDays, 5);
      expect(profile.lastCompletedDate, '2026-09-12');
      expect(profile.bestTimeSeconds, 18);
      expect(profile.totalTimeSeconds, 225);

      expect(outcome.entry.solved, isFalse);
      expect(outcome.entry.timeSeconds, 25);
      expect(outcome.entry.xpEarned, 15);
    });

    test('a timeout records full time, zero XP and stays unlocked', () {
      final RecordedCaseOutcome outcome = recorder.record(
        profile: const DetectiveProfile(totalXp: 0),
        solved: false,
        solveTimeSeconds: 60,
        xpReward: 0,
        caseNumber: 46,
        now: now,
      );

      expect(outcome.profile.totalXp, 0);
      expect(outcome.profile.casesFailed, 1);
      expect(outcome.profile.lastCompletedDate, isNull);
      expect(outcome.profile.streakDays, 0);
      expect(outcome.entry.timeSeconds, 60);
      expect(outcome.entry.xpEarned, 0);
    });
  });

  test('negative or zero rewards never subtract XP', () {
    final RecordedCaseOutcome outcome = recorder.record(
      profile: const DetectiveProfile(totalXp: 100),
      solved: false,
      solveTimeSeconds: 10,
      xpReward: -5,
      caseNumber: 47,
      now: now,
    );
    expect(outcome.profile.totalXp, 100);
    expect(outcome.entry.xpEarned, 0);
  });

  test('a solve after a missed day restarts the streak', () {
    final RecordedCaseOutcome outcome = recorder.record(
      profile: const DetectiveProfile(
        streakDays: 9,
        lastCompletedDate: '2026-09-10',
      ),
      solved: true,
      solveTimeSeconds: 22,
      xpReward: 110,
      caseNumber: 48,
      now: now,
    );
    expect(outcome.profile.streakDays, 1);
    expect(outcome.profile.lastCompletedDate, '2026-09-13');
  });
}