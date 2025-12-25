import 'dart:async';
import 'dart:math'; // Diperlukan untuk 'max'
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart' as geo;
// Import 'currentGpsLocationProvider'
import 'package:jejak_faa_new/core/services/gps_service.dart';
import 'package:jejak_faa_new/data/local_db/daos/hike_dao.dart';
import 'package:jejak_faa_new/data/models/location_models.dart';
import 'package:jejak_faa_new/data/local_db/database.dart';
import 'package:jejak_faa_new/data/local_db/database_providers.dart';
// Import provider database
import 'package:jejak_faa_new/features/hike_log/providers/route_points_provider.dart';
import 'package:jejak_faa_new/data/models/sync_status.dart';
import 'package:jejak_faa_new/features/map_view/providers/weather_provider.dart';
import 'package:jejak_faa_new/features/sync/providers/sync_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Import service baru kita
import 'package:flutter_background_service/flutter_background_service.dart';

part 'map_provider.g.dart';

// ... (Class WaypointData dan MapTrackingState tetap sama) ...
@immutable
class WaypointData {
  const WaypointData({
    required this.latitude,
    required this.longitude,
    required this.name,
    required this.description,
    this.category,
  });
  final double latitude;
  final double longitude;
  final String name;
  final String? description;
  final String? category;
}

@immutable
class MapTrackingState {
  const MapTrackingState({
    required this.isTracking,
    required this.isPaused,
    this.currentHikeId,
    required this.livePoints,
    required this.liveWaypoints,
    required this.liveDistanceMeters,
    required this.liveElevationGainMeters,
    required this.liveElevationLossMeters,
    required this.liveMaxSpeedKmh,
    required this.livePaceMinPerKm,
    required this.liveDuration,
    this.lastPosition,
    this.isPickingWaypoint = false,
  });

  final bool isTracking;
  final bool isPaused;
  final int? currentHikeId;
  final List<LatLng> livePoints;
  final List<WaypointData> liveWaypoints;
  final double liveDistanceMeters;
  final double liveElevationGainMeters;
  final double liveElevationLossMeters;
  final double liveMaxSpeedKmh;
  final double livePaceMinPerKm;
  final Duration liveDuration;
  final PositionData? lastPosition;
  final bool isPickingWaypoint;

  factory MapTrackingState.initial() {
    return const MapTrackingState(
      isTracking: false,
      isPaused: false,
      currentHikeId: null,
      livePoints: [],
      liveWaypoints: [],
      liveDistanceMeters: 0,
      liveElevationGainMeters: 0,
      liveElevationLossMeters: 0,
      liveMaxSpeedKmh: 0,
      livePaceMinPerKm: 0.0,
      liveDuration: Duration.zero,
      lastPosition: null,
      isPickingWaypoint: false,
    );
  }

  MapTrackingState copyWith({
    bool? isTracking,
    bool? isPaused,
    int? currentHikeId,
    List<LatLng>? livePoints,
    List<WaypointData>? liveWaypoints,
    double? liveDistanceMeters,
    double? liveElevationGainMeters,
    double? liveElevationLossMeters,
    double? liveMaxSpeedKmh,
    double? livePaceMinPerKm,
    Duration? liveDuration,
    PositionData? lastPosition,
    bool? isPickingWaypoint,
  }) {
    return MapTrackingState(
      isTracking: isTracking ?? this.isTracking,
      isPaused: isPaused ?? this.isPaused,
      currentHikeId: currentHikeId ?? this.currentHikeId,
      livePoints: livePoints ?? this.livePoints,
      liveWaypoints: liveWaypoints ?? this.liveWaypoints,
      liveDistanceMeters: liveDistanceMeters ?? this.liveDistanceMeters,
      liveElevationGainMeters:
          liveElevationGainMeters ?? this.liveElevationGainMeters,
      liveElevationLossMeters:
          liveElevationLossMeters ?? this.liveElevationLossMeters,
      liveMaxSpeedKmh: liveMaxSpeedKmh ?? this.liveMaxSpeedKmh,
      livePaceMinPerKm: livePaceMinPerKm ?? this.livePaceMinPerKm,
      liveDuration: liveDuration ?? this.liveDuration,
      lastPosition: lastPosition ?? this.lastPosition,
      isPickingWaypoint: isPickingWaypoint ?? this.isPickingWaypoint,
    );
  }
}

