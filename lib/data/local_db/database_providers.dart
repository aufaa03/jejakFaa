import 'package:jejak_faa_new/data/local_db/daos/hike_dao.dart';
import 'package:jejak_faa_new/data/local_db/daos/hike_photo_dao.dart';
import 'package:jejak_faa_new/data/local_db/database.dart';
import 'package:jejak_faa_new/data/repositories/sync_repository_impl.dart';
import 'package:jejak_faa_new/domain/repositories/sync_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jejak_faa_new/data/local_db/daos/hike_waypoint_dao.dart';
import 'package:jejak_faa_new/data/local_db/daos/route_point_dao.dart';
import 'package:jejak_faa_new/core/services/weather_service.dart';  
import 'package:dio/dio.dart';

part 'database_providers.g.dart';

@riverpod
AppDatabase appDatabase(AppDatabaseRef ref) {
  return AppDatabase();
}

@riverpod
HikeDao hikeDao(HikeDaoRef ref) {
  return ref.watch(appDatabaseProvider).hikeDao;
}

@riverpod
HikePhotoDao hikePhotoDao(HikePhotoDaoRef ref) {
  return ref.watch(appDatabaseProvider).hikePhotoDao;
}

@riverpod
HikeWaypointDao hikeWaypointDao(HikeWaypointDaoRef ref) {
  return ref.watch(appDatabaseProvider).hikeWaypointsDao;
}

@riverpod
RoutePointDao routePointDao(RoutePointDaoRef ref) {
  return ref.watch(appDatabaseProvider).routePointDao;
}

// ✅ TAMBAH PROVIDER SUPABASE
@riverpod
SupabaseClient supabaseProvider(SupabaseProviderRef ref) {
  return Supabase.instance.client;
}

@riverpod
Dio dio(DioRef ref) {
  return Dio();
}

/// Provider untuk WeatherService
@riverpod
WeatherService weatherService(WeatherServiceRef ref) {
  // Ambil instance Dio dari provider lain
  final dio = ref.watch(dioProvider); 
  return WeatherService(dio);
}

@riverpod
SyncRepository syncRepository(SyncRepositoryRef ref) {
  final hikeDao = ref.watch(hikeDaoProvider);
  final photoDao = ref.watch(hikePhotoDaoProvider); 
  final supabase = ref.watch(supabaseProviderProvider);
  final waypointDao = ref.watch(hikeWaypointDaoProvider);
  final routePointDao = ref.watch(routePointDaoProvider);
  final weatherService = ref.watch(weatherServiceProvider);
  return SyncRepositoryImpl(hikeDao, photoDao, waypointDao, routePointDao, supabase, weatherService); 
}

@riverpod
Stream<int> pendingHikesCount(PendingHikesCountRef ref) {
  final dao = ref.watch(hikeDaoProvider);
  return dao.watchPendingHikesCount();
}