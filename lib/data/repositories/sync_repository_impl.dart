import 'package:drift/drift.dart' hide Column;
import 'package:jejak_faa_new/data/local_db/daos/hike_dao.dart';
import 'package:jejak_faa_new/data/local_db/daos/hike_photo_dao.dart';
// --- TAMBAHAN DAO BARU ---
import 'package:jejak_faa_new/data/local_db/daos/hike_waypoint_dao.dart';
import 'package:jejak_faa_new/data/local_db/daos/route_point_dao.dart';
// --- AKHIR TAMBAHAN ---
import 'package:jejak_faa_new/core/services/weather_service.dart';
import 'package:jejak_faa_new/data/local_db/database.dart';
import 'package:jejak_faa_new/domain/repositories/sync_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jejak_faa_new/data/models/sync_status.dart';

// Ini adalah file class murni, tidak ada anotasi @riverpod
class SyncRepositoryImpl implements SyncRepository {
  final HikeDao _hikeDao;
  final HikePhotoDao _hikePhotoDao;
  // --- TAMBAHAN DAO BARU ---
  final HikeWaypointDao _hikeWaypointDao;
  final RoutePointDao _routePointDao;
  // --- AKHIR TAMBAHAN ---
  final SupabaseClient _supabase;
  final WeatherService _weatherService; 
  // --- PERUBAHAN KONSTRUKTOR (cocok dengan database_providers.dart) ---
  SyncRepositoryImpl(
    this._hikeDao,
    this._hikePhotoDao,
    this._hikeWaypointDao, // Tambahan
    this._routePointDao, // Tambahan
    this._supabase,
    this._weatherService, // Tambahan
  );
  // --- AKHIR PERUBAHAN ---

  @override
  Future<void> syncPendingHikes() async {
    try {
      // --- FASE 1: SYNC DOWN (Cloud -> Lokal) ---
      // Urutan penting: Induk (Hikes) -> Anak (Waypoints, RoutePoints) -> Cucu (Photos)
      print('[Sync] Memulai Fase Sync-Down...');
      await _syncDownHikes();
      await _syncDownWaypoints();
      await _syncDownRoutePoints();
      await _syncDownPhotos(); // Foto terakhir, butuh id Hikes & Waypoints

      // --- FASE 2: SYNC UP INSERT (Lokal Baru -> Cloud) ---
      // Urutan penting: Induk (Hikes) -> Anak (Waypoints, RoutePoints) -> Cucu (Photos)
      print('[Sync] Memulai Fase Sync-Up (Insert)...');
      await _syncInsertHikes();
      await _syncInsertWaypoints();
      await _syncInsertRoutePoints();
      await _syncInsertPhotos(); // Foto terakhir, butuh id Hikes & Waypoints

      // --- FASE 3: SYNC UP UPDATE/DELETE (Lokal Edit -> Cloud) ---
      print('[Sync] Memulai Fase Sync-Up (Update/Delete)...');
      await _syncUpdateHikes();
      await _syncUpdateWaypoints(); // Untuk soft-delete
      await _syncUpdatePhotos(); // Untuk soft-delete

      print('[Sync] Sinkronisasi 2 Arah (LENGKAP 4 Tabel) Selesai.');
    } catch (e) {
      print('[Sync] Sinkronisasi GAGAL TOTAL: $e');
      rethrow;
    }
  }

  // =======================================================
  // == FUNGSI SYNC HIKES (Logika lama Anda yang sudah diperbaiki)
  // =======================================================

