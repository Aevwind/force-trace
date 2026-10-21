import 'dart:math' as math;
import 'dart:ui';

import 'pose_models.dart';

/// Deterministic, physically plausible pose source used by the demo mode.
///
/// It reproduces the VBT rep rhythm (idle → eccentric → pause → concentric)
/// and adds fatigue: each rep gets slightly slower and shallower, eventually
/// crossing the ROM threshold. Replacing this class with a MediaPipe / YOLO
/// adapter is the only change needed for real inference.
class SimulatedPoseSource implements PoseFrameSource {
  SimulatedPoseSource({
    required this.pattern,
    this.maxReps = 10,
    int seed = 7,
    this.startDelaySeconds = 0.9,
  }) : _random = math.Random(seed) {
    _cycles = _buildCycles();
    _totalSeconds = _cycles.fold<double>(
      0,
      (sum, cycle) => sum > cycle.end ? sum : cycle.end,
    );
  }

  final MotionPattern pattern;
  final int maxReps;
  final double startDelaySeconds;
  final math.Random _random;

  late final List<_RepCycle> _cycles;
  late final double _totalSeconds;

  @override
  double get totalSeconds => _totalSeconds;
  double get cycleSeconds => _cycles.isEmpty ? 4 : _cycles.first.end;

  List<_RepCycle> _buildCycles() {
    final cycles = <_RepCycle>[];
    var cursor = startDelaySeconds;
    for (var rep = 0; rep < maxReps; rep++) {
      final eccentric = 1.5 + 0.03 * rep;
      final bottom = 0.25;
      final concentric = 1.15 + 0.04 * rep;
      final idle = 0.9;
      final end = cursor + eccentric + bottom + concentric + idle;
      cycles.add(
        _RepCycle(
          rep: rep,
          start: cursor,
          eccentricEnd: cursor + eccentric,
          bottomEnd: cursor + eccentric + bottom,
          concentricEnd: cursor + eccentric + bottom + concentric,
          end: end,
        ),
      );
      cursor = end;
    }
    return cycles;
  }

  @override
  PoseFrame frameAt(double seconds) {
    final t = seconds.clamp(0.0, _totalSeconds);
    final cycle = _cycleAt(t);
    var depth = 0.0;

    if (t >= cycle.start && t < cycle.eccentricEnd) {
      final p = (t - cycle.start) / (cycle.eccentricEnd - cycle.start);
      depth = _easeInOutCubic(p);
    } else if (t >= cycle.eccentricEnd && t < cycle.bottomEnd) {
      depth = 1;
    } else if (t >= cycle.bottomEnd && t < cycle.concentricEnd) {
      final p = (t - cycle.bottomEnd) / (cycle.concentricEnd - cycle.bottomEnd);
      depth = 1 - _easeInOutCubic(p);
    } else if (t >= cycle.concentricEnd) {
      depth = 0;
    }

    final amplitude = (1.0 - 0.07 * math.max(0, cycle.rep - 3)).clamp(
      0.42,
      1.0,
    );
    final effectiveDepth = depth * amplitude;
    final spec = _specFor(pattern);
    final landmarks = <LandmarkId, Offset>{};
    for (final entry in spec.top.entries) {
      final bottom = spec.bottom[entry.key] ?? entry.value;
      landmarks[entry.key] = _lerp(entry.value, bottom, effectiveDepth);
    }
    final bar = _lerp(spec.barTop, spec.barBottom, effectiveDepth);

    // Sensor noise: roughly ±0.4 px on a 1000 px reference frame.
    final noisyLandmarks = <LandmarkId, Offset>{
      for (final entry in landmarks.entries)
        entry.key: _jitter(entry.value, 0.0004),
    };
    final noisyBar = _jitter(bar, 0.0004);

    return PoseFrame(
      timestampMs: t * 1000,
      imageSize: const Size(1000, 1000),
      landmarks: noisyLandmarks,
      trackedPoint: noisyBar,
      platePixelDiameter: 120 + _random.nextDouble() * 2 - 1,
      hasPlate: true,
      pattern: pattern,
    );
  }

  _RepCycle _cycleAt(double t) {
    for (final cycle in _cycles) {
      if (t < cycle.end) return cycle;
    }
    return _cycles.last;
  }

  Offset _jitter(Offset point, double amount) {
    // Box-Muller for a normal-ish distribution.
    final u1 = _random.nextDouble().clamp(1e-6, 1.0);
    final u2 = _random.nextDouble();
    final magnitude = math.sqrt(-2 * math.log(u1)) * amount;
    final angle = 2 * math.pi * u2;
    return point +
        Offset(math.cos(angle) * magnitude, math.sin(angle) * magnitude);
  }

