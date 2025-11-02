// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_service.dart';

// ignore_for_file: type=lint
class $HikesTable extends Hikes with TableInfo<$HikesTable, Hike> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HikesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _namaGunungMeta = const VerificationMeta(
    'namaGunung',
  );
  @override
  late final GeneratedColumn<String> namaGunung = GeneratedColumn<String>(
    'nama_gunung',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tanggalMeta = const VerificationMeta(
    'tanggal',
  );
  @override
  late final GeneratedColumn<DateTime> tanggal = GeneratedColumn<DateTime>(
    'tanggal',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _catatanMeta = const VerificationMeta(
    'catatan',
  );
  @override
  late final GeneratedColumn<String> catatan = GeneratedColumn<String>(
    'catatan',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    namaGunung,
    tanggal,
    catatan,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hikes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Hike> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('nama_gunung')) {
      context.handle(
        _namaGunungMeta,
        namaGunung.isAcceptableOrUnknown(data['nama_gunung']!, _namaGunungMeta),
      );
    } else if (isInserting) {
      context.missing(_namaGunungMeta);
    }
    if (data.containsKey('tanggal')) {
      context.handle(
        _tanggalMeta,
        tanggal.isAcceptableOrUnknown(data['tanggal']!, _tanggalMeta),
      );
    } else if (isInserting) {
      context.missing(_tanggalMeta);
    }
    if (data.containsKey('catatan')) {
      context.handle(
        _catatanMeta,
        catatan.isAcceptableOrUnknown(data['catatan']!, _catatanMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Hike map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Hike(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      namaGunung: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nama_gunung'],
      )!,
      tanggal: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}tanggal'],
      )!,
      catatan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catatan'],
      ),
    );
  }

  @override
  $HikesTable createAlias(String alias) {
    return $HikesTable(attachedDatabase, alias);
  }
}

class Hike extends DataClass implements Insertable<Hike> {
  final int id;
  final String userId;
  final String namaGunung;
  final DateTime tanggal;
  final String? catatan;
  const Hike({
    required this.id,
    required this.userId,
    required this.namaGunung,
    required this.tanggal,
    this.catatan,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['nama_gunung'] = Variable<String>(namaGunung);
    map['tanggal'] = Variable<DateTime>(tanggal);
    if (!nullToAbsent || catatan != null) {
      map['catatan'] = Variable<String>(catatan);
    }
    return map;
  }

  HikesCompanion toCompanion(bool nullToAbsent) {
    return HikesCompanion(
      id: Value(id),
      userId: Value(userId),
      namaGunung: Value(namaGunung),
      tanggal: Value(tanggal),
      catatan: catatan == null && nullToAbsent
          ? const Value.absent()
          : Value(catatan),
    );
  }

  factory Hike.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Hike(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      namaGunung: serializer.fromJson<String>(json['namaGunung']),
      tanggal: serializer.fromJson<DateTime>(json['tanggal']),
      catatan: serializer.fromJson<String?>(json['catatan']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'namaGunung': serializer.toJson<String>(namaGunung),
      'tanggal': serializer.toJson<DateTime>(tanggal),
      'catatan': serializer.toJson<String?>(catatan),
    };
  }

  Hike copyWith({
    int? id,
    String? userId,
    String? namaGunung,
    DateTime? tanggal,
    Value<String?> catatan = const Value.absent(),
  }) => Hike(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    namaGunung: namaGunung ?? this.namaGunung,
    tanggal: tanggal ?? this.tanggal,
    catatan: catatan.present ? catatan.value : this.catatan,
  );
  Hike copyWithCompanion(HikesCompanion data) {
    return Hike(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      namaGunung: data.namaGunung.present
          ? data.namaGunung.value
          : this.namaGunung,
      tanggal: data.tanggal.present ? data.tanggal.value : this.tanggal,
      catatan: data.catatan.present ? data.catatan.value : this.catatan,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Hike(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('namaGunung: $namaGunung, ')
          ..write('tanggal: $tanggal, ')
          ..write('catatan: $catatan')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, namaGunung, tanggal, catatan);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Hike &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.namaGunung == this.namaGunung &&
          other.tanggal == this.tanggal &&
          other.catatan == this.catatan);
}

class HikesCompanion extends UpdateCompanion<Hike> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> namaGunung;
  final Value<DateTime> tanggal;
  final Value<String?> catatan;
  const HikesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.namaGunung = const Value.absent(),
    this.tanggal = const Value.absent(),
    this.catatan = const Value.absent(),
  });
  HikesCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    required String namaGunung,
    required DateTime tanggal,
    this.catatan = const Value.absent(),
  }) : userId = Value(userId),
       namaGunung = Value(namaGunung),
       tanggal = Value(tanggal);
  static Insertable<Hike> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? namaGunung,
    Expression<DateTime>? tanggal,
    Expression<String>? catatan,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (namaGunung != null) 'nama_gunung': namaGunung,
      if (tanggal != null) 'tanggal': tanggal,
      if (catatan != null) 'catatan': catatan,
    });
  }

  HikesCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<String>? namaGunung,
    Value<DateTime>? tanggal,
    Value<String?>? catatan,
  }) {
    return HikesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      namaGunung: namaGunung ?? this.namaGunung,
      tanggal: tanggal ?? this.tanggal,
      catatan: catatan ?? this.catatan,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (namaGunung.present) {
      map['nama_gunung'] = Variable<String>(namaGunung.value);
    }
    if (tanggal.present) {
      map['tanggal'] = Variable<DateTime>(tanggal.value);
    }
    if (catatan.present) {
      map['catatan'] = Variable<String>(catatan.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HikesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('namaGunung: $namaGunung, ')
          ..write('tanggal: $tanggal, ')
          ..write('catatan: $catatan')
          ..write(')'))
        .toString();
  }
}

