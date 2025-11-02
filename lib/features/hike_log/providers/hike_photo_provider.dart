import 'package:jejak_faa_new/data/local_db/database.dart';
import 'package:jejak_faa_new/data/local_db/database_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'hike_photo_provider.g.dart';

// Provider ini akan "memancarkan" (stream) daftar Foto
// untuk 1 'hikeId' lokal yang spesifik.
@riverpod
Stream<List<HikePhoto>> hikePhotos(HikePhotosRef ref, int localHikeId) {
  // Ambil DAO foto
  final dao = ref.watch(appDatabaseProvider).hikePhotoDao;
  // Panggil method 'watchPhotosForHike' yang sudah kita buat
  return dao.watchPhotosForHike(localHikeId);
}
