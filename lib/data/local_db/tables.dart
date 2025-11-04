import 'package:drift/drift.dart';
import 'package:jejak_faa_new/data/models/sync_status.dart';

// --- Hikes (Schema v3 - Tidak ada perubahan) ---
@DataClassName('Hike')
class Hikes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  TextColumn get cloudId => text().nullable()();
  TextColumn get mountainName => text()();
  DateTimeColumn get hikeDate => dateTime()();

  // --- Kolom Statistik (Baru dari v3) ---
  IntColumn get durationSeconds => integer().nullable()();
  RealColumn get totalDistanceKm => real().nullable()();
  RealColumn get totalElevationGainMeters => real().nullable()();
  RealColumn get totalElevationLossMeters => real().nullable()();
  RealColumn get averageSpeedKmh => real().nullable()();
  RealColumn get maxSpeedKmh => real().nullable()();
  RealColumn get averagePaceMinPerKm => real().nullable()();

  // --- Kolom Cuaca (Baru dari v3) ---
  TextColumn get startWeatherCondition => text().nullable()();
  RealColumn get startTemperature => real().nullable()();

  // --- Kolom Lainnya ---
  TextColumn get partners => text().nullable()();
  TextColumn get notes => text().nullable()();

  TextColumn get syncStatus => text()
      .map(const SyncStatusConverter())
      .withDefault(Constant(SyncStatus.pending.name))();

  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}

// --- HikePhotos (Update Schema v4) ---
@DataClassName('HikePhoto')
class HikePhotos extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get syncStatus => text()
      .map(const SyncStatusConverter())
      .withDefault(Constant(SyncStatus.pending.name))();

  TextColumn get cloudId => text().nullable()();
  IntColumn get hikeId =>
      integer().references(Hikes, #id, onDelete: KeyAction.cascade)();

  // --- TAMBAHAN (Link ke Waypoint) ---
  // Ini adalah Foreign Key opsional ke tabel HikeWaypoints.
  // Jika waypoint dihapus, foto TIDAK ikut terhapus (hanya link-nya jadi null).
  IntColumn get waypointId => integer()
      .nullable()
      .references(HikeWaypoints, #id, onDelete: KeyAction.setNull)();
  // --- END TAMBAHAN ---

  TextColumn get photoUrl => text()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  DateTimeColumn get capturedAt => dateTime().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}

// --- RoutePoints (Schema v3 - Tidak ada perubahan) ---
@DataClassName('RoutePoint')
class RoutePoints extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get cloudId => text().nullable()();

  TextColumn get syncStatus => text()
      .map(const SyncStatusConverter())
      .withDefault(Constant(SyncStatus.pending.name))();

  IntColumn get hikeId =>
      integer().references(Hikes, #id, onDelete: KeyAction.cascade)();

  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get altitude => real().nullable()();
  DateTimeColumn get timestamp => dateTime()();
  RealColumn get speedKmh => real().nullable()();
}

// --- HikeWaypoints (Update Schema v4) ---
@DataClassName('HikeWaypoint')
class HikeWaypoints extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get cloudId => text().nullable()();

  TextColumn get syncStatus => text()
      .map(const SyncStatusConverter())
      .withDefault(Constant(SyncStatus.pending.name))();

  IntColumn get hikeId =>
      integer().references(Hikes, #id, onDelete: KeyAction.cascade)();

  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  DateTimeColumn get timestamp => dateTime()();

  // --- TAMBAHAN FITUR (Schema v4) ---
  // Kategori: 'POS', 'SUMBER_AIR', 'PUNCAK', 'CAMP', 'LAINNYA'
  TextColumn get category => text().nullable()();

  // Altitude (akan null jika ditambah via tap peta)
  RealColumn get altitude => real().nullable()();

  // Statistik (dihitung saat 'Selesai')
  RealColumn get elevationGainToHere => real().nullable()();
  RealColumn get elevationLossToHere => real().nullable()();
  // --- END TAMBAHAN ---

  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}