import 'dart:convert';

import '../domain/models/answer_option.dart';
import '../domain/models/clue.dart';
import '../domain/models/mystery.dart';
import '../domain/mystery_category.dart';
import '../domain/mystery_difficulty.dart';
import '../domain/mystery_exceptions.dart';

final class MysteryJsonCodec {
  const MysteryJsonCodec();

  List<Mystery> decode(String source) {
    final Object? root;
    try {
      root = jsonDecode(source);
    } on Object catch (error) {
      throw MysteryDataException('Failed to decode the mystery JSON document.', cause: error);
    }
    return validate(root);
  }

  List<Mystery> validate(Object? root) {
    if (root is! Map<String, dynamic>) {
      throw const MysteryValidationException('Mystery JSON root must be a JSON object.');
    }

    final Object? itemsRaw = root['mysteries'];
    if (itemsRaw is! List) {
      throw const MysteryValidationException("Mystery JSON must contain a 'mysteries' array.");
    }
    if (itemsRaw.isEmpty) {
      throw const MysteryValidationException("The 'mysteries' array must not be empty.");
    }

    final List<String> errors = <String>[];
    final Map<String, int> ids = <String, int>{};
    final List<Mystery> mysteries = <Mystery>[];

    for (int index = 0; index < itemsRaw.length; index++) {
      final Object? itemRaw = itemsRaw[index];
      if (itemRaw is! Map<String, dynamic>) {
        errors.add('Mystery #${index + 1}: must be a JSON object.');
        continue;
      }

      final String label = _labelFor(itemRaw, index);
      final List<String> itemErrors = <String>[];

      final String? id = _requireString(itemRaw, 'id', label, itemErrors);
      final String? title = _requireString(itemRaw, 'title', label, itemErrors);
      final String? story = _requireString(itemRaw, 'story', label, itemErrors);
      final String? categoryLabel = _requireString(itemRaw, 'category', label, itemErrors);
      final String? difficultyLabel = _requireString(itemRaw, 'difficulty', label, itemErrors);
      final String? correctAnswerId = _requireString(
        itemRaw,
        'correctAnswerId',
        label,
        itemErrors,
      );
      final String? explanation = _requireString(itemRaw, 'explanation', label, itemErrors);

      final int? caseNumber = _requirePositiveInt(itemRaw, 'caseNumber', label, itemErrors);
      final int? timeLimitSeconds = _requirePositiveInt(
        itemRaw,
        'timeLimitSeconds',
        label,
        itemErrors,
      );

      MysteryCategory? category;
      if (categoryLabel != null) {
        category = MysteryCategory.fromLabelOrNull(categoryLabel);
        if (category == null) {
          itemErrors.add('$label: unknown category "$categoryLabel".');
        }
      }

      MysteryDifficulty? difficulty;
      if (difficultyLabel != null) {
        difficulty = MysteryDifficulty.fromLabelOrNull(difficultyLabel);
        if (difficulty == null) {
          itemErrors.add('$label: unknown difficulty "$difficultyLabel".');
        }
      }

      final DateTime? availableDate = _requireDate(itemRaw, 'availableDate', label, itemErrors);

      final List<Clue>? clues = _parseClues(itemRaw, label, itemErrors);
      final List<AnswerOption>? answers = _parseAnswers(itemRaw, label, itemErrors);

      if (correctAnswerId != null && answers != null) {
        final bool matches = answers.any(
          (AnswerOption answer) => answer.id == correctAnswerId,
        );
        if (!matches) {
          itemErrors.add(
            '$label: correctAnswerId "$correctAnswerId" does not match any answer option id.',
          );
        }
      }

      final List<String> hints = _parseHints(itemRaw, label, itemErrors);

      if (id != null) {
        final int? previousIndex = ids[id];
        if (previousIndex != null) {
          itemErrors.add(
            '$label: duplicate id "$id" (already used by mystery #${previousIndex + 1}).',
          );
        } else {
          ids[id] = index;
        }
      }

      if (itemErrors.isNotEmpty) {
        errors.addAll(itemErrors);
        continue;
      }

      mysteries.add(
        Mystery(
          id: id!,
          caseNumber: caseNumber!,
          title: title!,
          category: category!,
          difficulty: difficulty!,
          story: story!,
          clues: clues!,
          answers: answers!,
          correctAnswerId: correctAnswerId!,
          explanation: explanation!,
          hints: hints,
          timeLimitSeconds: timeLimitSeconds!,
          availableDate: availableDate!,
        ),
      );
    }

    if (errors.isNotEmpty) {
      throw MysteryValidationException(
        'Mystery JSON is invalid.',
        errors: List.unmodifiable(errors),
      );
    }

    return List.unmodifiable(mysteries);
  }