  Future<void> _syncDownHikes() async {
    print('[Sync Hikes] Memulai Sync-Down...');
    try {
      final cloudDataResponse = await _supabase
          .from('hikes')
          .select()
          .eq('user_id', _supabase.auth.currentUser!.id);

      final List<Map<String, dynamic>> cloudHikes =
          List<Map<String, dynamic>>.from(cloudDataResponse as List);

      if (cloudHikes.isEmpty) {
        print('[Sync Hikes] Cloud kosong.');
      } else {
        print('[Sync Hikes] Ditemukan ${cloudHikes.length} data di Cloud.');
      }

      final List<Hike> localHikes = await _hikeDao.getAllLocalHikesForSync();
      final Map<String, Hike> localHikesMap = {
        for (var hike in localHikes.where((h) => h.cloudId != null))
          hike.cloudId!: hike,
      };

      final List<HikesCompanion> hikesToUpsert = [];

      for (final cloudHike in cloudHikes) {
        final String cloudId = cloudHike['id'];
        final Hike? existingLocalHike = localHikesMap[cloudId];

        if (existingLocalHike != null &&
            existingLocalHike.syncStatus != SyncStatus.synced) {
          print(
            '[Sync Hikes] Lewati Sync-Down untuk ${existingLocalHike.mountainName} (status: ${existingLocalHike.syncStatus.name})',
          );
          continue;
        }

        final HikesCompanion companion = HikesCompanion(
          cloudId: Value(cloudId),
          userId: Value(cloudHike['user_id']),
          mountainName: Value(cloudHike['mountain_name']),
          hikeDate: Value(DateTime.parse(cloudHike['hike_date'])),
          durationSeconds: Value(cloudHike['duration_seconds']),
          totalDistanceKm: Value(
            (cloudHike['total_distance_km'] as num?)?.toDouble(),
          ),
          totalElevationGainMeters: Value(
            (cloudHike['total_elevation_gain_meters'] as num?)?.toDouble(),
          ),
          totalElevationLossMeters: Value(
            (cloudHike['total_elevation_loss_meters'] as num?)?.toDouble(),
          ),
          averageSpeedKmh: Value(
            (cloudHike['average_pace_min_per_km'] as num?)?.toDouble(),
          ),
          maxSpeedKmh: Value((cloudHike['max_speed_kmh'] as num?)?.toDouble()),
          startTemperature: Value(
            (cloudHike['start_temperature'] as num?)?.toDouble(),
          ),
          partners: Value(cloudHike['partners']),
          notes: Value(cloudHike['notes']),
          isDeleted: Value(cloudHike['is_deleted']),
          syncStatus: const Value(SyncStatus.synced),
        );

        if (existingLocalHike == null) {
          hikesToUpsert.add(companion);
        } else {
          bool needsUpdate =
              existingLocalHike.isDeleted != companion.isDeleted.value ||
              existingLocalHike.notes != companion.notes.value ||
              existingLocalHike.mountainName != companion.mountainName.value;

          if (needsUpdate) {
            hikesToUpsert.add(
              companion.copyWith(id: Value(existingLocalHike.id)),
            );
          }
        }
      }

      if (hikesToUpsert.isNotEmpty) {
        await _hikeDao.upsertHikes(hikesToUpsert);
      }
      print('[Sync Hikes] Sync-Down Selesai.');
    } catch (e) {
      print('[Sync Hikes] Gagal Sync-Down: $e');
      rethrow;
    }
  }

  Future<void> _syncInsertHikes() async {
    print('[Sync Hikes] Memulai Sync-Up (Kirim data BARU)...');
    final pendingInserts = await _hikeDao.getPendingInserts();
    if (pendingInserts.isEmpty) return;

    print(
      '[Sync Hikes] Ditemukan ${pendingInserts.length} data BARU untuk di-Insert.',
    );
    final List<Map<String, dynamic>> dataToInsert = [];
    for (final hike in pendingInserts) {
      dataToInsert.add({
        'user_id': hike.userId,
        'mountain_name': hike.mountainName,
        'hike_date': hike.hikeDate.toIso8601String(),
        'duration_seconds': hike.durationSeconds,
        'total_distance_km': hike.totalDistanceKm,
        'total_elevation_gain_meters': hike.totalElevationGainMeters,
        'total_elevation_loss_meters': hike.totalElevationLossMeters,
        'average_pace_min_per_km': hike.averagePaceMinPerKm,
        'max_speed_kmh': hike.maxSpeedKmh,
        'start_weather_condition': hike.startWeatherCondition,
        'start_temperature': hike.startTemperature,
        'partners': hike.partners,
        'notes': hike.notes,
        'is_deleted': hike.isDeleted,
      });
    }

    try {
      final insertedDataResponse = await _supabase
          .from('hikes')
          .insert(dataToInsert)
          .select();
      final insertedList = insertedDataResponse;

      for (int i = 0; i < insertedList.length; i++) {
        final cloudData = insertedList[i];
        final localData = pendingInserts[i];
        final String? cloudId = cloudData['id'];
        if (cloudId == null) continue;
        await _hikeDao.markAsSynced(localData.id, cloudId);
      }
      print('[Sync Hikes] Berhasil Sync-Up ${insertedList.length} data BARU.');
    } catch (e) {
      print('[Sync Hikes] Gagal Sync-Up data BARU: $e');
    }
  }

