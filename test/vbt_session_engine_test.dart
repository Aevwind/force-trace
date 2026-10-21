import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:force_trace/data/models/models.dart';
import 'package:force_trace/domain/vbt/calibration.dart';
import 'package:force_trace/domain/vbt/exercise_profile.dart';
import 'package:force_trace/domain/vbt/pose_models.dart';
import 'package:force_trace/domain/vbt/simulated_pose_source.dart';
import 'package:force_trace/domain/vbt/vbt_session_engine.dart';

Exercise _exercise({
  String name = 'barbell full squat',
  int tier = 1,
  String equipment = 'barbell',
  String target = 'quads',
}) {
  return Exercise(
    id: '0001',
    name: name,
    localName: '杠铃深蹲',
    category: 'upper legs',
    bodyPart: 'upper legs',
    equipment: equipment,
    target: target,
    secondaryMuscles: const ['glutes', 'hamstrings'],
    tier: ExerciseTier.fromValue(tier),
    mediaId: '',
  );
}

class _CameraSource implements PoseFrameSource {
  PoseFrame current = _cameraFrame(0);

  @override
  double get totalSeconds => 3600;

  @override
  PoseFrame frameAt(double seconds) => current;
}

PoseFrame _cameraFrame(
  double timestampMs, {
  double y = 0.5,
  bool hasPose = true,
  int trackingId = 0,
}) {
  return PoseFrame(
    timestampMs: timestampMs,
    imageSize: const Size(480, 640),
    landmarks: {for (final id in LandmarkId.values) id: Offset(0.4, y)},
    secondaryLandmarks: {
      for (final id in LandmarkId.values) id: Offset(0.6, y),
    },
    trackedPoint: Offset(0.5, y),
    isCameraFrame: true,
    hasPose: hasPose,
    trackingId: trackingId,
  );
}

VbtSessionEngine _engine(PoseFrameSource source) => VbtSessionEngine(
  exercise: _exercise(),
  exerciseName: 'Squat',
  profile: ExerciseProfile.forExercise(_exercise()),
  calibration: Calibration.fromPlate(
    plateDiameterCm: 45,
    platePixelDiameter: 120,
  )!,
  weightKg: 60,
  autoStopOnVl: false,
  source: source,
);

class _SampledSource implements PoseFrameSource {
  _SampledSource(this.fps);
  final int fps;
  final SimulatedPoseSource delegate = SimulatedPoseSource(
    pattern: MotionPattern.squat,
    seed: 3,
  );

  @override
  double get totalSeconds => delegate.totalSeconds;

  @override
  PoseFrame frameAt(double seconds) =>
      delegate.frameAt((seconds * fps).floor() / fps);
}

