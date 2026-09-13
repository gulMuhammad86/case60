import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/helpers/date_helpers.dart';

/// Calendar-based daily-streak logic.
///
/// A streak advances only when a case is **solved** on a given day — simply
/// opening the app never mutates state. Day identity uses the local calendar
/// via [DateHelpers.dateKey]/[DateHelpers.dayNumber] so day boundaries are
/// timezone-safe and a date crossing midnight cannot corrupt the count.
///
/// The service is stateless: all inputs are passed in and `now` always comes
/// from the injected [AppClock] at call time, keeping tests deterministic.
final class StreakService {
  const StreakService();

  /// Whether [day] (in local time) is a day the player completed a case.
  bool completedOn(String? lastCompletedDate, DateTime day) {
    if (lastCompletedDate == null) {
      return false;
    }
    return lastCompletedDate == DateHelpers.dateKey(day);
  }

  /// The streak a player would have *after* solving today.
  ///
  /// * no previous completion → starts at `1`;
  /// * completed yesterday → streaks continue (`storedDays + 1`);
  /// * completed today already → unchanged (defensive: today is locked after
  ///   a solve, so this path is normally unreachable);
  /// * completed earlier → a missed day resets the streak to `1`.
  int nextStreak({
    required String? lastCompletedDate,
    required int storedDays,
    required DateTime now,
  }) {
    if (lastCompletedDate == null) {
      return 1;
    }
    final DateTime? lastDay = _parseKey(lastCompletedDate);
    if (lastDay == null) {
      return 1;
    }
    final int daysSince = DateHelpers.dayNumber(now) - DateHelpers.dayNumber(
      lastDay,
    );
    if (daysSince == 1) {
      return storedDays + 1;
    }
    if (daysSince == 0) {
      return storedDays < 1 ? 1 : storedDays;
    }
    return 1;
  }

  /// The streak to *display* for the current time.
  ///
  /// The streak survives until a full day is missed: completing yesterday
  /// keeps it alive, but after a missed day it reads as `0`.
  int effectiveStreak({
    required String? lastCompletedDate,
    required int storedDays,
    required DateTime now,
  }) {
    if (lastCompletedDate == null || storedDays <= 0) {
      return 0;
    }
    final DateTime? lastDay = _parseKey(lastCompletedDate);
    if (lastDay == null) {
      return 0;
    }
    final int daysSince = DateHelpers.dayNumber(now) - DateHelpers.dayNumber(
      lastDay,
    );
    return daysSince <= 1 ? storedDays : 0;
  }

  DateTime? _parseKey(String key) {
    final List<int> parts = key
        .split('-')
        .map((String part) => int.tryParse(part))
        .whereType<int>()
        .toList();
    if (parts.length != 3) {
      return null;
    }
    return DateTime(parts[0], parts[1], parts[2]);
  }
}

/// The active [StreakService].
final Provider<StreakService> streakServiceProvider =
    Provider<StreakService>((_) {
  return const StreakService();
});