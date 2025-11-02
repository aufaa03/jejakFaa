import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// Import tabel (pastikan nama file & class sama)
import '../../data/models/hike_table.dart';
import '../../data/models/history_table.dart';

part 'drift_service.g.dart';

@DriftDatabase(
  tables: [Hikes, Histories],
)
class DriftService extends _$DriftService {
  DriftService() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ✅ Opsional: handle perubahan schema di masa depan
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          // bisa isi migrasi manual di sini kalo nambah kolom di versi baru nanti
          if (from < 2) {
            // contoh:
            // await m.addColumn(hikes, hikes.newColumn);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  // 🏔️ Hike CRUD
  Future<List<Hike>> getAllHikes() => select(hikes).get();

  Future<int> addHike(HikesCompanion entry) => into(hikes).insert(entry);

  Future<void> deleteHike(int id) async {
    await (delete(hikes)..where((tbl) => tbl.id.equals(id))).go();
  }

  // 📜 History CRUD
  Future<List<History>> getAllHistories() => select(histories).get();

  Future<int> addHistory(HistoriesCompanion entry) =>
      into(histories).insert(entry);

  Future<void> deleteHistory(int id) async {
    await (delete(histories)..where((tbl) => tbl.id.equals(id))).go();
  }

  // 🔍 (Opsional) cari berdasarkan userId, tanggal, dll.
  Future<List<Hike>> getHikesByUser(String userId) {
    return (select(hikes)..where((h) => h.userId.equals(userId))).get();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'jejak_faa.sqlite');

    // ✅ Safety: buat direktori kalau belum ada
    if (!(await Directory(dir.path).exists())) {
      await Directory(dir.path).create(recursive: true);
    }

    return NativeDatabase.createInBackground(File(path));
  });
}
