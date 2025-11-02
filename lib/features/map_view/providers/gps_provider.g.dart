// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gps_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$gpsPositionHash() => r'b4e58503bb7da4cf76a8932eefb72bf0ab986f21';

/// Provider untuk stream lokasi GPS real-time
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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
