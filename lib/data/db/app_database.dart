import 'package:drift/drift.dart';

import 'connection.dart';

part 'app_database.g.dart';

/// 动作主表。为保持列表查询轻量，逐语言步骤文本存放在 [ExerciseDetails]。
@DataClassName('ExerciseRow')
class Exercises extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get localName => text().withDefault(const Constant(''))();
  TextColumn get category => text()();
  TextColumn get bodyPart => text()();
  TextColumn get equipment => text()();
  TextColumn get target => text()();
  TextColumn get secondaryMuscles => text().withDefault(const Constant('[]'))();
  IntColumn get tier => integer()();
  TextColumn get mediaId => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ExerciseDetailRow')
class ExerciseDetails extends Table {
  TextColumn get exerciseId =>
      text().references(Exercises, #id, onDelete: KeyAction.cascade)();
  TextColumn get steps => text()();

  @override
  Set<Column> get primaryKey => {exerciseId};
}

@DataClassName('WorkoutSessionRow')
class WorkoutSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get exerciseId => text().withDefault(const Constant(''))();
  TextColumn get exerciseName => text()();
  IntColumn get tier => integer()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get finishedAt => dateTime()();
  RealColumn get weightKg => real().withDefault(const Constant(0))();
  RealColumn get plateDiameterCm => real().withDefault(const Constant(45))();
  RealColumn get scaleMetersPerPixel => real()();
  IntColumn get totalReps => integer()();
  IntColumn get invalidReps => integer().withDefault(const Constant(0))();
  RealColumn get avgMeanVelocity => real()();
  RealColumn get bestMeanVelocity => real()();
  RealColumn get peakVelocity => real()();
  RealColumn get bestRomCm => real()();
  RealColumn get velocityLoss => real()();
  TextColumn get notes => text().withDefault(const Constant(''))();
}

@DataClassName('RepRecordRow')
class RepRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId =>
      integer().references(WorkoutSessions, #id, onDelete: KeyAction.cascade)();
  IntColumn get repIndex => integer()();
  RealColumn get meanVelocity => real()();
  RealColumn get peakVelocity => real()();
  RealColumn get romCm => real()();
  RealColumn get velocityLossPercent => real()();
  IntColumn get durationMs => integer()();
  IntColumn get eccentricMs => integer()();
  IntColumn get concentricMs => integer()();
  RealColumn get minHipAngle => real()();
  RealColumn get minKneeAngle => real()();
  BoolColumn get isBestRep => boolean().withDefault(const Constant(false))();
}

@DataClassName('SetLogRow')
class SetLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get exerciseId => text()();
  TextColumn get exerciseName => text()();
  IntColumn get tier => integer()();
  DateTimeColumn get performedAt => dateTime()();
  RealColumn get weightKg => real().withDefault(const Constant(0))();
  IntColumn get reps => integer()();
  RealColumn get rpe => real().withDefault(const Constant(0))();
  IntColumn get restSeconds => integer().withDefault(const Constant(0))();
  TextColumn get notes => text().withDefault(const Constant(''))();
}

@DataClassName('PlanItemRow')
class PlanItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get exerciseId => text()();
  TextColumn get day => text()();
  IntColumn get position => integer().withDefault(const Constant(0))();
  IntColumn get targetSets => integer().withDefault(const Constant(3))();
  IntColumn get targetReps => integer().withDefault(const Constant(8))();
  RealColumn get weightKg => real().withDefault(const Constant(0))();
  IntColumn get completedSets => integer().withDefault(const Constant(0))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {exerciseId, day},
  ];
}

class AppMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(
  tables: [
    Exercises,
    ExerciseDetails,
    WorkoutSessions,
    RepRecords,
    SetLogs,
    PlanItems,
    AppMeta,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? openAppDatabase());

  @override
  int get schemaVersion => 1;
}
