# Testing

Three layers of headless tests + one layer of on-device tests, matching
the layers of the app. Each layer is independent.

> Latest snapshot of results and coverage: [`docs/TEST_RESULTS.md`](TEST_RESULTS.md).

```
┌──────────────────────────────────────────────────────────┐
│  Device tests           Maestro flows (or Patrol / any   │
│  (maestro/, future      other tool). Real APK on real    │
│  integration_test/)     device — the on-device proof.    │
├──────────────────────────────────────────────────────────┤
│  Widget tests           HomeScreen: FAB visibility,      │
│  (test/screens/)        store list, loading state,       │
│                         tap → snackbar                   │
├──────────────────────────────────────────────────────────┤
│  Provider tests         brandConfigProvider mapping,     │
│  (test/providers_test)  storesProvider integration,      │
│                         override-based DI                │
├──────────────────────────────────────────────────────────┤
│  Unit tests             StoreRepository per-brand list   │
│  (test/store_repo_test) length + latency contract        │
└──────────────────────────────────────────────────────────┘
```

## Run all tests

```sh
# without coverage — fastest
flutter test

# with coverage — writes coverage/lcov.info
flutter test --coverage

# view a per-file coverage report (requires lcov)
brew install lcov
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

Full headless suite is **12 tests, runs in ~2 seconds**. Current line
coverage: **82.2 %** across `lib/`.

---

## 1. Unit test — repository (`test/store_repository_test.dart`)

Verifies the mock server returns the right number of stores per brand. No
Riverpod, no widgets — pure Dart.

```dart
test('coral returns 2 stores', () async {
  final stores = await StoreRepository().fetchStores(Brand.coral);
  expect(stores.length, 2);
});
```

Run only unit tests:
```sh
flutter test test/store_repository_test.dart
flutter test test/store_repository_test.dart --coverage
```

---

## 2. Provider test — Riverpod DI (`test/providers_test.dart`)

Verifies providers wire brand → config → data correctly, and that the
feature-flag config (`giftEnabled`) is per-brand. Uses `ProviderContainer`
with overrides — no `--dart-define` needed at test time.

```dart
for (final brand in Brand.values) {
  test('brandConfigProvider returns the mapped config for ${brand.name}', () {
    final container = ProviderContainer(
      overrides: [brandProvider.overrideWith((ref) => brand)],
    );
    addTearDown(container.dispose);

    final config = container.read(brandConfigProvider);
    expect(config, same(brandConfigs[brand]));
  });
}
```

**Iterating `Brand.values`** means: when you add a 4th brand, this test
automatically covers it. No new test to write.

Run only provider tests:
```sh
flutter test test/providers_test.dart
flutter test test/providers_test.dart --coverage
```

---

## 3. Widget test — HomeScreen (`test/screens/home_screen_test.dart`)

Verifies the UI behaves correctly per brand. The key demo test: **Coral
must not show the Gifts FAB** — proof that the golden rule works end-to-end.

```dart
Widget _harness({
  required Brand brand,
  required List<Store> stores,
}) {
  return ProviderScope(
    overrides: [
      brandProvider.overrideWith((ref) => brand),
      storesProvider.overrideWith((ref) => Future.value(stores)),
    ],
    child: const MaterialApp(home: HomeScreen()),
  );
}

testWidgets('coral: shows appName, 2 stores, and NO Gifts FAB',
    (tester) async {
  await tester.pumpWidget(_harness(brand: Brand.coral, stores: _coralStores));
  await tester.pumpAndSettle();

  expect(find.text('Coral'), findsOneWidget);
  expect(find.text('Sunset Diner'), findsOneWidget);
  expect(find.text('Gifts'), findsNothing);              // ← the money check
});
```

The widget test covers:

| Case | What it proves |
|---|---|
| aqua: 3 stores + Gifts FAB | Happy path with capability ON |
| coral: 2 stores + **no** FAB | Feature flag hides UI without brand check |
| loading state | `storesProvider.when` handles the pending future |
| tapping Gifts → snackbar | FAB callback works |

Run only widget tests:
```sh
flutter test test/screens/home_screen_test.dart
flutter test test/screens/home_screen_test.dart --coverage
```

Widget tests run **headless on your host machine**, not on a connected
device. Great speed (<100 ms), but they cannot catch platform bugs
(permissions, missing resources, shader issues). For those, use device tests.

---

## 4. Device tests — Maestro (`maestro/`)

Real APK on a real device (or emulator). Cross-platform (Android + iOS),
YAML-based, and framework-agnostic — Maestro doesn't know or care that
the app is Flutter.

> Maestro is just **one example**. You could equally use
> [Flutter `integration_test`](https://docs.flutter.dev/testing/integration-tests),
> [Patrol](https://patrol.leancode.co/),
> [Appium](https://appium.io/), or
> [Detox](https://wix.github.io/Detox/). Each has different trade-offs;
> pick the one that matches your team's language and CI setup.

### Install

```sh
curl -Ls "https://get.maestro.mobile.dev" | bash
```

### Example flows

Three flows live in [`maestro/`](../maestro/), one per brand:

- [`aqua_smoke.yaml`](../maestro/aqua_smoke.yaml)
- [`coral_no_gifts.yaml`](../maestro/coral_no_gifts.yaml) ← golden-rule proof
- [`amber_smoke.yaml`](../maestro/amber_smoke.yaml)

Each flow launches the flavored APK, checks the AppBar title, checks a
brand-specific store name, and asserts the Gifts FAB is either visible
or absent depending on `giftEnabled`.

Coral flow, in full:

```yaml
appId: com.dinkar1708.flutter_white_label_template.coral
name: Coral smoke test (golden-rule: no Gifts FAB)
---
- launchApp:
    clearState: true