void main() {
  group('ExerciseProfile', () {
    test('squat is a 35 cm Tier 1 pattern', () {
      final profile = ExerciseProfile.forExercise(_exercise());
      expect(profile.pattern, MotionPattern.squat);
      expect(profile.minRomCm, 35);
      expect(profile.hasBarbell, isTrue);
    });

    test('bench press uses the bench pattern and 20 cm ROM', () {
      final profile = ExerciseProfile.forExercise(
        _exercise(name: 'barbell bench press'),
      );
      expect(profile.pattern, MotionPattern.bench);
      expect(profile.minRomCm, 20);
    });

    test('pull-up disables barbell rendering', () {
      final profile = ExerciseProfile.forExercise(
        _exercise(name: 'pull-up', tier: 2, equipment: 'body weight'),
      );
      expect(profile.pattern, MotionPattern.pullup);
      expect(profile.hasBarbell, isFalse);
    });

    test('romanian deadlift uses a shorter hinge threshold', () {
      final profile = ExerciseProfile.forExercise(
        _exercise(name: 'barbell romanian deadlift'),
      );
      expect(profile.pattern, MotionPattern.hinge);
      expect(profile.minRomCm, 30);
    });
  });

  group('VbtSessionEngine', () {
    test('a new tracking run resets filters without a sampled empty frame', () {
      final source = _CameraSource();
      final engine = _engine(source);
      engine.advance(1 / 30);
      source.current = _cameraFrame(100, y: 0.6);
      engine.advance(1 / 30);
      expect(engine.lastFrame!.velocity, greaterThan(0));
      source.current = _cameraFrame(200, y: 0.1, trackingId: 1);
      engine.advance(1 / 30);
      expect(engine.lastFrame!.velocity, 0);
      expect(engine.lastFrame!.bar.dy, 0.1);
      expect(engine.stateMachine.phase, RepPhase.idle);
    });

    test('cached camera frames never advance filters or kinematics twice', () {
      final source = _CameraSource();
      final engine = _engine(source);
      engine.advance(1 / 30);
      source.current = _cameraFrame(100, y: 0.52);
      engine.advance(1 / 30);
      final frame = engine.lastFrame;
      final stats = engine.lastStats;
      for (var i = 0; i < 5; i++) {
        engine.advance(1 / 30);
        expect(identical(engine.lastFrame, frame), isTrue);
        expect(identical(engine.lastStats, stats), isTrue);
      }
      expect(frame!.fps, closeTo(10, 0.001));
    });

    test(
      '10 FPS velocity uses actual sample time instead of a capped delta',
      () {
        final source = _CameraSource();
        final engine = _engine(source);
        for (var i = 0; i < 30; i++) {
          source.current = _cameraFrame(i * 100.0, y: 0.1 + i * 0.02);
          engine.advance(1 / 30);
        }
        // 0.2 image heights/s * 640 px * 0.00375 m/px = 0.48 m/s.
        expect(engine.lastFrame!.velocity, closeTo(0.48, 0.02));
        expect(engine.lastFrame!.fps, closeTo(10, 0.001));
      },
    );

    test('both anatomical sides suppress stationary jitter at 15 FPS', () {
      final source = _CameraSource();
      final engine = _engine(source);
      final primary = <double>[];
      final secondary = <double>[];
      for (var i = 0; i < 90; i++) {
        source.current = _cameraFrame(
          i * 1000 / 15,
          y: 0.5 + (i.isEven ? 0.008 : -0.008),
        );
        engine.advance(1 / 30);
        if (i > 30) {
          primary.add(engine.lastFrame!.landmarks[LandmarkId.knee]!.dy);
          secondary.add(
            engine.lastFrame!.secondaryLandmarks[LandmarkId.knee]!.dy,
          );
        }
      }
      for (final samples in [primary, secondary]) {
        expect(samples.every((y) => (y - 0.5).abs() < 0.003), isTrue);
      }
    });

    test('loss or long gaps discard motion history before reacquisition', () {
      final source = _CameraSource();
      final engine = _engine(source);
      engine.advance(1 / 30);
      source.current = _cameraFrame(100, y: 0.6);
      engine.advance(1 / 30);
      source.current = _cameraFrame(200, hasPose: false);
      engine.advance(1 / 30);
      expect(engine.lastFrame!.hasPose, isFalse);
      expect(engine.lastStats!.currentVelocity, 0);
      source.current = _cameraFrame(300, y: 0.1);
      engine.advance(1 / 30);
      expect(engine.lastFrame!.velocity, 0);
      expect(engine.lastFrame!.bar.dy, 0.1);
      source.current = _cameraFrame(1300, y: 0.8);
      engine.advance(1 / 30);
      expect(engine.lastFrame!.velocity, 0);
      expect(engine.lastFrame!.bar.dy, 0.8);
      expect(engine.stateMachine.phase, RepPhase.idle);
    });

    test('lower sampling rates retain valid reps and comparable velocity', () {
      final engines = [
        for (final fps in [10, 15, 30]) _engine(_SampledSource(fps)),
      ];
      for (final engine in engines) {
        for (var i = 0; i < 1600; i++) {
          engine.advance(1 / 30);
        }
        expect(engine.reps.length, greaterThanOrEqualTo(4));
        expect(engine.reps.every((rep) => rep.romCm >= 35), isTrue);
      }
      final reference = engines.last.finish().avgMeanVelocity;
      for (final engine in engines.take(2)) {
        expect(
          engine.finish().avgMeanVelocity,
          closeTo(reference, reference * 0.2),
        );
      }
    });

    test('produces valid reps, best rep and velocity loss over a set', () {
      final exercise = _exercise();
      final profile = ExerciseProfile.forExercise(exercise);
      final calibration = Calibration.fromPlate(
        plateDiameterCm: 45,
        platePixelDiameter: 120,
      )!;
      final engine = VbtSessionEngine(
        exercise: exercise,
        exerciseName: '杠铃深蹲',
        profile: profile,
        calibration: calibration,
        weightKg: 60,
        vlThreshold: 20,
        autoStopOnVl: true,
        seed: 3,
      );

      var frameCount = 0;
      for (var i = 0; i < 1600; i++) {
        engine.advance(1 / 30);
        frameCount++;
        final frame = engine.lastFrame;
        expect(frame, isNotNull);
        expect(frame!.landmarks, isNotEmpty);
        expect(frame.hasPose, isTrue);
      }

      expect(frameCount, 1600);
      expect(engine.reps.length, greaterThanOrEqualTo(4));
      expect(engine.reps.every((rep) => rep.romCm >= 35), isTrue);
      expect(engine.bestRep, isNotNull);
      expect(engine.bestMeanVelocity, greaterThan(0));
      expect(engine.lastStats, isNotNull);
      expect(engine.lastStats!.repCount, engine.reps.length);
      expect(engine.autoStopped, isTrue);
      expect(engine.takeEvents(), isNotEmpty);

      final summary = engine.finish();
      expect(summary.totalReps, engine.reps.length);
      expect(summary.avgMeanVelocity, greaterThan(0));
      expect(summary.peakVelocity, greaterThan(0));
      expect(summary.bestRomCm, greaterThanOrEqualTo(35));
      expect(summary.velocityLoss, greaterThan(0));
      expect(summary.weightKg, 60);
      expect(summary.calibration.metersPerPixel, closeTo(0.00375, 1e-9));
    });

    test('tier 2 bodyweight engine still tracks the body reference point', () {
      final exercise = _exercise(
        name: 'pull-up',
        tier: 2,
        equipment: 'body weight',
        target: 'lats',
      );
      final profile = ExerciseProfile.forExercise(exercise);
      final calibration = Calibration.fromPlate(
        plateDiameterCm: 45,
        platePixelDiameter: 120,
      )!;
      final engine = VbtSessionEngine(
        exercise: exercise,
        exerciseName: '引体向上',
        profile: profile,
        calibration: calibration,
        weightKg: 0,
        seed: 11,
      );
      for (var i = 0; i < 900; i++) {
        engine.advance(1 / 30);
      }
      expect(engine.lastFrame, isNotNull);
      expect(engine.lastFrame!.showBarbell, isFalse);
      expect(engine.reps, isNotEmpty);
    });
  });
}
