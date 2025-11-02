// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gps_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$gpsServiceHash() => r'320a21a9cc342266f6d431c82a2e7e0cf3823096';

/// Provider untuk GpsService (singleton)
///
/// Copied from [gpsService].
@ProviderFor(gpsService)
final gpsServiceProvider = AutoDisposeProvider<GpsService>.internal(
  gpsService,
  name: r'gpsServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$gpsServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GpsServiceRef = AutoDisposeProviderRef<GpsService>;
String _$gpsPositionHash() => r'24d069adee18f528a0f18b1987f37fd05e8b3a03';

/// Provider untuk stream lokasi real-time
/// (Nama ini dipanggil oleh map_provider.dart)
///
/// Copied from [gpsPosition].
@ProviderFor(gpsPosition)
final gpsPositionProvider = AutoDisposeStreamProvider<PositionData>.internal(
  gpsPosition,
  name: r'gpsPositionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$gpsPositionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GpsPositionRef = AutoDisposeStreamProviderRef<PositionData>;
String _$currentGpsLocationHash() =>
    r'a958d7980ae226a8a8a9d2ff2ea08d59c2257cfb';

/// Provider untuk mendapatkan lokasi satu kali (inisial peta)
/// (Nama ini dipanggil oleh map_page.dart)
///
/// Copied from [currentGpsLocation].
@ProviderFor(currentGpsLocation)
final currentGpsLocationProvider =
    AutoDisposeFutureProvider<PositionData?>.internal(
      currentGpsLocation,
      name: r'currentGpsLocationProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currentGpsLocationHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentGpsLocationRef = AutoDisposeFutureProviderRef<PositionData?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