- assertVisible: "Coral"
- assertVisible: "Sunset Diner"
- assertVisible: "Reef Records"
- assertNotVisible: "Gifts"     # feature flag OFF for coral
```

### Run

```sh
# build and install the flavor you want first (see main README)
flutter build apk --flavor coral --dart-define=BRAND=coral
adb install build/app/outputs/flutter-apk/app-coral-debug.apk

# then run the matching Maestro flow
maestro test maestro/coral_no_gifts.yaml

# or run all three flows in sequence
maestro test maestro/
```

> **Runnable after Commit 6.** These flows target flavored `appId`s
> (`.aqua`, `.coral`, `.amber`) that don't exist until Android product
> flavors land. Until then you can adapt them to target the current
> single package (`com.example.flutter_white_label_template`).

### Known issue — Flutter + Impeller + Maestro semantics

On some Android devices with the Impeller (Vulkan) renderer, Maestro's
`assertVisible: "…"` may fail to find widgets even when they are on
screen. The cause: Flutter publishes its semantics tree to Android
accessibility on demand, and Maestro's polling doesn't always trigger
it — but `adb shell uiautomator dump` does.

Workarounds tried in this repo:

- `SemanticsBinding.instance.ensureSemantics()` in `main.dart` — enables
  internal semantics generation but doesn't force OS-side publish.
- `waitForAnimationToEnd` before assertions — helps with timing but not
  the tree-publish gap.

Additional options if you hit this:

- Run with the Skia renderer: `flutter run --no-enable-impeller` (Skia
  publishes semantics more eagerly).
- Enable an accessibility service before test: `adb shell settings put
  secure enabled_accessibility_services ...`.
- Switch to [Patrol](https://patrol.leancode.co/) or Flutter's own
  [`integration_test`](https://docs.flutter.dev/testing/integration-tests)
  — both drive the app from inside the Dart VM, bypassing the a11y bridge.

The pattern (YAML flow + `assertNotVisible: "Gifts"` for the golden rule)
is validated. Choose the runner that matches your team's device fleet.

### Alternatives at a glance

| Tool | Language | Provider overrides | Runs on |
|---|---|---|---|
| **Maestro** | YAML | ❌ black-box | real device |
| **Flutter `integration_test`** | Dart | ✅ same as widget tests | real device |
| **Patrol** | Dart | ✅ | real device, supports native views |
| **Appium** | JS / Python / Java | ❌ | real device, older & heavier |
| **Detox** | JS | ❌ | real device, RN-first |

---

## The override pattern (why headless tests are fast)

Instead of setting `--dart-define=BRAND=coral` at test time, override the
provider directly:

```dart
ProviderScope(
  overrides: [
    brandProvider.overrideWith((ref) => Brand.coral),
    storesProvider.overrideWith((ref) => Future.value(mockStores)),
  ],
  child: const HomeScreen(),
)
```

Benefits:
- **No compile-time coupling** to the brand under test.
- **Any provider** in the graph can be swapped for a fake — `storeRepositoryProvider`, `storesProvider`, or `brandProvider` itself.
- Tests run in <100 ms because the 800 ms fake latency is bypassed.

Device tests, by contrast, can't do this — Maestro / Appium etc. operate
on the built APK and can only interact through the OS. Use headless tests
for logic breadth, device tests for OS integration proof.

---

## Adding tests for a new brand

If you add `Brand.pearl`:

1. **Repository unit test** — copy the `coral returns 2 stores` block, adjust name/count.
2. **Provider test** — no change needed. The `for (final brand in Brand.values)` loop picks up `pearl` automatically.
3. **Widget test** — copy the coral block, adjust expected text and gifts assertion based on `pearl`'s `giftEnabled` setting.
4. **Maestro flow** — copy `coral_no_gifts.yaml` → `pearl_smoke.yaml`, update `appId` and expected text.

---

## Coverage

```sh
flutter test --coverage
```

Writes `coverage/lcov.info`. Current per-file coverage:

| File | Lines | Hit | % |
|---|---:|---:|---:|
| `lib/brand/brand.dart` | 3 | 0 | 0.0% |
| `lib/brand/brand_config.dart` | 1 | 1 | 100.0% |
| `lib/models/store.dart` | 1 | 1 | 100.0% |
| `lib/repositories/store_repository.dart` | 3 | 3 | 100.0% |
| `lib/providers/brand_providers.dart` | 5 | 3 | 60.0% |
| `lib/providers/brand_providers.g.dart` | 26 | 18 | 69.2% |
| `lib/providers/store_providers.dart` | 6 | 6 | 100.0% |
| `lib/providers/store_providers.g.dart` | 23 | 20 | 87.0% |
| `lib/screens/home_screen.dart` | 39 | 36 | 92.3% |
| **TOTAL** | **107** | **88** | **82.2%** |

Notes:
- `brand.dart` at 0 % is misleading — its top-level `currentBrand`
  initializer runs at boot but the test process starts with providers
  overridden, so the raw file is never touched. Providers cover the logic.
- Generated `.g.dart` files are counted; if you'd rather exclude them,
  add `--coverage-package=flutter_white_label_template` and filter with
  `lcov --remove`.

To browse coverage per file:
```sh
brew install lcov
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## What we *don't* test (yet)

- **Golden image tests** — pixel snapshots per brand. Overkill for a
  template, but noted in the ideas parking lot.
- **Golden-rule linting** — a `custom_lint` rule to fail CI if any
  `brand == Brand.xxx` check appears in `lib/` outside `brand/`. Would be
  a nice enforcement mechanism to add later.
