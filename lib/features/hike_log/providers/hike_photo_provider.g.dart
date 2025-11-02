// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hike_photo_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$hikePhotosHash() => r'6986c7a563ce983db0f0a30ecf37ac8292b3046e';

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

/// See also [hikePhotos].
@ProviderFor(hikePhotos)
const hikePhotosProvider = HikePhotosFamily();

/// See also [hikePhotos].
class HikePhotosFamily extends Family<AsyncValue<List<HikePhoto>>> {
  /// See also [hikePhotos].
  const HikePhotosFamily();

  /// See also [hikePhotos].
  HikePhotosProvider call(int localHikeId) {
    return HikePhotosProvider(localHikeId);
  }

  @override
  HikePhotosProvider getProviderOverride(
    covariant HikePhotosProvider provider,
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
  String? get name => r'hikePhotosProvider';
}

/// See also [hikePhotos].
class HikePhotosProvider extends AutoDisposeStreamProvider<List<HikePhoto>> {
  /// See also [hikePhotos].
  HikePhotosProvider(int localHikeId)
    : this._internal(
        (ref) => hikePhotos(ref as HikePhotosRef, localHikeId),
        from: hikePhotosProvider,
        name: r'hikePhotosProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$hikePhotosHash,
        dependencies: HikePhotosFamily._dependencies,
        allTransitiveDependencies: HikePhotosFamily._allTransitiveDependencies,
        localHikeId: localHikeId,
      );

  HikePhotosProvider._internal(
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
    Stream<List<HikePhoto>> Function(HikePhotosRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: HikePhotosProvider._internal(
        (ref) => create(ref as HikePhotosRef),
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
  AutoDisposeStreamProviderElement<List<HikePhoto>> createElement() {
    return _HikePhotosProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HikePhotosProvider && other.localHikeId == localHikeId;
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
mixin HikePhotosRef on AutoDisposeStreamProviderRef<List<HikePhoto>> {
  /// The parameter `localHikeId` of this provider.
  int get localHikeId;
}

class _HikePhotosProviderElement
    extends AutoDisposeStreamProviderElement<List<HikePhoto>>
    with HikePhotosRef {
  _HikePhotosProviderElement(super.provider);

  @override
  int get localHikeId => (origin as HikePhotosProvider).localHikeId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
