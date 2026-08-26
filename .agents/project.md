# Project Context

GoMeter is a Flutter application that tracks OpenCode Go subscription limits. It reads usage limits (rolling 5-hour, weekly, monthly windows) and warns when thresholds are reached.

## Platforms

Android, iOS, Linux, macOS, Windows. Web is intentionally excluded.

## Toolchain

- No FVM. Use the system Flutter SDK.
- Flutter 3.44.8 (stable channel), Dart SDK ^3.12.2.
- CI exists in `.github/workflows/build.yaml`; releases are published on `v*` tags.

## Package

- `name: gometer`
- `version: 0.1.0+1`
- `org: dev.gometer`

## Dependencies

Core dependencies:

- `flutter_riverpod` — state management.
- `go_router` — routing.
- `shared_preferences` — local persistence for settings and the API key flag.
- `flutter_localizations` — Russian locale for Material widgets.
- `dio` — HTTP client for update checks and downloads.
- `package_info_plus` — current app version.
- `path_provider` — download directory for updates.
- `url_launcher` — opening external links.

## Design Basis

The source of truth for UI/UX is the Material Design 3 mockup in `docs/gometer-mockup-md3/`:

- Mobile layout: 2-tab bottom navigation (Лимиты, Настройки) plus stacked screens (Onboarding, Access Key, About).
- Desktop layout: static 240px navigation rail with brand block and 3 destinations (Лимиты, Настройки, О приложении).
- Default theme: dark mode, MD3 seed-based theme (blue accent seed `#2196F3` as a default; the palette stays app-defined, not the mockup's LocalSend colors).
- Accent seeds: auto, blue, violet, green, orange, pink.

Legacy mockups live in `docs/gometer-mockup/` and `docs/gometer-mockup-standalone/` and should not be used as the design basis.

## Status

Phase 1–4 complete. The UI matches the mockup, in-app updates are implemented, packaging configs and `setup.dart` are in place, and CI releases are configured. The Usage screen still uses mock data; real OpenCode Go API integration has not started.
