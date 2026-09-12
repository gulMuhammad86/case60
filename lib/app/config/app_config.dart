/// Centralized application-wide configuration values.
///
/// Kept small on purpose: configuration related to specific features should
/// live in their own feature-local files.
final class AppConfig {
  const AppConfig._();

  static const String appName = 'CASE 60';
  static const String tagline = 'ONE CASE. 60 SECONDS. SOLVE IT.';
  static const String appVersion = '1.0.0';
}