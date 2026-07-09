import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_white_label_template/brand/brand.dart';
import 'package:flutter_white_label_template/brand/brand_config.dart';
import 'package:flutter_white_label_template/providers/providers.dart';

void main() {
  for (final brand in Brand.values) {
    test('brandConfigProvider returns the mapped config for ${brand.name}', () {
      final container = ProviderContainer(
        overrides: [brandProvider.overrideWith((ref) => brand)],
      );
      addTearDown(container.dispose);

      final config = container.read(brandConfigProvider);

      expect(config, same(brandConfigs[brand]));
      expect(config.appName.toLowerCase(), contains(brand.name));
    });
  }

  test('coral has gifts disabled (feature-flag demo)', () {
    final container = ProviderContainer(
      overrides: [brandProvider.overrideWith((ref) => Brand.coral)],
    );
    addTearDown(container.dispose);

    expect(container.read(brandConfigProvider).giftEnabled, isFalse);
  });

  test('storesProvider returns 2 stores for coral', () async {
    final container = ProviderContainer(
      overrides: [brandProvider.overrideWith((ref) => Brand.coral)],
    );
    addTearDown(container.dispose);

    final stores = await container.read(storesProvider.future);

    expect(stores.length, 2);
  });
}
