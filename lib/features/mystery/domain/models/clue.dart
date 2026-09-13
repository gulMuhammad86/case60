final class Clue {
  const Clue({
    required this.id,
    required this.text,
    required this.orderIndex,
  });

  final String id;
  final String text;
  final int orderIndex;

  @override
  bool operator ==(Object other) {
    return other is Clue &&
        other.id == id &&
        other.text == text &&
        other.orderIndex == orderIndex;
  }

  @override
  int get hashCode => Object.hash(id, text, orderIndex);
}