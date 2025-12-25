import 'package:drift/drift.dart';
import 'package:jejak_faa_new/data/local_db/database.dart';
import 'package:jejak_faa_new/data/local_db/tables.dart';
// 1. IMPORT ENUM SYNCSTATUS
import 'package:jejak_faa_new/data/models/sync_status.dart';

part 'hike_dao.g.dart';

@DriftAccessor(tables: [Hikes])
class HikeDao extends DatabaseAccessor<AppDatabase> with _$HikeDaoMixin {
  HikeDao(AppDatabase db) : super(db);

  // Method untuk mengambil stream (untuk Halaman List)
  Stream<List<Hike>> watchAllHikes() {
    return (select(hikes)
          ..where((tbl) => tbl.isDeleted.equals(false))
          ..orderBy([
            (tbl) =>
                OrderingTerm(expression: tbl.hikeDate, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  // Method untuk mengambil satu data (untuk Halaman Detail)
  Future<Hike?> getHikeById(int id) {
    return (select(hikes)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  // (Memperbaiki error 'getter 'id' isn't defined for type 'void'' di MapProvider)
  Future<Hike> insertHike(HikesCompanion companion) async {
    return await into(hikes).insertReturning(companion);
  }

  // Method untuk update data (untuk MapProvider selesai & Halaman Edit)
  Future<void> updateHike(HikesCompanion companion) async {
    await update(hikes).replace(companion);
  }

  // (Memperbaiki error 'softDeleteHike isn't defined')
  Future<void> softDeleteHike(int id) {
    return (update(hikes)..where((tbl) => tbl.id.equals(id))).write(
      const HikesCompanion(
        isDeleted: Value(true),
        // --- PERBAIKAN: Hapus underscore ---
        syncStatus: Value(SyncStatus.pending_update), // Tandai untuk di-sync
      ),
    );
  }

  // --- Ini adalah method-method untuk SyncRepository ---

  // Mengambil semua data, termasuk yg 'pending' (untuk Sync-Up)
  Future<List<Hike>> getPendingInserts() {
    // --- PERBAIKAN: Gunakan ENUM (bukan .name) ---
    return (select(hikes)..where(
          (tbl) =>
              tbl.syncStatus.equals(SyncStatus.pending.name) &
              tbl.cloudId.isNull(),
        )) // <--  FILTER cloudId.isNull()
        .get();
  }

  // Mengambil data yg 'pending_update' (termasuk soft delete)
  Future<List<Hike>> getPendingUpdates() {
    // --- PERBAIKAN: Gunakan ENUM (bukan .name dan hapus underscore) ---
    return (select(hikes)..where(
          (tbl) => tbl.syncStatus.equals(SyncStatus.pending_update.name),
        ))
        .get();
  }

  // Menandai data yg baru di-insert sebagai 'synced'
  Future<void> markAsSynced(int localId, String cloudId) {
    return (update(hikes)..where((tbl) => tbl.id.equals(localId))).write(
      HikesCompanion(
        cloudId: Value(cloudId),
        syncStatus: Value(SyncStatus.synced), // Ini sudah benar
      ),
    );
  }

  // Menandai data yg di-delete sebagai 'synced'
  Future<void> markDeletedAsSynced(int localId) {
    return (update(hikes)..where((tbl) => tbl.id.equals(localId))).write(
      const HikesCompanion(
        syncStatus: Value(SyncStatus.synced), // Ini sudah benar
      ),
    );
  }

  // Mengambil semua data (untuk Sync-Down)
  Future<List<Hike>> getAllLocalHikesForSync() {
    return select(hikes).get();
  }

  // Memasukkan/Mengupdate data dari cloud (Sync-Down)
  Future<void> upsertHikes(List<HikesCompanion> companions) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(hikes, companions);
    });
  }

  // Menghitung data pending (untuk Pemicu Sync)
  Stream<int> watchPendingHikesCount() {
    // --- PERBAIKAN: Gunakan parameter 'filter' & ENUM ---
    final count = countAll(
      filter:
          hikes.syncStatus.equals(SyncStatus.pending.name) |
          hikes.syncStatus.equals(SyncStatus.pending_update.name),
    );

    final query = selectOnly(hikes)..addColumns([count]);

    // --- PERBAIKAN: Atasi Stream<int?> dengan '.map((c) => c ?? 0)' ---
    return query
        .map((row) => row.read(count))
        .watchSingle()
        .map((nullableCount) => nullableCount ?? 0); // Jika null, kembalikan 0
  }
}

extension HikeUpdate on HikeDao {
  Future<void> updateHike(Hike hike) async {
    await update(hikes).replace(hike);
  }

  Future<Hike?> getHikeById(int id) async {
    return (select(hikes)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> hardDeleteHike(int id) {
    print('[HikeDao] Melakukan hard delete pada Hike ID: $id');
    // 'onDelete: KeyAction.cascade' di 'tables.dart' akan otomatis
    // menghapus semua RoutePoints, Waypoints, dan Photos yang terkait.
    return (delete(hikes)..where((tbl) => tbl.id.equals(id))).go();
  }
  // Update durasi dan status 
  Future<void> updateDurationAndStatus(int id, int seconds, SyncStatus status) {
    return (update(hikes)..where((tbl) => tbl.id.equals(id))).write(
      HikesCompanion(
        durationSeconds: Value(seconds),
        syncStatus: Value(status), // Kita juga perlu update status
      ),
    );
  }
  // Update durasi live ketika tracking berjalan
  Future<void> updateLiveDuration(int id, int durationSeconds) {
  return (update(hikes)
        ..where((tbl) => tbl.id.equals(id))
      ).write(HikesCompanion(
        durationSeconds: Value(durationSeconds),
      ));
}
}
