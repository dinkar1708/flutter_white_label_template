// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brand_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(brand)
final brandProvider = BrandProvider._();

final class BrandProvider extends $FunctionalProvider<Brand, Brand, Brand>
    with $Provider<Brand> {
  BrandProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'brandProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$brandHash();

  @$internal
  @override
  $ProviderElement<Brand> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Brand create(Ref ref) {
    return brand(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Brand value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Brand>(value),
    );
  }
}

String _$brandHash() => r'73284e945e20037a5b0cff8b3812dcbb98d3d384';

@ProviderFor(brandConfig)
final brandConfigProvider = BrandConfigProvider._();

final class BrandConfigProvider
    extends $FunctionalProvider<BrandConfig, BrandConfig, BrandConfig>
    with $Provider<BrandConfig> {
  BrandConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'brandConfigProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$brandConfigHash();

  @$internal
  @override
  $ProviderElement<BrandConfig> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BrandConfig create(Ref ref) {
    return brandConfig(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BrandConfig value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BrandConfig>(value),
    );
  }
}

String _$brandConfigHash() => r'604b22ffcde1c8b0343cf5235b7fd42badb69c3e';