  Future<void> _syncUpdateHikes() async {
    print('[Sync Hikes] Memulai Sync-Up (Kirim data UPDATE/DELETE)...');
    final pendingUpdates = await _hikeDao.getPendingUpdates();
    if (pendingUpdates.isEmpty) return;

    print(
      '[Sync Hikes] Ditemukan ${pendingUpdates.length} data UPDATE/DELETE.',
    );
    try {
      for (final hike in pendingUpdates) {
        if (hike.cloudId == null) continue;
        await _supabase
            .from('hikes')
            .update({
              'mountain_name': hike.mountainName,
              'hike_date': hike.hikeDate.toIso8601String(),
              'duration_seconds': hike.durationSeconds,
              'total_distance_km': hike.totalDistanceKm,
              'total_elevation_gain_meters': hike.totalElevationGainMeters,
              'total_elevation_loss_meters': hike.totalElevationLossMeters,
              'average_pace_min_per_km': hike.averagePaceMinPerKm,
              'max_speed_kmh': hike.maxSpeedKmh,
              'start_weather_condition': hike.startWeatherCondition,
              'start_temperature': hike.startTemperature,
              'partners': hike.partners,
              'notes': hike.notes,
              'is_deleted': hike.isDeleted,
            })
            .eq('id', hike.cloudId!);
        await _hikeDao.markDeletedAsSynced(hike.id);
      }
      print(
        '[Sync Hikes] Berhasil Sync-Up ${pendingUpdates.length} data UPDATE/DELETE.',
      );
    } catch (e) {
      print('[Sync Hikes] Gagal Sync-Up data UPDATE/DELETE: $e');
    }
  }

  // =======================================================
  // == FUNGSI SYNC WAYPOINTS (BARU)
  // =======================================================

