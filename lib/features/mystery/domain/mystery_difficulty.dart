enum MysteryDifficulty {
  easy('Easy'),
  medium('Medium'),
  hard('Hard');

  const MysteryDifficulty(this.label);

  final String label;

  static MysteryDifficulty? fromLabelOrNull(String label) {
    for (final MysteryDifficulty difficulty in MysteryDifficulty.values) {
      if (difficulty.label == label) {
        return difficulty;
      }
    }
    return null;
  }
}