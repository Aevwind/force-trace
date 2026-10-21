import 'dart:ui';

import 'calibration.dart';

enum LandmarkId { head, shoulder, elbow, wrist, hip, knee, ankle, toe }

enum MotionPattern { squat, hinge, bench, press, pullup, pushup, curl }

extension MotionPatternX on MotionPattern {
  bool get hasBarbell =>
      this == MotionPattern.squat ||
      this == MotionPattern.hinge ||
      this == MotionPattern.bench ||
      this == MotionPattern.press ||
      this == MotionPattern.curl;

  String get assetLabel => switch (this) {
    MotionPattern.squat => 'squat',
    MotionPattern.hinge => 'hinge',
    MotionPattern.bench => 'bench',
    MotionPattern.press => 'press',
    MotionPattern.pullup => 'pull-up',
    MotionPattern.pushup => 'push-up',
    MotionPattern.curl => 'curl',
  };
}

enum RepPhase { idle, eccentric, concentric, completed }

extension RepPhaseX on RepPhase {
  String get key => switch (this) {
    RepPhase.idle => 'phaseIdle',
    RepPhase.eccentric => 'phaseEccentric',
    RepPhase.concentric => 'phaseConcentric',
    RepPhase.completed => 'phaseCompleted',
  };
}

/// Contract every pose/barbell source implements. The demo uses
/// [SimulatedPoseSource]; MediaPipe/MLKit + YOLOv8 adapters can implement the
/// same interface without touching the kinematics engine or HUD.
abstract interface class PoseFrameSource {
  double get totalSeconds;

  PoseFrame frameAt(double seconds);
}

/// A single raw camera/pose frame in normalized image coordinates.
class PoseFrame {
  const PoseFrame({
    required this.timestampMs,
    required this.imageSize,
    required this.landmarks,
    required this.trackedPoint,
    this.platePixelDiameter = 0,
    this.hasPlate = false,
    this.pattern = MotionPattern.squat,
    this.hasPose = true,
    this.isCameraFrame = false,
    this.secondaryLandmarks = const {},
  });

  final double timestampMs;
  final Size imageSize;
  final Map<LandmarkId, Offset> landmarks;

  /// Opposite body side, used only to draw a two-sided front-view skeleton.
  final Map<LandmarkId, Offset> secondaryLandmarks;

  /// Barbell center, wrist, or body reference point used for kinematics.
  final Offset trackedPoint;
  final double platePixelDiameter;
  final bool hasPlate;
  final MotionPattern pattern;

  /// False while the real detector has not produced a usable pose yet.
  final bool hasPose;

  /// True when [landmarks] come from the real camera and must be mapped with
  /// the camera preview's BoxFit.cover transform instead of the HUD stage.
  final bool isCameraFrame;
}

class TrajectoryPoint {
  const TrajectoryPoint({
    required this.point,
    required this.phase,
    required this.repIndex,
  });

  final Offset point;
  final RepPhase phase;
  final int repIndex;
}

class LiveFrame {
  const LiveFrame({
    required this.landmarks,
    required this.bar,
    required this.trajectory,
    required this.ghostTrajectory,
    required this.phase,
    required this.velocity,
    required this.hipAngle,
    required this.kneeAngle,
    required this.elbowAngle,
    required this.fps,
    required this.pattern,
    required this.romCm,
    required this.repIndex,
    required this.hasPose,
    this.imageSize = const Size(1000, 1000),
    this.cameraFrame = false,
    this.secondaryLandmarks = const {},
  });

  final Map<LandmarkId, Offset> landmarks;
  final Map<LandmarkId, Offset> secondaryLandmarks;
  final Offset bar;
  final List<TrajectoryPoint> trajectory;
  final List<TrajectoryPoint> ghostTrajectory;
  final RepPhase phase;
  final double velocity;
  final double hipAngle;
  final double kneeAngle;
  final double elbowAngle;
  final double fps;
  final MotionPattern pattern;
  final double romCm;
  final int repIndex;
  final bool hasPose;