  Future<void> _syncDownWaypoints() async {
    print('[Sync Waypoints] Memulai Sync-Down...');
    try {
      final List<String> localHikeCloudIds =
          (await _hikeDao.getAllLocalHikesForSync())
              .map((h) => h.cloudId)
              .whereType<String>()
              .toList();

      if (localHikeCloudIds.isEmpty) {
        print('[Sync Waypoints] Batal: Tidak ada data induk (hikes) lokal.');
        return;
      }

      final cloudDataResponse = await _supabase
          .from('hike_waypoints')
          .select()
          .inFilter('hike_id', localHikeCloudIds);

      final List<Map<String, dynamic>> cloudWaypoints =
          List<Map<String, dynamic>>.from(cloudDataResponse as List);

      if (cloudWaypoints.isEmpty) {
        print('[Sync Waypoints] Cloud kosong.');
      } else {
        print(
          '[Sync Waypoints] Ditemukan ${cloudWaypoints.length} data di Cloud.',
        );
      }

      final List<HikeWaypoint> localWaypoints = await _hikeWaypointDao
          .getAllLocalWaypointsForSync();
      final Map<String, HikeWaypoint> localWaypointsMap = {
        for (var wp in localWaypoints.where((p) => p.cloudId != null))
          wp.cloudId!: wp,
      };

      final Map<String, int> hikeCloudIdToLocalIdMap = {
        for (var hike in await _hikeDao.getAllLocalHikesForSync())
          if (hike.cloudId != null) hike.cloudId!: hike.id,
      };

      final List<HikeWaypointsCompanion> waypointsToUpsert = [];

      for (final cloudWaypoint in cloudWaypoints) {
        final String cloudId = cloudWaypoint['id'];
        final HikeWaypoint? existingLocalWaypoint = localWaypointsMap[cloudId];

        if (existingLocalWaypoint != null &&
            existingLocalWaypoint.syncStatus != SyncStatus.synced) {
          print(
            '[Sync Waypoints] Lewati Sync-Down untuk ${existingLocalWaypoint.name} (status: ${existingLocalWaypoint.syncStatus.name})',
          );
          continue;
        }

        final String parentHikeCloudId = cloudWaypoint['hike_id'];
        final int? parentHikeLocalId =
            hikeCloudIdToLocalIdMap[parentHikeCloudId];

        if (parentHikeLocalId == null) continue;

        final HikeWaypointsCompanion companion = HikeWaypointsCompanion(
          cloudId: Value(cloudId),
          hikeId: Value(parentHikeLocalId),
          name: Value(cloudWaypoint['name']),
          description: Value(cloudWaypoint['description']),
          latitude: Value(cloudWaypoint['latitude']),
          longitude: Value(cloudWaypoint['longitude']),
          timestamp: Value(DateTime.parse(cloudWaypoint['timestamp'])),
          category: Value(cloudWaypoint['category']),
          altitude: Value((cloudWaypoint['altitude'] as num?)?.toDouble()),
          elevationGainToHere: Value(
            (cloudWaypoint['elevation_gain_to_here'] as num?)?.toDouble(),
          ),
          elevationLossToHere: Value(
            (cloudWaypoint['elevation_loss_to_here'] as num?)?.toDouble(),
          ),
          isDeleted: Value(cloudWaypoint['is_deleted']),
          syncStatus: const Value(SyncStatus.synced),
        );

        if (existingLocalWaypoint == null) {
          waypointsToUpsert.add(companion);
        } else {
          bool needsUpdate =
              existingLocalWaypoint.isDeleted != companion.isDeleted.value ||
              existingLocalWaypoint.name != companion.name.value;

          if (needsUpdate) {
            waypointsToUpsert.add(
              companion.copyWith(id: Value(existingLocalWaypoint.id)),
            );
          }
        }
      }

      if (waypointsToUpsert.isNotEmpty) {
        await _hikeWaypointDao.upsertWaypoints(waypointsToUpsert);
      }
      print('[Sync Waypoints] Sync-Down Selesai.');
    } catch (e) {
      print('[Sync Waypoints] Gagal Sync-Down: $e');
      rethrow;
    }
  }

  Future<void> _syncInsertWaypoints() async {
    print('[Sync Waypoints] Memulai Sync-Up (Kirim data BARU)...');
    try {
      final pendingWaypoints = await _hikeWaypointDao
          .getPendingWaypointInserts();
      if (pendingWaypoints.isEmpty) return;

      final Map<int, String> hikeLocalIdToCloudIdMap = {
        for (var hike in await _hikeDao.getAllLocalHikesForSync())
          if (hike.cloudId != null) hike.id: hike.cloudId!,
      };

      final List<Map<String, dynamic>> dataToInsert = [];
      final List<HikeWaypoint> waypointsToSync = [];

      for (final waypoint in pendingWaypoints) {
        final String? parentHikeCloudId =
            hikeLocalIdToCloudIdMap[waypoint.hikeId];

        if (parentHikeCloudId == null) {
          print(
            '[Sync Waypoints] WAYPOINT DITUNDA: Induk (hikeId: ${waypoint.hikeId}) belum di-sync.',
          );
          continue;
        }

        dataToInsert.add({
          'hike_id': parentHikeCloudId,
          'name': waypoint.name,
          'description': waypoint.description,
          'latitude': waypoint.latitude,
          'longitude': waypoint.longitude,
          'timestamp': waypoint.timestamp.toIso8601String(),
          'category': waypoint.category,
          'altitude': waypoint.altitude,
          'elevation_gain_to_here': waypoint.elevationGainToHere,
          'elevation_loss_to_here': waypoint.elevationLossToHere,
          'is_deleted': waypoint.isDeleted,
          // user_id ditangani otomatis oleh Supabase
        });
        waypointsToSync.add(waypoint);
      }

      if (dataToInsert.isEmpty) return;

      final insertedDataResponse = await _supabase
          .from('hike_waypoints')
          .insert(dataToInsert)
          .select();
      final insertedList = insertedDataResponse as List<Map<String, dynamic>>;

      for (int i = 0; i < insertedList.length; i++) {
        final cloudData = insertedList[i];
        final localData = waypointsToSync[i];
        final String? cloudId = cloudData['id'];
        if (cloudId == null) continue;
        await _hikeWaypointDao.markWaypointAsSynced(localData.id, cloudId);
      }
      print(
        '[Sync Waypoints] Berhasil Sync-Up ${insertedList.length} Waypoint BARU.',
      );
    } catch (e) {
      print('[Sync Waypoints] Gagal Sync-Up Waypoint BARU: $e');
    }
  }

