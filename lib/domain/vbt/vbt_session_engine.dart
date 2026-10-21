import 'dart:math' as math;
import 'dart:ui';

import '../../data/models/models.dart';
import 'angles.dart';
import 'calibration.dart';
import 'exercise_profile.dart';
import 'one_euro_filter.dart';
import 'pose_models.dart';
import 'rep_state_machine.dart';
import 'simulated_pose_source.dart';

/// Pure session engine: advance it with a delta time and read the latest HUD
/// frame / statistics. It has no timers, so it is fully unit-testable.
class VbtSessionEngine {
  VbtSessionEngine({
    required this.exercise,
    required this.exerciseName,
    required this.profile,
    required this.calibration,
    required this.weightKg,
    this.vlThreshold = 20,
    this.autoStopOnVl = true,
    int maxReps = 10,
    int seed = 7,
    PoseFrameSource? source,
  }) : source =
           source ??
           SimulatedPoseSource(
             pattern: profile.pattern,
             maxReps: maxReps,
             seed: seed,
           ),
       stateMachine = RepStateMachine(minRomCm: profile.minRomCm),
       startedAt = DateTime.now() {
    _barFilter = PointFilter(beta: 2.2, minCutoff: 2.2);
    for (final id in LandmarkId.values) {
      _landmarkFilters[id] = PointFilter(beta: 1.2, minCutoff: 1.8);
    }
  }

  final Exercise exercise;
  final String exerciseName;
  final ExerciseProfile profile;
  final Calibration calibration;
  final double weightKg;
  final double vlThreshold;
  final bool autoStopOnVl;
  final PoseFrameSource source;
  final RepStateMachine stateMachine;
  final DateTime startedAt;
  final FpsCounter _fps = FpsCounter();

  late final PointFilter _barFilter;
  final Map<LandmarkId, PointFilter> _landmarkFilters = {};

  final List<RepResult> reps = [];
  final List<VbtEvent> _events = [];
  final List<TrajectoryPoint> _trajectory = [];
  final List<TrajectoryPoint> _ghostTrajectory = [];

  int invalidReps = 0;
  double bestMeanVelocity = 0;
  RepResult? bestRep;
  bool autoStopTriggered = false;
  bool autoStopped = false;
  int _cueSerial = 0;
  String? _cue;
  int _depthCueRep = -1;

  double _sessionSeconds = 0;
  double _fpsValue = 30;
  Offset? _previousBarPixels;
  double? _previousTimestampMs;
  double _speed = 0;
  double _rawSpeed = 0;
  double _verticalVelocity = 0;

  LiveFrame? _lastFrame;
  LiveStats? _lastStats;

  double get sessionSeconds => _sessionSeconds;
  bool get hasReps => reps.isNotEmpty;
  bool get shouldAutoStop => autoStopped;

  LiveFrame? get lastFrame => _lastFrame;
  LiveStats? get lastStats => _lastStats;

  List<VbtEvent> takeEvents() {
    final events = List<VbtEvent>.from(_events);
    _events.clear();
    return events;
  }

