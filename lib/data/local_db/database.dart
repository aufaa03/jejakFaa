import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:jejak_faa_new/data/local_db/daos/hike_dao.dart';
import 'package:jejak_faa_new/data/local_db/daos/hike_photo_dao.dart';
import 'package:jejak_faa_new/data/local_db/tables.dart';
import 'package:jejak_faa_new/data/models/sync_status.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:jejak_faa_new/data/local_db/daos/hike_waypoint_dao.dart'; 
import 'package:jejak_faa_new/data/local_db/daos/route_point_dao.dart';


part 'database.g.dart';

@DriftDatabase(
  tables: [Hikes, HikePhotos, HikeWaypoints, RoutePoints], 
  daos: [HikeDao, HikePhotoDao, HikeWaypointDao, RoutePointDao]
)
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal() : super(_openConnection());

  // 2. BUAT SATU STATIC INSTANCE (SINGLETON)
  static final AppDatabase _instance = AppDatabase._internal();

  // 3. BUAT 'FACTORY' CONSTRUCTOR
  //    Ini memastikan siapa pun yang memanggil 'AppDatabase()'
  //    akan selalu mendapatkan instance yang SAMA
  factory AppDatabase() {
    return _instance;
  }

  @override
  // --- 1. NAIKKAN VERSI SCHEMA DARI 2 KE 3 ---
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        // Buat semua tabel saat database pertama kali dibuat
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        // Migrasi v1 -> v2 (Sudah ada)
        if (from == 1) {
          await m.createTable(hikeWaypoints);
          await m.createTable(routePoints);
        }
        
        // Migrasi v2 -> v3 (Sudah ada)
        if (from == 2) {
          await m.addColumn(hikes, hikes.totalDistanceKm);
          await m.addColumn(hikes, hikes.totalElevationGainMeters);
          await m.addColumn(hikes, hikes.totalElevationLossMeters);
          await m.addColumn(hikes, hikes.averageSpeedKmh);
          await m.addColumn(hikes, hikes.maxSpeedKmh);
          await m.addColumn(hikes, hikes.startWeatherCondition);
          await m.addColumn(hikes, hikes.startTemperature);
        }

        // --- INI LOGIKA MIGRASI BARU V3 -> V4 ---
        if (from == 3) {
          // 1. Tambah 4 kolom baru ke tabel 'HikeWaypoints'
          await m.addColumn(hikeWaypoints, hikeWaypoints.category);
          await m.addColumn(hikeWaypoints, hikeWaypoints.altitude);
          await m.addColumn(hikeWaypoints, hikeWaypoints.elevationGainToHere);
          await m.addColumn(hikeWaypoints, hikeWaypoints.elevationLossToHere);

          // 2. Tambah 1 kolom baru ke tabel 'HikePhotos'
          await m.addColumn(hikePhotos, hikePhotos.waypointId);
        }
        // ini adalah migrasi dari v4 ke v5
        if (from == 4) {
  await m.renameColumn(hikes, 'duration_minutes', hikes.durationSeconds);
}
// migrasi dari v5 ke v6
if (from == 5) {
  await m.addColumn(hikes, hikes.averagePaceMinPerKm);
}
        // --- AKHIR LOGIKA BARU ---
      },
    );
  }
  // --- END PERUBAHAN ---

  // Getter untuk semua DAO
  HikeDao get hikeDao => HikeDao(this);
  HikePhotoDao get hikePhotoDao => HikePhotoDao(this);
  HikeWaypointDao get hikeWaypointsDao => HikeWaypointDao(this);
  RoutePointDao get routePointDao => RoutePointDao(this);
}

// Fungsi _openConnection() tetap sama
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'jejak_faa_db.sqlite'));

    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    return NativeDatabase.createInBackground(file);
  });
}