/// "OTAK" DARI FITUR PELACAKAN (VERSI REFAKTOR)
// Salin ke: map_provider.dart
// (Pastikan semua import sudah ada di atas file)
@riverpod
class MapNotifier extends _$MapNotifier {
  // --- HAPUS SEMUA TIMER & STOPWATCH DARI SINI ---
  // HAPUS: _stopwatch, _durationTimer

  // GANTI DENGAN POLLER (Pembaca Buku Log)
  Timer? _liveStatsPoller;

  String? _mountainName;
  DateTime? _hikeDate;
  bool _isSaving = false;
  bool _isStarting = false;
  PositionData? _lastGpsPosition; // Untuk pace/speed UI

  @override
  MapTrackingState build() {
    ref.onDispose(() {
      print('[MapProvider] Disposing MapNotifier');
      _liveStatsPoller?.cancel();
    });

    // PANGGIL FUNGSI UNTUK CEK STATUS SAAT APP DIBUKA
    _checkAndRestoreSession();

    return MapTrackingState.initial();
  }

  // --- FUNGSI BARU UNTUK MEMULIHKAN STATE (FIX BUG POPUP JEDA) ---
  Future<void> _checkAndRestoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final int? hikeId = prefs.getInt('ongoing_hike_id');
    final String? status = prefs.getString('tracking_status');

    if (hikeId == null || status == null) {
      print('[MapProvider] Tidak ada sesi untuk dipulihkan.');
      return; // Selesai, tidak ada sesi
    }

    print('[MapProvider] ⚠️ Memulihkan sesi (Hike $hikeId, Status: $status)');

    // Muat data terakhir dari DB
    await _reloadStateFromDatabase(hikeId);

