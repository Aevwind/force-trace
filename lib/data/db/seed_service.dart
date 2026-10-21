import 'package:drift/drift.dart';

import 'app_database.dart';

/// Version of the prebuilt exercise database shipped in `assets/db/`.
const int kSeedVersion = 1;
const int kExpectedExerciseCount = 1324;

class SeedReport {
  const SeedReport({
    required this.exerciseCount,
    required this.seededNow,
    required this.seededPlan,
  });

  final int exerciseCount;
  final bool seededNow;
  final bool seededPlan;
}

class SeedService {
  SeedService(this.db);

  final AppDatabase db;

  Future<SeedReport> ensureSeeded() async {
    final count = await _countExercises();
    if (count < kExpectedExerciseCount) {
      throw StateError(
        'Exercise database is incomplete: $count / $kExpectedExerciseCount. '
        'Reinstall the app or clear site data to restore the bundled database.',
      );
    }

    final meta = await _readMeta('seed_version');
    if (meta != '$kSeedVersion') {
      await _writeMeta('seed_version', '$kSeedVersion');
    }

    final seededPlan = await _ensureStarterPlan();
    return SeedReport(
      exerciseCount: count,
      seededNow: false,
      seededPlan: seededPlan,
    );
  }

  Future<int> _countExercises() async {
    final countExp = db.exercises.id.count();
    final row = await (db.selectOnly(
      db.exercises,
    )..addColumns([countExp])).getSingle();
    return row.read(countExp) ?? 0;
  }

  Future<String?> _readMeta(String key) async {
    final row = await (db.select(
      db.appMeta,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> _writeMeta(String key, String value) async {
    await db
        .into(db.appMeta)
        .insertOnConflictUpdate(
          AppMetaCompanion.insert(key: key, value: value),
        );
  }

  Future<bool> _ensureStarterPlan() async {
    final today = _dayKey(DateTime.now());
    final existing = await (db.select(
      db.planItems,
    )..where((t) => t.day.equals(today))).get();
    if (existing.isNotEmpty) return false;

    const starters = <(String, int, int)>[
      ('barbell full squat', 4, 5),
      ('barbell bench press', 3, 5),
      ('barbell deadlift', 3, 5),
      ('barbell bent over row', 3, 8),
    ];

    var position = 0;
    for (final starter in starters) {
      final row =
          await (db.select(db.exercises)
                ..where((t) => t.name.equals(starter.$1))
                ..limit(1))
              .getSingleOrNull();
      if (row == null) continue;
      await db
          .into(db.planItems)
          .insert(
            PlanItemsCompanion.insert(
              exerciseId: row.id,
              day: today,
              position: Value(position++),
              targetSets: Value(starter.$2),
              targetReps: Value(starter.$3),
            ),
          );
    }
    return position > 0;
  }
}

String _dayKey(DateTime time) {
  final local = time.toLocal();
  return '${local.year.toString().padLeft(4, '0')}-'
      '${local.month.toString().padLeft(2, '0')}-'
      '${local.day.toString().padLeft(2, '0')}';
}
