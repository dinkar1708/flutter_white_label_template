# Independent applicationIds per flavor

By default this template uses **Pattern A** — one shared base
`applicationId` with per-flavor suffixes:

```
com.dinkar1708.flutter_white_label_template.aqua
com.dinkar1708.flutter_white_label_template.coral
com.dinkar1708.flutter_white_label_template.amber
```

That's the easy option and it's great for showcases and portfolios
where you own every brand under one org.

**Real white-label products almost always want Pattern B** — a
completely independent `applicationId` (Android) / `PRODUCT_BUNDLE_IDENTIFIER`
(iOS) per brand, with no visible connection back to your base org:

```
com.aquaperks.mobile      ← client A's org
com.coralrewards.app      ← client B's org
com.amberloyalty.mobile   ← client C's org
```

This guide shows how to switch.

---

## Why Pattern B

- **Play Store / App Store listings** appear as separate companies. No
  reviewer sees "com.dinkar1708.*" three times.
- **Signing keys** are typically owned by the client. Fully independent
  applicationIds let each brand carry its own keystore and provisioning
  profile without leaking anything about the others.
- **Regulatory / partner constraints** — some enterprise partners require
  their own reverse-DNS namespace end-to-end.
- **Analytics + crash reporting are per-app** — Firebase, Sentry,
  Crashlytics, and MDM tools key off `applicationId` / `bundleId`.

---

## Android — switch to independent applicationIds

Edit `android/app/build.gradle.kts`. Replace the `applicationIdSuffix`
lines inside each `productFlavors { create(...) }` block with a full
`applicationId`:

```kotlin
// Before — Pattern A (suffix under your base org)
productFlavors {
    create("aqua")  {
        dimension = "brand"
        applicationIdSuffix = ".aqua"
        resValue("string", "app_name", "Aqua")
    }
    create("coral") {
        dimension = "brand"
        applicationIdSuffix = ".coral"
        resValue("string", "app_name", "Coral")
    }
    create("amber") {
        dimension = "brand"
        applicationIdSuffix = ".amber"
        resValue("string", "app_name", "Amber")
    }
}

// After — Pattern B (fully independent per brand)
productFlavors {
    create("aqua")  {
        dimension = "brand"
        applicationId = "com.aquaperks.mobile"     // ← full, unrelated
        resValue("string", "app_name", "Aqua Perks")
    }
    create("coral") {
        dimension = "brand"
        applicationId = "com.coralrewards.app"     // ← full, unrelated
        resValue("string", "app_name", "Coral Rewards")
    }
    create("amber") {
        dimension = "brand"
        applicationId = "com.amberloyalty.mobile"  // ← full, unrelated
        resValue("string", "app_name", "Amber Loyalty")
    }
}
```

Notes:

- `defaultConfig.applicationId` is now overridden per flavor and stops
  mattering for shipped builds — leave it alone or set it to a marker
  value like `"com.dinkar1708.flutter_white_label_template.default"`
  so unflavored `flutter run` still installs something.
- `namespace` (which controls Kotlin source resolution) stays as
  `com.dinkar1708.flutter_white_label_template`. It has **nothing to do
  with the applicationId** — no need to move `MainActivity.kt`.
- Reverse-DNS names on the Play Store must be unique across the entire
  Play catalog. Do a Play Store search on each proposed ID **before**
  publishing.

Optional: per-flavor signing configs (usually one per brand for release):

```kotlin
signingConfigs {
    create("aquaRelease")  { storeFile = file("keystores/aqua.jks");  storePassword = "…"; keyAlias = "aqua";  keyPassword = "…" }
    create("coralRelease") { storeFile = file("keystores/coral.jks"); storePassword = "…"; keyAlias = "coral"; keyPassword = "…" }
    create("amberRelease") { storeFile = file("keystores/amber.jks"); storePassword = "…"; keyAlias = "amber"; keyPassword = "…" }
}

productFlavors {
    create("aqua")  { ...; signingConfig = signingConfigs.getByName("aquaRelease")  }
    create("coral") { ...; signingConfig = signingConfigs.getByName("coralRelease") }
    create("amber") { ...; signingConfig = signingConfigs.getByName("amberRelease") }
}
```

Never commit real keystores or passwords. Pull them from environment
variables in CI and from `~/.gradle/gradle.properties` locally.

---

## iOS — switch to independent bundle identifiers

Edit each `ios/Flutter/*-<brand>.xcconfig` and replace the
`PRODUCT_BUNDLE_IDENTIFIER` value with the full, unrelated ID. For
example, coral:

```
# ios/Flutter/Debug-coral.xcconfig
#include "Debug.xcconfig"

# Before
# PRODUCT_BUNDLE_IDENTIFIER = com.dinkar1708.flutterWhiteLabelTemplate.coral

# After
PRODUCT_BUNDLE_IDENTIFIER = com.coralrewards.app
APP_DISPLAY_NAME = Coral Rewards
```

