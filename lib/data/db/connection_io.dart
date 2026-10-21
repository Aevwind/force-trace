import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Native platforms copy the prebuilt SQLite database from the asset bundle on
/// first launch, then open it as a regular file.
const String _databaseFileName = 'force_trace_v3.sqlite';

QueryExecutor openAppDatabase() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, _databaseFileName));
    if (!await file.exists()) {
      final raw = await rootBundle.load('assets/db/initial_exercises.db.gz');
      final Uint8List bytes = Uint8List.fromList(
        GZipDecoder().decodeBytes(raw.buffer.asUint8List()),
      );
      await file.writeAsBytes(bytes, flush: true);
    }
    return NativeDatabase.createInBackground(file);
  });
}
