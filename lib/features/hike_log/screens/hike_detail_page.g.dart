// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hike_detail_page.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$hikeDetailHash() => r'ea65259106014d2896dd6293832a5b23ef6b9b69';

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

/// See also [hikeDetail].
@ProviderFor(hikeDetail)
const hikeDetailProvider = HikeDetailFamily();

/// See also [hikeDetail].
class HikeDetailFamily extends Family<AsyncValue<Hike?>> {
  /// See also [hikeDetail].
  const HikeDetailFamily();

  /// See also [hikeDetail].
  HikeDetailProvider call(int localHikeId) {
    return HikeDetailProvider(localHikeId);
  }

  @override
  HikeDetailProvider getProviderOverride(
    covariant HikeDetailProvider provider,
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
  String? get name => r'hikeDetailProvider';
}

/// See also [hikeDetail].
class HikeDetailProvider extends AutoDisposeFutureProvider<Hike?> {
  /// See also [hikeDetail].
  HikeDetailProvider(int localHikeId)
    : this._internal(
        (ref) => hikeDetail(ref as HikeDetailRef, localHikeId),
        from: hikeDetailProvider,
        name: r'hikeDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$hikeDetailHash,
        dependencies: HikeDetailFamily._dependencies,
        allTransitiveDependencies: HikeDetailFamily._allTransitiveDependencies,
        localHikeId: localHikeId,
      );

  HikeDetailProvider._internal(
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
    FutureOr<Hike?> Function(HikeDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: HikeDetailProvider._internal(
        (ref) => create(ref as HikeDetailRef),
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
  AutoDisposeFutureProviderElement<Hike?> createElement() {
    return _HikeDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HikeDetailProvider && other.localHikeId == localHikeId;
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
mixin HikeDetailRef on AutoDisposeFutureProviderRef<Hike?> {
  /// The parameter `localHikeId` of this provider.
  int get localHikeId;
}

class _HikeDetailProviderElement extends AutoDisposeFutureProviderElement<Hike?>
    with HikeDetailRef {
  _HikeDetailProviderElement(super.provider);

  @override
  int get localHikeId => (origin as HikeDetailProvider).localHikeId;
}

String _$waypointPhotoHash() => r'd6aca8e936ec5398bdf8c1db3654a20603b53874';

/// See also [waypointPhoto].
@ProviderFor(waypointPhoto)
const waypointPhotoProvider = WaypointPhotoFamily();

/// See also [waypointPhoto].
class WaypointPhotoFamily extends Family<HikePhoto?> {
  /// See also [waypointPhoto].
  const WaypointPhotoFamily();

  /// See also [waypointPhoto].
  WaypointPhotoProvider call({required int hikeId, required int waypointId}) {
    return WaypointPhotoProvider(hikeId: hikeId, waypointId: waypointId);
  }

  @override
  WaypointPhotoProvider getProviderOverride(
    covariant WaypointPhotoProvider provider,
  ) {
    return call(hikeId: provider.hikeId, waypointId: provider.waypointId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'waypointPhotoProvider';
}

/// See also [waypointPhoto].
class WaypointPhotoProvider extends AutoDisposeProvider<HikePhoto?> {
  /// See also [waypointPhoto].
  WaypointPhotoProvider({required int hikeId, required int waypointId})
    : this._internal(
        (ref) => waypointPhoto(
          ref as WaypointPhotoRef,
          hikeId: hikeId,
          waypointId: waypointId,
        ),
        from: waypointPhotoProvider,
        name: r'waypointPhotoProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$waypointPhotoHash,
        dependencies: WaypointPhotoFamily._dependencies,
        allTransitiveDependencies:
            WaypointPhotoFamily._allTransitiveDependencies,
        hikeId: hikeId,
        waypointId: waypointId,
      );

  WaypointPhotoProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.hikeId,
    required this.waypointId,
  }) : super.internal();

  final int hikeId;
  final int waypointId;

  @override
  Override overrideWith(HikePhoto? Function(WaypointPhotoRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: WaypointPhotoProvider._internal(
        (ref) => create(ref as WaypointPhotoRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        hikeId: hikeId,
        waypointId: waypointId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<HikePhoto?> createElement() {
    return _WaypointPhotoProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WaypointPhotoProvider &&
        other.hikeId == hikeId &&
        other.waypointId == waypointId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, hikeId.hashCode);
    hash = _SystemHash.combine(hash, waypointId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WaypointPhotoRef on AutoDisposeProviderRef<HikePhoto?> {
  /// The parameter `hikeId` of this provider.
  int get hikeId;

  /// The parameter `waypointId` of this provider.
  int get waypointId;
}

class _WaypointPhotoProviderElement
    extends AutoDisposeProviderElement<HikePhoto?>
    with WaypointPhotoRef {
  _WaypointPhotoProviderElement(super.provider);

  @override
  int get hikeId => (origin as WaypointPhotoProvider).hikeId;
  @override
  int get waypointId => (origin as WaypointPhotoProvider).waypointId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
