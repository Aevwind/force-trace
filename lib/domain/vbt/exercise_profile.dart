import '../../data/models/models.dart';
import 'pose_models.dart';

/// The biometric profile used by the live engine for an exercise.
class ExerciseProfile {
  const ExerciseProfile({
    required this.pattern,
    required this.minRomCm,
    required this.targetReps,
    required this.depthCue,
    required this.depthCueAngle,
    required this.cueMessageKey,
  });

  final MotionPattern pattern;
  final double minRomCm;
  final int targetReps;
  final bool depthCue;

  /// If the minimum joint angle of the rep is *above* this value the rep was
  /// shallow. For squat this is the knee angle; for a hinge it is the hip.
  final double depthCueAngle;
  final String cueMessageKey;

  bool get hasBarbell => pattern.hasBarbell;

  static ExerciseProfile forExercise(Exercise exercise) {
    final name = exercise.name.toLowerCase();
    final target = exercise.target.toLowerCase();

    if (name.contains('bench press') || name.contains('floor press')) {
      return const ExerciseProfile(
        pattern: MotionPattern.bench,
        minRomCm: 20,
        targetReps: 5,
        depthCue: false,
        depthCueAngle: 0,
        cueMessageKey: 'depthCue',
      );
    }
    if (name.contains('deadlift')) {
      final isRdl =
          name.contains('romanian') ||
          name.contains('stiff') ||
          name.contains('straight');
      return ExerciseProfile(
        pattern: MotionPattern.hinge,
        minRomCm: isRdl ? 30 : 40,
        targetReps: 5,
        depthCue: true,
        depthCueAngle: 105,
        cueMessageKey: 'depthCue',
      );
    }
    if (name.contains('row') || name.contains('good morning')) {
      return const ExerciseProfile(
        pattern: MotionPattern.hinge,
        minRomCm: 25,
        targetReps: 8,
        depthCue: true,
        depthCueAngle: 120,
        cueMessageKey: 'depthCue',
      );
    }
    if (name.contains('squat') ||
        name.contains('lunge') ||
        name.contains('leg press')) {
      return ExerciseProfile(
        pattern: MotionPattern.squat,
        minRomCm: name.contains('lunge') || name.contains('split') ? 30 : 35,
        targetReps: 5,
        depthCue: true,
        depthCueAngle: 100,
        cueMessageKey: 'depthCue',
      );
    }
    if (name.contains('overhead press') ||
        name.contains('shoulder press') ||
        name.contains('military press') ||
        name.contains('arnold press')) {
      return const ExerciseProfile(
        pattern: MotionPattern.press,
        minRomCm: 25,
        targetReps: 8,
        depthCue: false,
        depthCueAngle: 0,
        cueMessageKey: 'depthCue',
      );
    }
    if (name.contains('pull-up') ||
        name.contains('pull up') ||
        name.contains('chin-up') ||
        name.contains('chin up')) {
      return const ExerciseProfile(
        pattern: MotionPattern.pullup,
        minRomCm: 30,
        targetReps: 8,
        depthCue: false,
        depthCueAngle: 0,
        cueMessageKey: 'depthCue',
      );
    }
    if (name.contains('push-up') ||
        name.contains('push up') ||
        name.contains('dip')) {
      return ExerciseProfile(
        pattern: MotionPattern.pushup,
        minRomCm: name.contains('dip') ? 20 : 15,
        targetReps: 10,
        depthCue: true,
        depthCueAngle: 95,
        cueMessageKey: 'depthCue',
      );
    }
    if (name.contains('curl') || name.contains('extension')) {
      return const ExerciseProfile(
        pattern: MotionPattern.curl,
        minRomCm: 12,
        targetReps: 10,
        depthCue: true,
        depthCueAngle: 55,
        cueMessageKey: 'depthCue',
      );
    }
    if (name.contains('calf raise')) {
      return const ExerciseProfile(
        pattern: MotionPattern.press,
        minRomCm: 8,
        targetReps: 12,
        depthCue: false,
        depthCueAngle: 0,
        cueMessageKey: 'depthCue',
      );
    }
    if (name.contains('hip thrust') || name.contains('glute bridge')) {
      return const ExerciseProfile(
        pattern: MotionPattern.hinge,
        minRomCm: 15,
        targetReps: 10,
        depthCue: false,
        depthCueAngle: 0,
        cueMessageKey: 'depthCue',
      );
    }

    if (exercise.tier == ExerciseTier.vbt) {
      return const ExerciseProfile(
        pattern: MotionPattern.squat,
        minRomCm: 25,
        targetReps: 5,
        depthCue: true,
        depthCueAngle: 100,
        cueMessageKey: 'depthCue',
      );
    }
    if (target == 'biceps' || target == 'triceps') {
      return const ExerciseProfile(
        pattern: MotionPattern.curl,
        minRomCm: 12,
        targetReps: 10,
        depthCue: true,
        depthCueAngle: 55,
        cueMessageKey: 'depthCue',
      );
    }
    if (target == 'delts') {
      return const ExerciseProfile(
        pattern: MotionPattern.press,
        minRomCm: 20,
        targetReps: 10,
        depthCue: false,
        depthCueAngle: 0,
        cueMessageKey: 'depthCue',
      );
    }
    if (target == 'pectorals') {
      return const ExerciseProfile(
        pattern: MotionPattern.pushup,
        minRomCm: 15,
        targetReps: 10,
        depthCue: true,
        depthCueAngle: 95,
        cueMessageKey: 'depthCue',
      );
    }
    return const ExerciseProfile(
      pattern: MotionPattern.squat,
      minRomCm: 15,
      targetReps: 10,
      depthCue: false,
      depthCueAngle: 0,
      cueMessageKey: 'depthCue',
    );
  }
}
