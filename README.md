# flutter_white_label_template

A new Flutter project.

## Run

Select a brand at compile time with `--dart-define=BRAND=<aqua|coral|amber>`
(defaults to `aqua` when omitted):

```sh
flutter pub get

# default brand (aqua)
flutter run

# pick a brand
flutter run --dart-define=BRAND=coral
flutter run --dart-define=BRAND=amber

# target a specific device
flutter run -d <device-id> --dart-define=BRAND=coral

# list devices
flutter devices
```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
