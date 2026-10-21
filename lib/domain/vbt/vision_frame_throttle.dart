/// Drops excess camera frames before conversion or native inference. There is
/// no queue: a slow detector always gets the next available fresh frame.
class VisionFrameThrottle {
  VisionFrameThrottle({int framesPerSecond = 15})
    : assert(framesPerSecond > 0),
      // Floor to the clock's microsecond precision. Rounding up would reject
      // every other frame of an otherwise exact 15 Hz camera cadence.
      interval = Duration(microseconds: (1000000 / framesPerSecond).floor());

  final Duration interval;
  Duration? _lastAccepted;

  bool accept(Duration now) {
    final previous = _lastAccepted;
    if (previous != null && now - previous < interval) return false;
    _lastAccepted = now;
    return true;
  }

  void reset() => _lastAccepted = null;
}
