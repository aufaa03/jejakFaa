// Salin ke: lib/core/services/background_tracker.dart
import 'dart:async';
import 'dart:ui';
import 'package:drift/drift.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jejak_faa_new/core/services/gps_service.dart';
import 'package:jejak_faa_new/data/local_db/database.dart';
import 'package:jejak_faa_new/data/local_db/daos/hike_dao.dart';
import 'package:jejak_faa_new/data/local_db/daos/route_point_dao.dart';
import 'package:jejak_faa_new/data/models/location_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

StreamSubscription<Position>? _gpsSubscription;
late AppDatabase _db;
late SharedPreferences _prefs;
bool _isTracking = false;

// --- STATE YANG DIKELOLA SERVICE ---
int _currentHikeId = 0;
DateTime? _sessionStartTime; 
int _sessionInitialDuration = 0; // Durasi yang sudah terkumpul (dari pause)
double _liveDistanceMeters = 0.0;
PositionData? _lastGpsPosition;
// --- AKHIR STATE ---

String _formatDuration(int totalSeconds) {
  final duration = Duration(seconds: totalSeconds);
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (hours > 0) return '$hours:$minutes:$seconds';
  return '$minutes:$seconds';
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  print('[BackgroundService] ===== SERVICE DIMULAI =====');
  DartPluginRegistrant.ensureInitialized();
  _db = AppDatabase();
  _prefs = await SharedPreferences.getInstance();

  // --- LOGIKA PEMULIHAN CRASH (FIX BUG RELOG) ---
  final String? existingStatus = _prefs.getString('tracking_status');
  final int? existingHikeId = _prefs.getInt('ongoing_hike_id');
  
  if (existingStatus == 'tracking' && existingHikeId != null) {
    print('[BackgroundService] ⚠️ Memulihkan dari CRASH. Melanjutkan tracking...');
    // Langsung mulai ulang tracking, jangan tunggu perintah UI
    await _startGpsTracking(existingHikeId);
  }
  // --- AKHIR PEMULIHAN ---

  // Polling untuk perintah dari UI (Start/Pause) dan update notifikasi
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    try {
      await _prefs.reload();
      
      // 'tracking_command' adalah perintah sekali jalan dari UI
      final String? command = _prefs.getString('tracking_command');
      
      if (command == 'START') {
        final int? hikeId = _prefs.getInt('ongoing_hike_id');
        if (hikeId != null && !_isTracking) {
          print('[BackgroundService] 📨 Perintah: START (Hike $hikeId)');
          await _startGpsTracking(hikeId);
        }
        await _prefs.remove('tracking_command'); // Selesaikan perintah
      } 
      else if (command == 'PAUSE' || command == 'STOP') {
        if (_isTracking) {
          print('[BackgroundService] 📨 Perintah: $command');
          await _stopGpsTracking(command == 'STOP');
        }
        await _prefs.remove('tracking_command'); // Selesaikan perintah
      }

      // Jika sedang tracking, update notifikasi & "Buku Log" (Prefs)
      if (_isTracking) {
        if (_sessionStartTime == null) return;

        // 1. Hitung Durasi
        final elapsed = DateTime.now().difference(_sessionStartTime!);
        final int totalDurationInSeconds = _sessionInitialDuration + elapsed.inSeconds;

        // 2. TULIS Data Live ke Prefs (agar UI bisa baca)
        await _prefs.setInt('live_duration_seconds', totalDurationInSeconds);
        await _prefs.setDouble('live_distance_meters', _liveDistanceMeters);
        
        // 3. Simpan durasi ke DB (setiap 15 detik)
        if (elapsed.inSeconds > 0 && elapsed.inSeconds % 15 == 0) {
          await _db.hikeDao.updateLiveDuration(_currentHikeId, totalDurationInSeconds);
        }

        // 4. Update Notifikasi
        final String durationStr = _formatDuration(totalDurationInSeconds);
        final String distanceStr = (_liveDistanceMeters / 1000.0).toStringAsFixed(2);
        service.invoke('updateNotification', {
          'title': 'Jejak Faa Sedang Merekam',
          'content': '$durationStr  -  ${distanceStr} km',
        });
      }
    } catch (e) {
      print('[BackgroundService] ❌ Polling error: $e');
    }
  });
}

