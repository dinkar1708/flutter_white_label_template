plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.dinkar1708.flutter_white_label_template"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.dinkar1708.flutter_white_label_template"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // One codebase, N brand-flavored APKs. Each flavor gets its own
    // applicationId suffix so all three can install side-by-side, plus
    // a per-brand app_name resource used from AndroidManifest.xml.
    // Flavor name MUST match the --dart-define=BRAND=<name> value.
    buildFeatures {
        resValues = true
    }

    flavorDimensions += "brand"
    productFlavors {
        create("aqua") {
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

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
