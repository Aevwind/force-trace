import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:force_trace/data/db/app_database.dart';
import 'package:force_trace/data/db/seed_service.dart';

void main() {
  test('bundled SQLite database matches the Drift schema and seeds a plan', () async {
    final gzip = File('assets/db/initial_exercises.db.gz').readAsBytesSync();
    final file = File(
      '${Directory.systemTemp.path}/force_trace_prebuilt_${DateTime.now().microsecondsSinceEpoch}.sqlite',
    );
    await file.writeAsBytes(GZipDecoder().decodeBytes(gzip), flush: true);

    final db = AppDatabase(NativeDatabase(file));
    addTearDown(() async {
      await db.close();
      if (await file.exists()) await file.delete();
    });

    final countExp = db.exercises.id.count();
    final countRow = await (db.selectOnly(
      db.exercises,
    )..addColumns([countExp])).getSingle();
    expect(countRow.read(countExp), kExpectedExerciseCount);

    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.first, 1);

    final squat = await (db.select(
      db.exercises,
    )..where((t) => t.name.equals('barbell full squat'))).getSingle();
    expect(squat.tier, 1);
    expect(squat.localName, contains('深蹲'));

    final detail = await (db.select(
      db.exerciseDetails,
    )..where((t) => t.exerciseId.equals(squat.id))).getSingle();
    final steps = jsonDecode(detail.steps) as Map<String, dynamic>;
    expect(steps.keys, containsAll(['en', 'zh', 'tr', 'es', 'ru']));
    expect((steps['zh'] as List), isNotEmpty);

    final service = SeedService(db);
    final report = await service.ensureSeeded();
    expect(report.exerciseCount, kExpectedExerciseCount);
    final plan = await db.select(db.planItems).get();
    expect(plan, hasLength(4));

    // Idempotent: a second bootstrap must not duplicate today's plan.
    await service.ensureSeeded();
    final again = await db.select(db.planItems).get();
    expect(again, hasLength(4));
  });
}
