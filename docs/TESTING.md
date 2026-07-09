# Testing

Three layers of tests, matching the three layers of code. Each layer runs
independently — no emulator required.

```
┌──────────────────────────────────────────────────────────┐
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
flutter test
```

Full suite is ~12 tests, runs in ~2 seconds. Each brand is covered.

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
```

---

## The override pattern (why this template is testable)

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

---

## Adding tests for a new brand

If you add `Brand.pearl`:

1. **Repository unit test** — copy the `coral returns 2 stores` block, adjust name/count.
2. **Provider test** — no change needed. The `for (final brand in Brand.values)` loop picks up `pearl` automatically.
3. **Widget test** — copy the coral block, adjust expected text and gifts assertion based on `pearl`'s `giftEnabled` setting.

---

## What we *don't* test (yet)

- **Platform code** — Android flavors / iOS xcconfig are verified manually
  by installing side-by-side on device. Adding an `integration_test`
  package suite would run on a real device — a future addition.
- **Golden image tests** — pixel snapshots per brand. Overkill for a
  template, but noted in the ideas parking lot.
- **Golden-rule linting** — a `custom_lint` rule to fail CI if any
  `brand == Brand.xxx` check appears in `lib/` outside `brand/`. Would be
  a nice enforcement mechanism to add later.
