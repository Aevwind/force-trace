import 'dart:math' as math;

import 'pose_models.dart';

/// Four-state repetition detector: idle → eccentric → concentric → completed.
///
/// The thresholds and hold times follow the VBT spec: a downward vertical
/// velocity sustained for 150 ms starts the eccentric; a change of direction
/// sustained for 60 ms starts the concentric; a return to near-zero velocity
/// for 120 ms closes the rep.
class RepStateMachine {
  RepStateMachine({
    required this.minRomCm,
    this.downThreshold = 0.06,
    this.upThreshold = 0.05,
    this.topThreshold = 0.05,
    this.downHoldMs = 150,
    this.upHoldMs = 60,
    this.topHoldMs = 120,
    this.completedHoldMs = 280,
  });

  final double minRomCm;
  final double downThreshold;
  final double upThreshold;
  final double topThreshold;
  final int downHoldMs;
  final int upHoldMs;
  final int topHoldMs;
  final int completedHoldMs;

  RepPhase _phase = RepPhase.idle;
  int _repIndex = 0;

  int? _downSinceMs;
  int? _upSinceMs;
  int? _topSinceMs;
  int? _eccStartMs;
  int? _conStartMs;
  int? _completedAtMs;
  double _bottomY = 0;
  double _currentY = 0;

  double _minHip = 180;
  double _minKnee = 180;
  double _minElbow = 180;

  final List<double> _concentricSpeeds = [];

  RepPhase get phase => _phase;
  int get repIndex => _repIndex;
  double get bottomY => _bottomY;
  double get currentY => _currentY;
  double get minHipAngle => _minHip;
  double get minKneeAngle => _minKnee;
  double get minElbowAngle => _minElbow;

  int? get eccStartMs => _eccStartMs;
  int? get conStartMs => _conStartMs;

  int get eccentricMs => _conStartMs == null || _eccStartMs == null
      ? 0
      : _conStartMs! - _eccStartMs!;

  int get concentricMs {
    if (_conStartMs == null) return 0;
    final end = _completedAtMs ?? _lastTimestampMs;
    if (end == null) return 0;
    return math.max(0, end - _conStartMs!);
  }

  double get currentConcentricMean {
    if (_concentricSpeeds.isEmpty) return 0;
    return _concentricSpeeds.reduce((a, b) => a + b) / _concentricSpeeds.length;
  }

  double get currentConcentricPeak {
    if (_concentricSpeeds.isEmpty) return 0;
    return _concentricSpeeds.reduce((a, b) => a > b ? a : b);
  }

  int get currentRomCm {
    if (_bottomY <= 0 || _currentY <= 0) return 0;
    return math.max(
      0,
      ((_bottomY - _currentY) * _metersPerPixel * 100).round(),
    );
  }

  int? _lastTimestampMs;
  double _metersPerPixel = 0.00375;