  void advance(double dtSeconds) {
    final dt = dtSeconds.clamp(0.001, 0.08);
    _sessionSeconds += dt;
    final frame = source.frameAt(_sessionSeconds);
    if (!frame.hasPose) {
      // Keep the last metrics visible, but do not let empty landmarks complete
      // a rep or produce a fake velocity spike while the detector warms up.
      _previousBarPixels = null;
      _previousTimestampMs = null;
      final neutral = LiveFrame(
        landmarks: const {},
        bar: const Offset(0.5, 0.5),
        trajectory: List<TrajectoryPoint>.unmodifiable(_trajectory),
        ghostTrajectory: List<TrajectoryPoint>.unmodifiable(_ghostTrajectory),
        phase: stateMachine.phase,
        velocity: 0,
        hipAngle: 180,
        kneeAngle: 180,
        elbowAngle: 180,
        fps: _fpsValue,
        pattern: profile.pattern,
        romCm: stateMachine.currentRomCm.toDouble(),
        repIndex: stateMachine.repIndex + 1,
        hasPose: false,
        imageSize: frame.imageSize,
        cameraFrame: frame.isCameraFrame,
      );
      _lastFrame = neutral;
      _lastStats = _buildStats(neutral);
      return;
    }
    final timestampMs = frame.timestampMs;
    final dtSecondsEffective = _previousTimestampMs == null
        ? dt
        : ((timestampMs - _previousTimestampMs!) / 1000).clamp(0.008, 0.08);
    _fpsValue = _fps.add(dtSecondsEffective);

    final width = frame.imageSize.width;
    final height = frame.imageSize.height;
    final tSeconds = timestampMs / 1000;

    final rawBarPixels = Offset(
      frame.trackedPoint.dx * width,
      frame.trackedPoint.dy * height,
    );
    final filteredBarX = _barFilter.x.filter(rawBarPixels.dx, tSeconds);
    final filteredBarY = _barFilter.y.filter(rawBarPixels.dy, tSeconds);
    final barPixels = Offset(filteredBarX, filteredBarY);

    final landmarks = <LandmarkId, Offset>{};
    for (final entry in frame.landmarks.entries) {
      final filter = _landmarkFilters[entry.key]!;
      final x = filter.x.filter(entry.value.dx * width, tSeconds);
      final y = filter.y.filter(entry.value.dy * height, tSeconds);
      landmarks[entry.key] = Offset(x, y);
    }

    if (_previousBarPixels != null) {
      final dx = barPixels.dx - _previousBarPixels!.dx;
      final dy = barPixels.dy - _previousBarPixels!.dy;
      final meters = math.sqrt(dx * dx + dy * dy) * calibration.metersPerPixel;
      _rawSpeed = meters / dtSecondsEffective;
      // A light exponential smoother removes single-frame noise spikes from the
      // peak-velocity value without adding noticeable lag to the mean.
      _speed = _speed <= 0 ? _rawSpeed : _speed * 0.55 + _rawSpeed * 0.45;
      _verticalVelocity = -dy * calibration.metersPerPixel / dtSecondsEffective;
    }
    _previousBarPixels = barPixels;
    _previousTimestampMs = timestampMs;

    final shoulder = landmarks[LandmarkId.shoulder] ?? Offset.zero;
    final hip = landmarks[LandmarkId.hip] ?? Offset.zero;
    final knee = landmarks[LandmarkId.knee] ?? Offset.zero;
    final ankle = landmarks[LandmarkId.ankle] ?? Offset.zero;
    final elbow = landmarks[LandmarkId.elbow] ?? Offset.zero;
    final wrist = landmarks[LandmarkId.wrist] ?? Offset.zero;
    final hipDeg = hipAngle(shoulder, hip, knee);
    final kneeDeg = kneeAngle(hip, knee, ankle);
    final elbowDeg = elbowAngle(shoulder, elbow, wrist);

    final previousPhase = stateMachine.phase;
    final attempt = stateMachine.update(
      timestampMs: timestampMs.round(),
      barY: barPixels.dy,
      metersPerPixel: calibration.metersPerPixel,
      verticalVelocity: _verticalVelocity,
      speed: _speed,
      hipAngle: hipDeg,
      kneeAngle: kneeDeg,
      elbowAngle: elbowDeg,
    );

    if (previousPhase == RepPhase.idle &&
        stateMachine.phase == RepPhase.eccentric) {
      _ghostTrajectory
        ..clear()
        ..addAll(_trajectory);
      _trajectory.clear();
      _depthCueRep = -1;
    }

    if (stateMachine.phase == RepPhase.eccentric ||
        stateMachine.phase == RepPhase.concentric) {
      _trajectory.add(
        TrajectoryPoint(
          point: Offset(barPixels.dx / width, barPixels.dy / height),
          phase: stateMachine.phase,
          repIndex: stateMachine.repIndex + 1,
        ),
      );
      if (_trajectory.length > 260) _trajectory.removeAt(0);
    }

    if (stateMachine.phase == RepPhase.concentric &&
        _depthCueRep != stateMachine.repIndex) {
      _depthCueRep = stateMachine.repIndex;
      final depthMetric = switch (profile.pattern) {
        MotionPattern.squat => stateMachine.minKneeAngle,
        MotionPattern.hinge => stateMachine.minHipAngle,
        MotionPattern.pushup ||
        MotionPattern.curl => stateMachine.minElbowAngle,
        _ => 0.0,
      };
      if (profile.depthCue &&
          depthMetric > profile.depthCueAngle &&
          depthMetric > 0) {
        _emit(
          VbtEvent(
            kind: VbtEventKind.depth,
            messageKey: profile.cueMessageKey,
            value: depthMetric,
          ),
        );
      }
    }

    if (attempt != null) {
      _handleAttempt(attempt);
    }

    final currentRom = stateMachine.currentRomCm.toDouble();
    final normalizedLandmarks = <LandmarkId, Offset>{
      for (final entry in landmarks.entries)
        entry.key: Offset(entry.value.dx / width, entry.value.dy / height),
    };
    final frameOut = LiveFrame(
      landmarks: normalizedLandmarks,
      bar: Offset(barPixels.dx / width, barPixels.dy / height),
      trajectory: List<TrajectoryPoint>.unmodifiable(_trajectory),
      ghostTrajectory: List<TrajectoryPoint>.unmodifiable(_ghostTrajectory),
      phase: stateMachine.phase,
      velocity: _speed,
      hipAngle: hipDeg,
      kneeAngle: kneeDeg,
      elbowAngle: elbowDeg,
      fps: _fpsValue,
      pattern: profile.pattern,
      romCm: currentRom,
      repIndex: stateMachine.repIndex + 1,
      hasPose: frame.hasPose,
      imageSize: frame.imageSize,
      cameraFrame: frame.isCameraFrame,
      secondaryLandmarks: frame.secondaryLandmarks,
    );
    _lastFrame = frameOut;
    _lastStats = _buildStats(frameOut);
  }

