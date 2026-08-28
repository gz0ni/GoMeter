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

**Local builds are forbidden without an explicit user request.** Builds and packaging are done by GitHub Actions on `v*` tags (`.github/workflows/build.yaml`). If an artifact is needed, ask the user to push a tag instead.

For reference, the commands the CI runs (never execute locally unless the user explicitly asks):

```bash
flutter build linux --debug
flutter build android
flutter build ios
flutter build macos
flutter build windows
```

## Packaging

Generate or regenerate platform launcher icons from the brand logo (`assets/images/svg/logo.svg` → `assets/images/png/icon-1024.png` / `icon-2048.png`):

```bash
# High-quality supersample from SVG (requires sharp, used in CI):
npm install sharp --no-save
node scripts/svg_to_png.mjs   # SVG → icon-2048.png + high-quality icon-1024.png

dart run scripts/generate_launcher_assets.dart
dart run flutter_launcher_icons
dart run scripts/generate_ico.dart
```

`generate_ico.dart` must run **after** `flutter_launcher_icons` — the latter rewrites `windows/runner/resources/app_icon.ico`, and the ico generator writes the final multi-frame PNG-compressed ICO plus the tray-optimized `assets/images/ico/gometer.ico` (10 frames `[16,20,24,32,40,48,64,96,128,256]` + 5 tray frames). Adaptive Android icons use `assets/images/png/adaptive-foreground.png` (ring 66% / 676px inside the 66/108 safe zone) and `adaptive-background.png` (blue→lavender gradient); regenerate them with `dart run scripts/generate_launcher_assets.dart` before `flutter_launcher_icons`. `icon-2048.png` is preferred by `generate_launcher_assets.dart` / `generate_ico.dart` when present, otherwise fallback to `icon-1024.png`.

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
