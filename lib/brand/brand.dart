enum Brand { aqua, coral, amber }

const String _brandFromEnv = String.fromEnvironment('BRAND', defaultValue: 'aqua');

const Brand currentBrand = _brandFromEnv == 'coral'
    ? Brand.coral
    : _brandFromEnv == 'amber'
        ? Brand.amber
        : Brand.aqua;
