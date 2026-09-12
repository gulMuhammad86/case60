import 'package:flutter/foundation.dart';

/// Severity levels for [AppLogger].
enum AppLogLevel { debug, info, warning, error }

/// Minimal, tree-shakeable logger.
///
/// In debug builds messages are forwarded to the console via [debugPrint];
/// in release builds everything is dropped so no tracing leaks to production.
final class AppLogger {
  const AppLogger._();

  static void debug(String message) => _log(AppLogLevel.debug, message);

  static void info(String message) => _log(AppLogLevel.info, message);

  static void warning(String message) => _log(AppLogLevel.warning, message);

  static void error(String message, {Object? exception, StackTrace? stackTrace}) {
    final String trace = stackTrace?.toString().split('\n').take(4).join('\n') ?? '';
    _log(
      AppLogLevel.error,
      exception == null
          ? message
          : '$message\nCause: $exception${trace.isEmpty ? '' : '\n$trace'}',
    );
  }

  static void _log(AppLogLevel level, String message) {
    if (kReleaseMode) return;
    final String tag = switch (level) {
      AppLogLevel.debug => 'DEBUG',
      AppLogLevel.info => 'INFO',
      AppLogLevel.warning => 'WARN',
      AppLogLevel.error => 'ERROR',
    };
    debugPrint('[$tag][CASE60] $message');
  }
}