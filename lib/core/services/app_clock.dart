import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A wrapper around the wall clock.
///
/// Injected through Riverpod so tests can override it with a fixed [DateTime]
/// instead of relying on the real clock. All time sources inside CASE 60 should
/// go through this service.
abstract interface class AppClock {
  DateTime now();
}

final class SystemAppClock implements AppClock {
  const SystemAppClock();

  @override
  DateTime now() => DateTime.now();
}

/// Single source of truth for the current time.
final Provider<AppClock> appClockProvider = Provider<AppClock>((_) {
  return const SystemAppClock();
});