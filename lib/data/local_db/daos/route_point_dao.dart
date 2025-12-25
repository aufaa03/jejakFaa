import 'package:drift/drift.dart';
import 'package:jejak_faa_new/data/local_db/database.dart';
import 'package:jejak_faa_new/data/local_db/tables.dart';
import 'package:jejak_faa_new/data/models/location_models.dart';
import 'package:jejak_faa_new/data/models/sync_status.dart';

part 'route_point_dao.g.dart';

@DriftAccessor(tables: [RoutePoints])
class RoutePointDao extends DatabaseAccessor<AppDatabase>
  with _$RoutePointDaoMixin {
RoutePointDao(AppDatabase db) : super(db);

/// Stream semua route points untuk hike (dengan .distinct() untuk prevent duplicate emissions)
Stream<List<RoutePoint>> watchAllRoutePointsForHike(int localHikeId) {
  return (select(routePoints)
        ..where((tbl) => tbl.hikeId.equals(localHikeId))
        ..orderBy([(tbl) => OrderingTerm(expression: tbl.timestamp)]))
      .watch()
      .distinct(); // ← TAMBAH INI UNTUK PREVENT DUPLICATE STREAM EMISSIONS
}

/// Get semua route points (untuk debugging)
Future<List<RoutePoint>> getRoutePointsForHike(int hikeId) {
  return (select(routePoints)
        ..where((tbl) => tbl.hikeId.equals(hikeId))
        ..orderBy([(tbl) => OrderingTerm(expression: tbl.timestamp)]))
      .get();
}

/// Insert route point dengan deduplication (prevent duplicate pada race condition)
/// Check apakah sudah ada point dengan timestamp sama di hike yang sama
Future<void> insertRoutePoint(RoutePointsCompanion companion) async {
  print('[RoutePointDao] Inserting route point for hike ${companion.hikeId}');
  
  // Guard: check apakah sudah ada route point dengan timestamp yang sama
  final existingPoint = await (select(routePoints)
        ..where((tbl) =>
            tbl.hikeId.equals(companion.hikeId.value) &
            tbl.timestamp.equals(companion.timestamp.value)))
      .getSingleOrNull();

  if (existingPoint != null) {
    print('[RoutePointDao] Duplicate route point detected (same timestamp), skipping insert');
    return;
  }

  // Insert kalau tidak ada duplicate
  await into(routePoints).insert(companion);
  print('[RoutePointDao] Route point inserted: lat=${companion.latitude.value}, lng=${companion.longitude.value}');
}

/// Get pending route points (untuk Sync-Up Insert)
Future<List<RoutePoint>> getPendingRoutePointInserts() {
  return (select(routePoints)
        ..where((tbl) => tbl.syncStatus.equals(SyncStatus.pending.name))
        ..where((tbl) => tbl.cloudId.isNull()))
      .get();
}

/// Mark route points as synced
Future<void> markRoutePointsAsSynced(List<int> localIds, List<String> cloudIds) async {
  await db.transaction(() async {
    for (int i = 0; i < localIds.length; i++) {
      await (update(routePoints)..where((tbl) => tbl.id.equals(localIds[i])))
          .write(
        RoutePointsCompanion(
          cloudId: Value(cloudIds[i]),
          syncStatus: const Value(SyncStatus.synced),
        ),
      );
    }
  });
}

/// Upsert route points dari cloud (Sync-Down)
Future<void> upsertRoutePoints(List<RoutePointsCompanion> companions) async {
  await batch((batch) {
    batch.insertAllOnConflictUpdate(routePoints, companions);
  });
}

/// Get all route points (untuk Sync-Down)
Future<List<RoutePoint>> getAllLocalRoutePointsForSync() {
  return select(routePoints).get();
}

/// Delete route points untuk hike (cleanup)
Future<void> deleteRoutePointsForHike(int hikeId) async {
  print('[RoutePointDao] Deleting all route points for hike $hikeId');
  await (delete(routePoints)..where((tbl) => tbl.hikeId.equals(hikeId))).go();
}

/// Get count route points untuk hike
Future<int> getRoutePointCountForHike(int hikeId) async {
  final result = await (select(routePoints)
        ..where((tbl) => tbl.hikeId.equals(hikeId)))
      .get();
  print('[RoutePointDao] Route point count for hike $hikeId: ${result.length}');
  return result.length;
}
/// Get last route point untuk hike
Future<RoutePoint?> getLastRoutePoint(int hikeId) {
    return (select(routePoints)
          ..where((tbl) => tbl.hikeId.equals(hikeId))
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.timestamp, mode: OrderingMode.desc)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<PositionData?> getLastPositionData(int hikeId) async {
  final lastPoint = await (select(routePoints)
        ..where((tbl) => tbl.hikeId.equals(hikeId))
        ..orderBy([(tbl) => OrderingTerm(expression: tbl.timestamp, mode: OrderingMode.desc)])
        ..limit(1))
      .getSingleOrNull();

  if (lastPoint == null) {
    return null;
  }

  return PositionData(
    latitude: lastPoint.latitude,
    longitude: lastPoint.longitude,
    altitude: lastPoint.altitude ?? 0.0,
    speedKmh: lastPoint.speedKmh ?? 0.0,
    timestamp: lastPoint.timestamp,
  );
}
}

extension SafeInsertRoutePoint on RoutePointDao {
/// Insert RoutePoint kalau belum ada dengan hikeId + timestamp sama
Future<int> insertSafe(RoutePoint rp) async {
  final existing = await (select(routePoints)
        ..where((t) =>
            t.hikeId.equals(rp.hikeId) &
            t.timestamp.equals(rp.timestamp)))
      .getSingleOrNull();

  if (existing != null) {
    return existing.id; // skip insert
  }

  return into(routePoints).insert(rp);
}

/// Stream pending RoutePoints untuk sync
Stream<List<RoutePoint>> watchPending(int hikeId) {
  return (select(routePoints)
        ..where((t) =>
            t.hikeId.equals(hikeId) &
            t.syncStatus.equals(SyncStatus.pending.name)))
      .watch();
}
}