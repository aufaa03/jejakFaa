import 'package:jejak_faa_new/data/local_db/database.dart';
import 'package:jejak_faa_new/data/local_db/database_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'hike_list_provider.g.dart';

// Provider ini akan "memancarkan" (stream) daftar Hike
// dari database lokal (Drift) secara real-time.
// Dia otomatis hanya mengambil data yang 'isDeleted == false'.
@riverpod
Stream<List<Hike>> hikeListStream(HikeListStreamRef ref) {
  // Ambil DAO dari provider-nya
  final dao = ref.watch(hikeDaoProvider);
  // Panggil method watchAllHikes() yang sudah kita buat
  return dao.watchAllHikes();
}