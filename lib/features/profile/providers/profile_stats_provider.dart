// Salin ke: lib/features/profile/providers/profile_stats_provider.dart
import 'dart:math';
import 'package:jejak_faa_new/data/local_db/database.dart';
import 'package:jejak_faa_new/data/local_db/database_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_stats_provider.g.dart';

// 1. Data Class untuk menampung hasil kalkulasi
class ProfileStats {
  final int totalHikes;
  final double totalDistanceKm;
  final double totalElevationGainM;
  final int totalDurationSeconds;

  // Rekor Terbaik
  final Hike? longestHike;
  final Hike? highestClimbHike;
  final Hike? longestDurationHike;

  ProfileStats({
    this.totalHikes = 0,
    this.totalDistanceKm = 0.0,
    this.totalElevationGainM = 0.0,
    this.totalDurationSeconds = 0,
    this.longestHike,
    this.highestClimbHike,
    this.longestDurationHike,
  });
}

// 2. Provider-nya
@riverpod
Stream<ProfileStats> profileStats(ProfileStatsRef ref) {
  // Ambil DAO (Data Access Object) untuk tabel Hikes
  final hikeDao = ref.watch(hikeDaoProvider);
  
  // Tonton (watch) semua data 'hikes'
  final hikesStream = hikeDao.watchAllHikes();

  // 'map' (ubah) stream dari List<Hike> menjadi ProfileStats
  return hikesStream.map((hikes) {
    if (hikes.isEmpty) {
      return ProfileStats(); // Kembalikan data kosong
    }

    double totalDistance = 0;
    double totalElevation = 0;
    int totalDuration = 0;

    Hike? longestHike;
    Hike? highestClimbHike;
    Hike? longestDurationHike;

    double maxDistance = 0;
    double maxElevation = 0;
    int maxDuration = 0;

    for (final hike in hikes) {
      // Hitung Total (untuk Beranda)
      totalDistance += hike.totalDistanceKm ?? 0;
      totalElevation += hike.totalElevationGainMeters ?? 0;
      totalDuration += hike.durationSeconds ?? 0;

      // --- Cari Rekor Terbaik (untuk Profil) ---
      
      // 1. Cek Jarak Terpanjang
      if ((hike.totalDistanceKm ?? 0) > maxDistance) {
        maxDistance = hike.totalDistanceKm!;
        longestHike = hike;
      }

      // 2. Cek Tanjakan Tertinggi
      if ((hike.totalElevationGainMeters ?? 0) > maxElevation) {
        maxElevation = hike.totalElevationGainMeters!;
        highestClimbHike = hike;
      }

      // 3. Cek Durasi Terlama
      if ((hike.durationSeconds ?? 0) > maxDuration) {
        maxDuration = hike.durationSeconds!;
        longestDurationHike = hike;
      }
    }

    // Kembalikan hasilnya
    return ProfileStats(
      totalHikes: hikes.length,
      totalDistanceKm: totalDistance,
      totalElevationGainM: totalElevation,
      totalDurationSeconds: totalDuration,
      longestHike: longestHike,
      highestClimbHike: highestClimbHike,
      longestDurationHike: longestDurationHike,
    );
  });
}