  /// Camera image dimensions and a flag that enables the preview-aligned
  /// BoxFit.cover transform in the HUD painter.
  final Size imageSize;
  final bool cameraFrame;

  bool get showBarbell => pattern.hasBarbell;
}

class LiveStats {
  const LiveStats({
    required this.repCount,
    required this.invalidCount,
    required this.targetReps,
    required this.currentVelocity,
    required this.meanVelocity,
    required this.peakVelocity,
    required this.bestMeanVelocity,
    required this.romCm,
    required this.bestRomCm,
    required this.velocityLoss,
    required this.eccentricSeconds,
    required this.concentricSeconds,
    required this.phase,
    required this.hipAngle,
    required this.kneeAngle,
    required this.elapsed,
    required this.running,
    required this.cue,
    required this.cueSerial,
    required this.autoStopped,
  });

  final int repCount;
  final int invalidCount;
  final int targetReps;
  final double currentVelocity;
  final double meanVelocity;
  final double peakVelocity;
  final double bestMeanVelocity;
  final double romCm;
  final double bestRomCm;
  final double velocityLoss;
  final double eccentricSeconds;
  final double concentricSeconds;
  final RepPhase phase;
  final double hipAngle;
  final double kneeAngle;
  final Duration elapsed;
  final bool running;
  final String? cue;
  final int cueSerial;
  final bool autoStopped;
}

enum VbtEventKind { rep, invalidRep, bestRep, depth, velocityLoss, autoStop }

class VbtEvent {
  const VbtEvent({
    required this.kind,
    required this.messageKey,
    this.repIndex = 0,
    this.value = 0,
  });

  final VbtEventKind kind;
  final String messageKey;
  final int repIndex;
  final double value;
}

class RepResult {
  RepResult({
    required this.index,
    required this.meanVelocity,
    required this.peakVelocity,
    required this.romCm,
    required this.durationMs,
    required this.eccentricMs,
    required this.concentricMs,
    required this.minHipAngle,
    required this.minKneeAngle,
    this.velocityLossPercent = 0,
    this.isBestRep = false,
  });

  final int index;
  final double meanVelocity;
  final double peakVelocity;
  final double romCm;
  final int durationMs;
  final int eccentricMs;
  final int concentricMs;
  final double minHipAngle;
  final double minKneeAngle;
  double velocityLossPercent;
  bool isBestRep;

  double get durationSeconds => durationMs / 1000;
  double get tempoRatio => concentricMs == 0 ? 0 : eccentricMs / concentricMs;
}

class SetResult {
  const SetResult({
    required this.exerciseId,
    required this.exerciseName,
    required this.tier,
    required this.reps,
    required this.invalidReps,
    required this.startedAt,
    required this.finishedAt,
    required this.weightKg,
    required this.calibration,
    required this.autoStopped,
  });

  final String exerciseId;
  final String exerciseName;
  final int tier;
  final List<RepResult> reps;
  final int invalidReps;
  final DateTime startedAt;
  final DateTime finishedAt;
  final double weightKg;
  final Calibration calibration;
  final bool autoStopped;

  int get totalReps => reps.length;
  double get avgMeanVelocity => reps.isEmpty
      ? 0
      : reps.map((r) => r.meanVelocity).reduce((a, b) => a + b) / reps.length;
  double get bestMeanVelocity => reps.isEmpty
      ? 0
      : reps.map((r) => r.meanVelocity).reduce((a, b) => a > b ? a : b);
  double get peakVelocity => reps.isEmpty
      ? 0
      : reps.map((r) => r.peakVelocity).reduce((a, b) => a > b ? a : b);
  double get bestRomCm => reps.isEmpty
      ? 0
      : reps.map((r) => r.romCm).reduce((a, b) => a > b ? a : b);
  double get velocityLoss => reps.isEmpty ? 0 : reps.last.velocityLossPercent;
  RepResult? get bestRep {
    if (reps.isEmpty) return null;
    return reps.reduce((a, b) => a.meanVelocity >= b.meanVelocity ? a : b);
  }
}