  void _handleAttempt(RepAttempt attempt) {
    if (!attempt.valid) {
      invalidReps++;
      _emit(
        VbtEvent(
          kind: VbtEventKind.invalidRep,
          messageKey: 'invalidRep',
          repIndex: attempt.index + 1,
          value: attempt.romCm,
        ),
      );
      return;
    }
    final rep = RepResult(
      index: attempt.index + 1,
      meanVelocity: attempt.meanVelocity,
      peakVelocity: attempt.peakVelocity,
      romCm: attempt.romCm,
      durationMs: attempt.durationMs,
      eccentricMs: attempt.eccentricMs,
      concentricMs: attempt.concentricMs,
      minHipAngle: attempt.minHipAngle,
      minKneeAngle: attempt.minKneeAngle,
    );
    final previousBest = bestMeanVelocity;
    reps.add(rep);
    _recomputeBestAndLoss();
    _emit(
      VbtEvent(
        kind: VbtEventKind.rep,
        messageKey: 'reps',
        repIndex: rep.index,
        value: rep.meanVelocity,
      ),
    );
    if (rep.isBestRep && rep.meanVelocity > previousBest + 1e-6) {
      _emit(
        VbtEvent(
          kind: VbtEventKind.bestRep,
          messageKey: 'newBest',
          repIndex: rep.index,
          value: rep.meanVelocity,
        ),
      );
    }
    if (rep.velocityLossPercent >= vlThreshold && !autoStopTriggered) {
      autoStopTriggered = true;
      _emit(
        VbtEvent(
          kind: VbtEventKind.velocityLoss,
          messageKey: 'vlWarning',
          repIndex: rep.index,
          value: rep.velocityLossPercent,
        ),
      );
      if (autoStopOnVl) {
        autoStopped = true;
        _emit(
          const VbtEvent(
            kind: VbtEventKind.autoStop,
            messageKey: 'autoStopTitle',
          ),
        );
      }
    }
  }

  void _recomputeBestAndLoss() {
    if (reps.isEmpty) {
      bestMeanVelocity = 0;
      bestRep = null;
      return;
    }
    bestMeanVelocity = reps
        .map((rep) => rep.meanVelocity)
        .reduce((a, b) => a > b ? a : b);
    for (final rep in reps) {
      rep.velocityLossPercent = bestMeanVelocity <= 0
          ? 0
          : ((bestMeanVelocity - rep.meanVelocity) / bestMeanVelocity) * 100;
      rep.isBestRep = (rep.meanVelocity - bestMeanVelocity).abs() < 1e-9;
      if (rep.isBestRep) bestRep = rep;
    }
  }

  LiveStats _buildStats(LiveFrame frame) {
    final lastRep = reps.isEmpty ? null : reps.last;
    final liveMean = stateMachine.currentConcentricMean;
    final livePeak = stateMachine.currentConcentricPeak;
    final mean = reps.isEmpty
        ? liveMean
        : reps.map((r) => r.meanVelocity).reduce((a, b) => a + b) / reps.length;
    final completedPeak = reps.isEmpty
        ? 0.0
        : reps.map((r) => r.peakVelocity).reduce((a, b) => a > b ? a : b);
    final peak = math.max(completedPeak, livePeak);
    final bestRom = reps.isEmpty
        ? 0.0
        : reps.map((r) => r.romCm).reduce((a, b) => a > b ? a : b);
    final rom = stateMachine.currentRomCm > 0
        ? stateMachine.currentRomCm.toDouble()
        : (lastRep?.romCm ?? 0);
    return LiveStats(
      repCount: reps.length,
      invalidCount: invalidReps,
      targetReps: profile.targetReps,
      currentVelocity: _speed,
      meanVelocity: mean,
      peakVelocity: peak,
      bestMeanVelocity: bestMeanVelocity,
      romCm: rom,
      bestRomCm: bestRom,
      velocityLoss: lastRep?.velocityLossPercent ?? 0,
      eccentricSeconds: (lastRep?.eccentricMs ?? 0) / 1000,
      concentricSeconds: (lastRep?.concentricMs ?? 0) / 1000,
      phase: stateMachine.phase,
      hipAngle: frame.hipAngle,
      kneeAngle: frame.kneeAngle,
      elapsed: Duration(milliseconds: (_sessionSeconds * 1000).round()),
      running: true,
      cue: _cue,
      cueSerial: _cueSerial,
      autoStopped: autoStopped,
    );
  }

  void _emit(VbtEvent event) {
    _events.add(event);
    _cueSerial++;
    _cue = event.messageKey;
  }

  SetResult finish() {
    stateMachine.abort();
    return SetResult(
      exerciseId: exercise.id,
      exerciseName: exerciseName,
      tier: exercise.tier.value,
      reps: List<RepResult>.unmodifiable(reps),
      invalidReps: invalidReps,
      startedAt: startedAt,
      finishedAt: DateTime.now(),
      weightKg: weightKg,
      calibration: calibration,
      autoStopped: autoStopped,
    );
  }
}
