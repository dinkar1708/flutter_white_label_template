# Flavors vs Monorepo — read this before you copy this template

This template ships the **flavors** pattern: one Flutter codebase → N
branded apps. Before you use it, decide whether flavors are the right
shape for your problem. Getting this wrong costs weeks of refactor
later.

---

## Quick decision

| Situation | Use |
|---|---|
| One product, N brands / regions, **same feature set** | ✅ **Flavors** (this template) |
| N distinct products sharing auth / UI / network, **different features** | ✅ **Monorepo** (Pub Workspaces / Melos) |
| Any app needs `in_app_purchase`, camera, health, etc. that others must **not** ship | ❌ **Not flavors** — see the [IAP trap](#the-iap-trap) below |
| Solo dev, single app, still exploring | ✅ Plain Flutter — neither |

**Rule of thumb:** if the apps have different `pubspec.yaml` files in
your head, use a monorepo.

---

## Why flavors (what this template gives you)

If your apps *are* the same product wearing different clothes, the
flavors pattern gives you real leverage:

- **One PR fixes N apps.** Auth bug in the shared `HomeScreen`? Fix it
  once, all brands ship the fix on the next release.
- **Every module is reused for free.** `brand`, `providers`, `models`,
  `repositories`, `screens`, tests — everything but a `BrandConfig` map
  entry is shared by all brands. Nothing to sync between codebases.
- **Provider tests iterate `Brand.values`.** Adding a brand automatically
  gains repo + config test coverage. Zero test files to edit.
- **One dependency graph.** Bump `flutter_riverpod` once, all brands
  move together. No drift.
- **One CI matrix line per brand.** ~15 minutes to onboard a new brand
  (enum + config + Android flavor + iOS xcconfig + scheme + CI matrix
  entry + launch.json).
- **One dev environment.** One IDE, one Flutter version, one Gradle
  cache, one CocoaPods install. Instant context-switching between
  brands.
- **Compile-time selection = tree-shaking.** Unused branches of `const`
  data can be dropped from release builds when Dart's AOT compiler can
  prove reachability.
- **Testable without rebuilding.** `ProviderContainer.overrideWith`
  swaps the active brand at test time — no `--dart-define` needed to
  cover another brand.

The cost of this leverage is that **all** brands share **all**
dependencies. See the trap below.

---

## Why a monorepo (when flavors run out)

Flavors buy you code sharing but *only* if every brand can tolerate the
same dependency list. The moment one app needs a native package that
another must not carry, flavors stop scaling. A monorepo gives you:

- **Per-app pubspec.** Each app declares only what it uses → clean
  App Store / Play Store reviews.
- **Shared code via workspace packages.** `common_auth`, `common_ui`,
  `common_network`, etc. — imported only where needed.
- **Independent release cadence per app.** Ship app A on Monday, app B
  on Friday, no cross-contamination.
- **CI matrix over `apps/*`.** Only apps whose dependency graph changed
  need to rebuild — big win at 5+ apps.

Real example: [Very Good Ventures' Very Yummy Coffee](https://verygood.ventures/blog/your-business-doesnt-fit-on-a-phone-neither-should-your-flutter-app-recap/) —
5 apps (customer, kiosk, POS, kitchen display, menu board), 21 % code
shared across 8 workspace packages.

---

## The IAP trap

The line where flavors stop working and a monorepo starts being
mandatory.

**Problem.** Apple and Google's review pipelines scan the shipped
binary for unused frameworks and declared permissions. If your
`pubspec.yaml` lists `in_app_purchase`, **every** flavor's APK / IPA
links Play Billing (Android) and StoreKit (iOS). A flavor that doesn't
actually use IAP will get flagged — see
[Apple App Review Guidelines §2.1](https://developer.apple.com/app-store/review/guidelines/)
and this real
[PassKit rejection walkthrough](https://blog.wenhaofree.com/en/posts/articles/app-store-guideline-2-1-fix-passkit/).
Same story for `health`, `location`, `camera`, `bluetooth`,
`background_fetch`, `contacts`.

**No clean fix in flavors.** Flutter has no way to condition a pubspec
dep on the active flavor — confirmed as an open limitation in
[flutter/flutter#46979](https://github.com/flutter/flutter/issues/46979).
Workarounds (scripted `pub remove` + `pub add`, multiple pubspec files,
native Podfile / Gradle conditional includes) are brittle and
IDE-hostile.

**Clean fix in a monorepo.** Each app has its own `pubspec.yaml`:

```
portfolio_repo/
├── apps/
│   ├── perks_a/           pubspec: firebase_core, in_app_purchase
│   ├── perks_b/           pubspec: firebase_core             (no IAP)
│   └── media_c/           pubspec: firebase_core, video_player
└── packages/
    ├── common_auth/
    ├── common_network/
    ├── common_ui/
    └── iap_feature/       used by perks_a only
```

Only `perks_a`'s binary links `in_app_purchase`. Reviewer happy.

---

## Migration path (flavors → monorepo)

When you outgrow flavors:

1. Wrap the current app inside `apps/<first-product>/` in a new repo.
2. Extract shared code (brand, providers, common widgets, network,
   analytics) into `packages/common_*`.
3. Add a workspace root — [Pub Workspaces](https://dart.dev/tools/pub/workspaces)
   (Dart 3.6+ / Flutter 3.27+) is now the default, [Melos](https://pub.dev/packages/melos)
   still fine if you want its extra commands. See
   [Sijal Neupane's 2025→2026 guide](https://medium.com/@sijalneupane5/flutter-monorepo-from-scratch-2025-going-into-2026-pub-workspaces-melos-explained-properly-fae98bfc8a6e)
   for the comparison.
4. Add each subsequent app under `apps/<name>/` with its own
   `pubspec.yaml`.
5. CI matrix over `apps/*` instead of `matrix.brand`.

**Flavors compose inside a monorepo.** One app in the monorepo can
itself have flavors (regional variants of that product). You don't
lose the flavors pattern by switching — you just push it one level
down.

---

## Sources

- [flutter/flutter#46979 — Support different dependencies when using flavors](https://github.com/flutter/flutter/issues/46979) — canonical proof that per-flavor pubspec deps aren't supported
- [Flutter official flavors guide](https://docs.flutter.dev/deployment/flavors)
- [Flutter pubspec options — flavor-conditional *assets*](https://docs.flutter.dev/tools/pubspec) — works for assets, not deps
- [Very Good Ventures — One codebase, five apps](https://verygood.ventures/blog/your-business-doesnt-fit-on-a-phone-neither-should-your-flutter-app-recap/) — real 5-app monorepo case study
- [Marcelo Mussi — Building a Scalable Flutter Monorepo for White-Label Apps](https://medium.com/@marcelomussi/building-a-scalable-flutter-monorepo-for-white-label-apps-a622ad7a25aa)
- [Shahzaib Abid — When to Use Flutter Melos and Monorepo](https://shahzaibabid.com/when-to-use-flutter-melos-and-monorepo/)
- [Sijal Neupane — Flutter Monorepo from Scratch (2025→2026)](https://medium.com/@sijalneupane5/flutter-monorepo-from-scratch-2025-going-into-2026-pub-workspaces-melos-explained-properly-fae98bfc8a6e)
- [Codemagic — How to manage your Flutter monorepos](https://blog.codemagic.io/flutter-monorepos/)
- [melos on pub.dev](https://pub.dev/packages/melos)
- [Dart Pub Workspaces docs](https://dart.dev/tools/pub/workspaces)
- [Apple App Review Guidelines §2.1](https://developer.apple.com/app-store/review/guidelines/)
- [Apple PassKit unused-framework rejection walkthrough](https://blog.wenhaofree.com/en/posts/articles/app-store-guideline-2-1-fix-passkit/)
- [freeCodeCamp — How to Use Monorepos in Flutter](https://www.freecodecamp.org/news/how-to-use-monorepos-in-flutter/)
