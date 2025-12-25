// Salin ke: lib/features/profile/providers/mountain_stats_provider.dart
import 'package:jejak_faa_new/data/local_db/database.dart';
import 'package:jejak_faa_new/data/local_db/database_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mountain_stats_provider.g.dart';

// 1. Data Class untuk menampung hasil kalkulasi
class MountainStat {
  final String mountainName;
  final int hikeCount;
  final double totalDistanceKm;

  MountainStat({
    required this.mountainName,
    required this.hikeCount,
    required this.totalDistanceKm,
  });
}

// 2. Provider-nya
@riverpod
Stream<List<MountainStat>> mountainStats(MountainStatsRef ref) {
  final hikeDao = ref.watch(hikeDaoProvider);
  
  // Tonton (watch) semua data 'hikes'
  final hikesStream = hikeDao.watchAllHikes();

  // 'map' (ubah) stream dari List<Hike> menjadi List<MountainStat>
  return hikesStream.map((hikes) {
    if (hikes.isEmpty) {
      return []; // Kembalikan list kosong
    }

    // Gunakan Map untuk mengelompokkan data
    final Map<String, MountainStat> statsMap = {};

    for (final hike in hikes) {
      final name = hike.mountainName;
      
      // Cek apakah gunung ini sudah ada di map
      if (statsMap.containsKey(name)) {
        // Jika ya, tambahkan datanya
        final existingStat = statsMap[name]!;
        statsMap[name] = MountainStat(
          mountainName: name,
          hikeCount: existingStat.hikeCount + 1,
          totalDistanceKm: existingStat.totalDistanceKm + (hike.totalDistanceKm ?? 0),
        );
      } else {
        // Jika belum, buat entri baru
        statsMap[name] = MountainStat(
          mountainName: name,
          hikeCount: 1,
          totalDistanceKm: hike.totalDistanceKm ?? 0,
        );
      }
    }

    // Ubah Map menjadi List
    final statsList = statsMap.values.toList();

    // Urutkan list berdasarkan 'hikeCount' (paling banyak didaki)
    statsList.sort((a, b) => b.hikeCount.compareTo(a.hikeCount));

    return statsList;
  });
}