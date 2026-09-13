import '../../../core/helpers/date_helpers.dart';
import '../domain/models/mystery.dart';

final class DailyMysteryService {
  const DailyMysteryService();

  Mystery mysteryForDate(DateTime date, List<Mystery> mysteries) {
    if (mysteries.isEmpty) {
      throw StateError('Cannot select a daily mystery from an empty list.');
    }

    final List<Mystery> ordered = List<Mystery>.of(mysteries)
      ..sort((Mystery a, Mystery b) => a.caseNumber.compareTo(b.caseNumber));

    final int index = _randomIndexForDay(
      DateHelpers.dayNumber(date),
      ordered.length,
    );
    return ordered[index];
  }

  static int _randomIndexForDay(int dayNumber, int length) {
    int h = dayNumber * 2654435761;
    h = ((h ^ (h >> 16)) * 0x45d9f3b) & 0x7fffffff;
    h = ((h ^ (h >> 13)) * 0x45d9f3b) & 0x7fffffff;
    h = h ^ (h >> 16);
    return h % length;
  }
}