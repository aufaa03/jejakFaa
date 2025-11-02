import 'package:drift/drift.dart';

// 1. ENUM YANG HILANG
enum SyncStatus {
  pending, // Data baru, siap dikirim
  synced, // Data sudah sama dengan cloud
  pending_update, // Data diubah/dihapus, siap dikirim
}

// 2. CONVERTER YANG HILANG
class SyncStatusConverter extends TypeConverter<SyncStatus, String> {
  const SyncStatusConverter();
  @override
  SyncStatus fromSql(String fromDb) {
    return SyncStatus.values.firstWhere((e) => e.name == fromDb,
        orElse: () => SyncStatus.pending);
  }

  @override
  String toSql(SyncStatus value) {
    return value.name;
  }
}