class $HistoriesTable extends Histories
    with TableInfo<$HistoriesTable, History> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HistoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, title, date];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'histories';
  @override
  VerificationContext validateIntegrity(
    Insertable<History> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  History map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return History(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
    );
  }

  @override
  $HistoriesTable createAlias(String alias) {
    return $HistoriesTable(attachedDatabase, alias);
  }
}

class History extends DataClass implements Insertable<History> {
  final int id;
  final String title;
  final DateTime date;
  const History({required this.id, required this.title, required this.date});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['date'] = Variable<DateTime>(date);
    return map;
  }

  HistoriesCompanion toCompanion(bool nullToAbsent) {
    return HistoriesCompanion(
      id: Value(id),
      title: Value(title),
      date: Value(date),
    );
  }

  factory History.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return History(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      date: serializer.fromJson<DateTime>(json['date']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'date': serializer.toJson<DateTime>(date),
    };
  }

  History copyWith({int? id, String? title, DateTime? date}) => History(
    id: id ?? this.id,
    title: title ?? this.title,
    date: date ?? this.date,
  );
  History copyWithCompanion(HistoriesCompanion data) {
    return History(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      date: data.date.present ? data.date.value : this.date,
    );
  }

  @override
  String toString() {
    return (StringBuffer('History(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, date);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is History &&
          other.id == this.id &&
          other.title == this.title &&
          other.date == this.date);
}

class HistoriesCompanion extends UpdateCompanion<History> {
  final Value<int> id;
  final Value<String> title;
  final Value<DateTime> date;
  const HistoriesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.date = const Value.absent(),
  });
  HistoriesCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required DateTime date,
  }) : title = Value(title),
       date = Value(date);
  static Insertable<History> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<DateTime>? date,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (date != null) 'date': date,
    });
  }

  HistoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<DateTime>? date,
  }) {
    return HistoriesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistoriesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }
}

abstract class _$DriftService extends GeneratedDatabase {
  _$DriftService(QueryExecutor e) : super(e);
  $DriftServiceManager get managers => $DriftServiceManager(this);
  late final $HikesTable hikes = $HikesTable(this);
  late final $HistoriesTable histories = $HistoriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [hikes, histories];
}

typedef $$HikesTableCreateCompanionBuilder =
    HikesCompanion Function({
      Value<int> id,
      required String userId,
      required String namaGunung,
      required DateTime tanggal,
      Value<String?> catatan,
    });
typedef $$HikesTableUpdateCompanionBuilder =
    HikesCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<String> namaGunung,
      Value<DateTime> tanggal,
      Value<String?> catatan,
    });

