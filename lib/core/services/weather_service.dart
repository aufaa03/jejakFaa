// Salin dan tempel kode ini ke lib/core/services/weather_service.dart

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jejak_faa_new/data/models/weather_model.dart'; // Import model kita

class WeatherService {
  final Dio _dio;
  final String _apiKey;

  WeatherService(this._dio)
      : _apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '' {
    if (_apiKey.isEmpty) {
      print(
        'KESALAHAN: OPENWEATHER_API_KEY tidak ditemukan di file .env',
      );
    }
  }

  /// Mengambil data cuaca lengkap (Current & Hourly) dari One Call API
  Future<WeatherData> getWeatherData(double lat, double lon) async {
    if (_apiKey.isEmpty) {
      throw Exception('API Key OpenWeatherMap tidak dikonfigurasi.');
    }

    // Ini adalah URL untuk One Call API v3.0
    // - 'exclude' untuk membuang data yang tidak kita perlukan
    // - 'units=metric' untuk mendapatkan suhu dalam Celcius
    // - 'lang=id' untuk mendapatkan deskripsi dalam Bahasa Indonesia
    final String url =
        'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=id';

    try {
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        // Jika berhasil, kita 'decode' JSON
        // dan berikan ke 'factory constructor' model kita
        return WeatherData.fromJson(response.data as Map<String, dynamic>);
      } else {
        // Jika server merespons tapi dengan error (misal: 404, 500)
        throw Exception(
          'Gagal memuat data cuaca (Status Code: ${response.statusCode})',
        );
      }
    } on DioException catch (e) {
      // Menangani error koneksi (misal: tidak ada internet, DNS lookup gagal)
      throw Exception('Gagal memuat data cuaca: ${e.message}');
    } catch (e) {
      // Menangani error lainnya (misal: parsing JSON gagal)
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }

  // Helper kecil untuk mendapatkan URL ikon cuaca dari OWM
  String getIconUrl(String iconCode) {
    // '@2x.png' untuk gambar resolusi tinggi
    return 'https://openweathermap.org/img/wn/$iconCode@2x.png'; 
  }
}