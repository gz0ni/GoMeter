# Commands

## Development

```bash
flutter pub get
flutter run -d linux        # fastest desktop target for local checks
flutter run                 # choose a device interactively
```

## Verification

Run these before claiming work is done:

```bash
flutter analyze
flutter test
```

CI parity target (when CI is added):

```bash
flutter pub get
flutter analyze --no-fatal-infos
flutter test --reporter expanded
```

## Build

Debug desktop build:

```bash
flutter build linux --debug
```

Other platforms:

```bash
flutter build android
flutter build ios
flutter build macos
flutter build windows
```

## Packaging

Generate or regenerate the source icon and platform launcher icons:

```bash
dart run scripts/generate_icon.dart
dart run flutter_launcher_icons
```

Package for the current host platform:

```bash
dart setup.dart
```

Package a specific platform (`android` can be built from any host; desktop targets must match the host):

```bash
dart setup.dart windows --env stable -v
dart setup.dart linux --env stable -v
dart setup.dart macos --env stable -v
dart setup.dart android --env stable -v
dart setup.dart android --env stable --arch arm64 -v
```

Outputs are written to `dist/`.

## CI

Pushing a tag matching `v*` triggers `.github/workflows/build.yaml`. The workflow runs tests, builds Android, Windows, Linux, and macOS packages, and creates a GitHub release including `SHA256SUMS`.

## Tests

Tests live in `test/`. Current suite is small:

- `test/widget_test.dart` — smoke test that the app starts and builds a `MaterialApp`.

Add focused tests when behavior changes, especially for:

- Settings repository save/load round-trips.
- Provider notifier state transitions.
- Widget rendering for key states (loading, empty, error).
