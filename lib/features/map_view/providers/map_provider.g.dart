// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$supabaseProviderHash() => r'a9de5ae38e260b57a57ad413665686661568d252';

/// See also [supabaseProvider].
@ProviderFor(supabaseProvider)
final supabaseProviderProvider = AutoDisposeProvider<SupabaseClient>.internal(
  supabaseProvider,
  name: r'supabaseProviderProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$supabaseProviderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SupabaseProviderRef = AutoDisposeProviderRef<SupabaseClient>;
String _$positionStreamHash() => r'386c78c1687615ec26e4da6f80788f75dfd4189a';

/// See also [positionStream].
@ProviderFor(positionStream)
final positionStreamProvider = AutoDisposeStreamProvider<PositionData>.internal(
  positionStream,
  name: r'positionStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$positionStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PositionStreamRef = AutoDisposeStreamProviderRef<PositionData>;
String _$currentGpsLocationHash() =>
    r'a958d7980ae226a8a8a9d2ff2ea08d59c2257cfb';

/// See also [currentGpsLocation].
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
String _$mapNotifierHash() => r'e1bb878c2986f4cb1b39555c361f0d6b5533d45e';

/// "OTAK" DARI FITUR PELACAKAN
///
/// Copied from [MapNotifier].
@ProviderFor(MapNotifier)
final mapNotifierProvider =
    AutoDisposeNotifierProvider<MapNotifier, MapTrackingState>.internal(
      MapNotifier.new,
      name: r'mapNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$mapNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MapNotifier = AutoDisposeNotifier<MapTrackingState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
