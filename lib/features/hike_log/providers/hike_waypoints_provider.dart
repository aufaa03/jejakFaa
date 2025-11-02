import 'package:jejak_faa_new/data/local_db/database.dart';

import 'package:jejak_faa_new/data/local_db/database.dart';
import 'package:jejak_faa_new/data/local_db/database_providers.dart'; // (Asumsi 2)
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'hike_waypoints_provider.g.dart';

// Provider ini meng-query semua Waypoints (POI) untuk satu 'hikeId'
@riverpod
Stream<List<HikeWaypoint>> hikeWaypoints(HikeWaypointsRef ref, int localHikeId) {
  // ASUMSI 1: Anda sudah membuat 'hikeWaypointsDaoProvider'
  // ASUMSI 2: Anda sudah membuat method 'watchAllWaypointsForHike' di DAO
  final dao = ref.watch(hikeWaypointDaoProvider);
  
  // Ganti 'watchAllWaypointsForHike' jika nama method di DAO Anda berbeda
  return dao.watchAllWaypointsForHike(localHikeId);
}
