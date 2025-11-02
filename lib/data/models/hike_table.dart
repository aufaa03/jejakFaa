import 'package:drift/drift.dart';

// 1. Ganti nama class 'Hikes' (dari kodemu) jadi 'HikeTable'
//    agar tidak bentrok dengan class 'Hike' (Data Class)
@DataClassName('Hike')
class Hikes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()(); // <-- HARUS ADA INI
  TextColumn get namaGunung => text()(); // <-- Indo
  DateTimeColumn get tanggal => dateTime()(); // <-- Indo
  TextColumn get catatan => text().nullable()(); // <-- Indo
  
}

