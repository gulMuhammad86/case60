final class AnswerOption {
  const AnswerOption({
    required this.id,
    required this.text,
  });

  final String id;
  final String text;

  @override
  bool operator ==(Object other) {
    return other is AnswerOption && other.id == id && other.text == text;
  }

  @override
  int get hashCode => Object.hash(id, text);
}