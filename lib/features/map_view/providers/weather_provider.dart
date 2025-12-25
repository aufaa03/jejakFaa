// Salin dan tempel ke file: lib/features/map_view/providers/weather_provider.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jejak_faa_new/core/services/weather_service.dart';
import 'package:jejak_faa_new/data/local_db/database_providers.dart';
import 'package:jejak_faa_new/data/models/weather_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'weather_provider.g.dart';

// State untuk menyimpan data cuaca DAN kapan terakhir diambil
class WeatherCache {
  final WeatherData? data;
  final DateTime? lastFetched;

  WeatherCache({this.data, this.lastFetched});

  // Cek apakah cache masih valid (kurang dari 15 menit)
  bool get isValid {
    if (lastFetched == null) return false;
    return DateTime.now().difference(lastFetched!).inMinutes < 15;
  }
}

@riverpod
class Weather extends _$Weather {
  @override
  WeatherCache build() {
    // State awal, tidak ada data, belum pernah diambil
    return WeatherCache(data: null, lastFetched: null);
  }

  /// Fungsi utama yang akan dipanggil oleh UI (MapProvider)
  /// Fungsi ini akan mengembalikan data cuaca saat ini (untuk snapshot)
  /// dan juga memperbarui state provider (untuk widget live)
  Future<CurrentWeather?> fetchWeather(double lat, double lon) async {
    // 1. Cek Cache
    // Jika cache masih valid (kurang dari 15 menit),
    // kita gunakan data lama dan tidak perlu panggil API.
    if (state.isValid) {
      print('[WeatherProvider] Menggunakan data cuaca dari cache.');
      return state.data?.current;
    }

    print('[WeatherProvider] Mengambil data cuaca baru dari API...');
    // Set state ke loading
    state = WeatherCache(data: state.data, lastFetched: state.lastFetched);
    
    try {
      // 2. Ambil data dari Service
      final weatherService = ref.read(weatherServiceProvider);
      final weatherData = await weatherService.getWeatherData(lat, lon);

      // 3. Simpan data baru ke state
      state = WeatherCache(data: weatherData, lastFetched: DateTime.now());
      print('[WeatherProvider] Data cuaca baru berhasil diambil.');
      
      // 4. Kembalikan data 'current' untuk snapshot
      return weatherData.current;

    } catch (e) {
      print('[WeatherProvider] Gagal mengambil data cuaca: $e');
      // Set state ke error
      state = WeatherCache(data: null, lastFetched: null); // Reset cache jika error
      return null;
    }
  }

  /// Helper untuk mendapatkan URL ikon
  String? getIconUrl(String iconCode) {
    if (iconCode.isEmpty) return null;
    return ref.read(weatherServiceProvider).getIconUrl(iconCode);
  }
}