  Future<void> _syncUpdateWaypoints() async {
    print('[Sync Waypoints] Memulai Sync-Up (Kirim data UPDATE/DELETE)...');
    try {
      final pendingUpdates = await _hikeWaypointDao.getPendingWaypointUpdates();
      if (pendingUpdates.isEmpty) return;

      for (final waypoint in pendingUpdates) {
        if (waypoint.cloudId == null) continue;
        await _supabase
            .from('hike_waypoints')
            .update({
              'is_deleted': waypoint.isDeleted,
              'name': waypoint.name,
              'description': waypoint.description,
              'category': waypoint.category,
            })
            .eq('id', waypoint.cloudId!);
        await _hikeWaypointDao.markDeletedWaypointAsSynced(waypoint.id);
      }
      print(
        '[Sync Waypoints] Berhasil Sync-Up ${pendingUpdates.length} Waypoint UPDATE/DELETE.',
      );
    } catch (e) {
      print('[Sync Waypoints] Gagal Sync-Up Waypoint UPDATE/DELETE: $e');
    }
  }

  // =======================================================
  // == FUNGSI SYNC ROUTE POINTS (BARU)
  // =======================================================

  Future<void> _syncDownRoutePoints() async {
    print('[Sync RoutePoints] Memulai Sync-Down...');
    try {
      final List<String> localHikeCloudIds =
          (await _hikeDao.getAllLocalHikesForSync())
              .map((h) => h.cloudId)
              .whereType<String>()
              .toList();

      if (localHikeCloudIds.isEmpty) {
        print('[Sync RoutePoints] Batal: Tidak ada data induk (hikes) lokal.');
        return;
      }

      final cloudDataResponse = await _supabase
          .from('route_points')
          .select()
          .inFilter('hike_id', localHikeCloudIds);

      final List<Map<String, dynamic>> cloudRoutePoints =
          List<Map<String, dynamic>>.from(cloudDataResponse as List);

      if (cloudRoutePoints.isEmpty) {
        print('[Sync RoutePoints] Cloud kosong.');
      } else {
        print(
          '[Sync RoutePoints] Ditemukan ${cloudRoutePoints.length} data di Cloud.',
        );
      }

      final List<RoutePoint> localRoutePoints = await _routePointDao
          .getAllLocalRoutePointsForSync();
      final Map<String, RoutePoint> localRoutePointsMap = {
        for (var rp in localRoutePoints.where((p) => p.cloudId != null))
          rp.cloudId!: rp,
      };

      final Map<String, int> hikeCloudIdToLocalIdMap = {
        for (var hike in await _hikeDao.getAllLocalHikesForSync())
          if (hike.cloudId != null) hike.cloudId!: hike.id,
      };

      final List<RoutePointsCompanion> pointsToUpsert = [];

      for (final cloudPoint in cloudRoutePoints) {
        final String cloudId = cloudPoint['id'];
        final RoutePoint? existingLocalPoint = localRoutePointsMap[cloudId];

        // RoutePoints bersifat "append-only". Jika sudah ada, lewati.
        if (existingLocalPoint != null) {
          continue;
        }

        final String parentHikeCloudId = cloudPoint['hike_id'];
        final int? parentHikeLocalId =
            hikeCloudIdToLocalIdMap[parentHikeCloudId];

        if (parentHikeLocalId == null) continue;

        final RoutePointsCompanion companion = RoutePointsCompanion(
          cloudId: Value(cloudId),
          hikeId: Value(parentHikeLocalId),
          latitude: Value(cloudPoint['latitude']),
          longitude: Value(cloudPoint['longitude']),
          altitude: Value((cloudPoint['altitude'] as num?)?.toDouble()),
          speedKmh: Value((cloudPoint['speed_kmh'] as num?)?.toDouble()),
          timestamp: Value(DateTime.parse(cloudPoint['timestamp'])),
          syncStatus: const Value(SyncStatus.synced),
        );
        pointsToUpsert.add(companion);
      }

      if (pointsToUpsert.isNotEmpty) {
        await _routePointDao.upsertRoutePoints(pointsToUpsert);
      }
      print('[Sync RoutePoints] Sync-Down Selesai.');
    } catch (e) {
      print('[Sync RoutePoints] Gagal Sync-Down: $e');
      rethrow;
    }
  }

