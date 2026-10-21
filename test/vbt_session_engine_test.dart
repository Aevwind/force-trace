import 'package:flutter_test/flutter_test.dart';
import 'package:force_trace/data/models/models.dart';
import 'package:force_trace/domain/vbt/calibration.dart';
import 'package:force_trace/domain/vbt/exercise_profile.dart';
import 'package:force_trace/domain/vbt/pose_models.dart';
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