    // Atur state UI
    if (status == 'tracking') {
      // FIX BUG RELOG: Jika status 'tracking', langsung masuk mode tracking
      // JANGAN TAMPILKAN POPUP
      state = state.copyWith(
        isTracking: true,
        isPaused: false,
        currentHikeId: hikeId,
      );
      _startLiveStatsPoller(); // Mulai dengarkan data live
    } else if (status == 'paused') {
      // FIX BUG POPUP: Jika status 'paused', baru tampilkan popup
      // (UI akan otomatis menampilkan popup jika isTracking=true dan isPaused=true)
      state = state.copyWith(
        isTracking: true,
        isPaused: true,
        currentHikeId: hikeId,
        // liveDuration & liveDistance sudah diisi oleh _reloadStateFromDatabase
      );
    }
  }

  Future<int?> get pausedHikeId async {
    final prefs = await SharedPreferences.getInstance();
    final status = prefs.getString('tracking_status');
    // Hanya kembalikan ID jika statusnya BENAR-BENAR 'paused'
    if (status == 'paused') {
      return prefs.getInt('ongoing_hike_id');
    }
    return null;
  }

  /// =======================================================
  /// METODE 1: MULAI MEREKAM (Disederhanakan)
  /// =======================================================
  Future<void> startTracking() async {
    if (state.isTracking || _isStarting) return;
    _isStarting = true;

    try {
      print('[MapProvider] ════════════════════════════════════');
      print('[MapProvider] Memulai pelacakan baru...');

      final prefs = await SharedPreferences.getInstance();
      final hikeDao = ref.read(hikeDaoProvider);

      // --- DAPATKAN POSISI AWAL ---
      PositionData? startPosition;
      try {
        startPosition = await ref.read(currentGpsLocationProvider.future);
        if (startPosition == null)
          throw Exception("Cannot get initial position");
      } catch (e) {
        _isStarting = false;
        rethrow;
      }
      _lastGpsPosition = startPosition; // Simpan untuk pace

      // --- AMBIL CUACA ---
      final weatherSnapshot = await ref
          .read(weatherProvider.notifier)
          .fetchWeather(startPosition.latitude, startPosition.longitude);

      // --- BUAT HIKE BARU ---
      _hikeDate = DateTime.now();
      _mountainName =
          'Jejak Baru ${DateTime.now().day}/${DateTime.now().month}';
      final newHikeCompanion = HikesCompanion(
        userId: Value(ref.read(supabaseProviderProvider).auth.currentUser!.id),
        mountainName: Value(_mountainName!),
        hikeDate: Value(_hikeDate!),
        startWeatherCondition: Value(weatherSnapshot?.conditionMain),
        startTemperature: Value(weatherSnapshot?.temp),
        durationSeconds: const Value(0), // Mulai dari 0
      );
      final newHike = await hikeDao.insertHike(newHikeCompanion);
      final newHikeId = newHike.id;

      // --- SIMPAN STATE KE BUKU LOG (PREFS) ---
      await prefs.setInt('ongoing_hike_id', newHikeId);
      await prefs.setString('tracking_status', 'tracking');
      await prefs.setInt('live_duration_seconds', 0); // FIX TIMER GA JALAN
      await prefs.setDouble('live_distance_meters', 0.0); // FIX TIMER GA JALAN

      // --- KIRIM PERINTAH KE SERVICE ---
      await prefs.setString('tracking_command', 'START');

      // Update UI
      state = state.copyWith(
        isTracking: true,
        isPaused: false,
        currentHikeId: newHikeId,
        livePoints: [LatLng(startPosition.latitude, startPosition.longitude)],
        lastPosition: startPosition,
        liveDuration: Duration.zero, // UI mulai dari 0
        liveDistanceMeters: 0.0,
      );

      _startLiveStatsPoller(); // Mulai poller UI

      print('[MapProvider] ✅ Tracking started');
    } catch (e, st) {
      print('[MapProvider] ❌ Error: $e\n$st');
    } finally {
      _isStarting = false;
    }
  }

  /// =======================================================
  /// METODE 2: RESUME MANUAL (Disederhanakan)
  /// =======================================================
  Future<void> resumeTracking() async {
    final prefs = await SharedPreferences.getInstance();
    final persistedHikeId = prefs.getInt('ongoing_hike_id');
    if (persistedHikeId == null) return;

    print('[MapProvider] Resuming hike: $persistedHikeId');

    // Muat ulang state (poin, durasi, jarak) dari DB
    await _reloadStateFromDatabase(persistedHikeId);

    // Ambil data yang BARU di-reload dari state
    final lastKnownDuration = state.liveDuration.inSeconds;
    final lastKnownDistance = state.liveDistanceMeters;

    // --- SIMPAN STATE KE BUKU LOG (PREFS) ---
    await prefs.setString('tracking_status', 'tracking');
    await prefs.setInt('live_duration_seconds', lastKnownDuration);
    await prefs.setDouble('live_distance_meters', lastKnownDistance);

    // --- KIRIM PERINTAH KE SERVICE ---
    await prefs.setString('tracking_command', 'START');

    state = state.copyWith(isTracking: true, isPaused: false);
    _startLiveStatsPoller(); // Mulai poller UI
  }

  /// =======================================================
  /// METODE 3: PAUSE (Disederhanakan)
  /// =======================================================
  Future<void> pauseTracking() async {
    if (!state.isTracking || state.isPaused) return;
    print('[MapProvider] Pelacakan dijeda...');

    _liveStatsPoller?.cancel(); // Hentikan poller UI
    _liveStatsPoller = null;

    final prefs = await SharedPreferences.getInstance();

    // --- SIMPAN STATE KE BUKU LOG (PREFS) ---
    await prefs.setString('tracking_status', 'paused');

    // --- KIRIM PERINTAH KE SERVICE ---
    await prefs.setString('tracking_command', 'PAUSE');

    // Update UI
    state = state.copyWith(
      isPaused: true,
      // (Durasi & Jarak live terakhir biarkan tersimpan di state)
    );
  }

  /// =======================================================
  /// METODE 4: STOP (FULL CODE)
  /// =======================================================
  Future<Hike?> stopTrackingAndGetHike() async {
    if (!state.isTracking || state.currentHikeId == null) return null;
    if (_isSaving) return null;
    _isSaving = true;
    print('[MapProvider] Menghentikan pelacakan...');

    try {
      _liveStatsPoller?.cancel();
      _liveStatsPoller = null;

      final prefs = await SharedPreferences.getInstance();
      final hikeDao = ref.read(hikeDaoProvider);
      final routePointDao = ref.read(routePointDaoProvider);
      final hikeId = state.currentHikeId!;

      await prefs.setString('tracking_command', 'STOP');
      await Future.delayed(const Duration(seconds: 1)); 

      await prefs.remove('ongoing_hike_id');
      await prefs.remove('tracking_status');
      await prefs.remove('live_duration_seconds');
      await prefs.remove('live_distance_meters');
      
      final currentHike = await hikeDao.getHikeById(hikeId);
      if (currentHike == null) throw Exception("Hike data missing");
      
      final finalTotalDuration = Duration(seconds: currentHike.durationSeconds ?? 0);

      // --- MULAI KALKULASI STATISTIK AKHIR ---
      final allRoutePoints = await (routePointDao.select(
        routePointDao.routePoints,
      )..where((tbl) => tbl.hikeId.equals(hikeId)))
          .get();

      print(
        '[MapProvider] Menghitung statistik akhir dari ${allRoutePoints.length} titik...',
      );

      double finalTotalKm = 0.0;
      double finalMaxSpeed = 0.0;
      double finalElevationGain = 0.0;
      double finalElevationLoss = 0.0;
      double uncommittedGain = 0.0;
      double uncommittedLoss = 0.0;
      const GAIN_COMMIT_THRESHOLD = 1.5;
      const LOSS_COMMIT_THRESHOLD = 1.5;
      const RESET_THRESHOLD = 0.5;
      RoutePoint? lastPoint;

      for (final point in allRoutePoints) {
        if (lastPoint != null) {
          finalTotalKm +=
              geo.Geolocator.distanceBetween(
                lastPoint.latitude,
                lastPoint.longitude,
                point.latitude,
                point.longitude,
              ) /
              1000.0; // Langsung konversi ke KM

          if (point.altitude != null && lastPoint.altitude != null) {
            final elevationDiff = point.altitude! - lastPoint.altitude!;
            if (elevationDiff > RESET_THRESHOLD) {
              uncommittedGain += elevationDiff;
              if (uncommittedLoss >= LOSS_COMMIT_THRESHOLD) {
                finalElevationLoss += uncommittedLoss;
              }
              uncommittedLoss = 0.0;
            } else if (elevationDiff < -RESET_THRESHOLD) {
              uncommittedLoss += elevationDiff.abs();
              if (uncommittedGain >= GAIN_COMMIT_THRESHOLD) {
                finalElevationGain += uncommittedGain;
              }
              uncommittedGain = 0.0;
            }
          }
        }
        finalMaxSpeed = max(finalMaxSpeed, point.speedKmh ?? 0.0);
        lastPoint = point;
      }

      if (uncommittedGain >= GAIN_COMMIT_THRESHOLD) {
        finalElevationGain += uncommittedGain;
      }
      if (uncommittedLoss >= LOSS_COMMIT_THRESHOLD) {
        finalElevationLoss += uncommittedLoss;
      }

      final double totalMinutes = finalTotalDuration.inSeconds / 60.0;
      final double averagePace = (finalTotalKm > 0 && totalMinutes > 0)
          ? (totalMinutes / finalTotalKm)
          : 0.0;
      
      print('[MapProvider] Stats calculated: ${finalTotalKm.toStringAsFixed(2)} km');
      // --- SELESAI KALKULASI STATISTIK AKHIR ---
      
      await _calculateWaypointStats(hikeId);

      final SyncStatus newSyncStatus =
          (currentHike.syncStatus == SyncStatus.synced)
          ? SyncStatus.pending_update
          : SyncStatus.pending;

      final finalStatsCompanion = HikesCompanion(
        id: Value(hikeId),
        userId: Value(currentHike.userId),
        cloudId: Value(currentHike.cloudId),
        partners: Value(currentHike.partners),
        notes: Value(currentHike.notes),
        isDeleted: Value(currentHike.isDeleted),
        mountainName: Value(_mountainName ?? currentHike.mountainName),
        hikeDate: Value(_hikeDate ?? currentHike.hikeDate),
        durationSeconds: Value(finalTotalDuration.inSeconds),
        totalDistanceKm: Value(finalTotalKm),
        totalElevationGainMeters: Value(finalElevationGain),
        totalElevationLossMeters: Value(finalElevationLoss),
        averagePaceMinPerKm: Value(averagePace),
        maxSpeedKmh: Value(finalMaxSpeed),
        startWeatherCondition: Value(currentHike.startWeatherCondition),
        startTemperature: Value(currentHike.startTemperature),
        syncStatus: Value(newSyncStatus),
      );

      await hikeDao.updateHike(finalStatsCompanion);
      print('[MapProvider] ✅ Hike updated dengan statistik');
      
      final Hike? finalHike = await hikeDao.getHikeById(hikeId);
      
      state = MapTrackingState.initial(); 

      print('[MapProvider] Memicu sinkronisasi pasca-pelacakan...');
      ref.read(syncProvider.notifier).syncNow();

      return finalHike;

    } catch (e, st) {
      print('[MapProvider] ❌ Error stopping tracking: $e');
      print('[MapProvider] Stack: $st');
      _isSaving = false;
      rethrow;
    } finally {
      _isSaving = false;
    }
  }

  /// =======================================================
  /// METODE 5: TAMBAH WAYPOINT
  /// =======================================================
  Future<HikeWaypoint?> addWaypoint(
    String name,
    String? description,
    String? category,
    LatLng? tappedLatLng,
  ) async {
    if (!state.isTracking || state.currentHikeId == null) {
      print(
        '[MapProvider] Cannot add waypoint: isTracking=${state.isTracking}',
      );
      return null;
    }
    try {
      final waypointDao = ref.read(hikeWaypointDaoProvider);
      final double latitude;
      final double longitude;
      final double? altitude;
      final DateTime timestamp;

      if (tappedLatLng != null) {
        print('[MapProvider] Menambah waypoint dari Peta');
        latitude = tappedLatLng.latitude;
        longitude = tappedLatLng.longitude;
        altitude = null;
        timestamp = DateTime.now();
      } else {
        print('[MapProvider] Menambah waypoint dari Lokasi GPS');
        final lastPos = await ref
            .read(routePointDaoProvider)
            .getLastRoutePoint(state.currentHikeId!);

        if (lastPos == null) {
          print('[MapProvider] Gagal menambah: Tidak ada RoutePoint di DB');
          if (state.lastPosition != null) {
            latitude = state.lastPosition!.latitude;
            longitude = state.lastPosition!.longitude;
            altitude = state.lastPosition!.altitude;
            timestamp = state.lastPosition!.timestamp;
          } else {
            return null;
          }
        } else {
          latitude = lastPos.latitude;
          longitude = lastPos.longitude;
          altitude = lastPos.altitude;
          timestamp = lastPos.timestamp;
        }
      }

      final companion = HikeWaypointsCompanion(
        hikeId: Value(state.currentHikeId!),
        latitude: Value(latitude),
        longitude: Value(longitude),
        altitude: Value(altitude),
        timestamp: Value(timestamp),
        name: Value(name),
        description: Value(description),
        category: Value(category),
      );

      final newWaypoint = await waypointDao
          .into(waypointDao.hikeWaypoints)
          .insertReturning(companion);

      // (Update state liveWaypoints jika diperlukan, tapi ini akan
      //  diambil oleh _reloadStateFromDatabase)

      print('[MapProvider] Waypoint "$name" disimpan (ID: ${newWaypoint.id}).');
      return newWaypoint;
    } catch (e) {
      print('[MapProvider] Error adding waypoint: $e');
      return null;
    }
  }

  // --- Fungsi Mode Waypoint (Tetap Sama) ---
  void enterWaypointPickMode() {
    if (!state.isTracking) return;
    state = state.copyWith(isPickingWaypoint: true);
  }

  void exitWaypointPickMode() {
    state = state.copyWith(isPickingWaypoint: false);
  }

  // --- Fungsi Buang Sesi (Hampir Sama) ---
  Future<void> discardPausedSession() async {
    print('[MapProvider] Membuang sesi yang dijeda...');
    final prefs = await SharedPreferences.getInstance();
    final persistedHikeId = prefs.getInt('ongoing_hike_id');

    if (persistedHikeId != null) {
      // KIRIM PERINTAH STOP (agar service juga bersih-bersih)
      await prefs.setString('tracking_command', 'STOP');
      await Future.delayed(const Duration(milliseconds: 500));

      final hikeDao = ref.read(hikeDaoProvider);
      await hikeDao.hardDeleteHike(persistedHikeId);
      print(
        '[MapProvider] Data Hike ID: $persistedHikeId telah di-hard-delete.',
      );
    }

    _cleanupSubscriptions();
    state = MapTrackingState.initial();
    print('[MapProvider] Sesi berhasil dibuang dan state di-reset.');
  }

  // (Fungsi _calculateWaypointStats tetap sama)
  Future<void> _calculateWaypointStats(int hikeId) async {
    final hikeDao = ref.read(hikeDaoProvider);

    final routePointDao = ref.read(routePointDaoProvider);

    final waypointDao = ref.read(hikeWaypointDaoProvider);

    final Hike? hike = await hikeDao.getHikeById(hikeId);

    if (hike == null) {
      print('[StatCalculator] Hike not found, aborting.');

      return;
    }

    final allWaypoints =
        await (waypointDao.select(waypointDao.hikeWaypoints)
              ..where((tbl) => tbl.hikeId.equals(hikeId))
              ..orderBy([(tbl) => OrderingTerm(expression: tbl.timestamp)]))
            .get();

    final allRoutePoints =
        await (routePointDao.select(routePointDao.routePoints)
              ..where((tbl) => tbl.hikeId.equals(hikeId))
              ..orderBy([(tbl) => OrderingTerm(expression: tbl.timestamp)]))
            .get();

    if (allWaypoints.isEmpty || allRoutePoints.isEmpty) {
      print(
        '[StatCalculator] No waypoints or route points, nothing to calculate.',
      );

      return;
    }

    DateTime lastTimestamp = hike.hikeDate;

    double cumulativeGain = 0.0;

    double cumulativeLoss = 0.0;

    const GAIN_COMMIT_THRESHOLD = 1.5;

    const LOSS_RESET_THRESHOLD = 0.5;

    for (final waypoint in allWaypoints) {
      final segmentRoutePoints = allRoutePoints
          .where(
            (p) =>
                p.timestamp.isAfter(lastTimestamp) &&
                !p.timestamp.isAfter(waypoint.timestamp),
          )
          .toList();

      if (segmentRoutePoints.isNotEmpty) {
        double segmentGain = 0.0;

        double segmentLoss = 0.0;

        double uncommittedGain = 0.0;

        RoutePoint? lastSegPos;

        final lastPosBeforeSegment = allRoutePoints.lastWhere(
          (p) => !p.timestamp.isAfter(lastTimestamp),

          orElse: () => allRoutePoints.first,
        );

        lastSegPos = lastPosBeforeSegment;

        for (final currentSegPos in segmentRoutePoints) {
          if (lastSegPos != null &&
              currentSegPos.altitude != null &&
              lastSegPos.altitude != null) {
            final elevationDiff =
                currentSegPos.altitude! - lastSegPos.altitude!;

            if (elevationDiff > 0) {
              uncommittedGain += elevationDiff;
            } else if (elevationDiff < -LOSS_RESET_THRESHOLD) {
              if (uncommittedGain >= GAIN_COMMIT_THRESHOLD) {
                segmentGain += uncommittedGain;
              }

              uncommittedGain = 0.0;

              segmentLoss += elevationDiff.abs();
            }
          }

          lastSegPos = currentSegPos;
        }

        if (uncommittedGain >= GAIN_COMMIT_THRESHOLD) {
          segmentGain += uncommittedGain;
        }

        cumulativeGain += segmentGain;

        cumulativeLoss += segmentLoss;
      }

      final companion = HikeWaypointsCompanion(
        id: Value(waypoint.id),

        elevationGainToHere: Value(cumulativeGain),

        elevationLossToHere: Value(cumulativeLoss),
      );

      await waypointDao.update(waypointDao.hikeWaypoints).replace(companion);

      print(
        '[StatCalculator] Waypoint ${waypoint.name}: Gain=${cumulativeGain.toStringAsFixed(1)}, Loss=${cumulativeLoss.toStringAsFixed(1)}',
      );

      lastTimestamp = waypoint.timestamp;
    }
  }

  /// =======================================================
  /// Helper Internal (Baru & Diubah)
  /// =======================================================

  // --- FUNGSI BARU (Pembaca Buku Log) ---
  void _startLiveStatsPoller() {
  _liveStatsPoller?.cancel();
  print('[MapProvider] Memulai Polling Data Live...');

  _liveStatsPoller = Timer.periodic(const Duration(seconds: 1), (
   timer,
  ) async {
   if (!state.isTracking || state.isPaused || state.currentHikeId == null) {
    timer.cancel();
    return;
   }

   try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload(); // Ambil data terbaru

    // 1. Baca data STATISTIK dari Prefs (Ditulis oleh Service)
    final liveDuration = prefs.getInt('live_duration_seconds');
    final liveDistance = prefs.getDouble('live_distance_meters');

    // 2. ⬇️ TAMBAHAN: Baca data PETA dari Database ⬇️
    final routePointDao = ref.read(routePointDaoProvider);
        // Kita ambil semua poin untuk hike ini
        // (Note: Untuk optimasi di masa depan, bisa ambil poin 'terbaru' saja, 
        // tapi untuk sekarang 'semua' lebih aman agar rute tidak putus)
    final points = await routePointDao.getRoutePointsForHike(state.currentHikeId!);

        // Konversi ke LatLng untuk UI
        final List<LatLng> livePoints = points
            .map((p) => LatLng(p.latitude, p.longitude))
            .toList();
        
        // Ambil posisi terakhir dari list poin (lebih akurat drpd _lastGpsPosition lama)
        final PositionData? lastPos = points.isNotEmpty 
            ? PositionData(
                latitude: points.last.latitude,
                longitude: points.last.longitude,
                altitude: points.last.altitude ?? 0,
                speedKmh: points.last.speedKmh ?? 0,
                timestamp: points.last.timestamp,
              ) 
            : _lastGpsPosition;
            
    final double currentSpeedKmh = lastPos?.speedKmh ?? 0.0;
    final double currentPace = (currentSpeedKmh > 0.5)
      ? (60.0 / currentSpeedKmh)
      : 0.0;

    // 3. Update UI dengan data LENGKAP
    state = state.copyWith(
     liveDuration: Duration(
      seconds: liveDuration ?? state.liveDuration.inSeconds,
     ),
     liveDistanceMeters: liveDistance ?? state.liveDistanceMeters,
          livePoints: livePoints, // <-- Update Garis Peta
     livePaceMinPerKm: currentPace,
     lastPosition: lastPos,      // <-- Update Blue Dot
    );
   } catch (e) {
        // Database locked mungkin terjadi sesekali, aman diabaikan
        // karena akan dicoba lagi detik berikutnya
    // print('[MapProvider] Polling skip (db lock?): $e');
   }
  });
 }

  // --- HAPUS FUNGSI LAMA ---
  // HAPUS: _listenToDatabaseUpdates
  // HAPUS: _startPositionStreamListener
  // HAPUS: _refreshLiveStatsFromDb (fungsinya pindah ke poller)

  // UBAH: Fungsi ini sekarang hanya membersihkan poller
  void _cleanupSubscriptions() {
    print('[MapProvider] Cleaning up subscriptions...');
    _liveStatsPoller?.cancel();
    _liveStatsPoller = null;
  }

  // UBAH: Fungsi ini sekarang memuat data dari DB ke state
  Future<void> _reloadStateFromDatabase(int hikeId) async {
    print('[MapProvider] Memuat ulang state dari DB untuk Hike ID: $hikeId');
    _liveStatsPoller?.cancel(); // Pastikan poller mati

    try {
      final routePointDao = ref.read(routePointDaoProvider);
      final hikeDao = ref.read(hikeDaoProvider);

      final hike = await hikeDao.getHikeById(hikeId);
      final points = await routePointDao.getRoutePointsForHike(hikeId);

      // Hitung stats poin (jarak, elevasi, dll)
      _recalculateStatsFromPoints(points);

      // Update state durasi (penting)
      state = state.copyWith(
        liveDuration: Duration(seconds: hike?.durationSeconds ?? 0),
      );
    } catch (e) {
      print("[MapProvider] Gagal reload state: $e");
      _recalculateStatsFromPoints([]);
      state = state.copyWith(liveDuration: Duration.zero);
    }
  }

  // FUNGSI INI TETAP SAMA (penting untuk reload)
  void _recalculateStatsFromPoints(List<RoutePoint> points) {
    if (points.isEmpty) {
      state = state.copyWith(
        livePoints: [],
        liveDistanceMeters: 0,
        liveElevationGainMeters: 0,
        liveElevationLossMeters: 0,
        livePaceMinPerKm: 0.0,
      );
      return;
    }

    double newDistance = 0.0;
    double newElevationGain = 0.0;
    double newElevationLoss = 0.0;
    double newMaxSpeed = 0.0;
    double uncommittedGain = 0.0;
    double uncommittedLoss = 0.0;
    const GAIN_COMMIT_THRESHOLD = 1.5;
    const LOSS_COMMIT_THRESHOLD = 1.5;
    const RESET_THRESHOLD = 0.5;
    RoutePoint? lastPoint;

    for (final point in points) {
      if (lastPoint != null) {
        newDistance += geo.Geolocator.distanceBetween(
          lastPoint.latitude,
          lastPoint.longitude,
          point.latitude,
          point.longitude,
        );
        if (point.altitude != null && lastPoint.altitude != null) {
          final elevationDiff = point.altitude! - lastPoint.altitude!;
          if (elevationDiff > RESET_THRESHOLD) {
            uncommittedGain += elevationDiff;
            if (uncommittedLoss >= LOSS_COMMIT_THRESHOLD)
              newElevationLoss += uncommittedLoss;
            uncommittedLoss = 0.0;
          } else if (elevationDiff < -RESET_THRESHOLD) {
            uncommittedLoss += elevationDiff.abs();
            if (uncommittedGain >= GAIN_COMMIT_THRESHOLD)
              newElevationGain += uncommittedGain;
            uncommittedGain = 0.0;
          }
        }
      }
      newMaxSpeed = max(newMaxSpeed, point.speedKmh ?? 0.0);
      lastPoint = point;
    }

    if (uncommittedGain >= GAIN_COMMIT_THRESHOLD)
      newElevationGain += uncommittedGain;
    if (uncommittedLoss >= LOSS_COMMIT_THRESHOLD)
      newElevationLoss += uncommittedLoss;

    final double currentSpeedKmh = lastPoint?.speedKmh ?? 0.0;
    final double currentPace = (currentSpeedKmh > 0.5)
        ? (60.0 / currentSpeedKmh)
        : 0.0;

    final List<LatLng> livePoints = points
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();

    final PositionData? lastPosition = (lastPoint != null)
        ? PositionData(
            latitude: lastPoint.latitude,
            longitude: lastPoint.longitude,
            altitude: lastPoint.altitude ?? 0.0,
            speedKmh: lastPoint.speedKmh ?? 0.0,
            timestamp: lastPoint.timestamp,
          )
        : null;

    state = state.copyWith(
      livePoints: livePoints,
      lastPosition: lastPosition,
      liveDistanceMeters: newDistance,
      liveElevationGainMeters: newElevationGain,
      liveElevationLossMeters: newElevationLoss,
      liveMaxSpeedKmh: newMaxSpeed,
      livePaceMinPerKm: currentPace,
    );
  }
}
