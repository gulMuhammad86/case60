/// Base exception for all expected CASE 60 failures.
///
/// Feature/domain errors should extend this class so callers can catch a
/// single, typed root cause without relying on [Exception] strings.
class AppException implements Exception {
  const AppException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

/// Thrown when persisted or remote data cannot be loaded.
class DataLoadException extends AppException {
  const DataLoadException(super.message, {super.cause});
}

/// Thrown when user input fails validation.
class ValidationException extends AppException {
  const ValidationException(super.message, {super.cause});
}

/// Thrown when an operation is attempted before it is available (e.g. today's
/// case has not been unlocked yet).
class NotAvailableException extends AppException {
  const NotAvailableException(super.message, {super.cause});
}