import 'package:drift/drift.dart';
import 'package:jejak_faa_new/data/local_db/database.dart';
import 'package:jejak_faa_new/data/local_db/tables.dart';
// 1. IMPORT ENUM SYNCSTATUS
import 'package:jejak_faa_new/data/models/sync_status.dart';

// Penting: Jalankan build_runner untuk men-generate file 'hike_waypoint_dao.g.dart'
part 'hike_waypoint_dao.g.dart';

@DriftAccessor(tables: [HikeWaypoints])
class HikeWaypointDao extends DatabaseAccessor<AppDatabase>
    with _$HikeWaypointDaoMixin {
  HikeWaypointDao(AppDatabase db) : super(db);

  // === Method untuk Halaman Detail ===
  // (Dibutuhkan oleh hikeWaypointsProvider)
  Stream<List<HikeWaypoint>> watchAllWaypointsForHike(int localHikeId) {
    return (select(hikeWaypoints)
          ..where((tbl) => tbl.hikeId.equals(localHikeId))
          ..where((tbl) => tbl.isDeleted.equals(false))) // Hanya tampilkan yg tidak dihapus
        .watch();
  }

  // Method untuk memasukkan satu POI/Waypoint saat merekam
  Future<void> insertWaypoint(HikeWaypointsCompanion companion) async {
    await into(hikeWaypoints).insert(companion);
  }

  // === Method untuk Sinkronisasi ===
  // (Nanti akan dibutuhkan oleh SyncRepositoryImpl)
  
  // Ambil semua Waypoints lokal (untuk Sync-Down)
  Future<List<HikeWaypoint>> getAllLocalWaypointsForSync() => select(hikeWaypoints).get();
  
  // Ambil Waypoints baru (untuk Sync-Up Insert)
  Future<List<HikeWaypoint>> getPendingWaypointInserts() {
    return (select(hikeWaypoints)
          // --- 2. PERBAIKAN: Gunakan ENUM ---
          ..where((tbl) => tbl.syncStatus.equals(SyncStatus.pending.name))
          ..where((tbl) => tbl.cloudId.isNull())
          ..where((tbl) => tbl.isDeleted.equals(false)))
        .get();
  }

  // Ambil Waypoints yang diupdate/dihapus (untuk Sync-Up Update)
  Future<List<HikeWaypoint>> getPendingWaypointUpdates() {
    return (select(hikeWaypoints)
          // --- 2. PERBAIKAN: Gunakan ENUM ---
          ..where((tbl) => tbl.syncStatus.equals(SyncStatus.pending_update.name))
          ..where((tbl) => tbl.cloudId.isNotNull()))
        .get();
  }

  // Tandai sebagai sudah di-sync (setelah Insert)
  Future<void> markWaypointAsSynced(int localId, String cloudId) {
    return (update(hikeWaypoints)..where((tbl) => tbl.id.equals(localId))).write(
      HikeWaypointsCompanion(
        cloudId: Value(cloudId),
        // --- 2. PERBAIKAN: Gunakan ENUM ---
        syncStatus: const Value(SyncStatus.synced),
      ),
    );
  }

  // Tandai (soft delete) sebagai sudah di-sync (setelah Update)
  Future<void> markDeletedWaypointAsSynced(int localId) {
    return (update(hikeWaypoints)..where((tbl) => tbl.id.equals(localId))).write(
      const HikeWaypointsCompanion(
        // --- 2. PERBAIKAN: Gunakan ENUM ---
        syncStatus: Value(SyncStatus.synced),
      ),
    );
  }
  
  // Masukkan/Update data dari Cloud (Sync-Down)
  Future<void> upsertWaypoints(List<HikeWaypointsCompanion> companions) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(hikeWaypoints, companions);
    });
  }

  Future<HikeWaypoint> insertAndReturnWaypoint(HikeWaypointsCompanion companion) async {
    // 'insertReturning' akan mengembalikan objek data lengkap (termasuk ID baru)
    return await into(hikeWaypoints).insertReturning(companion);
  }
}

extension SafeInsertWaypoint on HikeWaypointDao {
  /// Insert HikeWaypoint aman
  Future<int> insertSafe(HikeWaypoint hw) async {
    final existing = await (select(hikeWaypoints)
          ..where((t) =>
              t.hikeId.equals(hw.hikeId) &
              t.timestamp.equals(hw.timestamp) &
              t.latitude.equals(hw.latitude) &
              t.longitude.equals(hw.longitude)))
        .getSingleOrNull();

    if (existing != null) {
      return existing.id;
    }

    return into(hikeWaypoints).insert(hw);
  }

  Stream<List<HikeWaypoint>> watchPending(int hikeId) {
    return (select(hikeWaypoints)
          ..where((t) =>
              t.hikeId.equals(hikeId) &
              t.syncStatus.equals(SyncStatus.pending.name)))
        .watch();
  }
}

