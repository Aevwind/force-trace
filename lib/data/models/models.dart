import 'dart:convert';

import '../db/app_database.dart';

enum ExerciseTier {
  vbt(1),
  pose(2),
  volume(3);

  const ExerciseTier(this.value);

  final int value;

  static ExerciseTier fromValue(int value) {
    return switch (value) {
      1 => ExerciseTier.vbt,
      2 => ExerciseTier.pose,
      _ => ExerciseTier.volume,
    };
  }

  bool get supportsVbt => this == ExerciseTier.vbt;
  bool get supportsPose =>
      this == ExerciseTier.vbt || this == ExerciseTier.pose;
}

class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.localName,
    required this.category,
    required this.bodyPart,
    required this.equipment,
    required this.target,
    required this.secondaryMuscles,
    required this.tier,
    required this.mediaId,
  });

  factory Exercise.fromRow(ExerciseRow row) {
    return Exercise(
      id: row.id,
      name: row.name,
      localName: row.localName,
      category: row.category,
      bodyPart: row.bodyPart,
      equipment: row.equipment,
      target: row.target,
      secondaryMuscles: _decodeList(row.secondaryMuscles),
      tier: ExerciseTier.fromValue(row.tier),
      mediaId: row.mediaId,
    );
  }

  final String id;
  final String name;
  final String localName;
  final String category;
  final String bodyPart;
  final String equipment;
  final String target;
  final List<String> secondaryMuscles;
  final ExerciseTier tier;
  final String mediaId;

  String displayName(String locale) {
    if (locale == 'zh' && localName.trim().isNotEmpty) return localName;
    return name;
  }

  String get searchText =>
      '$name $localName $target ${secondaryMuscles.join(' ')} $equipment $category'
          .toLowerCase();

  static List<String> _decodeList(String raw) {
    try {
      final value = jsonDecode(raw);
      if (value is List) return value.map((e) => '$e').toList();
    } catch (_) {
      // Corrupt seed rows fall back to an empty list.
    }
    return const [];
  }
}

class ExerciseDetail {
  const ExerciseDetail({required this.exercise, required this.steps});

  final Exercise exercise;
  final Map<String, List<String>> steps;

  List<String> stepsFor(String language) {
    final direct = steps[language];
    if (direct != null && direct.isNotEmpty) return direct;
    return steps['en'] ?? const [];
  }

  String instructionsFor(String language) => stepsFor(language).join(' ');
}

class SetLog {
  const SetLog({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.tier,
    required this.performedAt,
    required this.weightKg,
    required this.reps,
    required this.rpe,
    required this.restSeconds,
    required this.notes,
  });

  factory SetLog.fromRow(SetLogRow row) {
    return SetLog(
      id: row.id,
      exerciseId: row.exerciseId,
      exerciseName: row.exerciseName,
      tier: row.tier,
      performedAt: row.performedAt,
      weightKg: row.weightKg,
      reps: row.reps,
      rpe: row.rpe,
      restSeconds: row.restSeconds,
      notes: row.notes,
    );
  }

  final int id;
  final String exerciseId;
  final String exerciseName;
  final int tier;
  final DateTime performedAt;
  final double weightKg;
  final int reps;
  final double rpe;
  final int restSeconds;
  final String notes;
}

class SessionSummary {
  const SessionSummary({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.tier,
    required this.startedAt,
    required this.finishedAt,
    required this.weightKg,
    required this.totalReps,
    required this.invalidReps,
    required this.avgMeanVelocity,
    required this.bestMeanVelocity,
    required this.peakVelocity,
    required this.bestRomCm,
    required this.velocityLoss,
  });

  factory SessionSummary.fromRow(WorkoutSessionRow row) {
    return SessionSummary(
      id: row.id,
      exerciseId: row.exerciseId,
      exerciseName: row.exerciseName,
      tier: row.tier,
      startedAt: row.startedAt,
      finishedAt: row.finishedAt,
      weightKg: row.weightKg,
      totalReps: row.totalReps,
      invalidReps: row.invalidReps,
      avgMeanVelocity: row.avgMeanVelocity,
      bestMeanVelocity: row.bestMeanVelocity,
      peakVelocity: row.peakVelocity,
      bestRomCm: row.bestRomCm,
      velocityLoss: row.velocityLoss,
    );
  }

  final int id;
  final String exerciseId;
  final String exerciseName;
  final int tier;
  final DateTime startedAt;
  final DateTime finishedAt;
  final double weightKg;
  final int totalReps;
  final int invalidReps;
  final double avgMeanVelocity;
  final double bestMeanVelocity;
  final double peakVelocity;
  final double bestRomCm;
  final double velocityLoss;

  Duration get duration => finishedAt.difference(startedAt);
}

class RepRecord {
  const RepRecord({
    required this.id,
    required this.sessionId,
    required this.repIndex,
    required this.meanVelocity,
    required this.peakVelocity,
    required this.romCm,
    required this.velocityLossPercent,
    required this.durationMs,
    required this.eccentricMs,
    required this.concentricMs,
    required this.minHipAngle,
    required this.minKneeAngle,
    required this.isBestRep,
  });

  factory RepRecord.fromRow(RepRecordRow row) {
    return RepRecord(
      id: row.id,
      sessionId: row.sessionId,
      repIndex: row.repIndex,
      meanVelocity: row.meanVelocity,
      peakVelocity: row.peakVelocity,
      romCm: row.romCm,
      velocityLossPercent: row.velocityLossPercent,
      durationMs: row.durationMs,
      eccentricMs: row.eccentricMs,
      concentricMs: row.concentricMs,
      minHipAngle: row.minHipAngle,
      minKneeAngle: row.minKneeAngle,
      isBestRep: row.isBestRep,
    );
  }

  final int id;
  final int sessionId;
  final int repIndex;
  final double meanVelocity;
  final double peakVelocity;
  final double romCm;
  final double velocityLossPercent;
  final int durationMs;
  final int eccentricMs;
  final int concentricMs;
  final double minHipAngle;
  final double minKneeAngle;
  final bool isBestRep;
}

class SessionDetail {
  const SessionDetail({required this.session, required this.reps});

  final SessionSummary session;
  final List<RepRecord> reps;
}

class PlanItem {
  const PlanItem({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.localName,
    required this.tier,
    required this.position,
    required this.targetSets,
    required this.targetReps,
    required this.weightKg,
    required this.completedSets,
  });

  final int id;
  final String exerciseId;
  final String exerciseName;
  final String localName;
  final ExerciseTier tier;
  final int position;
  final int targetSets;
  final int targetReps;
  final double weightKg;
  final int completedSets;

  String displayName(String locale) =>
      locale == 'zh' && localName.isNotEmpty ? localName : exerciseName;
}