  Future<void> _syncInsertRoutePoints() async {
    print('[Sync RoutePoints] Memulai Sync-Up (Kirim data BARU)...');
    try {
      final pendingPoints = await _routePointDao.getPendingRoutePointInserts();
      if (pendingPoints.isEmpty) return;

      print(
        '[Sync RoutePoints] Ditemukan ${pendingPoints.length} RoutePoint BARU.',
      );

      final Map<int, String> hikeLocalIdToCloudIdMap = {
        for (var hike in await _hikeDao.getAllLocalHikesForSync())
          if (hike.cloudId != null) hike.id: hike.cloudId!,
      };

      const batchSize = 500; // Kirim per 500 titik
      for (int i = 0; i < pendingPoints.length; i += batchSize) {
        final batch = pendingPoints.sublist(
          i,
          i + batchSize > pendingPoints.length
              ? pendingPoints.length
              : i + batchSize,
        );

        final List<Map<String, dynamic>> dataToInsert = [];
        final List<RoutePoint> pointsToSync = [];

        for (final point in batch) {
          final String? parentHikeCloudId =
              hikeLocalIdToCloudIdMap[point.hikeId];

          if (parentHikeCloudId == null) {
            continue; // Induk belum di-sync, lewati
          }

          dataToInsert.add({
            'hike_id': parentHikeCloudId,
            'latitude': point.latitude,
            'longitude': point.longitude,
            'altitude': point.altitude,
            'timestamp': point.timestamp.toIso8601String(),
            'speed_kmh': point.speedKmh,
          });
          pointsToSync.add(point);
        }

        if (dataToInsert.isEmpty) continue;

        final insertedDataResponse = await _supabase
            .from('route_points')
            .insert(dataToInsert)
            .select();
        final insertedList = insertedDataResponse as List<Map<String, dynamic>>;

        final List<int> localIdsToMark = [];
        final List<String> cloudIdsToMark = [];

        for (int j = 0; j < insertedList.length; j++) {
          final cloudData = insertedList[j];
          final localData = pointsToSync[j];
          final String? cloudId = cloudData['id'];
          if (cloudId == null) continue;

          localIdsToMark.add(localData.id);
          cloudIdsToMark.add(cloudId);
        }

        if (localIdsToMark.isNotEmpty) {
          await _routePointDao.markRoutePointsAsSynced(
            localIdsToMark,
            cloudIdsToMark,
          );
        }
      }
      print(
        '[Sync RoutePoints] Berhasil Sync-Up ${pendingPoints.length} RoutePoint BARU.',
      );
    } catch (e) {
      print('[Sync RoutePoints] Gagal Sync-Up RoutePoint BARU: $e');
    }
  }

  // =======================================================
  // == FUNGSI SYNC FOTO (DI-UPGRADE DENGAN LINK WAYPOINT)
  // =======================================================