  static Offset _lerp(Offset a, Offset b, double t) {
    return Offset(a.dx + (b.dx - a.dx) * t, a.dy + (b.dy - a.dy) * t);
  }

  static double _easeInOutCubic(double t) {
    return t < 0.5 ? 4 * t * t * t : 1 - math.pow(-2 * t + 2, 3) / 2;
  }

  static _PoseSpec _specFor(MotionPattern pattern) {
    switch (pattern) {
      case MotionPattern.squat:
        return _PoseSpec(
          top: {
            LandmarkId.head: const Offset(0.56, 0.225),
            LandmarkId.shoulder: const Offset(0.57, 0.30),
            LandmarkId.elbow: const Offset(0.55, 0.38),
            LandmarkId.wrist: const Offset(0.56, 0.285),
            LandmarkId.hip: const Offset(0.59, 0.56),
            LandmarkId.knee: const Offset(0.62, 0.73),
            LandmarkId.ankle: const Offset(0.62, 0.90),
          },
          bottom: {
            LandmarkId.head: const Offset(0.60, 0.385),
            LandmarkId.shoulder: const Offset(0.61, 0.46),
            LandmarkId.elbow: const Offset(0.53, 0.55),
            LandmarkId.wrist: const Offset(0.60, 0.445),
            LandmarkId.hip: const Offset(0.55, 0.69),
            LandmarkId.knee: const Offset(0.70, 0.68),
            LandmarkId.ankle: const Offset(0.62, 0.90),
          },
          barTop: const Offset(0.56, 0.285),
          barBottom: const Offset(0.60, 0.445),
        );
      case MotionPattern.hinge:
        return _PoseSpec(
          top: {
            LandmarkId.head: const Offset(0.585, 0.225),
            LandmarkId.shoulder: const Offset(0.59, 0.30),
            LandmarkId.elbow: const Offset(0.59, 0.42),
            LandmarkId.wrist: const Offset(0.61, 0.52),
            LandmarkId.hip: const Offset(0.62, 0.56),
            LandmarkId.knee: const Offset(0.65, 0.73),
            LandmarkId.ankle: const Offset(0.64, 0.90),
          },
          bottom: {
            LandmarkId.head: const Offset(0.75, 0.40),
            LandmarkId.shoulder: const Offset(0.72, 0.46),
            LandmarkId.elbow: const Offset(0.74, 0.57),
            LandmarkId.wrist: const Offset(0.73, 0.66),
            LandmarkId.hip: const Offset(0.59, 0.60),
            LandmarkId.knee: const Offset(0.67, 0.73),
            LandmarkId.ankle: const Offset(0.64, 0.90),
          },
          barTop: const Offset(0.61, 0.52),
          barBottom: const Offset(0.73, 0.66),
        );
      case MotionPattern.bench:
        return _PoseSpec(
          top: {
            LandmarkId.head: const Offset(0.30, 0.60),
            LandmarkId.shoulder: const Offset(0.38, 0.61),
            LandmarkId.elbow: const Offset(0.42, 0.47),
            LandmarkId.wrist: const Offset(0.42, 0.38),
            LandmarkId.hip: const Offset(0.55, 0.61),
            LandmarkId.knee: const Offset(0.72, 0.68),
            LandmarkId.ankle: const Offset(0.76, 0.86),
          },
          bottom: {
            LandmarkId.head: const Offset(0.30, 0.60),
            LandmarkId.shoulder: const Offset(0.38, 0.61),
            LandmarkId.elbow: const Offset(0.48, 0.55),
            LandmarkId.wrist: const Offset(0.42, 0.50),
            LandmarkId.hip: const Offset(0.55, 0.61),
            LandmarkId.knee: const Offset(0.72, 0.68),
            LandmarkId.ankle: const Offset(0.76, 0.86),
          },
          barTop: const Offset(0.42, 0.38),
          barBottom: const Offset(0.42, 0.50),
        );
      case MotionPattern.press:
        return _PoseSpec(
          top: {
            LandmarkId.head: const Offset(0.56, 0.225),
            LandmarkId.shoulder: const Offset(0.57, 0.30),
            LandmarkId.elbow: const Offset(0.56, 0.23),
            LandmarkId.wrist: const Offset(0.56, 0.16),
            LandmarkId.hip: const Offset(0.59, 0.56),
            LandmarkId.knee: const Offset(0.62, 0.73),
            LandmarkId.ankle: const Offset(0.62, 0.90),
          },
          bottom: {
            LandmarkId.head: const Offset(0.56, 0.225),
            LandmarkId.shoulder: const Offset(0.57, 0.30),
            LandmarkId.elbow: const Offset(0.61, 0.35),
            LandmarkId.wrist: const Offset(0.56, 0.31),
            LandmarkId.hip: const Offset(0.59, 0.56),
            LandmarkId.knee: const Offset(0.62, 0.73),
            LandmarkId.ankle: const Offset(0.62, 0.90),
          },
          barTop: const Offset(0.56, 0.16),
          barBottom: const Offset(0.56, 0.31),
        );
      case MotionPattern.pullup:
        return _PoseSpec(
          top: {
            LandmarkId.head: const Offset(0.56, 0.235),
            LandmarkId.shoulder: const Offset(0.57, 0.31),
            LandmarkId.elbow: const Offset(0.62, 0.23),
            LandmarkId.wrist: const Offset(0.55, 0.16),
            LandmarkId.hip: const Offset(0.59, 0.51),
            LandmarkId.knee: const Offset(0.57, 0.65),
            LandmarkId.ankle: const Offset(0.56, 0.78),
          },
          bottom: {
            LandmarkId.head: const Offset(0.56, 0.375),
            LandmarkId.shoulder: const Offset(0.57, 0.44),
            LandmarkId.elbow: const Offset(0.64, 0.35),
            LandmarkId.wrist: const Offset(0.55, 0.16),
            LandmarkId.hip: const Offset(0.59, 0.64),
            LandmarkId.knee: const Offset(0.57, 0.78),
            LandmarkId.ankle: const Offset(0.56, 0.90),
          },
          barTop: const Offset(0.59, 0.51),
          barBottom: const Offset(0.59, 0.64),
        );
      case MotionPattern.pushup:
        return _PoseSpec(
          top: {
            LandmarkId.head: const Offset(0.36, 0.64),
            LandmarkId.shoulder: const Offset(0.43, 0.68),
            LandmarkId.elbow: const Offset(0.42, 0.78),
            LandmarkId.wrist: const Offset(0.40, 0.86),
            LandmarkId.hip: const Offset(0.60, 0.76),
            LandmarkId.knee: const Offset(0.70, 0.82),
            LandmarkId.ankle: const Offset(0.78, 0.86),
          },
          bottom: {
            LandmarkId.head: const Offset(0.37, 0.75),
            LandmarkId.shoulder: const Offset(0.44, 0.80),
            LandmarkId.elbow: const Offset(0.50, 0.84),
            LandmarkId.wrist: const Offset(0.40, 0.86),
            LandmarkId.hip: const Offset(0.60, 0.80),
            LandmarkId.knee: const Offset(0.70, 0.83),
            LandmarkId.ankle: const Offset(0.78, 0.86),
          },
          barTop: const Offset(0.43, 0.68),
          barBottom: const Offset(0.44, 0.80),
        );
      case MotionPattern.curl:
        return _PoseSpec(
          top: {
            LandmarkId.head: const Offset(0.56, 0.225),
            LandmarkId.shoulder: const Offset(0.57, 0.30),
            LandmarkId.elbow: const Offset(0.61, 0.44),
            LandmarkId.wrist: const Offset(0.60, 0.38),
            LandmarkId.hip: const Offset(0.59, 0.56),
            LandmarkId.knee: const Offset(0.62, 0.73),
            LandmarkId.ankle: const Offset(0.62, 0.90),
          },
          bottom: {
            LandmarkId.head: const Offset(0.56, 0.225),
            LandmarkId.shoulder: const Offset(0.57, 0.30),
            LandmarkId.elbow: const Offset(0.61, 0.44),
            LandmarkId.wrist: const Offset(0.62, 0.52),
            LandmarkId.hip: const Offset(0.59, 0.56),
            LandmarkId.knee: const Offset(0.62, 0.73),
            LandmarkId.ankle: const Offset(0.62, 0.90),
          },
          barTop: const Offset(0.60, 0.38),
          barBottom: const Offset(0.62, 0.52),
        );
    }
  }
}

class _PoseSpec {
  const _PoseSpec({
    required this.top,
    required this.bottom,
    required this.barTop,
    required this.barBottom,
  });

  final Map<LandmarkId, Offset> top;
  final Map<LandmarkId, Offset> bottom;
  final Offset barTop;
  final Offset barBottom;
}

class _RepCycle {
  const _RepCycle({
    required this.rep,
    required this.start,
    required this.eccentricEnd,
    required this.bottomEnd,
    required this.concentricEnd,
    required this.end,
  });

  final int rep;
  final double start;
  final double eccentricEnd;
  final double bottomEnd;
  final double concentricEnd;
  final double end;
}
