import 'package:flutter/foundation.dart';
import 'dart:math';

// ✅ Extension untuk konversi degree ke radian
extension NumExtension on num {
  double toRadians() => this * pi / 180.0;
}

@immutable
class WeatherData {
  final CurrentWeather current;
  final List<HourlyWeather> hourly;
  final List<DailyWeather> daily;

  const WeatherData({
    required this.current,
    required this.hourly,
    required this.daily,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    print('[WeatherData.fromJson] 🔍 Mulai parsing...');

    try {
      final List<dynamic> hourlyList = json['list'] as List<dynamic>? ?? [];
      print('[WeatherData.fromJson] 📊 Jumlah item dari API: ${hourlyList.length}');

      if (hourlyList.isEmpty) {
        throw Exception('Tidak ada data forecast dari API');
      }

      // 1. Parse hourly data
      final List<HourlyWeather> hourly = [];
      for (int i = 0; i < hourlyList.length; i++) {
        try {
          final HourlyWeather item = HourlyWeather.fromJson(
            hourlyList[i] as Map<String, dynamic>,
          );
          hourly.add(item);
        } catch (e) {
          print('[WeatherData.fromJson] ⚠️ Error parsing hourly[$i]: $e');
        }
      }

      print('[WeatherData.fromJson] ✅ Berhasil parse ${hourly.length} hourly items');

      if (hourly.isEmpty) {
        throw Exception('Tidak ada hourly data yang valid');
      }

      // 2. Current weather dari item pertama
      final CurrentWeather current = CurrentWeather.fromHourly(hourly.first);
      print('[WeatherData.fromJson] 🌡️ Current weather: ${current.temp}°C');

      // 3. Extract daily forecast
      final double lat =
          (json['city']?['coord']?['lat'] as num?)?.toDouble() ?? 0.0;
      final double lon =
          (json['city']?['coord']?['lon'] as num?)?.toDouble() ?? 0.0;

      final List<DailyWeather> daily = _extractDailyForecast(hourly, lat, lon);
      print('[WeatherData.fromJson] 📅 Berhasil extract ${daily.length} daily items');

      return WeatherData(
        current: current,
        hourly: hourly,
        daily: daily,
      );
    } catch (e) {
      print('[WeatherData.fromJson] ❌ CRITICAL Error: $e');
      rethrow;
    }
  }

  // Helper: Extract daily forecast
  static List<DailyWeather> _extractDailyForecast(
    List<HourlyWeather> hourly,
    double latitude,
    double longitude,
  ) {
    print('[_extractDailyForecast] 🔍 Extract dari ${hourly.length} data...');

    try {
      if (hourly.isEmpty) return [];

      final Map<String, List<HourlyWeather>> groupedByDay = {};

      for (final hour in hourly) {
        final dayKey =
            '${hour.time.year}-${hour.time.month.toString().padLeft(2, '0')}-${hour.time.day.toString().padLeft(2, '0')}';
        groupedByDay.putIfAbsent(dayKey, () => []);
        groupedByDay[dayKey]!.add(hour);
      }

      print('[_extractDailyForecast] 📅 Tergroup jadi ${groupedByDay.length} hari');

      final List<DailyWeather> result = [];

      for (final entry in groupedByDay.entries) {
        try {
          final dayHours = entry.value;
          if (dayHours.isEmpty) continue;

          // Min/Max temp
          double minTemp = dayHours[0].temp;
          double maxTemp = dayHours[0].temp;

          for (final h in dayHours) {
            if (h.temp < minTemp) minTemp = h.temp;
            if (h.temp > maxTemp) maxTemp = h.temp;
          }

          // Kondisi siang
          final middayIndex = dayHours.length ~/ 2;
          final noonCondition = dayHours[middayIndex];

          // POP (Probability of Precipitation)
          int popPercentage = 0;
          int rainCount = 0;
          for (final h in dayHours) {
            if (h.conditionMain.toLowerCase().contains('rain')) {
              rainCount++;
            }
          }
          if (rainCount > 0) {
            popPercentage = ((rainCount / dayHours.length) * 100).toInt();
          }

          final daily = DailyWeather(
            date: dayHours[0].time,
            tempMax: maxTemp,
            tempMin: minTemp,
            condition: noonCondition.conditionMain,
            iconCode: noonCondition.iconCode,
            popPercentage: popPercentage,
          );

          result.add(daily);
          print(
            '[_extractDailyForecast] ✅ ${entry.key}: ${minTemp.toStringAsFixed(0)}°C - ${maxTemp.toStringAsFixed(0)}°C',
          );
        } catch (e) {
          print('[_extractDailyForecast] ⚠️ Error: $e');
        }
      }

      print('[_extractDailyForecast] ✅ Total: ${result.length} days');
      return result;
    } catch (e) {
      print('[_extractDailyForecast] ❌ Error: $e');
      return [];
    }
  }
}

@immutable
class CurrentWeather {
  final double temp;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String conditionMain;
  final String conditionDescription;
  final String iconCode;
  final int pressure;
  final int visibility;
  final int uvIndex;
  final int clouds;
  final double dewPoint;
  final double windGust;
  final int windDeg;

