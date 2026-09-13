enum MysteryCategory {
  logic('Logic'),
  detective('Detective'),
  observation('Observation'),
  lateralThinking('Lateral Thinking'),
  science('Science'),
  wordplay('Wordplay'),
  pattern('Pattern'),
  timeline('Timeline'),
  crime('Crime'),
  general('General Mystery');

  const MysteryCategory(this.label);

  final String label;

  static MysteryCategory? fromLabelOrNull(String label) {
    for (final MysteryCategory category in MysteryCategory.values) {
      if (category.label == label) {
        return category;
      }
    }
    return null;
  }
}