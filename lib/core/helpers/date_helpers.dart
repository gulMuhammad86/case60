/// Date-time helpers for daily-gameplay concepts (day boundaries, streaks).
final class DateHelpers {
  const DateHelpers._();

  /// Returns the calendar date key for a [DateTime] in local time,
  /// e.g. `2026-09-12`. Used to identify "today's case".
  static String dateKey(DateTime date) {
    final DateTime d = date.toLocal();
    final String month = d.month.toString().padLeft(2, '0');
    final String day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$month-$day';
  }

  /// Returns a stable day number since the Unix epoch for a local date.
  /// Two dates belong to the same game day when they share the same value.
  static int dayNumber(DateTime date) {
    final DateTime local = date.toLocal();
    return DateTime(local.year, local.month, local.day)
        .difference(DateTime(1970))
        .inDays;
  }
}