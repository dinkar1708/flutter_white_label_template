# Test Results Snapshot

Snapshot of the latest local test + coverage run. Regenerate with:

```sh
flutter test --coverage
```

_Last updated: 2026-07-09_

---

## Summary by test category

| Category | Runs on | File | Tests | Passed |
|---|---|---|---:|---:|
| **Unit** | host, headless | `test/store_repository_test.dart` | 3 | 3 |
| **Provider** (Riverpod DI) | host, headless | `test/providers_test.dart` | 5 | 5 |
| **Widget** | host, headless | `test/screens/home_screen_test.dart` | 4 | 4 |
| **Device** (Maestro) | real device | `maestro/*.yaml` | 3 flows
| **Total headless** | | | **12** | **12** |

Wall time: ~2 s • Line coverage (headless suites): **82.2 %** (88 / 107 lines)
Flutter 3.44.0 • Dart 3.12.0 • macOS host

---

## 1. Unit tests — `test/store_repository_test.dart`

Category: **Unit**. Pure Dart, no Riverpod, no widgets. Verifies the mock
repository contract per brand.

```
00:00 +1: aqua returns 3 stores
00:00 +2: coral returns 2 stores
00:01 +3: amber returns 4 stores
00:02 +3: All tests passed!
```

Files exercised: `lib/models/store.dart`, `lib/repositories/store_repository.dart`,
`lib/brand/brand.dart` (enum values only).

---

## 2. Provider tests — `test/providers_test.dart`

Category: **Provider / Riverpod DI**. Uses `ProviderContainer` with
`overrideWith` to swap `brandProvider` per test. No widgets, no
`--dart-define`.

```
00:00 +1: brandConfigProvider returns the mapped config for aqua
00:00 +2: brandConfigProvider returns the mapped config for coral
00:00 +3: brandConfigProvider returns the mapped config for amber
00:00 +4: coral has gifts disabled (feature-flag demo)
00:00 +5: storesProvider returns 2 stores for coral
00:00 +5: All tests passed!
```

Files exercised: `lib/providers/brand_providers.dart` (+ `.g.dart`),
`lib/providers/store_providers.dart` (+ `.g.dart`), `lib/brand/brand_config.dart`.
The `for (final brand in Brand.values)` loop auto-covers any new brand.

---

## 3. Widget tests — `test/screens/home_screen_test.dart`

Category: **Widget**. Runs headless via `flutter_test`'s `WidgetTester` —
no device, no GPU, no OS. Pumps `HomeScreen` inside a `ProviderScope`
with brand + stores overridden.

```
00:00 +1: aqua: shows appName, all 3 stores, and Gifts FAB
00:00 +2: coral: shows appName, 2 stores, and NO Gifts FAB       ← golden-rule proof
00:00 +3: shows loading indicator before stores resolve
00:00 +4: tapping Gifts FAB shows a snackbar
00:00 +4: All tests passed!
```

Files exercised: `lib/screens/home_screen.dart` primarily, providers
indirectly via the widget tree.

---

## 4. Device tests — `maestro/*.yaml`

Category: **Device / on-device UI test**. Real APK, real device (or
emulator). Framework-agnostic: Maestro doesn't know the app is Flutter.

Flows staged (not yet runnable — target flavored `appId`s that arrive
in Commit 6):

- `maestro/aqua_smoke.yaml`
- `maestro/coral_no_gifts.yaml` ← on-device golden-rule proof
- `maestro/amber_smoke.yaml`

To run against the current default package (pre-flavors) for a demo,
adapt the `appId` to `com.example.flutter_white_label_template`. Also
requires `SemanticsBinding.instance.ensureSemantics()` at boot so
Maestro/UIAutomator can read the widget text — this is wired in
`lib/main.dart`.

