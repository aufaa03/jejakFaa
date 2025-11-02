import 'package:flutter/foundation.dart';
// Anda perlu menambahkan 'geolocator' ke pubspec.yaml jika belum
// flutter pub add geolocator
import 'package:geolocator/geolocator.dart';

/// Model data bersih (DTO) untuk membawa data posisi GPS
/// dari GpsService ke MapProvider dan UI.
@immutable
class PositionData {
  const PositionData({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.speedKmh,
    required this.timestamp,
  });

  final double latitude;
  final double longitude;
  final double altitude; // Ketinggian (untuk elevasi)
  final double speedKmh; // Kecepatan (km/jam)
  final DateTime timestamp;

  /// Factory constructor untuk konversi dari 'Position' (Geolocator)
  /// ke 'PositionData' (model bersih kita)
  factory PositionData.fromGeolocatorPosition(Position position) {
    return PositionData(
      latitude: position.latitude,
      longitude: position.longitude,
      altitude: position.altitude,
      // Konversi m/s (dari geolocator) ke km/jam
      speedKmh: position.speed * 3.6, 
      timestamp: position.timestamp ?? DateTime.now(),
    );
  }
}
