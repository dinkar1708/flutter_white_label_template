import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/store.dart';
import '../repositories/store_repository.dart';
import 'brand_providers.dart';

part 'store_providers.g.dart';

@riverpod
StoreRepository storeRepository(Ref ref) => StoreRepository();

@riverpod
Future<List<Store>> stores(Ref ref) {
  final b = ref.watch(brandProvider);
  final repo = ref.watch(storeRepositoryProvider);
  return repo.fetchStores(b);
}
