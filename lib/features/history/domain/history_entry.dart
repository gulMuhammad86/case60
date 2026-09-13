/// A single recorded case attempt (solved, wrong, or timed out).
final class HistoryEntry {
  const HistoryEntry({
    required this.caseNumber,
    required this.completedAt,
    required this.solved,
    required this.timeSeconds,
    required this.xpEarned,
  });

  /// The case number played (e.g. `42` for `CASE #042`).
  final int caseNumber;

  /// When the attempt concluded, in local time.
  final DateTime completedAt;

  /// Whether the correct answer was submitted.
  final bool solved;

  /// Seconds spent on the case (solve time, or the full limit when unsolved).
  final int timeSeconds;

  /// XP banked from this attempt (`0` for timeouts).
  final int xpEarned;

  /// Readable attempt label, e.g. `SOLVED` or `UNSOLVED`.
  String get statusLabel => solved ? 'SOLVED' : 'UNSOLVED';

  /// `CASE #042`-style label for the entry.
  String get caseLabel => 'CASE #${caseNumber.toString().padLeft(3, '0')}';
}