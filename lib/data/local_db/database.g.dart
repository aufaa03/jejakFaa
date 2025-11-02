// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

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
  static const VerificationMeta _cloudIdMeta = const VerificationMeta(
    'cloudId',
  );
  @override
  late final GeneratedColumn<String> cloudId = GeneratedColumn<String>(
    'cloud_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mountainNameMeta = const VerificationMeta(
    'mountainName',
  );
  @override
  late final GeneratedColumn<String> mountainName = GeneratedColumn<String>(
    'mountain_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hikeDateMeta = const VerificationMeta(
    'hikeDate',
  );
  @override
  late final GeneratedColumn<DateTime> hikeDate = GeneratedColumn<DateTime>(
    'hike_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMinutesMeta = const VerificationMeta(
    'durationMinutes',
  );
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
    'duration_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalDistanceKmMeta = const VerificationMeta(
    'totalDistanceKm',
  );
  @override
  late final GeneratedColumn<double> totalDistanceKm = GeneratedColumn<double>(
    'total_distance_km',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalElevationGainMetersMeta =
      const VerificationMeta('totalElevationGainMeters');
  @override
  late final GeneratedColumn<double> totalElevationGainMeters =
      GeneratedColumn<double>(
        'total_elevation_gain_meters',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _totalElevationLossMetersMeta =
      const VerificationMeta('totalElevationLossMeters');
  @override
  late final GeneratedColumn<double> totalElevationLossMeters =
      GeneratedColumn<double>(
        'total_elevation_loss_meters',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _averageSpeedKmhMeta = const VerificationMeta(
    'averageSpeedKmh',
  );
  @override
  late final GeneratedColumn<double> averageSpeedKmh = GeneratedColumn<double>(
    'average_speed_kmh',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxSpeedKmhMeta = const VerificationMeta(
    'maxSpeedKmh',
  );
  @override
  late final GeneratedColumn<double> maxSpeedKmh = GeneratedColumn<double>(
    'max_speed_kmh',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startWeatherConditionMeta =
      const VerificationMeta('startWeatherCondition');
  @override
  late final GeneratedColumn<String> startWeatherCondition =
      GeneratedColumn<String>(
        'start_weather_condition',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _startTemperatureMeta = const VerificationMeta(
    'startTemperature',
  );
  @override
  late final GeneratedColumn<double> startTemperature = GeneratedColumn<double>(
    'start_temperature',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _partnersMeta = const VerificationMeta(
    'partners',
  );
  @override
  late final GeneratedColumn<String> partners = GeneratedColumn<String>(
    'partners',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, String> syncStatus =
      GeneratedColumn<String>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(SyncStatus.pending.name),
      ).withConverter<SyncStatus>($HikesTable.$convertersyncStatus);
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    cloudId,
    mountainName,
    hikeDate,
    durationMinutes,
    totalDistanceKm,
    totalElevationGainMeters,
    totalElevationLossMeters,
    averageSpeedKmh,
    maxSpeedKmh,
    startWeatherCondition,
    startTemperature,
    partners,
    notes,
    syncStatus,
    isDeleted,
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
    if (data.containsKey('cloud_id')) {
      context.handle(
        _cloudIdMeta,
        cloudId.isAcceptableOrUnknown(data['cloud_id']!, _cloudIdMeta),
      );
    }
    if (data.containsKey('mountain_name')) {
      context.handle(
        _mountainNameMeta,
        mountainName.isAcceptableOrUnknown(
          data['mountain_name']!,
          _mountainNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mountainNameMeta);
    }
    if (data.containsKey('hike_date')) {
      context.handle(
        _hikeDateMeta,
        hikeDate.isAcceptableOrUnknown(data['hike_date']!, _hikeDateMeta),
      );
    } else if (isInserting) {
      context.missing(_hikeDateMeta);
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
        _durationMinutesMeta,
        durationMinutes.isAcceptableOrUnknown(
          data['duration_minutes']!,
          _durationMinutesMeta,
        ),
      );
    }
    if (data.containsKey('total_distance_km')) {
      context.handle(
        _totalDistanceKmMeta,
        totalDistanceKm.isAcceptableOrUnknown(
          data['total_distance_km']!,
          _totalDistanceKmMeta,
        ),
      );
    }
    if (data.containsKey('total_elevation_gain_meters')) {
      context.handle(
        _totalElevationGainMetersMeta,
        totalElevationGainMeters.isAcceptableOrUnknown(
          data['total_elevation_gain_meters']!,
          _totalElevationGainMetersMeta,
        ),
      );
    }
    if (data.containsKey('total_elevation_loss_meters')) {
      context.handle(
        _totalElevationLossMetersMeta,
        totalElevationLossMeters.isAcceptableOrUnknown(
          data['total_elevation_loss_meters']!,
          _totalElevationLossMetersMeta,
        ),
      );
    }
    if (data.containsKey('average_speed_kmh')) {
      context.handle(
        _averageSpeedKmhMeta,
        averageSpeedKmh.isAcceptableOrUnknown(
          data['average_speed_kmh']!,
          _averageSpeedKmhMeta,
        ),
      );
    }
    if (data.containsKey('max_speed_kmh')) {
      context.handle(
        _maxSpeedKmhMeta,
        maxSpeedKmh.isAcceptableOrUnknown(
          data['max_speed_kmh']!,
          _maxSpeedKmhMeta,
        ),
      );
    }
    if (data.containsKey('start_weather_condition')) {
      context.handle(
        _startWeatherConditionMeta,
        startWeatherCondition.isAcceptableOrUnknown(
          data['start_weather_condition']!,
          _startWeatherConditionMeta,
        ),
      );
    }
    if (data.containsKey('start_temperature')) {
      context.handle(
        _startTemperatureMeta,
        startTemperature.isAcceptableOrUnknown(
          data['start_temperature']!,
          _startTemperatureMeta,
        ),
      );
    }
    if (data.containsKey('partners')) {
      context.handle(
        _partnersMeta,
        partners.isAcceptableOrUnknown(data['partners']!, _partnersMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
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
      cloudId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cloud_id'],
      ),
      mountainName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mountain_name'],
      )!,
      hikeDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}hike_date'],
      )!,
      durationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_minutes'],
      ),
      totalDistanceKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_distance_km'],
      ),
      totalElevationGainMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_elevation_gain_meters'],
      ),
      totalElevationLossMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_elevation_loss_meters'],
      ),
      averageSpeedKmh: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}average_speed_kmh'],
      ),
      maxSpeedKmh: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_speed_kmh'],
      ),
      startWeatherCondition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_weather_condition'],
      ),
      startTemperature: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}start_temperature'],
      ),
      partners: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}partners'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      syncStatus: $HikesTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $HikesTable createAlias(String alias) {
    return $HikesTable(attachedDatabase, alias);
  }

  static TypeConverter<SyncStatus, String> $convertersyncStatus =
      const SyncStatusConverter();
}

