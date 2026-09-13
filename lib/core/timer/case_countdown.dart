import 'dart:async';

/// A reusable one-second countdown that is independent of widgets.
///
/// Owns its [Timer]; callers control the lifecycle through [start], [stop] and
/// [dispose]. Starting an already-running countdown is a no-op and stopping a
/// stopped one is safe, so callers can never create duplicate timers.
///
/// All countdown state lives here — widget layers only display what the
/// controller reports, they never manage the timer themselves.
final class CaseCountdown {
  CaseCountdown({
    required this.duration,
    this.onTick,
    this.onComplete,
  }) : _remaining = duration;

  /// Total countdown length.
  final Duration duration;

  /// Invoked each second with the time still remaining (full seconds).
  final void Function(Duration remaining)? onTick;

  /// Invoked exactly once when the countdown reaches zero.
  final void Function()? onComplete;

  Duration _remaining;
  Timer? _timer;

  /// The duration already counted down.
  Duration get elapsed => duration - _remaining;

  /// Time still remaining.
  Duration get remaining => _remaining;

  /// Whether a timer is currently running.
  bool get isRunning => _timer != null;

  /// Starts ticking once per second. No-op while already running.
  ///
  /// A finished countdown restarts from its original [duration].
  void start() {
    if (_timer != null) {
      return;
    }
    if (_remaining <= Duration.zero) {
      _remaining = duration;
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      _remaining -= const Duration(seconds: 1);
      if (_remaining <= Duration.zero) {
        _stop();
        onComplete?.call();
        return;
      }
      onTick?.call(_remaining);
    });
  }

  /// Stops the countdown without settling its remaining time. Safe to repeat.
  void stop() {
    _stop();
  }

  /// Cancels the countdown and releases the timer. Safe to repeat.
  void dispose() {
    _stop();
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Formats a duration as `mm:ss`, e.g. `01:00` or `00:47`.
  static String format(Duration duration) {
    final int total = duration.inSeconds < 0 ? 0 : duration.inSeconds;
    final int minutes = total ~/ 60;
    final int seconds = total % 60;
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(minutes)}:${two(seconds)}';
  }

  /// Formats a duration as `hh:mm:ss`, e.g. `08:42:13`, for long horizons
  /// like the countdown to tomorrow's case.
  static String formatHms(Duration duration) {
    final int total = duration.inSeconds < 0 ? 0 : duration.inSeconds;
    final int hours = total ~/ 3600;
    final int minutes = (total % 3600) ~/ 60;
    final int seconds = total % 60;
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(hours)}:${two(minutes)}:${two(seconds)}';
  }
}