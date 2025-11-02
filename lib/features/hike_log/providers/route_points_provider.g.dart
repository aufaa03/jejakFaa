// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_points_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$routePointsHash() => r'd150040da508037455b200adf915a6fb595cdca5';

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

/// See also [routePoints].
@ProviderFor(routePoints)
const routePointsProvider = RoutePointsFamily();

/// See also [routePoints].
class RoutePointsFamily extends Family<AsyncValue<List<RoutePoint>>> {
  /// See also [routePoints].
  const RoutePointsFamily();

  /// See also [routePoints].
  RoutePointsProvider call(int localHikeId) {
    return RoutePointsProvider(localHikeId);
  }

  @override
  RoutePointsProvider getProviderOverride(
    covariant RoutePointsProvider provider,
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
  String? get name => r'routePointsProvider';
}

/// See also [routePoints].
class RoutePointsProvider extends AutoDisposeStreamProvider<List<RoutePoint>> {
  /// See also [routePoints].
  RoutePointsProvider(int localHikeId)
    : this._internal(
        (ref) => routePoints(ref as RoutePointsRef, localHikeId),
        from: routePointsProvider,
        name: r'routePointsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$routePointsHash,
        dependencies: RoutePointsFamily._dependencies,
        allTransitiveDependencies: RoutePointsFamily._allTransitiveDependencies,
        localHikeId: localHikeId,
      );

  RoutePointsProvider._internal(
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
    Stream<List<RoutePoint>> Function(RoutePointsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RoutePointsProvider._internal(
        (ref) => create(ref as RoutePointsRef),
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
  AutoDisposeStreamProviderElement<List<RoutePoint>> createElement() {
    return _RoutePointsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RoutePointsProvider && other.localHikeId == localHikeId;
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
mixin RoutePointsRef on AutoDisposeStreamProviderRef<List<RoutePoint>> {
  /// The parameter `localHikeId` of this provider.
  int get localHikeId;
}

class _RoutePointsProviderElement
    extends AutoDisposeStreamProviderElement<List<RoutePoint>>
    with RoutePointsRef {
  _RoutePointsProviderElement(super.provider);

  @override
  int get localHikeId => (origin as RoutePointsProvider).localHikeId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
