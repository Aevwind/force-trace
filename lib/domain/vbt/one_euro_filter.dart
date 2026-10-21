import 'dart:math' as math;

/// One-Euro filter for noisy, low-latency landmark / barbell coordinates.
///
/// Low speeds are heavily smoothed; fast concentric phases dynamically raise
/// the cutoff frequency so peak velocity is not clipped.
class OneEuroFilter {
  OneEuroFilter({
    this.minCutoff = 1.6,
    this.beta = 1.2,
    this.dCutoff = 1.0,
    double initialFrequency = 30,
  }) : _frequency = initialFrequency;

  final double minCutoff;
  final double beta;
  final double dCutoff;

  final _ValueFilter _x = _ValueFilter();
  final _ValueFilter _dx = _ValueFilter();
  double _frequency;
  double? _lastRaw;
  double? _lastTime;
  double? _lastValue;

  double get value => _lastValue ?? 0;

  double filter(double x, double timestampSeconds) {
    final lastTime = _lastTime;
    if (lastTime != null && timestampSeconds <= lastTime) return value;
    if (lastTime != null) {
      final dt = timestampSeconds - lastTime;
      if (dt > 1e-6) {
        _frequency = (1.0 / dt).clamp(1.0, 240.0);
      }
    }
    _lastTime = timestampSeconds;

    final lastRaw = _lastRaw;
    final derivative = lastRaw == null ? 0.0 : (x - lastRaw) * _frequency;
    final filteredDerivative = _dx.filter(
      derivative,
      _alpha(dCutoff, _frequency),
    );
    final cutoff = minCutoff + beta * filteredDerivative.abs();
    final filtered = _x.filter(x, _alpha(cutoff, _frequency));

    _lastRaw = x;
    _lastValue = filtered;
    return filtered;
  }

  void reset([double? value]) {
    _x.reset();
    _dx.reset();
    _lastRaw = null;
    _lastTime = null;
    _lastValue = value;
  }

  static double _alpha(double cutoff, double frequency) {
    final tau = 1.0 / (2 * math.pi * cutoff);
    final te = 1.0 / frequency;
    return 1.0 / (1.0 + tau / te);
  }
}

class _ValueFilter {
  double? _value;

  double filter(double x, double alpha) {
    final previous = _value;
    final next = previous == null ? x : alpha * x + (1 - alpha) * previous;
    _value = next;
    return next;
  }

  void reset() => _value = null;
}

/// A pair of One-Euro filters for 2D points.
class PointFilter {
  PointFilter({double minCutoff = 1.6, double beta = 1.2, double dCutoff = 1.0})
    : x = OneEuroFilter(minCutoff: minCutoff, beta: beta, dCutoff: dCutoff),
      y = OneEuroFilter(minCutoff: minCutoff, beta: beta, dCutoff: dCutoff);

  final OneEuroFilter x;
  final OneEuroFilter y;

  void reset() {
    x.reset();
    y.reset();
  }
}

/// Tracks FPS over a short window for the HUD.
class FpsCounter {
  FpsCounter({this.window = 20});

  final int window;
  final List<double> _deltas = [];

  void reset() => _deltas.clear();

  double add(double dtSeconds) {
    if (dtSeconds <= 0) return 30;
    _deltas.add(dtSeconds);
    if (_deltas.length > window) _deltas.removeAt(0);
    final average = _deltas.reduce((a, b) => a + b) / _deltas.length;
    return average <= 0 ? 30 : 1.0 / average;
  }
}
