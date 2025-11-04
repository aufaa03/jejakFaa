import 'dart:async';
import 'dart:math'; // Diperlukan untuk 'max'
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:jejak_faa_new/core/services/gps_service.dart';
import 'package:jejak_faa_new/data/local_db/daos/hike_dao.dart';
import 'package:jejak_faa_new/data/models/location_models.dart';
import 'package:jejak_faa_new/data/local_db/database.dart';
import 'package:jejak_faa_new/data/local_db/database_providers.dart';
import 'package:jejak_faa_new/data/models/sync_status.dart';
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'map_provider.g.dart';

/// Model untuk Waypoint (POI)
@immutable
class WaypointData {
  // ... (Tetap sama)
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

/// Model status untuk MapProvider
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
    required this.livePaceMinPerKm, // <-- TAMBAHAN
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
  final double livePaceMinPerKm; // <-- TAMBAHAN
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
      livePaceMinPerKm: 0.0, // <-- TAMBAHAN
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
    double? livePaceMinPerKm, // <-- TAMBAHAN
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
      livePaceMinPerKm: livePaceMinPerKm ?? this.livePaceMinPerKm, // <-- TAMBAHAN
      liveDuration: liveDuration ?? this.liveDuration,
      lastPosition: lastPosition ?? this.lastPosition,
      isPickingWaypoint: isPickingWaypoint ?? this.isPickingWaypoint,
    );
  }
}

/// "OTAK" DARI FITUR PELACAKAN
@riverpod
class MapNotifier extends _$MapNotifier {
  // ... (Properti lain tetap sama) ...
  StreamSubscription<PositionData>? _positionSubscription;
  Timer? _durationTimer;
  final Stopwatch _stopwatch = Stopwatch();
  double _uncommittedElevationGain = 0.0;
  double _uncommittedElevationLoss = 0.0;
  String? _mountainName;
  DateTime? _hikeDate;
  bool _isSaving = false;
  bool _isStarting = false;

  @override
  MapTrackingState build() {
    ref.onDispose(() {
      print('[MapProvider] Disposing MapNotifier');
      _cleanupSubscriptions();
    });
    return MapTrackingState.initial();
  }

