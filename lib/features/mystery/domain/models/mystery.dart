import '../mystery_category.dart';
import '../mystery_difficulty.dart';
import 'answer_option.dart';
import 'clue.dart';

final class Mystery {
  Mystery({
    required this.id,
    required this.caseNumber,
    required this.title,
    required this.category,
    required this.difficulty,
    required this.story,
    required List<Clue> clues,
    required List<AnswerOption> answers,
    required this.correctAnswerId,
    required this.explanation,
    required List<String> hints,
    required this.timeLimitSeconds,
    required this.availableDate,
  }) : clues = List.unmodifiable(clues),
       answers = List.unmodifiable(answers),
       hints = List.unmodifiable(hints);

  final String id;
  final int caseNumber;
  final String title;
  final MysteryCategory category;
  final MysteryDifficulty difficulty;
  final String story;
  final List<Clue> clues;
  final List<AnswerOption> answers;
  final String correctAnswerId;
  final String explanation;
  final List<String> hints;
  final int timeLimitSeconds;
  final DateTime availableDate;

  AnswerOption? get correctAnswer {
    for (final AnswerOption answer in answers) {
      if (answer.id == correctAnswerId) {
        return answer;
      }
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (other is! Mystery) {
      return false;
    }
    if (other.id != id ||
        other.caseNumber != caseNumber ||
        other.title != title ||
        other.category != category ||
        other.difficulty != difficulty ||
        other.story != story ||
        other.correctAnswerId != correctAnswerId ||
        other.explanation != explanation ||
        other.timeLimitSeconds != timeLimitSeconds ||
        other.availableDate != availableDate) {
      return false;
    }
    if (!_listEquals(other.clues, clues) ||
        !_listEquals(other.answers, answers) ||
        !_listEquals(other.hints, hints)) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      caseNumber,
      title,
      category,
      difficulty,
      story,
      Object.hashAll(clues),
      Object.hashAll(answers),
      correctAnswerId,
      explanation,
      Object.hashAll(hints),
      timeLimitSeconds,
      availableDate,
    );
  }

  static bool _listEquals<T>(List<T> left, List<T> right) {
    if (left.length != right.length) {
      return false;
    }
    for (int i = 0; i < left.length; i++) {
      if (left[i] != right[i]) {
        return false;
      }
    }
    return true;
  }
}