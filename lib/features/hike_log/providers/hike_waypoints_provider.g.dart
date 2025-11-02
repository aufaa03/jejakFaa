// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hike_waypoints_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$hikeWaypointsHash() => r'3f15456d1bc47c1f9fc09b7adaccf046ba44ce63';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [hikeWaypoints].
@ProviderFor(hikeWaypoints)
const hikeWaypointsProvider = HikeWaypointsFamily();

/// See also [hikeWaypoints].
class HikeWaypointsFamily extends Family<AsyncValue<List<HikeWaypoint>>> {
  /// See also [hikeWaypoints].
  const HikeWaypointsFamily();

  /// See also [hikeWaypoints].
  HikeWaypointsProvider call(int localHikeId) {
    return HikeWaypointsProvider(localHikeId);
  }

  @override
  HikeWaypointsProvider getProviderOverride(
    covariant HikeWaypointsProvider provider,
  ) {
    return call(provider.localHikeId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'hikeWaypointsProvider';
}

/// See also [hikeWaypoints].
class HikeWaypointsProvider
    extends AutoDisposeStreamProvider<List<HikeWaypoint>> {
  /// See also [hikeWaypoints].
  HikeWaypointsProvider(int localHikeId)
    : this._internal(
        (ref) => hikeWaypoints(ref as HikeWaypointsRef, localHikeId),
        from: hikeWaypointsProvider,
        name: r'hikeWaypointsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$hikeWaypointsHash,
        dependencies: HikeWaypointsFamily._dependencies,
        allTransitiveDependencies:
            HikeWaypointsFamily._allTransitiveDependencies,
        localHikeId: localHikeId,
      );

  HikeWaypointsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.localHikeId,
  }) : super.internal();

  final int localHikeId;

  @override
  Override overrideWith(
    Stream<List<HikeWaypoint>> Function(HikeWaypointsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: HikeWaypointsProvider._internal(
        (ref) => create(ref as HikeWaypointsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        localHikeId: localHikeId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<HikeWaypoint>> createElement() {
    return _HikeWaypointsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HikeWaypointsProvider && other.localHikeId == localHikeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, localHikeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin HikeWaypointsRef on AutoDisposeStreamProviderRef<List<HikeWaypoint>> {
  /// The parameter `localHikeId` of this provider.
  int get localHikeId;
}

class _HikeWaypointsProviderElement
    extends AutoDisposeStreamProviderElement<List<HikeWaypoint>>
    with HikeWaypointsRef {
  _HikeWaypointsProviderElement(super.provider);

  @override
  int get localHikeId => (origin as HikeWaypointsProvider).localHikeId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