  /// Feeds one filtered frame. Returns a completed attempt exactly once.
  RepAttempt? update({
    required int timestampMs,
    required double barY,
    required double metersPerPixel,
    required double verticalVelocity,
    required double speed,
    required double hipAngle,
    required double kneeAngle,
    required double elbowAngle,
  }) {
    _lastTimestampMs = timestampMs;
    _metersPerPixel = metersPerPixel;
    _currentY = barY;

    if (_phase == RepPhase.completed) {
      final completedAt = _completedAtMs;
      if (completedAt != null && timestampMs - completedAt >= completedHoldMs) {
        _phase = RepPhase.idle;
        _resetRepState();
      }
      return null;
    }

    if (_phase == RepPhase.idle) {
      if (verticalVelocity < -downThreshold) {
        _downSinceMs ??= timestampMs;
        if (timestampMs - _downSinceMs! >= downHoldMs) {
          _phase = RepPhase.eccentric;
          _eccStartMs = _downSinceMs;
          _bottomY = barY;
          _minHip = hipAngle;
          _minKnee = kneeAngle;
          _minElbow = elbowAngle;
          _downSinceMs = null;
          _upSinceMs = null;
        }
      } else {
        _downSinceMs = null;
      }
      return null;
    }

    if (_phase == RepPhase.eccentric) {
      if (barY > _bottomY) _bottomY = barY;
      _minHip = math.min(_minHip, hipAngle);
      _minKnee = math.min(_minKnee, kneeAngle);
      _minElbow = math.min(_minElbow, elbowAngle);

      if (verticalVelocity > upThreshold) {
        _upSinceMs ??= timestampMs;
        if (timestampMs - _upSinceMs! >= upHoldMs) {
          _phase = RepPhase.concentric;
          _conStartMs = _upSinceMs;
          _concentricSpeeds.clear();
          _topSinceMs = null;
          _upSinceMs = null;
        }
      } else {
        _upSinceMs = null;
      }
      return null;
    }

    // Concentric.
    _minHip = math.min(_minHip, hipAngle);
    _minKnee = math.min(_minKnee, kneeAngle);
    _minElbow = math.min(_minElbow, elbowAngle);
    _concentricSpeeds.add(speed < 0 ? 0.0 : speed);

    if (verticalVelocity < topThreshold) {
      _topSinceMs ??= timestampMs;
      if (timestampMs - _topSinceMs! >= topHoldMs) {
        final attempt = _complete(timestampMs);
        return attempt;
      }
    } else {
      _topSinceMs = null;
    }
    return null;
  }

  RepAttempt _complete(int timestampMs) {
    _completedAtMs = timestampMs;
    final eccStart = _eccStartMs ?? timestampMs;
    final conStart = _conStartMs ?? timestampMs;
    final romCm = math.max(0.0, (_bottomY - _currentY) * _metersPerPixel * 100);
    final mean = _concentricSpeeds.isEmpty
        ? 0.0
        : _concentricSpeeds.reduce((a, b) => a + b) / _concentricSpeeds.length;
    final peak = _concentricSpeeds.isEmpty
        ? 0.0
        : _concentricSpeeds.reduce((a, b) => a > b ? a : b);
    final valid = romCm >= minRomCm;
    final attempt = RepAttempt(
      index: _repIndex,
      valid: valid,
      romCm: romCm,
      meanVelocity: mean,
      peakVelocity: peak,
      durationMs: timestampMs - eccStart,
      eccentricMs: math.max(0, conStart - eccStart),
      concentricMs: math.max(0, timestampMs - conStart),
      minHipAngle: _minHip,
      minKneeAngle: _minKnee,
      minElbowAngle: _minElbow,
      startMs: eccStart,
      endMs: timestampMs,
    );
    _repIndex++;
    _phase = RepPhase.completed;
    return attempt;
  }

  /// Aborts a partial rep (e.g. the user ends the set at the bottom).
  void abort() {
    _phase = RepPhase.idle;
    _resetRepState();
  }

  void reset() {
    _phase = RepPhase.idle;
    _repIndex = 0;
    _resetRepState();
  }

  void _resetRepState() {
    _downSinceMs = null;
    _upSinceMs = null;
    _topSinceMs = null;
    _eccStartMs = null;
    _conStartMs = null;
    _completedAtMs = null;
    _bottomY = 0;
    _minHip = 180;
    _minKnee = 180;
    _minElbow = 180;
    _concentricSpeeds.clear();
  }
}

class RepAttempt {
  const RepAttempt({
    required this.index,
    required this.valid,
    required this.romCm,
    required this.meanVelocity,
    required this.peakVelocity,
    required this.durationMs,
    required this.eccentricMs,
    required this.concentricMs,
    required this.minHipAngle,
    required this.minKneeAngle,
    required this.minElbowAngle,
    required this.startMs,
    required this.endMs,
  });

  final int index;
  final bool valid;
  final double romCm;
  final double meanVelocity;
  final double peakVelocity;
  final int durationMs;
  final int eccentricMs;
  final int concentricMs;
  final double minHipAngle;
  final double minKneeAngle;
  final double minElbowAngle;
  final int startMs;
  final int endMs;
}
