import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../brand/brand.dart';
import '../brand/brand_config.dart';

part 'brand_providers.g.dart';

@riverpod
Brand brand(Ref ref) => currentBrand;

@riverpod
BrandConfig brandConfig(Ref ref) {
  final b = ref.watch(brandProvider);
  return brandConfigs[b]!;
}
