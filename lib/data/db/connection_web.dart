import 'package:archive/archive.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/services.dart';

/// On the web the prebuilt database is passed to drift's WASM runtime the first
/// time the IndexedDB-backed database is created.
const String _databaseName = 'force_trace_v3';

QueryExecutor openAppDatabase() {
  return driftDatabase(
    name: _databaseName,
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
      initializeDatabase: () async {
        final raw = await rootBundle.load('assets/db/initial_exercises.db.gz');
        final Uint8List bytes = Uint8List.fromList(
          GZipDecoder().decodeBytes(raw.buffer.asUint8List()),
        );
        return bytes;
      },
    ),
  );
}
