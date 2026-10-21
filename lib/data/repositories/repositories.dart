import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../models/models.dart';

class ExerciseRepository {
  ExerciseRepository(this.db);

  final AppDatabase db;

  Future<List<Exercise>> loadAll() async {
    final rows = await db.select(db.exercises).get();
    return rows.map(Exercise.fromRow).toList();
  }

  Future<Exercise?> byId(String id) async {
    final row = await (db.select(
      db.exercises,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : Exercise.fromRow(row);
  }

  Future<ExerciseDetail?> detail(String id) async {
    final exercise = await byId(id);
    if (exercise == null) return null;
    final row = await (db.select(
      db.exerciseDetails,
    )..where((t) => t.exerciseId.equals(id))).getSingleOrNull();
    if (row == null) {
      return ExerciseDetail(exercise: exercise, steps: const {});
    }
    final decoded = jsonDecode(row.steps) as Map<String, dynamic>;
    final steps = decoded.map<String, List<String>>(
      (key, value) => MapEntry(key, (value as List).map((e) => '$e').toList()),
    );
    return ExerciseDetail(exercise: exercise, steps: steps);
  }

  Future<List<Exercise>> byIds(Iterable<String> ids) async {
    final unique = ids.toSet().toList();
    if (unique.isEmpty) return const [];
    final rows = await (db.select(
      db.exercises,
    )..where((t) => t.id.isIn(unique))).get();
    final map = {for (final row in rows) row.id: Exercise.fromRow(row)};
    return [
      for (final id in unique)
        if (map[id] != null) map[id]!,
    ];
  }
}

class SessionDraft {
  const SessionDraft({
    required this.exerciseId,
    required this.exerciseName,
    required this.tier,
    required this.startedAt,
    required this.finishedAt,
    required this.weightKg,
    required this.plateDiameterCm,
    required this.scaleMetersPerPixel,
    required this.totalReps,
    required this.invalidReps,
    required this.avgMeanVelocity,
    required this.bestMeanVelocity,
    required this.peakVelocity,
    required this.bestRomCm,
    required this.velocityLoss,
    this.notes = '',
  });

  final String exerciseId;
  final String exerciseName;
  final int tier;
  final DateTime startedAt;
  final DateTime finishedAt;
  final double weightKg;
  final double plateDiameterCm;
  final double scaleMetersPerPixel;
  final int totalReps;
  final int invalidReps;
  final double avgMeanVelocity;
  final double bestMeanVelocity;
  final double peakVelocity;
  final double bestRomCm;
  final double velocityLoss;
  final String notes;
}

class RepDraft {
  const RepDraft({
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

class WorkoutRepository {
  WorkoutRepository(this.db);

  final AppDatabase db;

  Future<int> saveSession(SessionDraft draft, List<RepDraft> reps) {
    return db.transaction(() async {
      final sessionId = await db
          .into(db.workoutSessions)
          .insert(
            WorkoutSessionsCompanion.insert(
              exerciseId: Value(draft.exerciseId),
              exerciseName: draft.exerciseName,
              tier: draft.tier,
              startedAt: draft.startedAt,
              finishedAt: draft.finishedAt,
              weightKg: Value(draft.weightKg),
              plateDiameterCm: Value(draft.plateDiameterCm),
              scaleMetersPerPixel: draft.scaleMetersPerPixel,
              totalReps: draft.totalReps,
              invalidReps: Value(draft.invalidReps),
              avgMeanVelocity: draft.avgMeanVelocity,
              bestMeanVelocity: draft.bestMeanVelocity,
              peakVelocity: draft.peakVelocity,
              bestRomCm: draft.bestRomCm,
              velocityLoss: draft.velocityLoss,
              notes: Value(draft.notes),
            ),
          );
      await db.batch((batch) {
        batch.insertAll(
          db.repRecords,
          reps.map((rep) {
            return RepRecordsCompanion.insert(
              sessionId: sessionId,
              repIndex: rep.repIndex,
              meanVelocity: rep.meanVelocity,
              peakVelocity: rep.peakVelocity,
              romCm: rep.romCm,
              velocityLossPercent: rep.velocityLossPercent,
              durationMs: rep.durationMs,
              eccentricMs: rep.eccentricMs,
              concentricMs: rep.concentricMs,
              minHipAngle: rep.minHipAngle,
              minKneeAngle: rep.minKneeAngle,
              isBestRep: Value(rep.isBestRep),
            );
          }).toList(),
        );
      });
      return sessionId;
    });
  }

  Stream<List<SessionSummary>> watchSessions({int limit = 60}) {
    final query = db.select(db.workoutSessions)
      ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
      ..limit(limit);
    return query.watch().map(
      (rows) => rows.map(SessionSummary.fromRow).toList(),
    );
  }

  Future<SessionDetail?> sessionDetail(int sessionId) async {
    final row = await (db.select(
      db.workoutSessions,
    )..where((t) => t.id.equals(sessionId))).getSingleOrNull();
    if (row == null) return null;
    final reps =
        await (db.select(db.repRecords)
              ..where((t) => t.sessionId.equals(sessionId))
              ..orderBy([(t) => OrderingTerm.asc(t.repIndex)]))
            .get();
    return SessionDetail(
      session: SessionSummary.fromRow(row),
      reps: reps.map(RepRecord.fromRow).toList(),
    );
  }

  Future<void> deleteSession(int sessionId) async {
    await (db.delete(
      db.workoutSessions,
    )..where((t) => t.id.equals(sessionId))).go();
  }

  Stream<List<SetLog>> watchSetLogs({int limit = 60}) {
    final query = db.select(db.setLogs)
      ..orderBy([(t) => OrderingTerm.desc(t.performedAt)])
      ..limit(limit);
    return query.watch().map((rows) => rows.map(SetLog.fromRow).toList());
  }

  Future<int> logSet({
    required Exercise exercise,
    required double weightKg,
    required int reps,
    required double rpe,
    required int restSeconds,
    String notes = '',
  }) {
    return db
        .into(db.setLogs)
        .insert(
          SetLogsCompanion.insert(
            exerciseId: exercise.id,
            exerciseName: exercise.name,
            tier: exercise.tier.value,
            performedAt: DateTime.now(),
            weightKg: Value(weightKg),
            reps: reps,
            rpe: Value(rpe),
            restSeconds: Value(restSeconds),
            notes: Value(notes),
          ),
        );
  }

  Future<void> deleteSetLog(int id) async {
    await (db.delete(db.setLogs)..where((t) => t.id.equals(id))).go();
  }

  Stream<List<PlanItem>> watchPlan(String dayKey) {
    final query =
        db.select(db.planItems).join([
            innerJoin(
              db.exercises,
              db.exercises.id.equalsExp(db.planItems.exerciseId),
            ),
          ])
          ..where(db.planItems.day.equals(dayKey))
          ..orderBy([OrderingTerm.asc(db.planItems.position)]);
    return query.watch().map((rows) {
      return rows.map((row) {
        final item = row.readTable(db.planItems);
        final exercise = row.readTable(db.exercises);
        return PlanItem(
          id: item.id,
          exerciseId: item.exerciseId,
          exerciseName: exercise.name,
          localName: exercise.localName,
          tier: ExerciseTier.fromValue(exercise.tier),
          position: item.position,
          targetSets: item.targetSets,
          targetReps: item.targetReps,
          weightKg: item.weightKg,
          completedSets: item.completedSets,
        );
      }).toList();
    });
  }

  Future<void> addToPlan({
    required Exercise exercise,
    required String dayKey,
    int targetSets = 3,
    int targetReps = 8,
    double weightKg = 0,
  }) async {
    final existing =
        await (db.select(db.planItems)..where(
              (t) => t.exerciseId.equals(exercise.id) & t.day.equals(dayKey),
            ))
            .getSingleOrNull();
    if (existing != null) return;
    final maxPos = await _maxPlanPosition(dayKey);
    await db
        .into(db.planItems)
        .insert(
          PlanItemsCompanion.insert(
            exerciseId: exercise.id,
            day: dayKey,
            position: Value(maxPos + 1),
            targetSets: Value(targetSets),
            targetReps: Value(targetReps),
            weightKg: Value(weightKg),
          ),
        );
  }

  Future<int> _maxPlanPosition(String dayKey) async {
    final maxExp = db.planItems.position.max();
    final row =
        await (db.selectOnly(db.planItems)
              ..addColumns([maxExp])
              ..where(db.planItems.day.equals(dayKey)))
            .getSingle();
    return row.read(maxExp) ?? -1;
  }

  Future<void> removeFromPlan({
    required String exerciseId,
    required String dayKey,
  }) async {
    await (db.delete(
          db.planItems,
        )..where((t) => t.exerciseId.equals(exerciseId) & t.day.equals(dayKey)))
        .go();
  }

  Future<void> setPlanWeight({
    required String exerciseId,
    required String dayKey,
    required double weightKg,
  }) async {
    await (db.update(
          db.planItems,
        )..where((t) => t.exerciseId.equals(exerciseId) & t.day.equals(dayKey)))
        .write(PlanItemsCompanion(weightKg: Value(weightKg)));
  }

  Future<void> completePlanSet({
    required String exerciseId,
    required String dayKey,
    required int targetSets,
  }) async {
    final row =
        await (db.select(db.planItems)..where(
              (t) => t.exerciseId.equals(exerciseId) & t.day.equals(dayKey),
            ))
            .getSingleOrNull();
    if (row == null) return;
    final next = (row.completedSets + 1).clamp(0, targetSets);
    await (db.update(db.planItems)..where((t) => t.id.equals(row.id))).write(
      PlanItemsCompanion(completedSets: Value(next)),
    );
  }

  Stream<int> watchSessionCount() {
    final countExp = db.workoutSessions.id.count();
    return (db.selectOnly(db.workoutSessions)..addColumns([countExp]))
        .watchSingle()
        .map((row) => row.read(countExp) ?? 0);
  }

  Future<void> resetAll() async {
    await db.transaction(() async {
      await db.delete(db.repRecords).go();
      await db.delete(db.workoutSessions).go();
      await db.delete(db.setLogs).go();
      await db.delete(db.planItems).go();
    });
  }

  Future<List<SessionSummary>> recentSessionsFor(String exerciseId) async {
    final rows =
        await (db.select(db.workoutSessions)
              ..where((t) => t.exerciseId.equals(exerciseId))
              ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
              ..limit(10))
            .get();
    return rows.map(SessionSummary.fromRow).toList();
  }
}

String dayKeyOf(DateTime time) {
  final local = time.toLocal();
  return '${local.year.toString().padLeft(4, '0')}-'
      '${local.month.toString().padLeft(2, '0')}-'
      '${local.day.toString().padLeft(2, '0')}';
}