  Future<void> _syncDownPhotos() async {
    print('[Sync Foto] Memulai Sync-Down...');
    try {
      final List<String> localHikeCloudIds =
          (await _hikeDao.getAllLocalHikesForSync())
              .map((h) => h.cloudId)
              .whereType<String>()
              .toList();

      if (localHikeCloudIds.isEmpty) {
        print('[Sync Foto] Batal: Tidak ada data induk (hikes) lokal.');
        return;
      }

      final cloudDataResponse = await _supabase
          .from('hike_photos')
          .select()
          .inFilter('hike_id', localHikeCloudIds);

      final List<Map<String, dynamic>> cloudPhotos =
          List<Map<String, dynamic>>.from(cloudDataResponse as List);

      if (cloudPhotos.isEmpty) {
        print('[Sync Foto] Cloud kosong.');
      } else {
        print(
          '[Sync Foto] Ditemukan ${cloudPhotos.length} data foto di Cloud.',
        );
      }

      final List<HikePhoto> localPhotos = await _hikePhotoDao
          .getAllLocalPhotosForSync();
      final Map<String, HikePhoto> localPhotosMap = {
        for (var photo in localPhotos.where((p) => p.cloudId != null))
          photo.cloudId!: photo,
      };

      // Ambil "peta" jembatan ID (Cloud ID -> Lokal ID)
      final Map<String, int> hikeCloudIdToLocalIdMap = {
        for (var hike in await _hikeDao.getAllLocalHikesForSync())
          if (hike.cloudId != null) hike.cloudId!: hike.id,
      };
      // --- TAMBAHAN PETA ID WAYPOINT ---
      final Map<String, int> waypointCloudIdToLocalIdMap = {
        for (var wp in await _hikeWaypointDao.getAllLocalWaypointsForSync())
          if (wp.cloudId != null) wp.cloudId!: wp.id,
      };
      // --- AKHIR TAMBAHAN ---

      final List<HikePhotosCompanion> photosToUpsert = [];

      for (final cloudPhoto in cloudPhotos) {
        final String cloudId = cloudPhoto['id'];
        final HikePhoto? existingLocalPhoto = localPhotosMap[cloudId];

        if (existingLocalPhoto != null &&
            existingLocalPhoto.syncStatus != SyncStatus.synced) {
          print(
            '[Sync Foto] Lewati Sync-Down untuk foto ${existingLocalPhoto.id} (status: ${existingLocalPhoto.syncStatus.name})',
          );
          continue;
        }

        final String parentHikeCloudId = cloudPhoto['hike_id'];
        final int? parentHikeLocalId =
            hikeCloudIdToLocalIdMap[parentHikeCloudId];

        if (parentHikeLocalId == null)
          continue; // Induk hike tidak ada di lokal, abaikan

        // --- PERUBAHAN: Dapatkan ID Waypoint Lokal ---
        final String? parentWaypointCloudId = cloudPhoto['waypoint_id'];
        final int? parentWaypointLocalId =
            waypointCloudIdToLocalIdMap[parentWaypointCloudId];
        // --- AKHIR PERUBAHAN ---

        final HikePhotosCompanion companion = HikePhotosCompanion(
          cloudId: Value(cloudId),
          hikeId: Value(parentHikeLocalId),
          waypointId: Value(
            parentWaypointLocalId,
          ), // <-- SIMPAN ID LOKAL (bisa null)
          photoUrl: Value(cloudPhoto['photo_url']),
          latitude: Value(cloudPhoto['latitude']),
          longitude: Value(cloudPhoto['longitude']),
          capturedAt: cloudPhoto['captured_at'] != null
              ? Value(DateTime.parse(cloudPhoto['captured_at']))
              : const Value.absent(),
          isDeleted: Value(cloudPhoto['is_deleted']),
          syncStatus: const Value(SyncStatus.synced),
        );

        if (existingLocalPhoto == null) {
          photosToUpsert.add(companion);
        } else if (existingLocalPhoto.isDeleted != companion.isDeleted.value) {
          photosToUpsert.add(
            companion.copyWith(id: Value(existingLocalPhoto.id)),
          );
        }
      }

      if (photosToUpsert.isNotEmpty) {
        await _hikePhotoDao.upsertPhotos(photosToUpsert);
      }
      print('[Sync Foto] Sync-Down Selesai.');
    } catch (e) {
      print('[Sync Foto] Gagal Sync-Down: $e');
      rethrow;
    }
  }