  Future<int?> get pausedHikeId async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('ongoing_hike_id');
  }

  // ... (Fungsi startTracking Anda sudah benar) ...
  Future<void> startTracking() async {
    if (state.isTracking || _isStarting) {
      print(
        '[MapProvider] Start already in progress or tracking active, skipping',
      );
      return;
    }
    _isStarting = true;
    try {
      print('[MapProvider] Memulai pelacakan (guarded)...');
      final prefs = await SharedPreferences.getInstance();
      final persistedHikeId = prefs.getInt('ongoing_hike_id');
      final pausedFlag = prefs.getBool('ongoing_hike_paused') ?? false;
      final hikeDao = ref.read(hikeDaoProvider);
      if (persistedHikeId != null && !pausedFlag) {
        print('[MapProvider] Auto-resuming existing Hike ID: $persistedHikeId');
        _mountainName ??= 'Jejak Lanjutan';
        _stopwatch.start();
        _startDurationTimer();
        _startPositionStreamListener(persistedHikeId);
        state = state.copyWith(
          isTracking: true,
          isPaused: false,
          currentHikeId: persistedHikeId,
        );
        _isStarting = false;
        return;
      }
      if (persistedHikeId != null && pausedFlag) {
        print(
          '[MapProvider] Found paused session (id: $persistedHikeId). UI should prompt resume.',
        );
        _isStarting = false;
        return;
      }
      PositionData? startPosition;
      try {
        print('[MapProvider] Requesting initial location...');
        startPosition = await ref.read(currentGpsLocationProvider.future);
        if (startPosition == null) {
          print('[MapProvider] Could not get initial location (null)');
          _isStarting = false;
          return;
        }
        print(
          '[MapProvider] Initial location received: ${startPosition.latitude}, ${startPosition.longitude}',
        );
      } catch (e) {
        print('[MapProvider] Gagal memulai - tidak dapat lokasi awal: $e');
        _isStarting = false;
        return;
      }
      _hikeDate = DateTime.now();
      _mountainName ??=
          'Jejak Baru ${DateTime.now().day}/${DateTime.now().month}';
      final newHikeCompanion = HikesCompanion(
        userId: Value(ref.read(supabaseProviderProvider).auth.currentUser!.id),
        mountainName: Value(_mountainName!),
        hikeDate: Value(_hikeDate!),
      );
      final newHike = await hikeDao.insertHike(newHikeCompanion);
      final newHikeId = newHike.id;
      await prefs.setInt('ongoing_hike_id', newHikeId);
      await prefs.setBool('ongoing_hike_paused', false);
      _stopwatch.start();
      _startDurationTimer();
      _startPositionStreamListener(newHikeId);
      state = state.copyWith(
        isTracking: true,
        isPaused: false,
        currentHikeId: newHikeId,
        livePoints: [LatLng(startPosition.latitude, startPosition.longitude)],
        lastPosition: startPosition,
        liveMaxSpeedKmh: startPosition.speedKmh ?? 0.0,
      );
      print('[MapProvider] Pelacakan dimulai untuk Hike ID: $newHikeId');
    } finally {
      _isStarting = false;
    }
  }

  // ... (Fungsi resumeTracking Anda sudah benar) ...
  Future<void> resumeTracking() async {
    final prefs = await SharedPreferences.getInstance();
    final persistedHikeId = prefs.getInt('ongoing_hike_id');
    if (persistedHikeId == null) {
      print('[MapProvider] No persisted hike to resume');
      return;
    }
    PositionData? resumePosition;
    try {
      resumePosition = await ref.read(currentGpsLocationProvider.future);
    } catch (e) {
      print("[MapProvider] Gagal dapat lokasi saat resume: $e");
    }
    print('[MapProvider] Resuming persisted hike: $persistedHikeId');
    await prefs.setBool('ongoing_hike_paused', false);
    _mountainName ??= 'Jejak Lanjutan';
    _stopwatch.start();
    _startDurationTimer();
    _startPositionStreamListener(persistedHikeId);
    state = state.copyWith(
      isTracking: true,
      isPaused: false,
      currentHikeId: persistedHikeId,
      lastPosition: resumePosition ?? state.lastPosition,
    );
  }
  
  // ... (Fungsi pauseTracking Anda sudah benar) ...
  Future<void> pauseTracking() async {
    if (!state.isTracking || state.isPaused) return;
    print('[MapProvider] Pelacakan dijeda...');
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _durationTimer?.cancel();
    _durationTimer = null;
    _stopwatch.stop();
    state = state.copyWith(isPaused: true);
    final prefs = await SharedPreferences.getInstance();
    if (state.currentHikeId != null) {
      await prefs.setBool('ongoing_hike_paused', true);
    }
  }

  /// =======================================================
  /// METODE 4: BERHENTI & SIMPAN (UPGRADE PACE)
  /// =======================================================
  Future<Hike?> stopTrackingAndGetHike() async {
    if (!state.isTracking || state.currentHikeId == null) return null;
    if (_isSaving) {
      print('[MapProvider] stopTracking already in progress, skipping');
      return null;
    }
    _isSaving = true;

    print('[MapProvider] Menghentikan pelacakan (idempotent save)...');

    try {
      _cleanupSubscriptions();
      _stopwatch.stop();
      _stopwatch.reset();
      _durationTimer?.cancel();
      _durationTimer = null;

      final hikeDao = ref.read(hikeDaoProvider);

      final Hike? currentHike = await hikeDao.getHikeById(state.currentHikeId!);
      if (currentHike == null) throw Exception("Hike data missing during save");

      final SyncStatus newSyncStatus = 
          (currentHike.syncStatus == SyncStatus.synced)
              ? SyncStatus.pending_update
              : SyncStatus.pending;

      // --- LOGIKA STATISTIK BARU ---
      
      // Final stats - Gain & Loss
      double finalElevationGain = state.liveElevationGainMeters;
      const GAIN_COMMIT_THRESHOLD = 1.5;
      if (_uncommittedElevationGain >= GAIN_COMMIT_THRESHOLD) {
        finalElevationGain += _uncommittedElevationGain;
      }
      _uncommittedElevationGain = 0.0;
      double finalElevationLoss = state.liveElevationLossMeters;
      const LOSS_COMMIT_THRESHOLD = 1.5;
      if (_uncommittedElevationLoss >= LOSS_COMMIT_THRESHOLD) {
        finalElevationLoss += _uncommittedElevationLoss;
      }
      _uncommittedElevationLoss = 0.0;
      
      // Final stats - Pace
      final double totalMinutes = state.liveDuration.inSeconds / 60.0;
      final double totalKm = state.liveDistanceMeters / 1000.0;
      // Rumus: Menit / Kilometer
      final double averagePace = (totalKm > 0 && totalMinutes > 0) ? (totalMinutes / totalKm) : 0.0;

      print('[MapProvider] Pace: ${averagePace.toStringAsFixed(2)} min/km');
      // --- AKHIR LOGIKA STATISTIK BARU ---

      final finalStatsCompanion = HikesCompanion(
        id: Value(state.currentHikeId!),
        userId: Value(currentHike.userId),
        cloudId: Value(currentHike.cloudId),
        partners: Value(currentHike.partners),
        notes: Value(currentHike.notes),
        isDeleted: Value(currentHike.isDeleted),
        mountainName: Value(_mountainName ?? currentHike.mountainName),
        hikeDate: Value(_hikeDate ?? currentHike.hikeDate),
        
        // --- SIMPAN STATISTIK BARU ---
        durationSeconds: Value(state.liveDuration.inSeconds),
        totalDistanceKm: Value(totalKm),
        totalElevationGainMeters: Value(finalElevationGain),
        totalElevationLossMeters: Value(finalElevationLoss),
        averagePaceMinPerKm: Value(averagePace), // <-- Simpan PACE
        maxSpeedKmh: Value(state.liveMaxSpeedKmh), 
        // caloriesBurned: (Dihapus sesuai permintaan)
        // --- AKHIR SIMPAN STATISTIK BARU ---
        
        startWeatherCondition: Value(currentHike.startWeatherCondition),
        startTemperature: Value(currentHike.startTemperature),
        syncStatus: Value(newSyncStatus),
      );

      await hikeDao.updateHike(finalStatsCompanion);
      print('[MapProvider] Pelacakan dihentikan dan disimpan.');
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('ongoing_hike_id');
      await prefs.remove('ongoing_hike_paused');

      final Hike? hike = await hikeDao.getHikeById(state.currentHikeId!);
      state = MapTrackingState.initial();

      return hike;
    } catch (e, st) {
      print('[MapProvider] Error stopping tracking: $e\n$st');
      rethrow;
    } finally {
      _isSaving = false;
    }
  }

  // ... (Fungsi addWaypoint Anda sudah benar) ...
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
        if (state.lastPosition == null) {
          print('[MapProvider] Gagal menambah: Lokasi GPS terakhir tidak ada');
          return null;
        }
        final pos = state.lastPosition!;
        latitude = pos.latitude;
        longitude = pos.longitude;
        altitude = pos.altitude;
        timestamp = pos.timestamp;
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
      state = state.copyWith(
        liveWaypoints: [
          ...state.liveWaypoints,
          WaypointData(
            latitude: latitude,
            longitude: longitude,
            name: name,
            description: description,
            category: category,
          ),
        ],
      );
      print('[MapProvider] Waypoint "$name" disimpan (ID: ${newWaypoint.id}).');
      return newWaypoint;
    } catch (e) {
      print('[MapProvider] Error adding waypoint: $e');
      return null;
    }
  }

  // ... (Fungsi enter/exit WaypointPickMode Anda sudah benar) ...
  void enterWaypointPickMode() {
    if (!state.isTracking) return;
    print('[MapProvider] Entering Waypoint Pick Mode');
    state = state.copyWith(isPickingWaypoint: true);
  }
  void exitWaypointPickMode() {
    print('[MapProvider] Exiting Waypoint Pick Mode');
    state = state.copyWith(isPickingWaypoint: false);
  }

  // ... (Fungsi _startDurationTimer Anda sudah benar) ...
  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_stopwatch.isRunning) {
        timer.cancel();
      } else {
        state = state.copyWith(liveDuration: _stopwatch.elapsed);
      }
    });
  }

  // ... (Fungsi _startPositionStreamListener Anda sudah benar) ...
  void _startPositionStreamListener(int hikeId) {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    print('[MapProvider] Starting position stream for Hike ID: $hikeId');
    _positionSubscription = ref
        .read(gpsPositionProvider.stream)
        .listen(
          (positionData) async {
            if (!state.isTracking || state.isPaused) return;
            await _onNewPosition(positionData, hikeId);
          },
          onError: (error) {
            print('[MapProvider] GPS stream error: $error');
          },
          onDone: () {
            print('[MapProvider] GPS stream completed');
          },
        );
  }

  /// =======================================================
  /// Helper _onNewPosition (UPGRADE PACE & STATISTIK)
  /// =======================================================
  Future<void> _onNewPosition(PositionData newData, int hikeId) async {
    if (!state.isTracking || state.isPaused) return;

    final routePointDao = ref.read(routePointDaoProvider);
    final lastPos = state.lastPosition;

    double newDistance = state.liveDistanceMeters;
    double newElevationGain = state.liveElevationGainMeters;
    double newElevationLoss = state.liveElevationLossMeters;
    double newMaxSpeed = state.liveMaxSpeedKmh;
    const GAIN_COMMIT_THRESHOLD = 1.5;
    const LOSS_COMMIT_THRESHOLD = 1.5;
    const RESET_THRESHOLD = 0.5;

    // --- HITUNG PACE REALTIME ---
    final double currentSpeedKmh = newData.speedKmh ?? 0.0;
    // Cek kecepatan > 0.5 km/j (8.3 m/mnt) untuk menghindari pace tidak valid
    final double currentPace = (currentSpeedKmh > 0.5) ? (60.0 / currentSpeedKmh) : 0.0;
    // --- AKHIR HITUNG PACE ---

    if (lastPos != null) {
      newDistance += geo.Geolocator.distanceBetween(
        lastPos.latitude,
        lastPos.longitude,
        newData.latitude,
        newData.longitude,
      );

      // Logika Kecepatan Maksimal
      newMaxSpeed = max(newMaxSpeed, currentSpeedKmh);

      // Logika Elevasi
      if (newData.altitude != null && lastPos.altitude != null) {
        final elevationDiff = newData.altitude! - lastPos.altitude!;

        if (elevationDiff > RESET_THRESHOLD) { // Tanjakan
          _uncommittedElevationGain += elevationDiff;
          if (_uncommittedElevationLoss >= LOSS_COMMIT_THRESHOLD) {
            newElevationLoss += _uncommittedElevationLoss;
          }
          _uncommittedElevationLoss = 0.0;

        } else if (elevationDiff < -RESET_THRESHOLD) { // Turunan
          _uncommittedElevationLoss += elevationDiff.abs();
          if (_uncommittedElevationGain >= GAIN_COMMIT_THRESHOLD) {
            newElevationGain += _uncommittedElevationGain;
          }
          _uncommittedElevationGain = 0.0;
        }
      }
    }

    final routeCompanion = RoutePointsCompanion(
      hikeId: Value(hikeId),
      latitude: Value(newData.latitude),
      longitude: Value(newData.longitude),
      altitude: Value(newData.altitude),
      speedKmh: Value(currentSpeedKmh), // Simpan kecepatan
      timestamp: Value(newData.timestamp),
    );

    try {
      await routePointDao.insertRoutePoint(routeCompanion);
    } catch (e) {
      print('[MapProvider] Failed to insert route point: $e');
    }

    state = state.copyWith(
      lastPosition: newData,
      livePoints: [
        ...state.livePoints,
        LatLng(newData.latitude, newData.longitude),
      ],
      liveDistanceMeters: newDistance,
      liveElevationGainMeters: newElevationGain,
      liveElevationLossMeters: newElevationLoss,
      liveMaxSpeedKmh: newMaxSpeed,
      livePaceMinPerKm: currentPace, // <-- Simpan PACE REALTIME
    );
  }

  // ... (Fungsi _cleanupSubscriptions Anda sudah benar) ...
  void _cleanupSubscriptions() {
    print('[MapProvider] Cleaning up subscriptions...');
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _durationTimer?.cancel();
    _durationTimer = null;
    _stopwatch.stop();
  }

  // ... (Fungsi clearPersistentSession Anda sudah benar) ...
  Future<void> clearPersistentSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('ongoing_hike_id');
    await prefs.remove('ongoing_hike_paused');
    _cleanupSubscriptions();
    state = MapTrackingState.initial();
    print('[MapProvider] Persistent session cleared');
  }

  // ... (Fungsi discardPausedSession Anda sudah benar) ...
  Future<void> discardPausedSession() async {
    print('[MapProvider] Membuang sesi yang dijeda...');
    final prefs = await SharedPreferences.getInstance();
    final persistedHikeId = prefs.getInt('ongoing_hike_id');
    if (persistedHikeId != null) {
      final hikeDao = ref.read(hikeDaoProvider);
      await hikeDao.hardDeleteHike(persistedHikeId);
      print('[MapProvider] Data Hike ID: $persistedHikeId telah di-hard-delete.');
      await prefs.remove('ongoing_hike_id');
      await prefs.remove('ongoing_hike_paused');
    }
    _cleanupSubscriptions();
    _stopwatch.reset();
    state = MapTrackingState.initial();
    print('[MapProvider] Sesi berhasil dibuang dan state di-reset.');
  }

  // ... (Fungsi _calculateWaypointStats Anda sudah benar) ...
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
}