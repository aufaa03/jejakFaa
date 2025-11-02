import 'dart:async';
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
// import 'package:jejak_faa_new/features/map_view/providers/gps_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'map_provider.g.dart';

/// Model untuk Waypoint (POI)
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
      liveDuration: liveDuration ?? this.liveDuration,
      lastPosition: lastPosition ?? this.lastPosition,
      isPickingWaypoint: isPickingWaypoint ?? this.isPickingWaypoint,
    );
  }
}

/// "OTAK" DARI FITUR PELACAKAN
@riverpod
class MapNotifier extends _$MapNotifier {
  StreamSubscription<PositionData>? _positionSubscription;
  Timer? _durationTimer;
  final Stopwatch _stopwatch = Stopwatch();
  double _uncommittedElevationGain = 0.0;

  // Data untuk resume
  String? _mountainName;
  DateTime? _hikeDate;

  // Guards untuk prevent double-start & double-save
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

  /// Check if there's a paused/ongoing session (untuk UI)
  Future<bool> get hasPausedSession async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('ongoing_hike_id');
    final paused = prefs.getBool('ongoing_hike_paused') ?? false;
    print('[MapProvider] hasPausedSession: id=$id, paused=$paused');
    return id != null && paused;
  }

  /// Get paused hike ID (untuk debugging)
  Future<int?> get pausedHikeId async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('ongoing_hike_id');
  }

  /// =======================================================
  /// METODE 1: MULAI MEREKAM (dengan guard)
  /// =======================================================
  Future<void> startTracking() async {
    // Guard re-entrancy
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

      // Case 1: Resume automatic jika ada ongoing tapi tidak paused (app backgrounded)
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

      // Case 2: Ada paused session, jangan buat hike baru (UI akan ask user)
      if (persistedHikeId != null && pausedFlag) {
        print(
          '[MapProvider] Found paused session (id: $persistedHikeId). UI should prompt resume.',
        );
        _isStarting = false;
        return;
      }

      // Case 3: No persisted session - create new Hike
      PositionData? startPosition;
      try {
        print('[MapProvider] Requesting initial location...');
        // Gunakan currentGpsLocationProvider (Future) bukan stream
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

      // Persist untuk prevent duplicate pada relog
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
      );

      print('[MapProvider] Pelacakan dimulai untuk Hike ID: $newHikeId');
    } finally {
      _isStarting = false;
    }
  }

  /// =======================================================
  /// METODE 2: RESUME MANUAL (dipanggil dari UI dialog)
  /// =======================================================
  Future<void> resumeTracking() async {
    final prefs = await SharedPreferences.getInstance();
    final persistedHikeId = prefs.getInt('ongoing_hike_id');
    if (persistedHikeId == null) {
      print('[MapProvider] No persisted hike to resume');
      return;
    }

    PositionData? resumePosition;
    try {
      // Ambil lokasi GPS saat ini
      resumePosition = await ref.read(currentGpsLocationProvider.future);
    } catch (e) {
      print("[MapProvider] Gagal dapat lokasi saat resume: $e");
      // Jika gagal, kita lanjutkan saja. 'lastPosition' akan diisi
      // oleh stream GPS beberapa saat lagi.
    }
    print('[MapProvider] Resuming persisted hike: $persistedHikeId');

    // Clear paused flag
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

  /// =======================================================
  /// METODE 3: PAUSE (jeda & mark untuk UI)
  /// =======================================================
  Future<void> pauseTracking() async {
    if (!state.isTracking || state.isPaused) return;

    print('[MapProvider] Pelacakan dijeda...');

    _positionSubscription?.cancel();
    _positionSubscription = null;

    _durationTimer?.cancel();
    _durationTimer = null;

    _stopwatch.stop();

    state = state.copyWith(isPaused: true);

    // Mark paused di prefs supaya UI tahu ada session untuk di-resume
    final prefs = await SharedPreferences.getInstance();
    if (state.currentHikeId != null) {
      await prefs.setBool('ongoing_hike_paused', true);
    }
  }

  /// =======================================================
  /// METODE 4: BERHENTI & SIMPAN (idempotent)
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

      // --- INI PERBAIKAN UTAMANYA ---
      // 1. Ambil data Hike saat ini dari DB
      final Hike? currentHike = await hikeDao.getHikeById(state.currentHikeId!);
      if (currentHike == null) throw Exception("Hike data missing during save");

      // 2. Tentukan status sinkronisasi baru
      // Jika sudah di-sync, tandai sebagai update.
      // Jika masih baru (pending), biarkan pending.
      final SyncStatus newSyncStatus =
          (currentHike.syncStatus == SyncStatus.synced)
          ? SyncStatus.pending_update
          : SyncStatus.pending;
      // --- AKHIR PERBAIKAN UTAMA ---

      // Final stats
      double finalElevationGain = state.liveElevationGainMeters;
      const GAIN_COMMIT_THRESHOLD = 1.5;
      if (_uncommittedElevationGain >= GAIN_COMMIT_THRESHOLD) {
        finalElevationGain += _uncommittedElevationGain;
      }
      _uncommittedElevationGain = 0.0;

      // 3. Buat Companion LENGKAP untuk 'replace'
      // Kita harus menyertakan semua field lama agar tidak di-reset
      final finalStatsCompanion = HikesCompanion(
        id: Value(state.currentHikeId!),
        // Salin field yang ada dari 'currentHike'
        userId: Value(currentHike.userId),
        cloudId: Value(currentHike.cloudId),
        partners: Value(currentHike.partners),
        notes: Value(currentHike.notes),
        isDeleted: Value(currentHike.isDeleted),
        // Ambil data dari 'MapProvider'
        mountainName: Value(_mountainName ?? currentHike.mountainName),
        hikeDate: Value(_hikeDate ?? currentHike.hikeDate),
        // Tulis data statistik baru
        durationMinutes: Value(state.liveDuration.inMinutes),
        totalDistanceKm: Value(state.liveDistanceMeters / 1000),
        totalElevationGainMeters: Value(finalElevationGain),
        // Terapkan status sinkronisasi baru yang sudah kita tentukan
        syncStatus: Value(newSyncStatus),
      );

      await hikeDao.updateHike(
        finalStatsCompanion,
      ); // Ini akan memanggil 'replace'
      print('[MapProvider] Pelacakan dihentikan dan disimpan.');
      print(
        '[MapProvider] Stats - Duration: ${state.liveDuration.inMinutes}m, Distance: ${state.liveDistanceMeters / 1000}km, Elevation: ${finalElevationGain}m',
      );

      // Clear persisted session flags
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

  /// =======================================================
  /// METODE 5: TAMBAH WAYPOINT
  /// =======================================================
  Future<HikeWaypoint?> addWaypoint(
    String name,
    String? description,
    String? category,
    LatLng? tappedLatLng, // Parameter baru untuk lokasi dari peta
  ) async {
    // --- PERUBAHAN: Hapus guard 'lastPosition', kita mungkin tidak membutuhkannya ---
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
        // --- KASUS 2: "Tandai di sana" (Tap Peta) ---
        print('[MapProvider] Menambah waypoint dari Peta');
        latitude = tappedLatLng.latitude;
        longitude = tappedLatLng.longitude;
        altitude = null; // Kita TIDAK TAHU altitude dari titik di peta
        timestamp = DateTime.now(); // Tandai waktu saat POI dibuat
      } else {
        // --- KASUS 1: "Saya di sini" (Posisi GPS) ---
        print('[MapProvider] Menambah waypoint dari Lokasi GPS');
        if (state.lastPosition == null) {
          print('[MapProvider] Gagal menambah: Lokasi GPS terakhir tidak ada');
          return null;
        }
        final pos = state.lastPosition!;
        latitude = pos.latitude;
        longitude = pos.longitude;
        altitude = pos.altitude; // Kita TAHU altitude dari GPS
        timestamp = pos.timestamp;
      }

      // --- PERUBAHAN: Gunakan data baru di Companion ---
      final companion = HikeWaypointsCompanion(
        hikeId: Value(state.currentHikeId!),
        latitude: Value(latitude),
        longitude: Value(longitude),
        altitude: Value(altitude), // Simpan altitude (bisa null)
        timestamp: Value(timestamp),
        name: Value(name),
        description: Value(description),
        category: Value(category), // Simpan kategori
        // elevationGain/Loss akan null, diisi oleh _calculateWaypointStats nanti
      );

      // (Kita tidak perlu 'insertWaypointReturning' kecuali untuk tautan foto)
      // TODO: Implementasi tautan foto opsional di sini
      final newWaypoint = await waypointDao
          .into(waypointDao.hikeWaypoints)
          .insertReturning(companion);

      // Update UI state
      state = state.copyWith(
        liveWaypoints: [
          ...state.liveWaypoints,
          WaypointData(
            latitude: latitude,
            longitude: longitude,
            name: name,
            description: description,
            category: category, // Tampilkan di UI live
          ),
        ],
      );

      print('[MapProvider] Waypoint "$name" disimpan (ID: ${newWaypoint.id}).');
      return newWaypoint; // <-- Kembalikan objek Waypoint baru
    } catch (e) {
      print('[MapProvider] Error adding waypoint: $e');
      return null;
    }
  }

  // --- TAMBAHAN: FUNGSI BARU UNTUK KONTROL UI ---
  /// =======================================================
  /// METODE 6 & 7: KONTROL MODE PILIH PETA
  /// =======================================================

  /// Masuk ke mode "Pilih Lokasi dari Peta"
  void enterWaypointPickMode() {
    if (!state.isTracking) return;
    print('[MapProvider] Entering Waypoint Pick Mode');
    state = state.copyWith(isPickingWaypoint: true);
  }

  /// Keluar dari mode "Pilih Lokasi dari Peta"
  void exitWaypointPickMode() {
    print('[MapProvider] Exiting Waypoint Pick Mode');
    state = state.copyWith(isPickingWaypoint: false);
  }

  /// =======================================================
  /// Helper Internal
  /// =======================================================

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

  Future<void> _onNewPosition(PositionData newData, int hikeId) async {
    if (!state.isTracking || state.isPaused) return;

    final routePointDao = ref.read(routePointDaoProvider);
    final lastPos = state.lastPosition;

    double newDistance = state.liveDistanceMeters;
    double newElevationGain = state.liveElevationGainMeters;
    const GAIN_COMMIT_THRESHOLD = 1.5;
    const LOSS_RESET_THRESHOLD = 0.5;

    if (lastPos != null) {
      newDistance += geo.Geolocator.distanceBetween(
        lastPos.latitude,
        lastPos.longitude,
        newData.latitude,
        newData.longitude,
      );

      final elevationDiff = newData.altitude - lastPos.altitude;
      if (elevationDiff > 0) {
        _uncommittedElevationGain += elevationDiff;
      } else if (elevationDiff < -LOSS_RESET_THRESHOLD) {
        if (_uncommittedElevationGain >= GAIN_COMMIT_THRESHOLD) {
          newElevationGain += _uncommittedElevationGain;
        }
        _uncommittedElevationGain = 0.0;
      }
    }

    final routeCompanion = RoutePointsCompanion(
      hikeId: Value(hikeId),
      latitude: Value(newData.latitude),
      longitude: Value(newData.longitude),
      altitude: Value(newData.altitude),
      speedKmh: Value(newData.speedKmh),
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
    );
  }

  void _cleanupSubscriptions() {
    print('[MapProvider] Cleaning up subscriptions...');

    _positionSubscription?.cancel();
    _positionSubscription = null;

    _durationTimer?.cancel();
    _durationTimer = null;

    _stopwatch.stop();
  }

  /// Clear session (untuk logout handler)
  Future<void> clearPersistentSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('ongoing_hike_id');
    await prefs.remove('ongoing_hike_paused');
    _cleanupSubscriptions();
    state = MapTrackingState.initial();
    print('[MapProvider] Persistent session cleared');
  }

  Future<void> discardPausedSession() async {
    print('[MapProvider] Membuang sesi yang dijeda...');
    final prefs = await SharedPreferences.getInstance();
    final persistedHikeId = prefs.getInt('ongoing_hike_id');

    if (persistedHikeId != null) {
      // 1. Hapus data dari database
      final hikeDao = ref.read(hikeDaoProvider);
      await hikeDao.hardDeleteHike(persistedHikeId);
      print(
        '[MapProvider] Data Hike ID: $persistedHikeId telah di-hard-delete.',
      );

      // 2. Hapus dari SharedPreferences
      await prefs.remove('ongoing_hike_id');
      await prefs.remove('ongoing_hike_paused');
    }

    // 3. Reset state provider
    _cleanupSubscriptions();
    _stopwatch.reset();
    state = MapTrackingState.initial();
    print('[MapProvider] Sesi berhasil dibuang dan state di-reset.');
  }

  Future<void> _calculateWaypointStats(int hikeId) async {
    final hikeDao = ref.read(hikeDaoProvider);
    final routePointDao = ref.read(routePointDaoProvider);
    final waypointDao = ref.read(hikeWaypointDaoProvider);

    // 1. Ambil data induk (Hike) untuk timestamp awal
    final Hike? hike = await hikeDao.getHikeById(hikeId);
    if (hike == null) {
      print('[StatCalculator] Hike not found, aborting.');
      return;
    }

    // 2. Ambil semua waypoint & route point, urutkan berdasarkan waktu
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

    // Filter elevasi yang sama persis seperti di _onNewPosition
    const GAIN_COMMIT_THRESHOLD = 1.5;
    const LOSS_RESET_THRESHOLD = 0.5;

    // 3. Iterasi melalui setiap waypoint
    for (final waypoint in allWaypoints) {
      // Ambil "segmen" RoutePoint antara timestamp terakhir dan waypoint ini
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

        // Asumsi RoutePoint pertama di segmen adalah "lastPos"
        RoutePoint? lastSegPos;

        // Cari RoutePoint valid pertama sebelum segmen ini untuk perbandingan awal
        final lastPosBeforeSegment = allRoutePoints.lastWhere(
          (p) => !p.timestamp.isAfter(lastTimestamp),
          orElse: () => allRoutePoints.first, // fallback
        );
        lastSegPos = lastPosBeforeSegment;

        for (final currentSegPos in segmentRoutePoints) {
          // --- PERBAIKAN BUG ---
          // Hanya hitung jika kedua altitude ada (tidak null)
          if (lastSegPos != null &&
              currentSegPos.altitude != null &&
              lastSegPos.altitude != null) {
            // Sekarang aman menggunakan '!' (non-null assertion)
            final elevationDiff =
                currentSegPos.altitude! - lastSegPos.altitude!;
            if (elevationDiff > 0) {
              uncommittedGain += elevationDiff;
            } else if (elevationDiff < -LOSS_RESET_THRESHOLD) {
              // "Reset" ember jika terjadi penurunan
              if (uncommittedGain >= GAIN_COMMIT_THRESHOLD) {
                segmentGain += uncommittedGain;
              }
              uncommittedGain = 0.0;
              segmentLoss += elevationDiff.abs(); // Akumulasi penurunan
            }
          }
          // --- AKHIR PERBAIKAN ---
          lastSegPos = currentSegPos;
        }

        // Commit sisa "ember" di akhir segmen
        if (uncommittedGain >= GAIN_COMMIT_THRESHOLD) {
          segmentGain += uncommittedGain;
        }

        // Akumulasi total
        cumulativeGain += segmentGain;
        cumulativeLoss += segmentLoss;
      }

      // 4. Update waypoint di database dengan statistik kumulatif
      final companion = HikeWaypointsCompanion(
        id: Value(waypoint.id),
        elevationGainToHere: Value(cumulativeGain),
        elevationLossToHere: Value(cumulativeLoss),
      );
      await waypointDao.update(waypointDao.hikeWaypoints).replace(companion);

      print(
        '[StatCalculator] Waypoint ${waypoint.name}: Gain=${cumulativeGain.toStringAsFixed(1)}, Loss=${cumulativeLoss.toStringAsFixed(1)}',
      );

      // 5. Siapkan untuk iterasi berikutnya
      lastTimestamp = waypoint.timestamp;
    }
  }
}

@riverpod
SupabaseClient supabaseProvider(SupabaseProviderRef ref) {
  return Supabase.instance.client;
}

@riverpod
Stream<PositionData> positionStream(PositionStreamRef ref) {
  final gpsService = ref.watch(gpsServiceProvider);
  return gpsService.getPositionStream();
}

@riverpod
Future<PositionData?> currentGpsLocation(CurrentGpsLocationRef ref) async {
  final gpsService = ref.read(gpsServiceProvider);
  return gpsService.getCurrentLocation();
}
