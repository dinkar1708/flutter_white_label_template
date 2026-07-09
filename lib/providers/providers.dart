import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../brand/brand.dart';
import '../brand/brand_config.dart';
import '../data/store.dart';
import '../data/store_repository.dart';

final brandProvider = Provider<Brand>((ref) => currentBrand);

final brandConfigProvider = Provider<BrandConfig>((ref) {
  final brand = ref.watch(brandProvider);
  return brandConfigs[brand]!;
});

final storeRepositoryProvider = Provider<StoreRepository>(
  (ref) => StoreRepository(),
);

final storesProvider = FutureProvider<List<Store>>((ref) {
  final brand = ref.watch(brandProvider);
  final repo = ref.watch(storeRepositoryProvider);
  return repo.fetchStores(brand);
});
