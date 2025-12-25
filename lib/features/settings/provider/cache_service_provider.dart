// Salin ke: lib/features/settings/providers/cache_service_provider.dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jejak_faa_new/main.dart'; // <-- Impor 'globalCacheStore'
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cache_service_provider.g.dart';

// Helper untuk mendapatkan direktori cache
Future<Directory> _getCacheDirectory() async {
  final dir = await getTemporaryDirectory();
  final cachePath = '${dir.path}${Platform.pathSeparator}MapTiles';
  return Directory(cachePath);
}

// Helper untuk menghitung ukuran cache
Future<int> _calculateCacheSize() async {
  final cacheDir = await _getCacheDirectory();
  int totalSize = 0;

  if (await cacheDir.exists()) {
    try {
      // Loop semua file di dalam direktori cache secara rekursif
      await for (final entity in cacheDir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          totalSize += await entity.length(); // Tambahkan ukuran file
        }
      }
    } catch (e) {
      print('Gagal menghitung cache: $e');
      return 0; // Kembalikan 0 jika ada error
    }
  }
  return totalSize;
}

// 1. Definisikan Notifier
@riverpod
class CacheService extends _$CacheService {
  // 2. 'build' akan mengambil data awal (ukuran cache saat ini)
  @override
  Future<int> build() async {
    return _calculateCacheSize();
  }

  // 3. Method untuk menghapus cache
  Future<void> clearCache() async {
    // Tampilkan loading di UI
    state = const AsyncValue.loading();

    try {
      // 1. Ambil direktori cache (dari helper kita)
      final cacheDir = await _getCacheDirectory();

      // 2. Hapus folder cache-nya jika ada
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        print('[CacheService] Folder cache dihapus.');
      }

      // 3. BUAT LAGI folder-nya agar siap dipakai
      //    (Sangat penting agar aplikasi tidak error saat nulis cache baru)
      await cacheDir.create(recursive: true);
      
      // 4. Update state ke 0
      state = const AsyncValue.data(0);

    } catch (e, stackTrace) {
      // Jika error, kirim error-nya ke UI
      print('Gagal hapus cache: $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// Helper untuk format bytes (Contoh: 1048576 -> "1 MB")
String formatBytes(int bytes, {int decimals = 2}) {
  if (bytes <= 0) return "0 B";
  const suffixes = ["B", "KB", "MB", "GB", "TB"];
  var i = (bytes.toString().length - 1) ~/ 3;
  return '${(bytes / (1 << (i * 10))).toStringAsFixed(decimals)} ${suffixes[i]}';
}