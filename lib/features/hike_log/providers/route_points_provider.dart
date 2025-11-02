import 'package:jejak_faa_new/data/local_db/daos/route_point_dao.dart';
import 'package:jejak_faa_new/data/local_db/database.dart';
import 'package:jejak_faa_new/data/local_db/database_providers.dart'; // (Asumsi 2)
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'route_points_provider.g.dart';

// Provider ini meng-query semua titik rute untuk satu 'hikeId'
@riverpod
Stream<List<RoutePoint>> routePoints(RoutePointsRef ref, int localHikeId) {
  // ASUMSI 1: Anda sudah membuat 'routePointsDaoProvider'
  // ASUMSI 2: Anda sudah membuat method 'watchAllRoutePointsForHike' di DAO
  final dao = ref.watch(routePointDaoProvider);
  
  // Ganti 'watchAllRoutePointsForHike' jika nama method di DAO Anda berbeda
  return dao.watchAllRoutePointsForHike(localHikeId);
}