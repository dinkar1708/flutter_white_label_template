import '../brand/brand.dart';
import '../models/store.dart';

class StoreRepository {
  static const Duration _fakeLatency = Duration(milliseconds: 800);

  Future<List<Store>> fetchStores(Brand brand) async {
    await Future.delayed(_fakeLatency);
    return _storesByBrand[brand] ?? const [];
  }
}

const Map<Brand, List<Store>> _storesByBrand = {
  Brand.aqua: [
    Store(id: 'aq-1', name: 'Ocean Cafe', category: 'Food', discountPercent: 10),
    Store(id: 'aq-2', name: 'Wave Boutique', category: 'Fashion', discountPercent: 15),
    Store(id: 'aq-3', name: 'Pearl Books', category: 'Books', discountPercent: 5),
  ],
  Brand.coral: [
    Store(id: 'co-1', name: 'Sunset Diner', category: 'Food', discountPercent: 12),
    Store(id: 'co-2', name: 'Reef Records', category: 'Music', discountPercent: 20),
  ],
  Brand.amber: [
    Store(id: 'am-1', name: 'Golden Bakery', category: 'Food', discountPercent: 8),
    Store(id: 'am-2', name: 'Honey Deli', category: 'Food', discountPercent: 10),
    Store(id: 'am-3', name: 'Amber Threads', category: 'Fashion', discountPercent: 18),
    Store(id: 'am-4', name: 'Sunrise Grocers', category: 'Grocery', discountPercent: 6),
  ],
};