Note: Maestro / Patrol / Appium / Detox / Flutter `integration_test` are
all valid device-test runners. See [`docs/TESTING.md`](TESTING.md#4-device-tests--maestro-maestro)
for the comparison.

---

## Coverage per file

Coverage is aggregated across all **headless** categories (Unit +
Provider + Widget). Device tests are not measured by `--coverage` since
they run on the physical device outside the Dart VM.

| File | Category driving coverage | Lines | Hit | % |
|---|---|---:|---:|---:|
| `lib/brand/brand.dart` | boot-time constant, not exercised by tests | 3 | 0 | 0.0 % |
| `lib/brand/brand_config.dart` | Provider | 1 | 1 | 100.0 % |
| `lib/models/store.dart` | Unit + Widget | 1 | 1 | 100.0 % |
| `lib/repositories/store_repository.dart` | Unit | 3 | 3 | 100.0 % |
| `lib/providers/brand_providers.dart` | Provider | 5 | 3 | 60.0 % |
| `lib/providers/brand_providers.g.dart` | Provider (generated) | 26 | 18 | 69.2 % |
| `lib/providers/store_providers.dart` | Provider + Widget | 6 | 6 | 100.0 % |
| `lib/providers/store_providers.g.dart` | Provider (generated) | 23 | 20 | 87.0 % |
| `lib/screens/home_screen.dart` | Widget | 39 | 36 | 92.3 % |
| **TOTAL** | | **107** | **88** | **82.2 %** |

### Coverage notes

- `lib/brand/brand.dart` at 0 % is expected: its top-level `currentBrand`
  initializer runs at app boot from `String.fromEnvironment`. Tests
  bypass it by overriding `brandProvider` directly, so the source lines
  are never touched. The logic *behind* `currentBrand` (enum resolution)
  is covered indirectly through the provider tests.
- `.g.dart` files are Riverpod-generated. Exclude them with:
  ```sh
  lcov --remove coverage/lcov.info '**/*.g.dart' -o coverage/lcov.filtered.info
  ```

---

## Coverage by test kind

Which test category contributes how much coverage? Ran each suite in
isolation with `--coverage`, then reused the same lcov parser.

| Test kind | File(s) | Lines covered | % of full codebase (107) |
|---|---|---:|---:|
| **Unit** alone | `test/store_repository_test.dart` | 5 | ~5 % |
| **Provider** alone | `test/providers_test.dart` | 52 | ~49 % |
| **Widget** alone | `test/screens/home_screen_test.dart` | 67 | ~63 % |
| **All combined** | full suite | **88** | **~82 %** |

Reading the numbers:

- **Widget tests alone reach ~63 %** — the widget tree pulls in providers
  → `brandConfigProvider` → `BrandConfig`, so `home_screen.dart` and the
  brand layer light up together. But the repository is bypassed
  (`storesProvider.overrideWith` skips the real fetch), so repository
  lines stay at 0 in this suite.
- **Provider tests alone reach ~49 %** — providers exercise the real
  `StoreRepository` (100 % of it) and the whole config map, but never
  build any widgets, so `home_screen.dart` stays at 0.
- **Unit tests alone reach only ~5 %** — the repo is tiny (3 lines).
  Their real value is speed and the per-brand data contract, not raw
  coverage %.
- **Combined ~82 %** is not a sum — the categories overlap. The
  remaining 18 % is mostly the boot-time initializer in `brand.dart`
  (never touched at test time) and a few branches in the generated
  `.g.dart` files.

Add device (Maestro / integration) coverage on top of this for the
platform-level behavior that headless tests can't reach.

---

## How to regenerate this snapshot

```sh
# 1. Run all headless suites with coverage
flutter test --coverage

# 2. Regenerate the per-file table (uses awk over lcov.info)
awk '
/^SF:/ { sub("SF:","",$0); cur=$0 }
/^LF:/ { sub("LF:","",$0); total[cur]+=$0; gt+=$0 }
/^LH:/ { sub("LH:","",$0); hit[cur]+=$0; gh+=$0 }
END {
  for (f in total) printf "%-55s %6d %6d %6.1f%%\n", f, total[f], hit[f], 100*hit[f]/total[f]
  printf "%-55s %6d %6d %6.1f%%\n", "TOTAL", gt, gh, 100*gh/gt
}' coverage/lcov.info

# 3. For per-kind breakdown, run each test file with --coverage
#    separately and save its lcov.info snapshot before overwriting.
```
