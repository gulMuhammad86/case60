/// App-level constants that are not scoped to a single feature.
///
/// Feature-specific values (e.g. XP rewards) belong to their own feature and
/// should be placed there as they emerge.
final class AppConstants {
  const AppConstants._();

  /// Core gameplay duration in seconds.
  static const int caseSeconds = 60;

  /// Default limit for list-based data providers.
  static const int defaultListLimit = 20;
}