Future<void> _startGpsTracking(int hikeId) async {
  if (_isTracking) return;
  print('[BackgroundService] 🌍 Memulai GPS untuk hike $hikeId');
  
  try {
    _currentHikeId = hikeId;

    // 1. Baca durasi awal dari DB (sumber kebenaran)
    // final hike = await _db.hikeDao.getHikeById(hikeId);
    // _sessionInitialDuration = hike?.durationSeconds ?? 0;
    _sessionInitialDuration = _prefs.getInt('live_duration_seconds') ?? 0;
    _sessionStartTime = DateTime.now();

    // 2. Hitung ulang Jarak & Posisi Terakhir dari DB (FIX BUG JALUR LURUS)
    final allPoints = await _db.routePointDao.getRoutePointsForHike(hikeId);
    _liveDistanceMeters = 0.0;
    _lastGpsPosition = null;

    if (allPoints.isNotEmpty) {
      for (final point in allPoints) {
        final currentPointData = PositionData(
          latitude: point.latitude,
          longitude: point.longitude,
          altitude: point.altitude ?? 0.0,
          speedKmh: point.speedKmh ?? 0.0,
          timestamp: point.timestamp,
        );
        if (_lastGpsPosition != null) {
          _liveDistanceMeters += Geolocator.distanceBetween(
            _lastGpsPosition!.latitude, _lastGpsPosition!.longitude,
            currentPointData.latitude, currentPointData.longitude,
          );
        }
        _lastGpsPosition = currentPointData;
      }
      print('[BackgroundService] Sesi dilanjutkan dari ${_liveDistanceMeters.toStringAsFixed(2)} m');
    } else {
      print('[BackgroundService] Sesi baru dimulai dari 0 m');
    }
    
    // 3. Mulai GPS Stream (Pakai setting hemat baterai)
    await _gpsSubscription?.cancel();
    final locationSettings = getGpsLocationSettings();
    
    _gpsSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) async {
        try {
          final data = PositionData.fromGeolocatorPosition(position);
          
          if (_lastGpsPosition != null) {
            if (position.accuracy > 40) return; // Filter akurasi buruk
            final distanceDelta = Geolocator.distanceBetween(
              _lastGpsPosition!.latitude, _lastGpsPosition!.longitude,
              data.latitude, data.longitude,
            );
            
            final timeDelta = data.timestamp.difference(_lastGpsPosition!.timestamp).inSeconds;
            // Filter "GPS Jump" (misal > 50 m/detik atau 180 km/j)
            if (timeDelta > 0 && (distanceDelta / timeDelta) > 50) return; 
            
            _liveDistanceMeters += distanceDelta; // Tambahkan ke total
          }
          _lastGpsPosition = data; // Simpan untuk perhitungan berikutnya
          
          // Simpan ke DB
          final routeCompanion = RoutePointsCompanion(
            hikeId: Value(hikeId),
            latitude: Value(data.latitude),
            longitude: Value(data.longitude),
            altitude: Value(data.altitude),
            speedKmh: Value(data.speedKmh), // 'speedKmh' (bukan speedKMh)
            timestamp: Value(data.timestamp),
          );
          await _db.routePointDao.insertRoutePoint(routeCompanion);
          
        } catch (e) {
          print('[BackgroundService] ❌ Error simpan DB: $e');
        }
      },
      onError: (error) {
        print('[BackgroundService] ❌ GPS Stream Error: $error');
        _isTracking = false; // GPS mati, hentikan tracking
        _prefs.setString('tracking_status', 'paused'); // Set status ke jeda
      },
    );

    _isTracking = true;
    await _prefs.setString('tracking_status', 'tracking'); // Simpan status
    print('[BackgroundService] ✅ GPS mendengarkan');

  } catch (e) {
    print('[BackgroundService] ❌ Start GPS error: $e');
    _isTracking = false;
  }
}

Future<void> _stopGpsTracking(bool isStopping) async {
  print('[BackgroundService] ⏹️ Menghentikan GPS');
  await _gpsSubscription?.cancel();
  _gpsSubscription = null;
  _isTracking = false;

  if (_sessionStartTime == null) {
    // Jika service di-stop bahkan sebelum _sessionStartTime di-set
    print('[BackgroundService] ⏹️ Dihentikan sebelum sesi dimulai.');
  } else {
    // Jika di-pause, simpan durasi terakhir.
    final elapsed = DateTime.now().difference(_sessionStartTime!);
    final totalDurationInSeconds = _sessionInitialDuration + elapsed.inSeconds;
    await _db.hikeDao.updateLiveDuration(_currentHikeId, totalDurationInSeconds);
  }

  if (!isStopping) {
    await _prefs.setString('tracking_status', 'paused'); // Simpan status 'paused'
  } else {
    // Jika 'STOP' (selesai), hapus semua status
    await _prefs.remove('tracking_status');
    await _prefs.remove('live_duration_seconds');
    await _prefs.remove('live_distance_meters');
    await _prefs.remove('ongoing_hike_id');
  }

  // Reset state
  _sessionStartTime = null;
  _sessionInitialDuration = 0;
  _liveDistanceMeters = 0.0;
  _lastGpsPosition = null;
  _currentHikeId = 0;
  
  print('[BackgroundService] ✅ GPS dihentikan');
}