import 'package:jejak_faa_new/data/local_db/database.dart';
import 'package:jejak_faa_new/data/local_db/database_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'gallery_provider.g.dart';

// Provider ini akan 'memancarkan' (stream) SEMUA foto
// dari database lokal (Drift) secara real-time.
@riverpod
Stream<List<HikePhoto>> allPhotos(AllPhotosRef ref) {
  // Ambil DAO foto
  final dao = ref.watch(hikePhotoDaoProvider);
  // Panggil method 'watchAllPhotos' yang baru kita buat
  return dao.watchAllPhotos();
}
