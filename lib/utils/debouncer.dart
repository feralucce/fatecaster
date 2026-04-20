import 'dart:async';

/// Delays execution of [action] until [duration] has elapsed since the last
/// call.  Useful for reducing the frequency of expensive operations triggered
/// by rapid user input (e.g. live field validation, search).
///
/// Usage:
/// ```dart
/// final _debouncer = Debouncer(duration: const Duration(milliseconds: 400));
///
/// void _onSearchChanged(String query) {
///   _debouncer.run(() => _performSearch(query));
/// }
///
/// @override
/// void dispose() {
///   _debouncer.cancel();
///   super.dispose();
/// }
/// ```
class Debouncer {
  final Duration duration;
  Timer? _timer;

  Debouncer({this.duration = const Duration(milliseconds: 500)});

  /// Schedule [action] to run after [duration] of inactivity.
  ///
  /// Calling this method again before [duration] has elapsed cancels the
  /// previously scheduled call and resets the timer.
  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  /// Cancel any pending scheduled action without running it.
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Whether an action is currently pending.
  bool get isPending => _timer?.isActive ?? false;
}