  Future<void> _syncInsertPhotos() async {
    print('[Sync Foto] Memulai Sync-Up (Kirim data Foto BARU)...');
    try {
      final pendingPhotos = await _hikePhotoDao.getPendingPhotoInserts();
      if (pendingPhotos.isEmpty) return;

      final Map<int, String> hikeLocalIdToCloudIdMap = {
        for (var hike in await _hikeDao.getAllLocalHikesForSync())
          if (hike.cloudId != null) hike.id: hike.cloudId!,
      };
      // --- TAMBAHAN PETA ID WAYPOINT ---
      final Map<int, String> waypointLocalIdToCloudIdMap = {
        for (var wp in await _hikeWaypointDao.getAllLocalWaypointsForSync())
          if (wp.cloudId != null) wp.id: wp.cloudId!,
      };
      // --- AKHIR TAMBAHAN ---

      final List<Map<String, dynamic>> dataToInsert = [];
      final List<HikePhoto> photosToSync = [];

      for (final photo in pendingPhotos) {
        final String? parentHikeCloudId = hikeLocalIdToCloudIdMap[photo.hikeId];

        if (parentHikeCloudId == null) {
          print(
            '[Sync Foto] FOTO DITUNDA: Induk (hikeId: ${photo.hikeId}) belum di-sync.',
          );
          continue;
        }

        // --- PERUBAHAN: Dapatkan ID Waypoint Cloud ---
        final String? parentWaypointCloudId =
            waypointLocalIdToCloudIdMap[photo.waypointId];
        // (Jika photo.waypointId null, parentWaypointCloudId juga akan null, ini sudah benar)
        // --- AKHIR PERUBAHAN ---

        dataToInsert.add({
          'hike_id': parentHikeCloudId,
          'waypoint_id':
              parentWaypointCloudId, // <-- KIRIM ID CLOUD (bisa null)
          'photo_url': photo.photoUrl,
          'latitude': photo.latitude,
          'longitude': photo.longitude,
          'captured_at': photo.capturedAt?.toIso8601String(),
          'is_deleted': photo.isDeleted,
        });
        photosToSync.add(photo);
      }

      if (dataToInsert.isEmpty) return;

      final insertedDataResponse = await _supabase
          .from('hike_photos')
          .insert(dataToInsert)
          .select();
      final insertedList = insertedDataResponse as List<Map<String, dynamic>>;

      for (int i = 0; i < insertedList.length; i++) {
        final cloudData = insertedList[i];
        final localData = photosToSync[i];
        final String? cloudId = cloudData['id'];
        if (cloudId == null) continue;
        await _hikePhotoDao.markPhotoAsSynced(localData.id, cloudId);
      }
      print('[Sync Foto] Berhasil Sync-Up ${insertedList.length} Foto BARU.');
    } catch (e) {
      print('[Sync Foto] Gagal Sync-Up Foto BARU: $e');
    }
  }

  Future<void> _syncUpdatePhotos() async {
    print('[Sync Foto] Memulai Sync-Up (Kirim data Foto HAPUS)...');
    try {
      final pendingUpdates = await _hikePhotoDao.getPendingPhotoUpdates();
      if (pendingUpdates.isEmpty) return;

      for (final photo in pendingUpdates) {
        if (photo.cloudId == null) continue;
        await _supabase
            .from('hike_photos')
            .update({'is_deleted': photo.isDeleted}) // Hanya sync 'is_deleted'
            .eq('id', photo.cloudId!);
        await _hikePhotoDao.markDeletedPhotoAsSynced(photo.id);
      }
      print(
        '[Sync Foto] Berhasil Sync-Up ${pendingUpdates.length} Foto HAPUS.',
      );
    } catch (e) {
      print('[Sync Foto] Gagal Sync-Up Foto HAPUS: $e');
    }
  }
}
