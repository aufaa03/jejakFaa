import 'dart:async';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:geolocator/geolocator.dart';
import 'package:jejak_faa_new/data/models/location_models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:geolocator_android/geolocator_android.dart';
import 'package:geolocator_apple/geolocator_apple.dart';

part 'gps_service.g.dart';

/// Service GPS - Tracking akurat seperti Strava
class GpsService {
  
  /// Meminta dan memvalidasi izin lokasi dari pengguna.
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Cek apakah layanan lokasi HP aktif
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("[GpsService] Layanan lokasi nonaktif.");
      return false;
    }

    // 2. Cek izin aplikasi
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("[GpsService] Izin lokasi ditolak.");
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      print("[GpsService] Izin lokasi ditolak permanen.");
      return false;
    }

    return true;
  }

  /// Mendapatkan satu kali lokasi saat ini (untuk inisial peta).
  Future<PositionData?> getCurrentLocation() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return null;

    try {
      print('[GpsService] Requesting initial position...');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print('[GpsService] Got initial position: ${position.latitude}, ${position.longitude}');
      return PositionData.fromGeolocatorPosition(position);
    } catch (e) {
      print("[GpsService] Error mendapat lokasi: $e");
      return null;
    }
  }

  /// Mendapatkan STREAM lokasi (untuk pelacakan live real-time).
  Stream<PositionData> getPositionStream() async* {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) {
      yield* Stream.error(Exception("Izin lokasi tidak diberikan."));
      return;
    }

    LocationSettings locationSettings;

    // --- SETUP PLATFORM-SPECIFIC ---
    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1, // Update jika bergerak 1 meter
        intervalDuration: const Duration(seconds: 1), // ATAU setiap 1 detik
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: "Jejak FAA",
          notificationText: "Pelacakan sedang berlangsung...",
          notificationChannelName: "Jejak FAA Location",
          enableWakeLock: true, 
          setOngoing: true, 
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.best,
        activityType: ActivityType.fitness,
        distanceFilter: 1,
        showBackgroundLocationIndicator: true, 
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1,
      );
    }

    try {
      // (Menghapus 'getCurrentLocation' dari sini, biarkan provider 'currentGpsLocation' menanganinya)
      print('[GpsService] Starting position stream...');
      await for (final position in Geolocator.getPositionStream(
        locationSettings: locationSettings,
      )) {
        yield PositionData.fromGeolocatorPosition(position);
      }
    } catch (e) {
      print('[GpsService] Error in position stream: $e');
      yield* Stream.error(e);
    }
  }
}

// --- Riverpod Providers ---

/// Provider untuk GpsService (singleton)
@riverpod
GpsService gpsService(GpsServiceRef ref) {
  return GpsService();
}

/// Provider untuk stream lokasi real-time
/// (Nama ini dipanggil oleh map_provider.dart)
@riverpod
Stream<PositionData> gpsPosition(GpsPositionRef ref) {
  final gpsService = ref.watch(gpsServiceProvider);
  return gpsService.getPositionStream();
}

/// Provider untuk mendapatkan lokasi satu kali (inisial peta)
/// (Nama ini dipanggil oleh map_page.dart)
@riverpod
Future<PositionData?> currentGpsLocation(CurrentGpsLocationRef ref) async {
  final gpsService = ref.read(gpsServiceProvider);
  return gpsService.getCurrentLocation();
}

