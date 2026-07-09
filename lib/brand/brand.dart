enum Brand { aqua, coral, amber }

const String _brandFromEnv = String.fromEnvironment('BRAND');

final Brand currentBrand = Brand.values.firstWhere(
  (b) => b.name == _brandFromEnv,
  orElse: () => Brand.values.first,
);
