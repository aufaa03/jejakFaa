import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jejak_faa_new/data/local_db/database.dart'; // <-- Import class 'Hike'
import 'package:jejak_faa_new/data/local_db/database_providers.dart'; // <-- Import DAO

// Ini adalah StreamProvider
// Dia akan "nonton" stream dari DAO
final hikeListStreamProvider = StreamProvider<List<Hike>>((ref) {
  // Tonton DAO
  final dao = ref.watch(hikeDaoProvider);
  // Panggil fungsi stream 'watchAllHikes'
  return dao.watchAllHikes();
});
