  import 'package:drift/drift.dart';

@DataClassName('History')
class Histories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  DateTimeColumn get date => dateTime()();
}
