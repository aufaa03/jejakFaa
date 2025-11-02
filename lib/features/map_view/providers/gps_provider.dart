import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:jejak_faa_new/core/services/gps_service.dart';
import 'package:jejak_faa_new/data/models/location_models.dart';
import 'package:jejak_faa_new/features/map_view/providers/map_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'gps_provider.g.dart';

/// Provider untuk stream lokasi GPS real-time
@riverpod
Stream<PositionData> gpsPosition(GpsPositionRef ref) {
  // PERBAIKAN 1: Gunakan ref.read() untuk mendapat singleton GpsService
  final gpsService = ref.read(gpsServiceProvider);
  
  // PERBAIKAN 2: Return stream dari GpsService
  return gpsService.getPositionStream();
}

/// Provider untuk mendapatkan lokasi SATU KALI (snapshot)
/// Berguna untuk inisial map saat halaman dibuka
