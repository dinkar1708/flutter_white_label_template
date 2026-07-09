import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_white_label_template/brand/brand.dart';
import 'package:flutter_white_label_template/repositories/store_repository.dart';

void main() {
  final repo = StoreRepository();

  test('aqua returns 3 stores', () async {
    final stores = await repo.fetchStores(Brand.aqua);
    expect(stores.length, 3);
  });

  test('coral returns 2 stores', () async {
    final stores = await repo.fetchStores(Brand.coral);
    expect(stores.length, 2);
  });

  test('amber returns 4 stores', () async {
    final stores = await repo.fetchStores(Brand.amber);
    expect(stores.length, 4);
  });
}
