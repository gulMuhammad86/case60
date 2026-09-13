import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/helpers/date_helpers.dart';
import '../../history/domain/history_entry.dart';
import '../domain/detective_profile.dart';
import 'streak_service.dart';

/// A solved/attempted case applied to progression plus its history record.
final class RecordedCaseOutcome {
  const RecordedCaseOutcome({required this.profile, required this.entry});

  /// The updated player profile.
  final DetectiveProfile profile;

  /// The history entry describing this attempt.
  final HistoryEntry entry;
}

/// Applies the end of a case attempt to player progression.
///
/// Pure and stateless so it is trivially testable:
///
/// * a **solved** attempt awards XP, counts a solve, advances the streak and
///   locks today's case (via `lastCompletedDate`);
/// * an **unsolved** attempt (wrong answer or timeout) counts a failure but
///   never touches the streak or the daily lock.
final class CaseOutcomeRecorder {
  const CaseOutcomeRecorder({required this.streaks});

  final StreakService streaks;

  RecordedCaseOutcome record({
    required DetectiveProfile profile,
    required bool solved,
    required int solveTimeSeconds,
    required int xpReward,
    required int caseNumber,
    required DateTime now,
  }) {
    final int safeTime = solveTimeSeconds < 0 ? 0 : solveTimeSeconds;
    final int reward = xpReward < 0 ? 0 : xpReward;

    final int casesSolved = profile.casesSolved + (solved ? 1 : 0);
    final int casesFailed = profile.casesFailed + (solved ? 0 : 1);

    final int? bestTime = solved
        ? (profile.bestTimeSeconds == null ||
                  safeTime < profile.bestTimeSeconds!)
              ? safeTime
              : profile.bestTimeSeconds
        : profile.bestTimeSeconds;

    final int nextStreak = solved
        ? streaks.nextStreak(
            lastCompletedDate: profile.lastCompletedDate,
            storedDays: profile.streakDays,
            now: now,
          )
        : profile.streakDays;

    final String? nextLastCompleted = solved
        ? DateHelpers.dateKey(now)
        : profile.lastCompletedDate;

    final DetectiveProfile nextProfile = profile.copyWith(
      totalXp: profile.totalXp + reward,
      streakDays: nextStreak,
      lastCompletedDate: nextLastCompleted,
      casesSolved: casesSolved,
      casesFailed: casesFailed,
      bestTimeSeconds: bestTime,
      totalTimeSeconds: profile.totalTimeSeconds + safeTime,
    );

    final HistoryEntry entry = HistoryEntry(
      caseNumber: caseNumber,
      completedAt: now,
      solved: solved,
      timeSeconds: safeTime,
      xpEarned: reward,
    );

    return RecordedCaseOutcome(profile: nextProfile, entry: entry);
  }
}

/// The active [CaseOutcomeRecorder].
final Provider<CaseOutcomeRecorder> caseOutcomeRecorderProvider =
    Provider<CaseOutcomeRecorder>((Ref ref) {
  return CaseOutcomeRecorder(streaks: ref.watch(streakServiceProvider));
});