  String _labelFor(Map<String, dynamic> map, int index) {
    final Object? id = map['id'];
    if (id is String && id.isNotEmpty) {
      return 'Mystery #${index + 1} ("$id")';
    }
    return 'Mystery #${index + 1}';
  }

  String? _requireString(
    Map<String, dynamic> map,
    String key,
    String label,
    List<String> errors,
  ) {
    final Object? value = map[key];
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
    errors.add('$label: "$key" must be a non-empty string.');
    return null;
  }

  int? _requirePositiveInt(
    Map<String, dynamic> map,
    String key,
    String label,
    List<String> errors,
  ) {
    final Object? value = map[key];
    if (value is int && value > 0) {
      return value;
    }
    errors.add('$label: "$key" must be a positive integer.');
    return null;
  }

  DateTime? _requireDate(
    Map<String, dynamic> map,
    String key,
    String label,
    List<String> errors,
  ) {
    final Object? value = map[key];
    if (value is String) {
      final DateTime? parsed = DateTime.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
    errors.add('$label: "$key" must be a valid date string.');
    return null;
  }

  List<Clue>? _parseClues(
    Map<String, dynamic> map,
    String label,
    List<String> errors,
  ) {
    final Object? value = map['clues'];
    if (value is! List) {
      errors.add('$label: "clues" must be an array of clue objects.');
      return null;
    }
    if (value.isEmpty) {
      errors.add('$label: "clues" must contain at least one clue.');
      return null;
    }

    final List<Clue> clues = <Clue>[];
    final Set<String> clueIds = <String>{};
    for (int index = 0; index < value.length; index++) {
      final Object? clueRaw = value[index];
      final String clueLabel = '$label, clue #${index + 1}';
      if (clueRaw is! Map<String, dynamic>) {
        errors.add('$clueLabel: must be a JSON object.');
        continue;
      }
      final String? clueId = _requireString(clueRaw, 'id', clueLabel, errors);
      final String? text = _requireString(clueRaw, 'text', clueLabel, errors);
      if (clueId == null || text == null) {
        continue;
      }
      if (!clueIds.add(clueId)) {
        errors.add('$clueLabel: duplicate clue id "$clueId".');
        continue;
      }
      clues.add(Clue(id: clueId, text: text, orderIndex: index));
    }

    if (clues.isEmpty) {
      return null;
    }
    return List.unmodifiable(clues);
  }

  List<AnswerOption>? _parseAnswers(
    Map<String, dynamic> map,
    String label,
    List<String> errors,
  ) {
    final Object? value = map['answers'];
    if (value is! List) {
      errors.add('$label: "answers" must be an array of answer objects.');
      return null;
    }
    if (value.length < 2) {
      errors.add('$label: "answers" must contain at least two options.');
      return null;
    }

    final List<AnswerOption> answers = <AnswerOption>[];
    final Set<String> answerIds = <String>{};
    for (int index = 0; index < value.length; index++) {
      final Object? answerRaw = value[index];
      final String answerLabel = '$label, answer #${index + 1}';
      if (answerRaw is! Map<String, dynamic>) {
        errors.add('$answerLabel: must be a JSON object.');
        continue;
      }
      final String? answerId = _requireString(answerRaw, 'id', answerLabel, errors);
      final String? text = _requireString(answerRaw, 'text', answerLabel, errors);
      if (answerId == null || text == null) {
        continue;
      }
      if (!answerIds.add(answerId)) {
        errors.add('$answerLabel: duplicate answer id "$answerId".');
        continue;
      }
      answers.add(AnswerOption(id: answerId, text: text));
    }

    if (answers.length < 2) {
      errors.add('$label: "answers" must contain at least two valid options.');
      return null;
    }
    return List.unmodifiable(answers);
  }

  List<String> _parseHints(
    Map<String, dynamic> map,
    String label,
    List<String> errors,
  ) {
    final Object? value = map['hints'];
    if (value == null) {
      return const <String>[];
    }
    if (value is! List) {
      errors.add('$label: "hints" must be an array of strings.');
      return const <String>[];
    }

    final List<String> hints = <String>[];
    for (int index = 0; index < value.length; index++) {
      final Object? entry = value[index];
      if (entry is String) {
        hints.add(entry);
      } else {
        errors.add('$label: hint #${index + 1} must be a string.');
      }
    }
    return List.unmodifiable(hints);
  }
}