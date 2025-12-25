import 'dart:async';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:geolocator/geolocator.dart';
import 'package:jejak_faa_new/data/models/location_models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:geolocator_android/geolocator_android.dart';
import 'package:geolocator_apple/geolocator_apple.dart';
import 'package:permission_handler/permission_handler.dart';

part 'gps_service.g.dart';

LocationSettings getGpsLocationSettings() {
  LocationSettings locationSettings;

  if (defaultTargetPlatform == TargetPlatform.android) {
    locationSettings = AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
      intervalDuration: const Duration(seconds: 5),
    );
  } else if (defaultTargetPlatform == TargetPlatform.iOS) {
    locationSettings = AppleSettings(
      accuracy: LocationAccuracy.best,
      activityType: ActivityType.fitness,
      distanceFilter: 5,
      showBackgroundLocationIndicator: true,
    );
  } else {
    locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );
  }
  return locationSettings;
}

class GpsService {
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("[GpsService] Layanan lokasi nonaktif.");
      return false;
    }
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
    if (defaultTargetPlatform == TargetPlatform.android) {
      final PermissionStatus notificationStatus = await Permission.notification
          .request();
      if (notificationStatus.isDenied ||
          notificationStatus.isPermanentlyDenied) {
        print("[GpsService] Izin notifikasi ditolak.");
      }
    }
    return true;
  }

  Future<PositionData?> getCurrentLocation() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return null;
    try {
      print('[GpsService] Requesting initial position...');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print(
        '[GpsService] Got initial position: ${position.latitude}, ${position.longitude}',
      );
      return PositionData.fromGeolocatorPosition(position);
    } catch (e) {
      print("[GpsService] Error mendapat lokasi: $e");
      return null;
    }
  }

  Stream<PositionData> getPositionStream() async* {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) {
      yield* Stream.error(Exception("Izin lokasi tidak diberikan."));
      return;
    }

    final locationSettings = getGpsLocationSettings();

    try {
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

@riverpod
GpsService gpsService(GpsServiceRef ref) {
  return GpsService();
}

@riverpod
Stream<PositionData> gpsPosition(GpsPositionRef ref) {
  final gpsService = ref.watch(gpsServiceProvider);
  return gpsService.getPositionStream();
}

@riverpod
Future<PositionData?> currentGpsLocation(CurrentGpsLocationRef ref) async {
  final gpsService = ref.read(gpsServiceProvider);
  return gpsService.getCurrentLocation();
}