class $$HikesTableFilterComposer extends Composer<_$DriftService, $HikesTable> {
  $$HikesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get namaGunung => $composableBuilder(
    column: $table.namaGunung,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get tanggal => $composableBuilder(
    column: $table.tanggal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get catatan => $composableBuilder(
    column: $table.catatan,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HikesTableOrderingComposer
    extends Composer<_$DriftService, $HikesTable> {
  $$HikesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get namaGunung => $composableBuilder(
    column: $table.namaGunung,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get tanggal => $composableBuilder(
    column: $table.tanggal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catatan => $composableBuilder(
    column: $table.catatan,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HikesTableAnnotationComposer
    extends Composer<_$DriftService, $HikesTable> {
  $$HikesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get namaGunung => $composableBuilder(
    column: $table.namaGunung,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get tanggal =>
      $composableBuilder(column: $table.tanggal, builder: (column) => column);

  GeneratedColumn<String> get catatan =>
      $composableBuilder(column: $table.catatan, builder: (column) => column);
}

class $$HikesTableTableManager
    extends
        RootTableManager<
          _$DriftService,
          $HikesTable,
          Hike,
          $$HikesTableFilterComposer,
          $$HikesTableOrderingComposer,
          $$HikesTableAnnotationComposer,
          $$HikesTableCreateCompanionBuilder,
          $$HikesTableUpdateCompanionBuilder,
          (Hike, BaseReferences<_$DriftService, $HikesTable, Hike>),
          Hike,
          PrefetchHooks Function()
        > {
  $$HikesTableTableManager(_$DriftService db, $HikesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HikesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HikesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HikesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> namaGunung = const Value.absent(),
                Value<DateTime> tanggal = const Value.absent(),
                Value<String?> catatan = const Value.absent(),
              }) => HikesCompanion(
                id: id,
                userId: userId,
                namaGunung: namaGunung,
                tanggal: tanggal,
                catatan: catatan,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String userId,
                required String namaGunung,
                required DateTime tanggal,
                Value<String?> catatan = const Value.absent(),
              }) => HikesCompanion.insert(
                id: id,
                userId: userId,
                namaGunung: namaGunung,
                tanggal: tanggal,
                catatan: catatan,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HikesTableProcessedTableManager =
    ProcessedTableManager<
      _$DriftService,
      $HikesTable,
      Hike,
      $$HikesTableFilterComposer,
      $$HikesTableOrderingComposer,
      $$HikesTableAnnotationComposer,
      $$HikesTableCreateCompanionBuilder,
      $$HikesTableUpdateCompanionBuilder,
      (Hike, BaseReferences<_$DriftService, $HikesTable, Hike>),
      Hike,
      PrefetchHooks Function()
    >;
typedef $$HistoriesTableCreateCompanionBuilder =
    HistoriesCompanion Function({
      Value<int> id,
      required String title,
      required DateTime date,
    });
typedef $$HistoriesTableUpdateCompanionBuilder =
    HistoriesCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<DateTime> date,
    });

class $$HistoriesTableFilterComposer
    extends Composer<_$DriftService, $HistoriesTable> {
  $$HistoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HistoriesTableOrderingComposer
    extends Composer<_$DriftService, $HistoriesTable> {
  $$HistoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HistoriesTableAnnotationComposer
    extends Composer<_$DriftService, $HistoriesTable> {
  $$HistoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);
}

class $$HistoriesTableTableManager
    extends
        RootTableManager<
          _$DriftService,
          $HistoriesTable,
          History,
          $$HistoriesTableFilterComposer,
          $$HistoriesTableOrderingComposer,
          $$HistoriesTableAnnotationComposer,
          $$HistoriesTableCreateCompanionBuilder,
          $$HistoriesTableUpdateCompanionBuilder,
          (History, BaseReferences<_$DriftService, $HistoriesTable, History>),
          History,
          PrefetchHooks Function()
        > {
  $$HistoriesTableTableManager(_$DriftService db, $HistoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HistoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HistoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HistoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
              }) => HistoriesCompanion(id: id, title: title, date: date),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required DateTime date,
              }) => HistoriesCompanion.insert(id: id, title: title, date: date),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HistoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$DriftService,
      $HistoriesTable,
      History,
      $$HistoriesTableFilterComposer,
      $$HistoriesTableOrderingComposer,
      $$HistoriesTableAnnotationComposer,
      $$HistoriesTableCreateCompanionBuilder,
      $$HistoriesTableUpdateCompanionBuilder,
      (History, BaseReferences<_$DriftService, $HistoriesTable, History>),
      History,
      PrefetchHooks Function()
    >;

class $DriftServiceManager {
  final _$DriftService _db;
  $DriftServiceManager(this._db);
  $$HikesTableTableManager get hikes =>
      $$HikesTableTableManager(_db, _db.hikes);
  $$HistoriesTableTableManager get histories =>
      $$HistoriesTableTableManager(_db, _db.histories);
}