Repeat for `Profile-coral.xcconfig`, `Release-coral.xcconfig`, and the
matching triplets for aqua and amber. Each brand's three files must
agree.

No changes needed in `project.pbxproj` — the target-level build
configurations still get `PRODUCT_BUNDLE_IDENTIFIER` overridden inline
(that override is what makes Pattern A work today). If you want the
xcconfig to be the single source of truth instead, delete the override
from the target's build settings for each `Debug-<brand>` /
`Profile-<brand>` / `Release-<brand>` configuration:

```ruby
# tweak of tmp/setup_ios_flavors.rb, run once
require 'xcodeproj'
project = Xcodeproj::Project.open('ios/Runner.xcodeproj')
runner = project.targets.find { |t| t.name == 'Runner' }
runner.build_configurations.each do |c|
  next unless c.name =~ /-(aqua|coral|amber)$/
  c.build_settings.delete('PRODUCT_BUNDLE_IDENTIFIER')
end
project.save
```

Signing: Xcode uses provisioning profiles keyed by `PRODUCT_BUNDLE_IDENTIFIER`
and Team ID. For fully independent releases, each brand needs its own
Apple Developer team (or at least its own App ID + profile within one
team). Add per-flavor `DEVELOPMENT_TEAM` and
`CODE_SIGN_STYLE = Manual` lines in the xcconfig if brands live under
different teams.

---

## Firebase, Sentry, and other keyed configs

These SDKs identify apps by `applicationId` / `bundleId`. When you flip
to Pattern B you'll usually need one config file per brand.

### Android — `google-services.json`

Put the per-flavor config at:

```
android/app/src/aqua/google-services.json
android/app/src/coral/google-services.json
android/app/src/amber/google-services.json
```

Gradle's Google Services plugin picks the right one automatically based
on the active flavor. Remove `android/app/google-services.json` (the
generic one) so nobody uses the wrong project by accident.

### iOS — `GoogleService-Info.plist`

Same idea, but iOS asset routing is manual. Two options:

1. **Multiple files + Run Script phase** that copies the correct one at
   build time based on `PRODUCT_BUNDLE_IDENTIFIER`.
2. **Multiple targets** (heaviest — one target per brand). Overkill for
   this template.

For most cases option 1 is what people do. Store the files as:

```
ios/Runner/Firebase/GoogleService-Info-aqua.plist
ios/Runner/Firebase/GoogleService-Info-coral.plist
ios/Runner/Firebase/GoogleService-Info-amber.plist
```

Add a Run Script build phase that resolves `${PRODUCT_BUNDLE_IDENTIFIER}`
and copies the matching file to `${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH}/../GoogleService-Info.plist`
before the "Copy Bundle Resources" phase.

### Sentry, Segment, Amplitude, MDM, App Center

Same pattern. Either resolve the DSN / write key at build time from a
per-flavor xcconfig / Gradle variable, or bundle per-flavor config
files and switch at runtime based on `PackageInfo.fromPlatform()`.

---

## Icons per brand

Real independent brands always ship distinct icons.

- **Android** — put per-flavor drawables under
  `android/app/src/<brand>/res/mipmap-*/ic_launcher.png`.
  Gradle merges them into the flavored APK automatically.
- **iOS** — add per-brand `AppIcon-aqua.xcassets` etc., then set
  `ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon-<brand>` in each brand's
  xcconfig.

---

## Verification

After swapping any brand, rebuild and check the boot log — it prints the
active native identity so mistakes are obvious:

```sh
flutter run --flavor coral --dart-define=BRAND=coral -d <device>
# expected line at boot:
# [boot] brand=coral appId=com.coralrewards.app appName="Coral Rewards" version=1.0.0+1
```

Then:

```sh
# Android — confirm three unrelated packages coexist
adb shell pm list packages | grep -E "aquaperks|coralrewards|amberloyalty"

# iOS simulator — confirm three unrelated bundle IDs
xcrun simctl listapps booted | grep -A1 "CFBundleIdentifier"
```

---

## Rollback to Pattern A

If a client changes their mind, revert by putting the suffix pattern
back in `android/app/build.gradle.kts` and restoring the
`com.dinkar1708.flutterWhiteLabelTemplate.<brand>` values in every
`ios/Flutter/*-<brand>.xcconfig`. No pbxproj or scheme changes needed —
only the applicationId string changes across the two platform config
layers.

---

## When to pick which

| Situation | Pattern |
|---|---|
| Portfolio / showcase you own end-to-end | **A** — suffix |
| Personal side-project with 2-3 personal brands | **A** — suffix |
| Real client work / agency deliverable | **B** — independent |
| Multi-region rollout with distinct legal entities per region | **B** — independent |
| Client wants their own Play Console / Apple Developer team | **B** — independent |
| Client wants their own Firebase project | **B** — independent |

The template ships **Pattern A** because it's simpler to read. Switching
to Pattern B is a one-line-per-flavor edit on Android plus a
one-line-per-file edit on iOS xcconfigs — everything else (schemes,
launch.json, CI matrix, tests) stays identical.