  const CurrentWeather({
    required this.temp,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.conditionMain,
    required this.conditionDescription,
    required this.iconCode,
    this.pressure = 1013,
    this.visibility = 10000,
    this.uvIndex = 0,
    this.clouds = 0,
    this.dewPoint = 0.0,
    this.windGust = 0.0,
    this.windDeg = 0,
  });

  factory CurrentWeather.fromHourly(HourlyWeather hourly) {
    return CurrentWeather(
      temp: hourly.temp,
      feelsLike: hourly.feelsLike,
      humidity: hourly.humidity,
      windSpeed: hourly.windSpeed,
      conditionMain: hourly.conditionMain,
      conditionDescription: hourly.conditionDescription,
      iconCode: hourly.iconCode,
      pressure: hourly.pressure,
      visibility: hourly.visibility,
      clouds: hourly.clouds,
      windDeg: hourly.windDeg,
      uvIndex: 0,
      dewPoint: 0.0,
      windGust: 0.0,
    );
  }
}

@immutable
class HourlyWeather {
  final DateTime time;
  final double temp;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String iconCode;
  final String conditionMain;
  final String conditionDescription;
  final int pressure;
  final int visibility;
  final int clouds;
  final int windDeg;

  const HourlyWeather({
    required this.time,
    required this.temp,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.iconCode,
    required this.conditionMain,
    required this.conditionDescription,
    required this.pressure,
    required this.visibility,
    required this.clouds,
    required this.windDeg,
  });

  factory HourlyWeather.fromJson(Map<String, dynamic> json) {
    try {
      final weatherList = json['weather'] as List?;
      if (weatherList == null || weatherList.isEmpty) {
        throw Exception('weather array is empty');
      }

      final weatherInfo = weatherList[0] as Map<String, dynamic>;
      final mainInfo = json['main'] as Map<String, dynamic>?;
      final windInfo = json['wind'] as Map<String, dynamic>?;
      final cloudsInfo = json['clouds'] as Map<String, dynamic>?;

      if (mainInfo == null) throw Exception('main info is null');

      return HourlyWeather(
        time: DateTime.fromMillisecondsSinceEpoch(
          (((json['dt'] as num?) ?? 0).toInt()) * 1000,
          isUtc: true,
        ),
        temp: ((mainInfo['temp'] as num?) ?? 0.0).toDouble(),
        feelsLike: ((mainInfo['feels_like'] as num?) ?? 0.0).toDouble(),
        humidity: ((mainInfo['humidity'] as num?) ?? 0).toInt(),
        windSpeed: ((windInfo?['speed'] as num?) ?? 0.0).toDouble(),
        iconCode: (weatherInfo['icon'] as String?) ?? '01d',
        conditionMain: (weatherInfo['main'] as String?) ?? 'Unknown',
        conditionDescription: (weatherInfo['description'] as String?) ?? 'N/A',
        pressure: ((mainInfo['pressure'] as num?) ?? 1013).toInt(),
        visibility: (((json['visibility'] as num?) ?? 10000).toInt()),
        clouds: ((cloudsInfo?['all'] as num?) ?? 0).toInt(),
        windDeg: ((windInfo?['deg'] as num?) ?? 0).toInt(),
      );
    } catch (e) {
      print('[HourlyWeather.fromJson] ⚠️ Error: $e');
      rethrow;
    }
  }
}

@immutable
class DailyWeather {
  final DateTime date;
  final double tempMax;
  final double tempMin;
  final String condition;
  final String iconCode;
  final int popPercentage;

  const DailyWeather({
    required this.date,
    required this.tempMax,
    required this.tempMin,
    required this.condition,
    required this.iconCode,
    required this.popPercentage,
  });
}