class Hike extends DataClass implements Insertable<Hike> {
  final int id;
  final String userId;
  final String? cloudId;
  final String mountainName;
  final DateTime hikeDate;
  final int? durationMinutes;
  final double? totalDistanceKm;
  final double? totalElevationGainMeters;
  final double? totalElevationLossMeters;
  final double? averageSpeedKmh;
  final double? maxSpeedKmh;
  final String? startWeatherCondition;
  final double? startTemperature;
  final String? partners;
  final String? notes;
  final SyncStatus syncStatus;
  final bool isDeleted;
  const Hike({
    required this.id,
    required this.userId,
    this.cloudId,
    required this.mountainName,
    required this.hikeDate,
    this.durationMinutes,
    this.totalDistanceKm,
    this.totalElevationGainMeters,
    this.totalElevationLossMeters,
    this.averageSpeedKmh,
    this.maxSpeedKmh,
    this.startWeatherCondition,
    this.startTemperature,
    this.partners,
    this.notes,
    required this.syncStatus,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || cloudId != null) {
      map['cloud_id'] = Variable<String>(cloudId);
    }
    map['mountain_name'] = Variable<String>(mountainName);
    map['hike_date'] = Variable<DateTime>(hikeDate);
    if (!nullToAbsent || durationMinutes != null) {
      map['duration_minutes'] = Variable<int>(durationMinutes);
    }
    if (!nullToAbsent || totalDistanceKm != null) {
      map['total_distance_km'] = Variable<double>(totalDistanceKm);
    }
    if (!nullToAbsent || totalElevationGainMeters != null) {
      map['total_elevation_gain_meters'] = Variable<double>(
        totalElevationGainMeters,
      );
    }
    if (!nullToAbsent || totalElevationLossMeters != null) {
      map['total_elevation_loss_meters'] = Variable<double>(
        totalElevationLossMeters,
      );
    }
    if (!nullToAbsent || averageSpeedKmh != null) {
      map['average_speed_kmh'] = Variable<double>(averageSpeedKmh);
    }
    if (!nullToAbsent || maxSpeedKmh != null) {
      map['max_speed_kmh'] = Variable<double>(maxSpeedKmh);
    }
    if (!nullToAbsent || startWeatherCondition != null) {
      map['start_weather_condition'] = Variable<String>(startWeatherCondition);
    }
    if (!nullToAbsent || startTemperature != null) {
      map['start_temperature'] = Variable<double>(startTemperature);
    }
    if (!nullToAbsent || partners != null) {
      map['partners'] = Variable<String>(partners);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    {
      map['sync_status'] = Variable<String>(
        $HikesTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  HikesCompanion toCompanion(bool nullToAbsent) {
    return HikesCompanion(
      id: Value(id),
      userId: Value(userId),
      cloudId: cloudId == null && nullToAbsent
          ? const Value.absent()
          : Value(cloudId),
      mountainName: Value(mountainName),
      hikeDate: Value(hikeDate),
      durationMinutes: durationMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMinutes),
      totalDistanceKm: totalDistanceKm == null && nullToAbsent
          ? const Value.absent()
          : Value(totalDistanceKm),
      totalElevationGainMeters: totalElevationGainMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(totalElevationGainMeters),
      totalElevationLossMeters: totalElevationLossMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(totalElevationLossMeters),
      averageSpeedKmh: averageSpeedKmh == null && nullToAbsent
          ? const Value.absent()
          : Value(averageSpeedKmh),
      maxSpeedKmh: maxSpeedKmh == null && nullToAbsent
          ? const Value.absent()
          : Value(maxSpeedKmh),
      startWeatherCondition: startWeatherCondition == null && nullToAbsent
          ? const Value.absent()
          : Value(startWeatherCondition),
      startTemperature: startTemperature == null && nullToAbsent
          ? const Value.absent()
          : Value(startTemperature),
      partners: partners == null && nullToAbsent
          ? const Value.absent()
          : Value(partners),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      syncStatus: Value(syncStatus),
      isDeleted: Value(isDeleted),
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
      cloudId: serializer.fromJson<String?>(json['cloudId']),
      mountainName: serializer.fromJson<String>(json['mountainName']),
      hikeDate: serializer.fromJson<DateTime>(json['hikeDate']),
      durationMinutes: serializer.fromJson<int?>(json['durationMinutes']),
      totalDistanceKm: serializer.fromJson<double?>(json['totalDistanceKm']),
      totalElevationGainMeters: serializer.fromJson<double?>(
        json['totalElevationGainMeters'],
      ),
      totalElevationLossMeters: serializer.fromJson<double?>(
        json['totalElevationLossMeters'],
      ),
      averageSpeedKmh: serializer.fromJson<double?>(json['averageSpeedKmh']),
      maxSpeedKmh: serializer.fromJson<double?>(json['maxSpeedKmh']),
      startWeatherCondition: serializer.fromJson<String?>(
        json['startWeatherCondition'],
      ),
      startTemperature: serializer.fromJson<double?>(json['startTemperature']),
      partners: serializer.fromJson<String?>(json['partners']),
      notes: serializer.fromJson<String?>(json['notes']),
      syncStatus: serializer.fromJson<SyncStatus>(json['syncStatus']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'cloudId': serializer.toJson<String?>(cloudId),
      'mountainName': serializer.toJson<String>(mountainName),
      'hikeDate': serializer.toJson<DateTime>(hikeDate),
      'durationMinutes': serializer.toJson<int?>(durationMinutes),
      'totalDistanceKm': serializer.toJson<double?>(totalDistanceKm),
      'totalElevationGainMeters': serializer.toJson<double?>(
        totalElevationGainMeters,
      ),
      'totalElevationLossMeters': serializer.toJson<double?>(
        totalElevationLossMeters,
      ),
      'averageSpeedKmh': serializer.toJson<double?>(averageSpeedKmh),
      'maxSpeedKmh': serializer.toJson<double?>(maxSpeedKmh),
      'startWeatherCondition': serializer.toJson<String?>(
        startWeatherCondition,
      ),
      'startTemperature': serializer.toJson<double?>(startTemperature),
      'partners': serializer.toJson<String?>(partners),
      'notes': serializer.toJson<String?>(notes),
      'syncStatus': serializer.toJson<SyncStatus>(syncStatus),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  Hike copyWith({
    int? id,
    String? userId,
    Value<String?> cloudId = const Value.absent(),
    String? mountainName,
    DateTime? hikeDate,
    Value<int?> durationMinutes = const Value.absent(),
    Value<double?> totalDistanceKm = const Value.absent(),
    Value<double?> totalElevationGainMeters = const Value.absent(),
    Value<double?> totalElevationLossMeters = const Value.absent(),
    Value<double?> averageSpeedKmh = const Value.absent(),
    Value<double?> maxSpeedKmh = const Value.absent(),
    Value<String?> startWeatherCondition = const Value.absent(),
    Value<double?> startTemperature = const Value.absent(),
    Value<String?> partners = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    SyncStatus? syncStatus,
    bool? isDeleted,
  }) => Hike(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    cloudId: cloudId.present ? cloudId.value : this.cloudId,
    mountainName: mountainName ?? this.mountainName,
    hikeDate: hikeDate ?? this.hikeDate,
    durationMinutes: durationMinutes.present
        ? durationMinutes.value
        : this.durationMinutes,
    totalDistanceKm: totalDistanceKm.present
        ? totalDistanceKm.value
        : this.totalDistanceKm,
    totalElevationGainMeters: totalElevationGainMeters.present
        ? totalElevationGainMeters.value
        : this.totalElevationGainMeters,
    totalElevationLossMeters: totalElevationLossMeters.present
        ? totalElevationLossMeters.value
        : this.totalElevationLossMeters,
    averageSpeedKmh: averageSpeedKmh.present
        ? averageSpeedKmh.value
        : this.averageSpeedKmh,
    maxSpeedKmh: maxSpeedKmh.present ? maxSpeedKmh.value : this.maxSpeedKmh,
    startWeatherCondition: startWeatherCondition.present
        ? startWeatherCondition.value
        : this.startWeatherCondition,
    startTemperature: startTemperature.present
        ? startTemperature.value
        : this.startTemperature,
    partners: partners.present ? partners.value : this.partners,
    notes: notes.present ? notes.value : this.notes,
    syncStatus: syncStatus ?? this.syncStatus,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  Hike copyWithCompanion(HikesCompanion data) {
    return Hike(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      cloudId: data.cloudId.present ? data.cloudId.value : this.cloudId,
      mountainName: data.mountainName.present
          ? data.mountainName.value
          : this.mountainName,
      hikeDate: data.hikeDate.present ? data.hikeDate.value : this.hikeDate,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      totalDistanceKm: data.totalDistanceKm.present
          ? data.totalDistanceKm.value
          : this.totalDistanceKm,
      totalElevationGainMeters: data.totalElevationGainMeters.present
          ? data.totalElevationGainMeters.value
          : this.totalElevationGainMeters,
      totalElevationLossMeters: data.totalElevationLossMeters.present
          ? data.totalElevationLossMeters.value
          : this.totalElevationLossMeters,
      averageSpeedKmh: data.averageSpeedKmh.present
          ? data.averageSpeedKmh.value
          : this.averageSpeedKmh,
      maxSpeedKmh: data.maxSpeedKmh.present
          ? data.maxSpeedKmh.value
          : this.maxSpeedKmh,
      startWeatherCondition: data.startWeatherCondition.present
          ? data.startWeatherCondition.value
          : this.startWeatherCondition,
      startTemperature: data.startTemperature.present
          ? data.startTemperature.value
          : this.startTemperature,
      partners: data.partners.present ? data.partners.value : this.partners,
      notes: data.notes.present ? data.notes.value : this.notes,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Hike(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('cloudId: $cloudId, ')
          ..write('mountainName: $mountainName, ')
          ..write('hikeDate: $hikeDate, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('totalDistanceKm: $totalDistanceKm, ')
          ..write('totalElevationGainMeters: $totalElevationGainMeters, ')
          ..write('totalElevationLossMeters: $totalElevationLossMeters, ')
          ..write('averageSpeedKmh: $averageSpeedKmh, ')
          ..write('maxSpeedKmh: $maxSpeedKmh, ')
          ..write('startWeatherCondition: $startWeatherCondition, ')
          ..write('startTemperature: $startTemperature, ')
          ..write('partners: $partners, ')
          ..write('notes: $notes, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    cloudId,
    mountainName,
    hikeDate,
    durationMinutes,
    totalDistanceKm,
    totalElevationGainMeters,
    totalElevationLossMeters,
    averageSpeedKmh,
    maxSpeedKmh,
    startWeatherCondition,
    startTemperature,
    partners,
    notes,
    syncStatus,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Hike &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.cloudId == this.cloudId &&
          other.mountainName == this.mountainName &&
          other.hikeDate == this.hikeDate &&
          other.durationMinutes == this.durationMinutes &&
          other.totalDistanceKm == this.totalDistanceKm &&
          other.totalElevationGainMeters == this.totalElevationGainMeters &&
          other.totalElevationLossMeters == this.totalElevationLossMeters &&
          other.averageSpeedKmh == this.averageSpeedKmh &&
          other.maxSpeedKmh == this.maxSpeedKmh &&
          other.startWeatherCondition == this.startWeatherCondition &&
          other.startTemperature == this.startTemperature &&
          other.partners == this.partners &&
          other.notes == this.notes &&
          other.syncStatus == this.syncStatus &&
          other.isDeleted == this.isDeleted);
}

class HikesCompanion extends UpdateCompanion<Hike> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String?> cloudId;
  final Value<String> mountainName;
  final Value<DateTime> hikeDate;
  final Value<int?> durationMinutes;
  final Value<double?> totalDistanceKm;
  final Value<double?> totalElevationGainMeters;
  final Value<double?> totalElevationLossMeters;
  final Value<double?> averageSpeedKmh;
  final Value<double?> maxSpeedKmh;
  final Value<String?> startWeatherCondition;
  final Value<double?> startTemperature;
  final Value<String?> partners;
  final Value<String?> notes;
  final Value<SyncStatus> syncStatus;
  final Value<bool> isDeleted;
  const HikesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.cloudId = const Value.absent(),
    this.mountainName = const Value.absent(),
    this.hikeDate = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.totalDistanceKm = const Value.absent(),
    this.totalElevationGainMeters = const Value.absent(),
    this.totalElevationLossMeters = const Value.absent(),
    this.averageSpeedKmh = const Value.absent(),
    this.maxSpeedKmh = const Value.absent(),
    this.startWeatherCondition = const Value.absent(),
    this.startTemperature = const Value.absent(),
    this.partners = const Value.absent(),
    this.notes = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDeleted = const Value.absent(),
  });
  HikesCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    this.cloudId = const Value.absent(),
    required String mountainName,
    required DateTime hikeDate,
    this.durationMinutes = const Value.absent(),
    this.totalDistanceKm = const Value.absent(),
    this.totalElevationGainMeters = const Value.absent(),
    this.totalElevationLossMeters = const Value.absent(),
    this.averageSpeedKmh = const Value.absent(),
    this.maxSpeedKmh = const Value.absent(),
    this.startWeatherCondition = const Value.absent(),
    this.startTemperature = const Value.absent(),
    this.partners = const Value.absent(),
    this.notes = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDeleted = const Value.absent(),
  }) : userId = Value(userId),
       mountainName = Value(mountainName),
       hikeDate = Value(hikeDate);
  static Insertable<Hike> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? cloudId,
    Expression<String>? mountainName,
    Expression<DateTime>? hikeDate,
    Expression<int>? durationMinutes,
    Expression<double>? totalDistanceKm,
    Expression<double>? totalElevationGainMeters,
    Expression<double>? totalElevationLossMeters,
    Expression<double>? averageSpeedKmh,
    Expression<double>? maxSpeedKmh,
    Expression<String>? startWeatherCondition,
    Expression<double>? startTemperature,
    Expression<String>? partners,
    Expression<String>? notes,
    Expression<String>? syncStatus,
    Expression<bool>? isDeleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (cloudId != null) 'cloud_id': cloudId,
      if (mountainName != null) 'mountain_name': mountainName,
      if (hikeDate != null) 'hike_date': hikeDate,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (totalDistanceKm != null) 'total_distance_km': totalDistanceKm,
      if (totalElevationGainMeters != null)
        'total_elevation_gain_meters': totalElevationGainMeters,
      if (totalElevationLossMeters != null)
        'total_elevation_loss_meters': totalElevationLossMeters,
      if (averageSpeedKmh != null) 'average_speed_kmh': averageSpeedKmh,
      if (maxSpeedKmh != null) 'max_speed_kmh': maxSpeedKmh,
      if (startWeatherCondition != null)
        'start_weather_condition': startWeatherCondition,
      if (startTemperature != null) 'start_temperature': startTemperature,
      if (partners != null) 'partners': partners,
      if (notes != null) 'notes': notes,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (isDeleted != null) 'is_deleted': isDeleted,
    });
  }

  HikesCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<String?>? cloudId,
    Value<String>? mountainName,
    Value<DateTime>? hikeDate,
    Value<int?>? durationMinutes,
    Value<double?>? totalDistanceKm,
    Value<double?>? totalElevationGainMeters,
    Value<double?>? totalElevationLossMeters,
    Value<double?>? averageSpeedKmh,
    Value<double?>? maxSpeedKmh,
    Value<String?>? startWeatherCondition,
    Value<double?>? startTemperature,
    Value<String?>? partners,
    Value<String?>? notes,
    Value<SyncStatus>? syncStatus,
    Value<bool>? isDeleted,
  }) {
    return HikesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      cloudId: cloudId ?? this.cloudId,
      mountainName: mountainName ?? this.mountainName,
      hikeDate: hikeDate ?? this.hikeDate,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      totalDistanceKm: totalDistanceKm ?? this.totalDistanceKm,
      totalElevationGainMeters:
          totalElevationGainMeters ?? this.totalElevationGainMeters,
      totalElevationLossMeters:
          totalElevationLossMeters ?? this.totalElevationLossMeters,
      averageSpeedKmh: averageSpeedKmh ?? this.averageSpeedKmh,
      maxSpeedKmh: maxSpeedKmh ?? this.maxSpeedKmh,
      startWeatherCondition:
          startWeatherCondition ?? this.startWeatherCondition,
      startTemperature: startTemperature ?? this.startTemperature,
      partners: partners ?? this.partners,
      notes: notes ?? this.notes,
      syncStatus: syncStatus ?? this.syncStatus,
      isDeleted: isDeleted ?? this.isDeleted,
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
    if (cloudId.present) {
      map['cloud_id'] = Variable<String>(cloudId.value);
    }
    if (mountainName.present) {
      map['mountain_name'] = Variable<String>(mountainName.value);
    }
    if (hikeDate.present) {
      map['hike_date'] = Variable<DateTime>(hikeDate.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (totalDistanceKm.present) {
      map['total_distance_km'] = Variable<double>(totalDistanceKm.value);
    }
    if (totalElevationGainMeters.present) {
      map['total_elevation_gain_meters'] = Variable<double>(
        totalElevationGainMeters.value,
      );
    }
    if (totalElevationLossMeters.present) {
      map['total_elevation_loss_meters'] = Variable<double>(
        totalElevationLossMeters.value,
      );
    }
    if (averageSpeedKmh.present) {
      map['average_speed_kmh'] = Variable<double>(averageSpeedKmh.value);
    }
    if (maxSpeedKmh.present) {
      map['max_speed_kmh'] = Variable<double>(maxSpeedKmh.value);
    }
    if (startWeatherCondition.present) {
      map['start_weather_condition'] = Variable<String>(
        startWeatherCondition.value,
      );
    }
    if (startTemperature.present) {
      map['start_temperature'] = Variable<double>(startTemperature.value);
    }
    if (partners.present) {
      map['partners'] = Variable<String>(partners.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(
        $HikesTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HikesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('cloudId: $cloudId, ')
          ..write('mountainName: $mountainName, ')
          ..write('hikeDate: $hikeDate, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('totalDistanceKm: $totalDistanceKm, ')
          ..write('totalElevationGainMeters: $totalElevationGainMeters, ')
          ..write('totalElevationLossMeters: $totalElevationLossMeters, ')
          ..write('averageSpeedKmh: $averageSpeedKmh, ')
          ..write('maxSpeedKmh: $maxSpeedKmh, ')
          ..write('startWeatherCondition: $startWeatherCondition, ')
          ..write('startTemperature: $startTemperature, ')
          ..write('partners: $partners, ')
          ..write('notes: $notes, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }
}

class $HikeWaypointsTable extends HikeWaypoints
    with TableInfo<$HikeWaypointsTable, HikeWaypoint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HikeWaypointsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _cloudIdMeta = const VerificationMeta(
    'cloudId',
  );
  @override
  late final GeneratedColumn<String> cloudId = GeneratedColumn<String>(
    'cloud_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, String> syncStatus =
      GeneratedColumn<String>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(SyncStatus.pending.name),
      ).withConverter<SyncStatus>($HikeWaypointsTable.$convertersyncStatus);
  static const VerificationMeta _hikeIdMeta = const VerificationMeta('hikeId');
  @override
  late final GeneratedColumn<int> hikeId = GeneratedColumn<int>(
    'hike_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES hikes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _altitudeMeta = const VerificationMeta(
    'altitude',
  );
  @override
  late final GeneratedColumn<double> altitude = GeneratedColumn<double>(
    'altitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _elevationGainToHereMeta =
      const VerificationMeta('elevationGainToHere');
  @override
  late final GeneratedColumn<double> elevationGainToHere =
      GeneratedColumn<double>(
        'elevation_gain_to_here',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _elevationLossToHereMeta =
      const VerificationMeta('elevationLossToHere');
  @override
  late final GeneratedColumn<double> elevationLossToHere =
      GeneratedColumn<double>(
        'elevation_loss_to_here',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cloudId,
    syncStatus,
    hikeId,
    name,
    description,
    latitude,
    longitude,
    timestamp,
    category,
    altitude,
    elevationGainToHere,
    elevationLossToHere,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hike_waypoints';
  @override
  VerificationContext validateIntegrity(
    Insertable<HikeWaypoint> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cloud_id')) {
      context.handle(
        _cloudIdMeta,
        cloudId.isAcceptableOrUnknown(data['cloud_id']!, _cloudIdMeta),
      );
    }
    if (data.containsKey('hike_id')) {
      context.handle(
        _hikeIdMeta,
        hikeId.isAcceptableOrUnknown(data['hike_id']!, _hikeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_hikeIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('altitude')) {
      context.handle(
        _altitudeMeta,
        altitude.isAcceptableOrUnknown(data['altitude']!, _altitudeMeta),
      );
    }
    if (data.containsKey('elevation_gain_to_here')) {
      context.handle(
        _elevationGainToHereMeta,
        elevationGainToHere.isAcceptableOrUnknown(
          data['elevation_gain_to_here']!,
          _elevationGainToHereMeta,
        ),
      );
    }
    if (data.containsKey('elevation_loss_to_here')) {
      context.handle(
        _elevationLossToHereMeta,
        elevationLossToHere.isAcceptableOrUnknown(
          data['elevation_loss_to_here']!,
          _elevationLossToHereMeta,
        ),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HikeWaypoint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HikeWaypoint(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cloudId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cloud_id'],
      ),
      syncStatus: $HikeWaypointsTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      hikeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hike_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      altitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}altitude'],
      ),
      elevationGainToHere: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}elevation_gain_to_here'],
      ),
      elevationLossToHere: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}elevation_loss_to_here'],
      ),
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $HikeWaypointsTable createAlias(String alias) {
    return $HikeWaypointsTable(attachedDatabase, alias);
  }

  static TypeConverter<SyncStatus, String> $convertersyncStatus =
      const SyncStatusConverter();
}

class HikeWaypoint extends DataClass implements Insertable<HikeWaypoint> {
  final int id;
  final String? cloudId;
  final SyncStatus syncStatus;
  final int hikeId;
  final String name;
  final String? description;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String? category;
  final double? altitude;
  final double? elevationGainToHere;
  final double? elevationLossToHere;
  final bool isDeleted;
  const HikeWaypoint({
    required this.id,
    this.cloudId,
    required this.syncStatus,
    required this.hikeId,
    required this.name,
    this.description,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.category,
    this.altitude,
    this.elevationGainToHere,
    this.elevationLossToHere,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || cloudId != null) {
      map['cloud_id'] = Variable<String>(cloudId);
    }
    {
      map['sync_status'] = Variable<String>(
        $HikeWaypointsTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['hike_id'] = Variable<int>(hikeId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || altitude != null) {
      map['altitude'] = Variable<double>(altitude);
    }
    if (!nullToAbsent || elevationGainToHere != null) {
      map['elevation_gain_to_here'] = Variable<double>(elevationGainToHere);
    }
    if (!nullToAbsent || elevationLossToHere != null) {
      map['elevation_loss_to_here'] = Variable<double>(elevationLossToHere);
    }
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  HikeWaypointsCompanion toCompanion(bool nullToAbsent) {
    return HikeWaypointsCompanion(
      id: Value(id),
      cloudId: cloudId == null && nullToAbsent
          ? const Value.absent()
          : Value(cloudId),
      syncStatus: Value(syncStatus),
      hikeId: Value(hikeId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      latitude: Value(latitude),
      longitude: Value(longitude),
      timestamp: Value(timestamp),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      altitude: altitude == null && nullToAbsent
          ? const Value.absent()
          : Value(altitude),
      elevationGainToHere: elevationGainToHere == null && nullToAbsent
          ? const Value.absent()
          : Value(elevationGainToHere),
      elevationLossToHere: elevationLossToHere == null && nullToAbsent
          ? const Value.absent()
          : Value(elevationLossToHere),
      isDeleted: Value(isDeleted),
    );
  }

  factory HikeWaypoint.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HikeWaypoint(
      id: serializer.fromJson<int>(json['id']),
      cloudId: serializer.fromJson<String?>(json['cloudId']),
      syncStatus: serializer.fromJson<SyncStatus>(json['syncStatus']),
      hikeId: serializer.fromJson<int>(json['hikeId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      category: serializer.fromJson<String?>(json['category']),
      altitude: serializer.fromJson<double?>(json['altitude']),
      elevationGainToHere: serializer.fromJson<double?>(
        json['elevationGainToHere'],
      ),
      elevationLossToHere: serializer.fromJson<double?>(
        json['elevationLossToHere'],
      ),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cloudId': serializer.toJson<String?>(cloudId),
      'syncStatus': serializer.toJson<SyncStatus>(syncStatus),
      'hikeId': serializer.toJson<int>(hikeId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'category': serializer.toJson<String?>(category),
      'altitude': serializer.toJson<double?>(altitude),
      'elevationGainToHere': serializer.toJson<double?>(elevationGainToHere),
      'elevationLossToHere': serializer.toJson<double?>(elevationLossToHere),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  HikeWaypoint copyWith({
    int? id,
    Value<String?> cloudId = const Value.absent(),
    SyncStatus? syncStatus,
    int? hikeId,
    String? name,
    Value<String?> description = const Value.absent(),
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    Value<String?> category = const Value.absent(),
    Value<double?> altitude = const Value.absent(),
    Value<double?> elevationGainToHere = const Value.absent(),
    Value<double?> elevationLossToHere = const Value.absent(),
    bool? isDeleted,
  }) => HikeWaypoint(
    id: id ?? this.id,
    cloudId: cloudId.present ? cloudId.value : this.cloudId,
    syncStatus: syncStatus ?? this.syncStatus,
    hikeId: hikeId ?? this.hikeId,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    timestamp: timestamp ?? this.timestamp,
    category: category.present ? category.value : this.category,
    altitude: altitude.present ? altitude.value : this.altitude,
    elevationGainToHere: elevationGainToHere.present
        ? elevationGainToHere.value
        : this.elevationGainToHere,
    elevationLossToHere: elevationLossToHere.present
        ? elevationLossToHere.value
        : this.elevationLossToHere,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  HikeWaypoint copyWithCompanion(HikeWaypointsCompanion data) {
    return HikeWaypoint(
      id: data.id.present ? data.id.value : this.id,
      cloudId: data.cloudId.present ? data.cloudId.value : this.cloudId,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      hikeId: data.hikeId.present ? data.hikeId.value : this.hikeId,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      category: data.category.present ? data.category.value : this.category,
      altitude: data.altitude.present ? data.altitude.value : this.altitude,
      elevationGainToHere: data.elevationGainToHere.present
          ? data.elevationGainToHere.value
          : this.elevationGainToHere,
      elevationLossToHere: data.elevationLossToHere.present
          ? data.elevationLossToHere.value
          : this.elevationLossToHere,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HikeWaypoint(')
          ..write('id: $id, ')
          ..write('cloudId: $cloudId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('hikeId: $hikeId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('timestamp: $timestamp, ')
          ..write('category: $category, ')
          ..write('altitude: $altitude, ')
          ..write('elevationGainToHere: $elevationGainToHere, ')
          ..write('elevationLossToHere: $elevationLossToHere, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cloudId,
    syncStatus,
    hikeId,
    name,
    description,
    latitude,
    longitude,
    timestamp,
    category,
    altitude,
    elevationGainToHere,
    elevationLossToHere,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HikeWaypoint &&
          other.id == this.id &&
          other.cloudId == this.cloudId &&
          other.syncStatus == this.syncStatus &&
          other.hikeId == this.hikeId &&
          other.name == this.name &&
          other.description == this.description &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.timestamp == this.timestamp &&
          other.category == this.category &&
          other.altitude == this.altitude &&
          other.elevationGainToHere == this.elevationGainToHere &&
          other.elevationLossToHere == this.elevationLossToHere &&
          other.isDeleted == this.isDeleted);
}

class HikeWaypointsCompanion extends UpdateCompanion<HikeWaypoint> {
  final Value<int> id;
  final Value<String?> cloudId;
  final Value<SyncStatus> syncStatus;
  final Value<int> hikeId;
  final Value<String> name;
  final Value<String?> description;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<DateTime> timestamp;
  final Value<String?> category;
  final Value<double?> altitude;
  final Value<double?> elevationGainToHere;
  final Value<double?> elevationLossToHere;
  final Value<bool> isDeleted;
  const HikeWaypointsCompanion({
    this.id = const Value.absent(),
    this.cloudId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.hikeId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.category = const Value.absent(),
    this.altitude = const Value.absent(),
    this.elevationGainToHere = const Value.absent(),
    this.elevationLossToHere = const Value.absent(),
    this.isDeleted = const Value.absent(),
  });
  HikeWaypointsCompanion.insert({
    this.id = const Value.absent(),
    this.cloudId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required int hikeId,
    required String name,
    this.description = const Value.absent(),
    required double latitude,
    required double longitude,
    required DateTime timestamp,
    this.category = const Value.absent(),
    this.altitude = const Value.absent(),
    this.elevationGainToHere = const Value.absent(),
    this.elevationLossToHere = const Value.absent(),
    this.isDeleted = const Value.absent(),
  }) : hikeId = Value(hikeId),
       name = Value(name),
       latitude = Value(latitude),
       longitude = Value(longitude),
       timestamp = Value(timestamp);
  static Insertable<HikeWaypoint> custom({
    Expression<int>? id,
    Expression<String>? cloudId,
    Expression<String>? syncStatus,
    Expression<int>? hikeId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<DateTime>? timestamp,
    Expression<String>? category,
    Expression<double>? altitude,
    Expression<double>? elevationGainToHere,
    Expression<double>? elevationLossToHere,
    Expression<bool>? isDeleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cloudId != null) 'cloud_id': cloudId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (hikeId != null) 'hike_id': hikeId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (timestamp != null) 'timestamp': timestamp,
      if (category != null) 'category': category,
      if (altitude != null) 'altitude': altitude,
      if (elevationGainToHere != null)
        'elevation_gain_to_here': elevationGainToHere,
      if (elevationLossToHere != null)
        'elevation_loss_to_here': elevationLossToHere,
      if (isDeleted != null) 'is_deleted': isDeleted,
    });
  }

  HikeWaypointsCompanion copyWith({
    Value<int>? id,
    Value<String?>? cloudId,
    Value<SyncStatus>? syncStatus,
    Value<int>? hikeId,
    Value<String>? name,
    Value<String?>? description,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<DateTime>? timestamp,
    Value<String?>? category,
    Value<double?>? altitude,
    Value<double?>? elevationGainToHere,
    Value<double?>? elevationLossToHere,
    Value<bool>? isDeleted,
  }) {
    return HikeWaypointsCompanion(
      id: id ?? this.id,
      cloudId: cloudId ?? this.cloudId,
      syncStatus: syncStatus ?? this.syncStatus,
      hikeId: hikeId ?? this.hikeId,
      name: name ?? this.name,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      category: category ?? this.category,
      altitude: altitude ?? this.altitude,
      elevationGainToHere: elevationGainToHere ?? this.elevationGainToHere,
      elevationLossToHere: elevationLossToHere ?? this.elevationLossToHere,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cloudId.present) {
      map['cloud_id'] = Variable<String>(cloudId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(
        $HikeWaypointsTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (hikeId.present) {
      map['hike_id'] = Variable<int>(hikeId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (altitude.present) {
      map['altitude'] = Variable<double>(altitude.value);
    }
    if (elevationGainToHere.present) {
      map['elevation_gain_to_here'] = Variable<double>(
        elevationGainToHere.value,
      );
    }
    if (elevationLossToHere.present) {
      map['elevation_loss_to_here'] = Variable<double>(
        elevationLossToHere.value,
      );
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HikeWaypointsCompanion(')
          ..write('id: $id, ')
          ..write('cloudId: $cloudId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('hikeId: $hikeId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('timestamp: $timestamp, ')
          ..write('category: $category, ')
          ..write('altitude: $altitude, ')
          ..write('elevationGainToHere: $elevationGainToHere, ')
          ..write('elevationLossToHere: $elevationLossToHere, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }
}

class $HikePhotosTable extends HikePhotos
    with TableInfo<$HikePhotosTable, HikePhoto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HikePhotosTable(this.attachedDatabase, [this._alias]);
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
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, String> syncStatus =
      GeneratedColumn<String>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(SyncStatus.pending.name),
      ).withConverter<SyncStatus>($HikePhotosTable.$convertersyncStatus);
  static const VerificationMeta _cloudIdMeta = const VerificationMeta(
    'cloudId',
  );
  @override
  late final GeneratedColumn<String> cloudId = GeneratedColumn<String>(
    'cloud_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hikeIdMeta = const VerificationMeta('hikeId');
  @override
  late final GeneratedColumn<int> hikeId = GeneratedColumn<int>(
    'hike_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES hikes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _waypointIdMeta = const VerificationMeta(
    'waypointId',
  );
  @override
  late final GeneratedColumn<int> waypointId = GeneratedColumn<int>(
    'waypoint_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES hike_waypoints (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _photoUrlMeta = const VerificationMeta(
    'photoUrl',
  );
  @override
  late final GeneratedColumn<String> photoUrl = GeneratedColumn<String>(
    'photo_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _capturedAtMeta = const VerificationMeta(
    'capturedAt',
  );
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
    'captured_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncStatus,
    cloudId,
    hikeId,
    waypointId,
    photoUrl,
    latitude,
    longitude,
    capturedAt,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hike_photos';
  @override
  VerificationContext validateIntegrity(
    Insertable<HikePhoto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cloud_id')) {
      context.handle(
        _cloudIdMeta,
        cloudId.isAcceptableOrUnknown(data['cloud_id']!, _cloudIdMeta),
      );
    }
    if (data.containsKey('hike_id')) {
      context.handle(
        _hikeIdMeta,
        hikeId.isAcceptableOrUnknown(data['hike_id']!, _hikeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_hikeIdMeta);
    }
    if (data.containsKey('waypoint_id')) {
      context.handle(
        _waypointIdMeta,
        waypointId.isAcceptableOrUnknown(data['waypoint_id']!, _waypointIdMeta),
      );
    }
    if (data.containsKey('photo_url')) {
      context.handle(
        _photoUrlMeta,
        photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_photoUrlMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('captured_at')) {
      context.handle(
        _capturedAtMeta,
        capturedAt.isAcceptableOrUnknown(data['captured_at']!, _capturedAtMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HikePhoto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HikePhoto(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      syncStatus: $HikePhotosTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      cloudId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cloud_id'],
      ),
      hikeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hike_id'],
      )!,
      waypointId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}waypoint_id'],
      ),
      photoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_url'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      capturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}captured_at'],
      ),
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $HikePhotosTable createAlias(String alias) {
    return $HikePhotosTable(attachedDatabase, alias);
  }

  static TypeConverter<SyncStatus, String> $convertersyncStatus =
      const SyncStatusConverter();
}

class HikePhoto extends DataClass implements Insertable<HikePhoto> {
  final int id;
  final SyncStatus syncStatus;
  final String? cloudId;
  final int hikeId;
  final int? waypointId;
  final String photoUrl;
  final double? latitude;
  final double? longitude;
  final DateTime? capturedAt;
  final bool isDeleted;
  const HikePhoto({
    required this.id,
    required this.syncStatus,
    this.cloudId,
    required this.hikeId,
    this.waypointId,
    required this.photoUrl,
    this.latitude,
    this.longitude,
    this.capturedAt,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['sync_status'] = Variable<String>(
        $HikePhotosTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    if (!nullToAbsent || cloudId != null) {
      map['cloud_id'] = Variable<String>(cloudId);
    }
    map['hike_id'] = Variable<int>(hikeId);
    if (!nullToAbsent || waypointId != null) {
      map['waypoint_id'] = Variable<int>(waypointId);
    }
    map['photo_url'] = Variable<String>(photoUrl);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || capturedAt != null) {
      map['captured_at'] = Variable<DateTime>(capturedAt);
    }
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  HikePhotosCompanion toCompanion(bool nullToAbsent) {
    return HikePhotosCompanion(
      id: Value(id),
      syncStatus: Value(syncStatus),
      cloudId: cloudId == null && nullToAbsent
          ? const Value.absent()
          : Value(cloudId),
      hikeId: Value(hikeId),
      waypointId: waypointId == null && nullToAbsent
          ? const Value.absent()
          : Value(waypointId),
      photoUrl: Value(photoUrl),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      capturedAt: capturedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(capturedAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory HikePhoto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HikePhoto(
      id: serializer.fromJson<int>(json['id']),
      syncStatus: serializer.fromJson<SyncStatus>(json['syncStatus']),
      cloudId: serializer.fromJson<String?>(json['cloudId']),
      hikeId: serializer.fromJson<int>(json['hikeId']),
      waypointId: serializer.fromJson<int?>(json['waypointId']),
      photoUrl: serializer.fromJson<String>(json['photoUrl']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      capturedAt: serializer.fromJson<DateTime?>(json['capturedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'syncStatus': serializer.toJson<SyncStatus>(syncStatus),
      'cloudId': serializer.toJson<String?>(cloudId),
      'hikeId': serializer.toJson<int>(hikeId),
      'waypointId': serializer.toJson<int?>(waypointId),
      'photoUrl': serializer.toJson<String>(photoUrl),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'capturedAt': serializer.toJson<DateTime?>(capturedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  HikePhoto copyWith({
    int? id,
    SyncStatus? syncStatus,
    Value<String?> cloudId = const Value.absent(),
    int? hikeId,
    Value<int?> waypointId = const Value.absent(),
    String? photoUrl,
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    Value<DateTime?> capturedAt = const Value.absent(),
    bool? isDeleted,
  }) => HikePhoto(
    id: id ?? this.id,
    syncStatus: syncStatus ?? this.syncStatus,
    cloudId: cloudId.present ? cloudId.value : this.cloudId,
    hikeId: hikeId ?? this.hikeId,
    waypointId: waypointId.present ? waypointId.value : this.waypointId,
    photoUrl: photoUrl ?? this.photoUrl,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    capturedAt: capturedAt.present ? capturedAt.value : this.capturedAt,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  HikePhoto copyWithCompanion(HikePhotosCompanion data) {
    return HikePhoto(
      id: data.id.present ? data.id.value : this.id,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      cloudId: data.cloudId.present ? data.cloudId.value : this.cloudId,
      hikeId: data.hikeId.present ? data.hikeId.value : this.hikeId,
      waypointId: data.waypointId.present
          ? data.waypointId.value
          : this.waypointId,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      capturedAt: data.capturedAt.present
          ? data.capturedAt.value
          : this.capturedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HikePhoto(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('cloudId: $cloudId, ')
          ..write('hikeId: $hikeId, ')
          ..write('waypointId: $waypointId, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncStatus,
    cloudId,
    hikeId,
    waypointId,
    photoUrl,
    latitude,
    longitude,
    capturedAt,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HikePhoto &&
          other.id == this.id &&
          other.syncStatus == this.syncStatus &&
          other.cloudId == this.cloudId &&
          other.hikeId == this.hikeId &&
          other.waypointId == this.waypointId &&
          other.photoUrl == this.photoUrl &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.capturedAt == this.capturedAt &&
          other.isDeleted == this.isDeleted);
}

class HikePhotosCompanion extends UpdateCompanion<HikePhoto> {
  final Value<int> id;
  final Value<SyncStatus> syncStatus;
  final Value<String?> cloudId;
  final Value<int> hikeId;
  final Value<int?> waypointId;
  final Value<String> photoUrl;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<DateTime?> capturedAt;
  final Value<bool> isDeleted;
  const HikePhotosCompanion({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.cloudId = const Value.absent(),
    this.hikeId = const Value.absent(),
    this.waypointId = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
  });
  HikePhotosCompanion.insert({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.cloudId = const Value.absent(),
    required int hikeId,
    this.waypointId = const Value.absent(),
    required String photoUrl,
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
  }) : hikeId = Value(hikeId),
       photoUrl = Value(photoUrl);
  static Insertable<HikePhoto> custom({
    Expression<int>? id,
    Expression<String>? syncStatus,
    Expression<String>? cloudId,
    Expression<int>? hikeId,
    Expression<int>? waypointId,
    Expression<String>? photoUrl,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<DateTime>? capturedAt,
    Expression<bool>? isDeleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (cloudId != null) 'cloud_id': cloudId,
      if (hikeId != null) 'hike_id': hikeId,
      if (waypointId != null) 'waypoint_id': waypointId,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
    });
  }

  HikePhotosCompanion copyWith({
    Value<int>? id,
    Value<SyncStatus>? syncStatus,
    Value<String?>? cloudId,
    Value<int>? hikeId,
    Value<int?>? waypointId,
    Value<String>? photoUrl,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<DateTime?>? capturedAt,
    Value<bool>? isDeleted,
  }) {
    return HikePhotosCompanion(
      id: id ?? this.id,
      syncStatus: syncStatus ?? this.syncStatus,
      cloudId: cloudId ?? this.cloudId,
      hikeId: hikeId ?? this.hikeId,
      waypointId: waypointId ?? this.waypointId,
      photoUrl: photoUrl ?? this.photoUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      capturedAt: capturedAt ?? this.capturedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(
        $HikePhotosTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (cloudId.present) {
      map['cloud_id'] = Variable<String>(cloudId.value);
    }
    if (hikeId.present) {
      map['hike_id'] = Variable<int>(hikeId.value);
    }
    if (waypointId.present) {
      map['waypoint_id'] = Variable<int>(waypointId.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HikePhotosCompanion(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('cloudId: $cloudId, ')
          ..write('hikeId: $hikeId, ')
          ..write('waypointId: $waypointId, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }
}

class $RoutePointsTable extends RoutePoints
    with TableInfo<$RoutePointsTable, RoutePoint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutePointsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _cloudIdMeta = const VerificationMeta(
    'cloudId',
  );
  @override
  late final GeneratedColumn<String> cloudId = GeneratedColumn<String>(
    'cloud_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, String> syncStatus =
      GeneratedColumn<String>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(SyncStatus.pending.name),
      ).withConverter<SyncStatus>($RoutePointsTable.$convertersyncStatus);
  static const VerificationMeta _hikeIdMeta = const VerificationMeta('hikeId');
  @override
  late final GeneratedColumn<int> hikeId = GeneratedColumn<int>(
    'hike_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES hikes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _altitudeMeta = const VerificationMeta(
    'altitude',
  );
  @override
  late final GeneratedColumn<double> altitude = GeneratedColumn<double>(
    'altitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speedKmhMeta = const VerificationMeta(
    'speedKmh',
  );
  @override
  late final GeneratedColumn<double> speedKmh = GeneratedColumn<double>(
    'speed_kmh',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cloudId,
    syncStatus,
    hikeId,
    latitude,
    longitude,
    altitude,
    timestamp,
    speedKmh,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'route_points';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutePoint> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cloud_id')) {
      context.handle(
        _cloudIdMeta,
        cloudId.isAcceptableOrUnknown(data['cloud_id']!, _cloudIdMeta),
      );
    }
    if (data.containsKey('hike_id')) {
      context.handle(
        _hikeIdMeta,
        hikeId.isAcceptableOrUnknown(data['hike_id']!, _hikeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_hikeIdMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('altitude')) {
      context.handle(
        _altitudeMeta,
        altitude.isAcceptableOrUnknown(data['altitude']!, _altitudeMeta),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('speed_kmh')) {
      context.handle(
        _speedKmhMeta,
        speedKmh.isAcceptableOrUnknown(data['speed_kmh']!, _speedKmhMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoutePoint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutePoint(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cloudId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cloud_id'],
      ),
      syncStatus: $RoutePointsTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      hikeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hike_id'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      altitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}altitude'],
      ),
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      speedKmh: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}speed_kmh'],
      ),
    );
  }

  @override
  $RoutePointsTable createAlias(String alias) {
    return $RoutePointsTable(attachedDatabase, alias);
  }

  static TypeConverter<SyncStatus, String> $convertersyncStatus =
      const SyncStatusConverter();
}

class RoutePoint extends DataClass implements Insertable<RoutePoint> {
  final int id;
  final String? cloudId;
  final SyncStatus syncStatus;
  final int hikeId;
  final double latitude;
  final double longitude;
  final double? altitude;
  final DateTime timestamp;
  final double? speedKmh;
  const RoutePoint({
    required this.id,
    this.cloudId,
    required this.syncStatus,
    required this.hikeId,
    required this.latitude,
    required this.longitude,
    this.altitude,
    required this.timestamp,
    this.speedKmh,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || cloudId != null) {
      map['cloud_id'] = Variable<String>(cloudId);
    }
    {
      map['sync_status'] = Variable<String>(
        $RoutePointsTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['hike_id'] = Variable<int>(hikeId);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    if (!nullToAbsent || altitude != null) {
      map['altitude'] = Variable<double>(altitude);
    }
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || speedKmh != null) {
      map['speed_kmh'] = Variable<double>(speedKmh);
    }
    return map;
  }

  RoutePointsCompanion toCompanion(bool nullToAbsent) {
    return RoutePointsCompanion(
      id: Value(id),
      cloudId: cloudId == null && nullToAbsent
          ? const Value.absent()
          : Value(cloudId),
      syncStatus: Value(syncStatus),
      hikeId: Value(hikeId),
      latitude: Value(latitude),
      longitude: Value(longitude),
      altitude: altitude == null && nullToAbsent
          ? const Value.absent()
          : Value(altitude),
      timestamp: Value(timestamp),
      speedKmh: speedKmh == null && nullToAbsent
          ? const Value.absent()
          : Value(speedKmh),
    );
  }

  factory RoutePoint.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutePoint(
      id: serializer.fromJson<int>(json['id']),
      cloudId: serializer.fromJson<String?>(json['cloudId']),
      syncStatus: serializer.fromJson<SyncStatus>(json['syncStatus']),
      hikeId: serializer.fromJson<int>(json['hikeId']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      altitude: serializer.fromJson<double?>(json['altitude']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      speedKmh: serializer.fromJson<double?>(json['speedKmh']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cloudId': serializer.toJson<String?>(cloudId),
      'syncStatus': serializer.toJson<SyncStatus>(syncStatus),
      'hikeId': serializer.toJson<int>(hikeId),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'altitude': serializer.toJson<double?>(altitude),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'speedKmh': serializer.toJson<double?>(speedKmh),
    };
  }

  RoutePoint copyWith({
    int? id,
    Value<String?> cloudId = const Value.absent(),
    SyncStatus? syncStatus,
    int? hikeId,
    double? latitude,
    double? longitude,
    Value<double?> altitude = const Value.absent(),
    DateTime? timestamp,
    Value<double?> speedKmh = const Value.absent(),
  }) => RoutePoint(
    id: id ?? this.id,
    cloudId: cloudId.present ? cloudId.value : this.cloudId,
    syncStatus: syncStatus ?? this.syncStatus,
    hikeId: hikeId ?? this.hikeId,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    altitude: altitude.present ? altitude.value : this.altitude,
    timestamp: timestamp ?? this.timestamp,
    speedKmh: speedKmh.present ? speedKmh.value : this.speedKmh,
  );
  RoutePoint copyWithCompanion(RoutePointsCompanion data) {
    return RoutePoint(
      id: data.id.present ? data.id.value : this.id,
      cloudId: data.cloudId.present ? data.cloudId.value : this.cloudId,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      hikeId: data.hikeId.present ? data.hikeId.value : this.hikeId,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      altitude: data.altitude.present ? data.altitude.value : this.altitude,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      speedKmh: data.speedKmh.present ? data.speedKmh.value : this.speedKmh,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutePoint(')
          ..write('id: $id, ')
          ..write('cloudId: $cloudId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('hikeId: $hikeId, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('altitude: $altitude, ')
          ..write('timestamp: $timestamp, ')
          ..write('speedKmh: $speedKmh')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cloudId,
    syncStatus,
    hikeId,
    latitude,
    longitude,
    altitude,
    timestamp,
    speedKmh,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutePoint &&
          other.id == this.id &&
          other.cloudId == this.cloudId &&
          other.syncStatus == this.syncStatus &&
          other.hikeId == this.hikeId &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.altitude == this.altitude &&
          other.timestamp == this.timestamp &&
          other.speedKmh == this.speedKmh);
}

class RoutePointsCompanion extends UpdateCompanion<RoutePoint> {
  final Value<int> id;
  final Value<String?> cloudId;
  final Value<SyncStatus> syncStatus;
  final Value<int> hikeId;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<double?> altitude;
  final Value<DateTime> timestamp;
  final Value<double?> speedKmh;
  const RoutePointsCompanion({
    this.id = const Value.absent(),
    this.cloudId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.hikeId = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.altitude = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.speedKmh = const Value.absent(),
  });
  RoutePointsCompanion.insert({
    this.id = const Value.absent(),
    this.cloudId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required int hikeId,
    required double latitude,
    required double longitude,
    this.altitude = const Value.absent(),
    required DateTime timestamp,
    this.speedKmh = const Value.absent(),
  }) : hikeId = Value(hikeId),
       latitude = Value(latitude),
       longitude = Value(longitude),
       timestamp = Value(timestamp);
  static Insertable<RoutePoint> custom({
    Expression<int>? id,
    Expression<String>? cloudId,
    Expression<String>? syncStatus,
    Expression<int>? hikeId,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? altitude,
    Expression<DateTime>? timestamp,
    Expression<double>? speedKmh,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cloudId != null) 'cloud_id': cloudId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (hikeId != null) 'hike_id': hikeId,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (altitude != null) 'altitude': altitude,
      if (timestamp != null) 'timestamp': timestamp,
      if (speedKmh != null) 'speed_kmh': speedKmh,
    });
  }

  RoutePointsCompanion copyWith({
    Value<int>? id,
    Value<String?>? cloudId,
    Value<SyncStatus>? syncStatus,
    Value<int>? hikeId,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<double?>? altitude,
    Value<DateTime>? timestamp,
    Value<double?>? speedKmh,
  }) {
    return RoutePointsCompanion(
      id: id ?? this.id,
      cloudId: cloudId ?? this.cloudId,
      syncStatus: syncStatus ?? this.syncStatus,
      hikeId: hikeId ?? this.hikeId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      timestamp: timestamp ?? this.timestamp,
      speedKmh: speedKmh ?? this.speedKmh,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cloudId.present) {
      map['cloud_id'] = Variable<String>(cloudId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(
        $RoutePointsTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (hikeId.present) {
      map['hike_id'] = Variable<int>(hikeId.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (altitude.present) {
      map['altitude'] = Variable<double>(altitude.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (speedKmh.present) {
      map['speed_kmh'] = Variable<double>(speedKmh.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutePointsCompanion(')
          ..write('id: $id, ')
          ..write('cloudId: $cloudId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('hikeId: $hikeId, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('altitude: $altitude, ')
          ..write('timestamp: $timestamp, ')
          ..write('speedKmh: $speedKmh')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $HikesTable hikes = $HikesTable(this);
  late final $HikeWaypointsTable hikeWaypoints = $HikeWaypointsTable(this);
  late final $HikePhotosTable hikePhotos = $HikePhotosTable(this);
  late final $RoutePointsTable routePoints = $RoutePointsTable(this);
  late final HikeDao hikeDao = HikeDao(this as AppDatabase);
  late final HikePhotoDao hikePhotoDao = HikePhotoDao(this as AppDatabase);
  late final HikeWaypointDao hikeWaypointDao = HikeWaypointDao(
    this as AppDatabase,
  );
  late final RoutePointDao routePointDao = RoutePointDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    hikes,
    hikeWaypoints,
    hikePhotos,
    routePoints,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'hikes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('hike_waypoints', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'hikes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('hike_photos', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'hike_waypoints',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('hike_photos', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'hikes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('route_points', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$HikesTableCreateCompanionBuilder =
    HikesCompanion Function({
      Value<int> id,
      required String userId,
      Value<String?> cloudId,
      required String mountainName,
      required DateTime hikeDate,
      Value<int?> durationMinutes,
      Value<double?> totalDistanceKm,
      Value<double?> totalElevationGainMeters,
      Value<double?> totalElevationLossMeters,
      Value<double?> averageSpeedKmh,
      Value<double?> maxSpeedKmh,
      Value<String?> startWeatherCondition,
      Value<double?> startTemperature,
      Value<String?> partners,
      Value<String?> notes,
      Value<SyncStatus> syncStatus,
      Value<bool> isDeleted,
    });
typedef $$HikesTableUpdateCompanionBuilder =
    HikesCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<String?> cloudId,
      Value<String> mountainName,
      Value<DateTime> hikeDate,
      Value<int?> durationMinutes,
      Value<double?> totalDistanceKm,
      Value<double?> totalElevationGainMeters,
      Value<double?> totalElevationLossMeters,
      Value<double?> averageSpeedKmh,
      Value<double?> maxSpeedKmh,
      Value<String?> startWeatherCondition,
      Value<double?> startTemperature,
      Value<String?> partners,
      Value<String?> notes,
      Value<SyncStatus> syncStatus,
      Value<bool> isDeleted,
    });

final class $$HikesTableReferences
    extends BaseReferences<_$AppDatabase, $HikesTable, Hike> {
  $$HikesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$HikeWaypointsTable, List<HikeWaypoint>>
  _hikeWaypointsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.hikeWaypoints,
    aliasName: $_aliasNameGenerator(db.hikes.id, db.hikeWaypoints.hikeId),
  );

  $$HikeWaypointsTableProcessedTableManager get hikeWaypointsRefs {
    final manager = $$HikeWaypointsTableTableManager(
      $_db,
      $_db.hikeWaypoints,
    ).filter((f) => f.hikeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_hikeWaypointsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$HikePhotosTable, List<HikePhoto>>
  _hikePhotosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.hikePhotos,
    aliasName: $_aliasNameGenerator(db.hikes.id, db.hikePhotos.hikeId),
  );

  $$HikePhotosTableProcessedTableManager get hikePhotosRefs {
    final manager = $$HikePhotosTableTableManager(
      $_db,
      $_db.hikePhotos,
    ).filter((f) => f.hikeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_hikePhotosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RoutePointsTable, List<RoutePoint>>
  _routePointsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.routePoints,
    aliasName: $_aliasNameGenerator(db.hikes.id, db.routePoints.hikeId),
  );

  $$RoutePointsTableProcessedTableManager get routePointsRefs {
    final manager = $$RoutePointsTableTableManager(
      $_db,
      $_db.routePoints,
    ).filter((f) => f.hikeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_routePointsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$HikesTableFilterComposer extends Composer<_$AppDatabase, $HikesTable> {
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

  ColumnFilters<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mountainName => $composableBuilder(
    column: $table.mountainName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get hikeDate => $composableBuilder(
    column: $table.hikeDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalDistanceKm => $composableBuilder(
    column: $table.totalDistanceKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalElevationGainMeters => $composableBuilder(
    column: $table.totalElevationGainMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalElevationLossMeters => $composableBuilder(
    column: $table.totalElevationLossMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get averageSpeedKmh => $composableBuilder(
    column: $table.averageSpeedKmh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxSpeedKmh => $composableBuilder(
    column: $table.maxSpeedKmh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startWeatherCondition => $composableBuilder(
    column: $table.startWeatherCondition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get startTemperature => $composableBuilder(
    column: $table.startTemperature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partners => $composableBuilder(
    column: $table.partners,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, String>
  get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> hikeWaypointsRefs(
    Expression<bool> Function($$HikeWaypointsTableFilterComposer f) f,
  ) {
    final $$HikeWaypointsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.hikeWaypoints,
      getReferencedColumn: (t) => t.hikeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HikeWaypointsTableFilterComposer(
            $db: $db,
            $table: $db.hikeWaypoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> hikePhotosRefs(
    Expression<bool> Function($$HikePhotosTableFilterComposer f) f,
  ) {
    final $$HikePhotosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.hikePhotos,
      getReferencedColumn: (t) => t.hikeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HikePhotosTableFilterComposer(
            $db: $db,
            $table: $db.hikePhotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> routePointsRefs(
    Expression<bool> Function($$RoutePointsTableFilterComposer f) f,
  ) {
    final $$RoutePointsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routePoints,
      getReferencedColumn: (t) => t.hikeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutePointsTableFilterComposer(
            $db: $db,
            $table: $db.routePoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HikesTableOrderingComposer
    extends Composer<_$AppDatabase, $HikesTable> {
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

  ColumnOrderings<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mountainName => $composableBuilder(
    column: $table.mountainName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get hikeDate => $composableBuilder(
    column: $table.hikeDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalDistanceKm => $composableBuilder(
    column: $table.totalDistanceKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalElevationGainMeters => $composableBuilder(
    column: $table.totalElevationGainMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalElevationLossMeters => $composableBuilder(
    column: $table.totalElevationLossMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get averageSpeedKmh => $composableBuilder(
    column: $table.averageSpeedKmh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxSpeedKmh => $composableBuilder(
    column: $table.maxSpeedKmh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startWeatherCondition => $composableBuilder(
    column: $table.startWeatherCondition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get startTemperature => $composableBuilder(
    column: $table.startTemperature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partners => $composableBuilder(
    column: $table.partners,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HikesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HikesTable> {
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

  GeneratedColumn<String> get cloudId =>
      $composableBuilder(column: $table.cloudId, builder: (column) => column);

  GeneratedColumn<String> get mountainName => $composableBuilder(
    column: $table.mountainName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get hikeDate =>
      $composableBuilder(column: $table.hikeDate, builder: (column) => column);

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalDistanceKm => $composableBuilder(
    column: $table.totalDistanceKm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalElevationGainMeters => $composableBuilder(
    column: $table.totalElevationGainMeters,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalElevationLossMeters => $composableBuilder(
    column: $table.totalElevationLossMeters,
    builder: (column) => column,
  );

  GeneratedColumn<double> get averageSpeedKmh => $composableBuilder(
    column: $table.averageSpeedKmh,
    builder: (column) => column,
  );

  GeneratedColumn<double> get maxSpeedKmh => $composableBuilder(
    column: $table.maxSpeedKmh,
    builder: (column) => column,
  );

  GeneratedColumn<String> get startWeatherCondition => $composableBuilder(
    column: $table.startWeatherCondition,
    builder: (column) => column,
  );

  GeneratedColumn<double> get startTemperature => $composableBuilder(
    column: $table.startTemperature,
    builder: (column) => column,
  );

  GeneratedColumn<String> get partners =>
      $composableBuilder(column: $table.partners, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, String> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  Expression<T> hikeWaypointsRefs<T extends Object>(
    Expression<T> Function($$HikeWaypointsTableAnnotationComposer a) f,
  ) {
    final $$HikeWaypointsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.hikeWaypoints,
      getReferencedColumn: (t) => t.hikeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HikeWaypointsTableAnnotationComposer(
            $db: $db,
            $table: $db.hikeWaypoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> hikePhotosRefs<T extends Object>(
    Expression<T> Function($$HikePhotosTableAnnotationComposer a) f,
  ) {
    final $$HikePhotosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.hikePhotos,
      getReferencedColumn: (t) => t.hikeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HikePhotosTableAnnotationComposer(
            $db: $db,
            $table: $db.hikePhotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> routePointsRefs<T extends Object>(
    Expression<T> Function($$RoutePointsTableAnnotationComposer a) f,
  ) {
    final $$RoutePointsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routePoints,
      getReferencedColumn: (t) => t.hikeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutePointsTableAnnotationComposer(
            $db: $db,
            $table: $db.routePoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HikesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HikesTable,
          Hike,
          $$HikesTableFilterComposer,
          $$HikesTableOrderingComposer,
          $$HikesTableAnnotationComposer,
          $$HikesTableCreateCompanionBuilder,
          $$HikesTableUpdateCompanionBuilder,
          (Hike, $$HikesTableReferences),
          Hike,
          PrefetchHooks Function({
            bool hikeWaypointsRefs,
            bool hikePhotosRefs,
            bool routePointsRefs,
          })
        > {
  $$HikesTableTableManager(_$AppDatabase db, $HikesTable table)
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
                Value<String?> cloudId = const Value.absent(),
                Value<String> mountainName = const Value.absent(),
                Value<DateTime> hikeDate = const Value.absent(),
                Value<int?> durationMinutes = const Value.absent(),
                Value<double?> totalDistanceKm = const Value.absent(),
                Value<double?> totalElevationGainMeters = const Value.absent(),
                Value<double?> totalElevationLossMeters = const Value.absent(),
                Value<double?> averageSpeedKmh = const Value.absent(),
                Value<double?> maxSpeedKmh = const Value.absent(),
                Value<String?> startWeatherCondition = const Value.absent(),
                Value<double?> startTemperature = const Value.absent(),
                Value<String?> partners = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
              }) => HikesCompanion(
                id: id,
                userId: userId,
                cloudId: cloudId,
                mountainName: mountainName,
                hikeDate: hikeDate,
                durationMinutes: durationMinutes,
                totalDistanceKm: totalDistanceKm,
                totalElevationGainMeters: totalElevationGainMeters,
                totalElevationLossMeters: totalElevationLossMeters,
                averageSpeedKmh: averageSpeedKmh,
                maxSpeedKmh: maxSpeedKmh,
                startWeatherCondition: startWeatherCondition,
                startTemperature: startTemperature,
                partners: partners,
                notes: notes,
                syncStatus: syncStatus,
                isDeleted: isDeleted,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String userId,
                Value<String?> cloudId = const Value.absent(),
                required String mountainName,
                required DateTime hikeDate,
                Value<int?> durationMinutes = const Value.absent(),
                Value<double?> totalDistanceKm = const Value.absent(),
                Value<double?> totalElevationGainMeters = const Value.absent(),
                Value<double?> totalElevationLossMeters = const Value.absent(),
                Value<double?> averageSpeedKmh = const Value.absent(),
                Value<double?> maxSpeedKmh = const Value.absent(),
                Value<String?> startWeatherCondition = const Value.absent(),
                Value<double?> startTemperature = const Value.absent(),
                Value<String?> partners = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
              }) => HikesCompanion.insert(
                id: id,
                userId: userId,
                cloudId: cloudId,
                mountainName: mountainName,
                hikeDate: hikeDate,
                durationMinutes: durationMinutes,
                totalDistanceKm: totalDistanceKm,
                totalElevationGainMeters: totalElevationGainMeters,
                totalElevationLossMeters: totalElevationLossMeters,
                averageSpeedKmh: averageSpeedKmh,
                maxSpeedKmh: maxSpeedKmh,
                startWeatherCondition: startWeatherCondition,
                startTemperature: startTemperature,
                partners: partners,
                notes: notes,
                syncStatus: syncStatus,
                isDeleted: isDeleted,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$HikesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                hikeWaypointsRefs = false,
                hikePhotosRefs = false,
                routePointsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (hikeWaypointsRefs) db.hikeWaypoints,
                    if (hikePhotosRefs) db.hikePhotos,
                    if (routePointsRefs) db.routePoints,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (hikeWaypointsRefs)
                        await $_getPrefetchedData<
                          Hike,
                          $HikesTable,
                          HikeWaypoint
                        >(
                          currentTable: table,
                          referencedTable: $$HikesTableReferences
                              ._hikeWaypointsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$HikesTableReferences(
                                db,
                                table,
                                p0,
                              ).hikeWaypointsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.hikeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (hikePhotosRefs)
                        await $_getPrefetchedData<Hike, $HikesTable, HikePhoto>(
                          currentTable: table,
                          referencedTable: $$HikesTableReferences
                              ._hikePhotosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$HikesTableReferences(
                                db,
                                table,
                                p0,
                              ).hikePhotosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.hikeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (routePointsRefs)
                        await $_getPrefetchedData<
                          Hike,
                          $HikesTable,
                          RoutePoint
                        >(
                          currentTable: table,
                          referencedTable: $$HikesTableReferences
                              ._routePointsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$HikesTableReferences(
                                db,
                                table,
                                p0,
                              ).routePointsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.hikeId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$HikesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HikesTable,
      Hike,
      $$HikesTableFilterComposer,
      $$HikesTableOrderingComposer,
      $$HikesTableAnnotationComposer,
      $$HikesTableCreateCompanionBuilder,
      $$HikesTableUpdateCompanionBuilder,
      (Hike, $$HikesTableReferences),
      Hike,
      PrefetchHooks Function({
        bool hikeWaypointsRefs,
        bool hikePhotosRefs,
        bool routePointsRefs,
      })
    >;
typedef $$HikeWaypointsTableCreateCompanionBuilder =
    HikeWaypointsCompanion Function({
      Value<int> id,
      Value<String?> cloudId,
      Value<SyncStatus> syncStatus,
      required int hikeId,
      required String name,
      Value<String?> description,
      required double latitude,
      required double longitude,
      required DateTime timestamp,
      Value<String?> category,
      Value<double?> altitude,
      Value<double?> elevationGainToHere,
      Value<double?> elevationLossToHere,
      Value<bool> isDeleted,
    });
typedef $$HikeWaypointsTableUpdateCompanionBuilder =
    HikeWaypointsCompanion Function({
      Value<int> id,
      Value<String?> cloudId,
      Value<SyncStatus> syncStatus,
      Value<int> hikeId,
      Value<String> name,
      Value<String?> description,
      Value<double> latitude,
      Value<double> longitude,
      Value<DateTime> timestamp,
      Value<String?> category,
      Value<double?> altitude,
      Value<double?> elevationGainToHere,
      Value<double?> elevationLossToHere,
      Value<bool> isDeleted,
    });

final class $$HikeWaypointsTableReferences
    extends BaseReferences<_$AppDatabase, $HikeWaypointsTable, HikeWaypoint> {
  $$HikeWaypointsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $HikesTable _hikeIdTable(_$AppDatabase db) => db.hikes.createAlias(
    $_aliasNameGenerator(db.hikeWaypoints.hikeId, db.hikes.id),
  );

  $$HikesTableProcessedTableManager get hikeId {
    final $_column = $_itemColumn<int>('hike_id')!;

    final manager = $$HikesTableTableManager(
      $_db,
      $_db.hikes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_hikeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$HikePhotosTable, List<HikePhoto>>
  _hikePhotosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.hikePhotos,
    aliasName: $_aliasNameGenerator(
      db.hikeWaypoints.id,
      db.hikePhotos.waypointId,
    ),
  );

  $$HikePhotosTableProcessedTableManager get hikePhotosRefs {
    final manager = $$HikePhotosTableTableManager(
      $_db,
      $_db.hikePhotos,
    ).filter((f) => f.waypointId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_hikePhotosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$HikeWaypointsTableFilterComposer
    extends Composer<_$AppDatabase, $HikeWaypointsTable> {
  $$HikeWaypointsTableFilterComposer({
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

  ColumnFilters<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, String>
  get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get altitude => $composableBuilder(
    column: $table.altitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get elevationGainToHere => $composableBuilder(
    column: $table.elevationGainToHere,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get elevationLossToHere => $composableBuilder(
    column: $table.elevationLossToHere,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  $$HikesTableFilterComposer get hikeId {
    final $$HikesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.hikeId,
      referencedTable: $db.hikes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HikesTableFilterComposer(
            $db: $db,
            $table: $db.hikes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> hikePhotosRefs(
    Expression<bool> Function($$HikePhotosTableFilterComposer f) f,
  ) {
    final $$HikePhotosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.hikePhotos,
      getReferencedColumn: (t) => t.waypointId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HikePhotosTableFilterComposer(
            $db: $db,
            $table: $db.hikePhotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HikeWaypointsTableOrderingComposer
    extends Composer<_$AppDatabase, $HikeWaypointsTable> {
  $$HikeWaypointsTableOrderingComposer({
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

  ColumnOrderings<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get altitude => $composableBuilder(
    column: $table.altitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get elevationGainToHere => $composableBuilder(
    column: $table.elevationGainToHere,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get elevationLossToHere => $composableBuilder(
    column: $table.elevationLossToHere,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  $$HikesTableOrderingComposer get hikeId {
    final $$HikesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.hikeId,
      referencedTable: $db.hikes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HikesTableOrderingComposer(
            $db: $db,
            $table: $db.hikes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HikeWaypointsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HikeWaypointsTable> {
  $$HikeWaypointsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cloudId =>
      $composableBuilder(column: $table.cloudId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, String> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get altitude =>
      $composableBuilder(column: $table.altitude, builder: (column) => column);

  GeneratedColumn<double> get elevationGainToHere => $composableBuilder(
    column: $table.elevationGainToHere,
    builder: (column) => column,
  );

  GeneratedColumn<double> get elevationLossToHere => $composableBuilder(
    column: $table.elevationLossToHere,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  $$HikesTableAnnotationComposer get hikeId {
    final $$HikesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.hikeId,
      referencedTable: $db.hikes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HikesTableAnnotationComposer(
            $db: $db,
            $table: $db.hikes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> hikePhotosRefs<T extends Object>(
    Expression<T> Function($$HikePhotosTableAnnotationComposer a) f,
  ) {
    final $$HikePhotosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.hikePhotos,
      getReferencedColumn: (t) => t.waypointId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HikePhotosTableAnnotationComposer(
            $db: $db,
            $table: $db.hikePhotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HikeWaypointsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HikeWaypointsTable,
          HikeWaypoint,
          $$HikeWaypointsTableFilterComposer,
          $$HikeWaypointsTableOrderingComposer,
          $$HikeWaypointsTableAnnotationComposer,
          $$HikeWaypointsTableCreateCompanionBuilder,
          $$HikeWaypointsTableUpdateCompanionBuilder,
          (HikeWaypoint, $$HikeWaypointsTableReferences),
          HikeWaypoint,
          PrefetchHooks Function({bool hikeId, bool hikePhotosRefs})
        > {
  $$HikeWaypointsTableTableManager(_$AppDatabase db, $HikeWaypointsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HikeWaypointsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HikeWaypointsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HikeWaypointsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<int> hikeId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<double?> altitude = const Value.absent(),
                Value<double?> elevationGainToHere = const Value.absent(),
                Value<double?> elevationLossToHere = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
              }) => HikeWaypointsCompanion(
                id: id,
                cloudId: cloudId,
                syncStatus: syncStatus,
                hikeId: hikeId,
                name: name,
                description: description,
                latitude: latitude,
                longitude: longitude,
                timestamp: timestamp,
                category: category,
                altitude: altitude,
                elevationGainToHere: elevationGainToHere,
                elevationLossToHere: elevationLossToHere,
                isDeleted: isDeleted,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                required int hikeId,
                required String name,
                Value<String?> description = const Value.absent(),
                required double latitude,
                required double longitude,
                required DateTime timestamp,
                Value<String?> category = const Value.absent(),
                Value<double?> altitude = const Value.absent(),
                Value<double?> elevationGainToHere = const Value.absent(),
                Value<double?> elevationLossToHere = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
              }) => HikeWaypointsCompanion.insert(
                id: id,
                cloudId: cloudId,
                syncStatus: syncStatus,
                hikeId: hikeId,
                name: name,
                description: description,
                latitude: latitude,
                longitude: longitude,
                timestamp: timestamp,
                category: category,
                altitude: altitude,
                elevationGainToHere: elevationGainToHere,
                elevationLossToHere: elevationLossToHere,
                isDeleted: isDeleted,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HikeWaypointsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({hikeId = false, hikePhotosRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (hikePhotosRefs) db.hikePhotos],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (hikeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.hikeId,
                                referencedTable: $$HikeWaypointsTableReferences
                                    ._hikeIdTable(db),
                                referencedColumn: $$HikeWaypointsTableReferences
                                    ._hikeIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (hikePhotosRefs)
                    await $_getPrefetchedData<
                      HikeWaypoint,
                      $HikeWaypointsTable,
                      HikePhoto
                    >(
                      currentTable: table,
                      referencedTable: $$HikeWaypointsTableReferences
                          ._hikePhotosRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$HikeWaypointsTableReferences(
                            db,
                            table,
                            p0,
                          ).hikePhotosRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.waypointId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$HikeWaypointsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HikeWaypointsTable,
      HikeWaypoint,
      $$HikeWaypointsTableFilterComposer,
      $$HikeWaypointsTableOrderingComposer,
      $$HikeWaypointsTableAnnotationComposer,
      $$HikeWaypointsTableCreateCompanionBuilder,
      $$HikeWaypointsTableUpdateCompanionBuilder,
      (HikeWaypoint, $$HikeWaypointsTableReferences),
      HikeWaypoint,
      PrefetchHooks Function({bool hikeId, bool hikePhotosRefs})
    >;
typedef $$HikePhotosTableCreateCompanionBuilder =
    HikePhotosCompanion Function({
      Value<int> id,
      Value<SyncStatus> syncStatus,
      Value<String?> cloudId,
      required int hikeId,
      Value<int?> waypointId,
      required String photoUrl,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<DateTime?> capturedAt,
      Value<bool> isDeleted,
    });
typedef $$HikePhotosTableUpdateCompanionBuilder =
    HikePhotosCompanion Function({
      Value<int> id,
      Value<SyncStatus> syncStatus,
      Value<String?> cloudId,
      Value<int> hikeId,
      Value<int?> waypointId,
      Value<String> photoUrl,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<DateTime?> capturedAt,
      Value<bool> isDeleted,
    });

final class $$HikePhotosTableReferences
    extends BaseReferences<_$AppDatabase, $HikePhotosTable, HikePhoto> {
  $$HikePhotosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $HikesTable _hikeIdTable(_$AppDatabase db) => db.hikes.createAlias(
    $_aliasNameGenerator(db.hikePhotos.hikeId, db.hikes.id),
  );

  $$HikesTableProcessedTableManager get hikeId {
    final $_column = $_itemColumn<int>('hike_id')!;

    final manager = $$HikesTableTableManager(
      $_db,
      $_db.hikes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_hikeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $HikeWaypointsTable _waypointIdTable(_$AppDatabase db) =>
      db.hikeWaypoints.createAlias(
        $_aliasNameGenerator(db.hikePhotos.waypointId, db.hikeWaypoints.id),
      );

  $$HikeWaypointsTableProcessedTableManager? get waypointId {
    final $_column = $_itemColumn<int>('waypoint_id');
    if ($_column == null) return null;
    final manager = $$HikeWaypointsTableTableManager(
      $_db,
      $_db.hikeWaypoints,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_waypointIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HikePhotosTableFilterComposer
    extends Composer<_$AppDatabase, $HikePhotosTable> {
  $$HikePhotosTableFilterComposer({
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

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, String>
  get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  $$HikesTableFilterComposer get hikeId {
    final $$HikesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.hikeId,
      referencedTable: $db.hikes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HikesTableFilterComposer(
            $db: $db,
            $table: $db.hikes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$HikeWaypointsTableFilterComposer get waypointId {
    final $$HikeWaypointsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.waypointId,
      referencedTable: $db.hikeWaypoints,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HikeWaypointsTableFilterComposer(
            $db: $db,
            $table: $db.hikeWaypoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HikePhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $HikePhotosTable> {
  $$HikePhotosTableOrderingComposer({
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

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  $$HikesTableOrderingComposer get hikeId {
    final $$HikesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.hikeId,
      referencedTable: $db.hikes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HikesTableOrderingComposer(
            $db: $db,
            $table: $db.hikes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$HikeWaypointsTableOrderingComposer get waypointId {
    final $$HikeWaypointsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.waypointId,
      referencedTable: $db.hikeWaypoints,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HikeWaypointsTableOrderingComposer(
            $db: $db,
            $table: $db.hikeWaypoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HikePhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $HikePhotosTable> {
  $$HikePhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, String> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<String> get cloudId =>
      $composableBuilder(column: $table.cloudId, builder: (column) => column);

  GeneratedColumn<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  $$HikesTableAnnotationComposer get hikeId {
    final $$HikesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.hikeId,
      referencedTable: $db.hikes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HikesTableAnnotationComposer(
            $db: $db,
            $table: $db.hikes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$HikeWaypointsTableAnnotationComposer get waypointId {
    final $$HikeWaypointsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.waypointId,
      referencedTable: $db.hikeWaypoints,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HikeWaypointsTableAnnotationComposer(
            $db: $db,
            $table: $db.hikeWaypoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HikePhotosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HikePhotosTable,
          HikePhoto,
          $$HikePhotosTableFilterComposer,
          $$HikePhotosTableOrderingComposer,
          $$HikePhotosTableAnnotationComposer,
          $$HikePhotosTableCreateCompanionBuilder,
          $$HikePhotosTableUpdateCompanionBuilder,
          (HikePhoto, $$HikePhotosTableReferences),
          HikePhoto,
          PrefetchHooks Function({bool hikeId, bool waypointId})
        > {
  $$HikePhotosTableTableManager(_$AppDatabase db, $HikePhotosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HikePhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HikePhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HikePhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
                Value<int> hikeId = const Value.absent(),
                Value<int?> waypointId = const Value.absent(),
                Value<String> photoUrl = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<DateTime?> capturedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
              }) => HikePhotosCompanion(
                id: id,
                syncStatus: syncStatus,
                cloudId: cloudId,
                hikeId: hikeId,
                waypointId: waypointId,
                photoUrl: photoUrl,
                latitude: latitude,
                longitude: longitude,
                capturedAt: capturedAt,
                isDeleted: isDeleted,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
                required int hikeId,
                Value<int?> waypointId = const Value.absent(),
                required String photoUrl,
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<DateTime?> capturedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
              }) => HikePhotosCompanion.insert(
                id: id,
                syncStatus: syncStatus,
                cloudId: cloudId,
                hikeId: hikeId,
                waypointId: waypointId,
                photoUrl: photoUrl,
                latitude: latitude,
                longitude: longitude,
                capturedAt: capturedAt,
                isDeleted: isDeleted,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HikePhotosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({hikeId = false, waypointId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (hikeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.hikeId,
                                referencedTable: $$HikePhotosTableReferences
                                    ._hikeIdTable(db),
                                referencedColumn: $$HikePhotosTableReferences
                                    ._hikeIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (waypointId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.waypointId,
                                referencedTable: $$HikePhotosTableReferences
                                    ._waypointIdTable(db),
                                referencedColumn: $$HikePhotosTableReferences
                                    ._waypointIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$HikePhotosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HikePhotosTable,
      HikePhoto,
      $$HikePhotosTableFilterComposer,
      $$HikePhotosTableOrderingComposer,
      $$HikePhotosTableAnnotationComposer,
      $$HikePhotosTableCreateCompanionBuilder,
      $$HikePhotosTableUpdateCompanionBuilder,
      (HikePhoto, $$HikePhotosTableReferences),
      HikePhoto,
      PrefetchHooks Function({bool hikeId, bool waypointId})
    >;
typedef $$RoutePointsTableCreateCompanionBuilder =
    RoutePointsCompanion Function({
      Value<int> id,
      Value<String?> cloudId,
      Value<SyncStatus> syncStatus,
      required int hikeId,
      required double latitude,
      required double longitude,
      Value<double?> altitude,
      required DateTime timestamp,
      Value<double?> speedKmh,
    });
typedef $$RoutePointsTableUpdateCompanionBuilder =
    RoutePointsCompanion Function({
      Value<int> id,
      Value<String?> cloudId,
      Value<SyncStatus> syncStatus,
      Value<int> hikeId,
      Value<double> latitude,
      Value<double> longitude,
      Value<double?> altitude,
      Value<DateTime> timestamp,
      Value<double?> speedKmh,
    });

final class $$RoutePointsTableReferences
    extends BaseReferences<_$AppDatabase, $RoutePointsTable, RoutePoint> {
  $$RoutePointsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $HikesTable _hikeIdTable(_$AppDatabase db) => db.hikes.createAlias(
    $_aliasNameGenerator(db.routePoints.hikeId, db.hikes.id),
  );

  $$HikesTableProcessedTableManager get hikeId {
    final $_column = $_itemColumn<int>('hike_id')!;

    final manager = $$HikesTableTableManager(
      $_db,
      $_db.hikes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_hikeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RoutePointsTableFilterComposer
    extends Composer<_$AppDatabase, $RoutePointsTable> {
  $$RoutePointsTableFilterComposer({
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

  ColumnFilters<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, String>
  get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get altitude => $composableBuilder(
    column: $table.altitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get speedKmh => $composableBuilder(
    column: $table.speedKmh,
    builder: (column) => ColumnFilters(column),
  );

  $$HikesTableFilterComposer get hikeId {
    final $$HikesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.hikeId,
      referencedTable: $db.hikes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HikesTableFilterComposer(
            $db: $db,
            $table: $db.hikes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutePointsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutePointsTable> {
  $$RoutePointsTableOrderingComposer({
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

  ColumnOrderings<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get altitude => $composableBuilder(
    column: $table.altitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get speedKmh => $composableBuilder(
    column: $table.speedKmh,
    builder: (column) => ColumnOrderings(column),
  );

  $$HikesTableOrderingComposer get hikeId {
    final $$HikesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.hikeId,
      referencedTable: $db.hikes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HikesTableOrderingComposer(
            $db: $db,
            $table: $db.hikes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutePointsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutePointsTable> {
  $$RoutePointsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cloudId =>
      $composableBuilder(column: $table.cloudId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, String> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get altitude =>
      $composableBuilder(column: $table.altitude, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<double> get speedKmh =>
      $composableBuilder(column: $table.speedKmh, builder: (column) => column);

  $$HikesTableAnnotationComposer get hikeId {
    final $$HikesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.hikeId,
      referencedTable: $db.hikes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HikesTableAnnotationComposer(
            $db: $db,
            $table: $db.hikes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutePointsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutePointsTable,
          RoutePoint,
          $$RoutePointsTableFilterComposer,
          $$RoutePointsTableOrderingComposer,
          $$RoutePointsTableAnnotationComposer,
          $$RoutePointsTableCreateCompanionBuilder,
          $$RoutePointsTableUpdateCompanionBuilder,
          (RoutePoint, $$RoutePointsTableReferences),
          RoutePoint,
          PrefetchHooks Function({bool hikeId})
        > {
  $$RoutePointsTableTableManager(_$AppDatabase db, $RoutePointsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutePointsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutePointsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutePointsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<int> hikeId = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<double?> altitude = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<double?> speedKmh = const Value.absent(),
              }) => RoutePointsCompanion(
                id: id,
                cloudId: cloudId,
                syncStatus: syncStatus,
                hikeId: hikeId,
                latitude: latitude,
                longitude: longitude,
                altitude: altitude,
                timestamp: timestamp,
                speedKmh: speedKmh,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                required int hikeId,
                required double latitude,
                required double longitude,
                Value<double?> altitude = const Value.absent(),
                required DateTime timestamp,
                Value<double?> speedKmh = const Value.absent(),
              }) => RoutePointsCompanion.insert(
                id: id,
                cloudId: cloudId,
                syncStatus: syncStatus,
                hikeId: hikeId,
                latitude: latitude,
                longitude: longitude,
                altitude: altitude,
                timestamp: timestamp,
                speedKmh: speedKmh,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RoutePointsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({hikeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (hikeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.hikeId,
                                referencedTable: $$RoutePointsTableReferences
                                    ._hikeIdTable(db),
                                referencedColumn: $$RoutePointsTableReferences
                                    ._hikeIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RoutePointsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutePointsTable,
      RoutePoint,
      $$RoutePointsTableFilterComposer,
      $$RoutePointsTableOrderingComposer,
      $$RoutePointsTableAnnotationComposer,
      $$RoutePointsTableCreateCompanionBuilder,
      $$RoutePointsTableUpdateCompanionBuilder,
      (RoutePoint, $$RoutePointsTableReferences),
      RoutePoint,
      PrefetchHooks Function({bool hikeId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$HikesTableTableManager get hikes =>
      $$HikesTableTableManager(_db, _db.hikes);
  $$HikeWaypointsTableTableManager get hikeWaypoints =>
      $$HikeWaypointsTableTableManager(_db, _db.hikeWaypoints);
  $$HikePhotosTableTableManager get hikePhotos =>
      $$HikePhotosTableTableManager(_db, _db.hikePhotos);
  $$RoutePointsTableTableManager get routePoints =>
      $$RoutePointsTableTableManager(_db, _db.routePoints);
}
