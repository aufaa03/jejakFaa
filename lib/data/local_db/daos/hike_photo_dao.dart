import 'package:drift/drift.dart';
import 'package:drift/drift.dart' as d;
import 'package:jejak_faa_new/data/local_db/database.dart';
import 'package:jejak_faa_new/data/local_db/tables.dart';
import 'package:jejak_faa_new/data/models/sync_status.dart';

part 'hike_photo_dao.g.dart';

@DriftAccessor(tables: [HikePhotos])
class HikePhotoDao extends DatabaseAccessor<AppDatabase>
    with _$HikePhotoDaoMixin {
  HikePhotoDao(AppDatabase db) : super(db);

  // Mengambil stream foto untuk Halaman Galeri (SEMUA FOTO)
  Stream<List<HikePhoto>> watchAllPhotos() {
    return (select(hikePhotos)
          ..where((tbl) => tbl.isDeleted.equals(false))
          ..orderBy([
            (tbl) =>
                OrderingTerm(expression: tbl.capturedAt, mode: OrderingMode.desc)
          ]))
        .watch();
  }

  // Mengambil stream foto untuk Halaman Detail (PER HIKE)
  Stream<List<HikePhoto>> watchPhotosForHike(int hikeId) {
    return (select(hikePhotos)
          ..where((tbl) => tbl.hikeId.equals(hikeId))
          ..where((tbl) => tbl.isDeleted.equals(false))
          ..orderBy([
            (tbl) =>
                OrderingTerm(expression: tbl.capturedAt, mode: OrderingMode.asc)
          ]))
        .watch();
  }

  // --- METHOD BARU (untuk HikeFormPage) ---
  Future<void> insertHikePhoto(HikePhotosCompanion companion) async {
    await into(hikePhotos).insert(companion);
  }

  // Method untuk soft delete (untuk Halaman Detail Foto)
  Future<void> softDeletePhoto(int id) {
    return (update(hikePhotos)..where((tbl) => tbl.id.equals(id))).write(
      const HikePhotosCompanion(
        isDeleted: d.Value(true),
        // --- PERBAIKAN: Hapus typo underscore ---
        syncStatus: d.Value(SyncStatus.pending_update), // Tandai untuk di-sync
      ),
    );
  }

  // --- Ini method-method untuk SyncRepository ---

  // Mengambil semua data (untuk Sync-Down)
  Future<List<HikePhoto>> getAllLocalPhotosForSync() {
    return select(hikePhotos).get();
  }

  // Memasukkan/Mengupdate data dari cloud (Sync-Down)
  Future<void> upsertPhotos(List<HikePhotosCompanion> companions) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(hikePhotos, companions);
    });
  }

  // Mengambil foto yg 'pending' (untuk Sync-Up)
  Future<List<HikePhoto>> getPendingPhotoInserts() {
    return (select(hikePhotos)
          // --- PERBAIKAN: Seharusnya 'pending', bukan 'pendingUpdate' ---
          ..where((tbl) =>
          tbl.syncStatus.equals(SyncStatus.pending.name) &
tbl.cloudId.isNull()))
        .get();
  }

  // Mengambil foto yg 'pending_update' (termasuk soft delete)
  Future<List<HikePhoto>> getPendingPhotoUpdates() {
    return (select(hikePhotos)
          // --- PERBAIKAN: Hapus typo underscore ---
          ..where((tbl) => tbl.syncStatus.equals(SyncStatus.pending_update.name)))
        .get();
  }

  // Menandai foto yg baru di-insert sebagai 'synced'
  Future<void> markPhotoAsSynced(int localId, String cloudId) {
    return (update(hikePhotos)..where((tbl) => tbl.id.equals(localId))).write(
      HikePhotosCompanion(
        cloudId: d.Value(cloudId),
        syncStatus: const d.Value(SyncStatus.synced),
      ),
    );
  }

  // Menandai foto yg di-delete sebagai 'synced'
  Future<void> markDeletedPhotoAsSynced(int localId) {
    return (update(hikePhotos)..where((tbl) => tbl.id.equals(localId))).write(
      const HikePhotosCompanion(
        syncStatus: d.Value(SyncStatus.synced),
      ),
    );
  }
}

