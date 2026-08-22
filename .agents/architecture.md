# Architecture

## Entry Point

`lib/main.dart` initializes `SharedPreferences`, creates a `SettingsRepository`, builds the `AppRouter`, creates a `Dio` client and `UpdateService` from `PackageInfo`, and runs the app under a `ProviderScope` that overrides `settingsRepositoryProvider` and `updateServiceProvider`.

`lib/app.dart` is the root widget. It watches `settingsProvider` and builds `MaterialApp.router` with:

- Russian locale (`Locale('ru', 'RU')`).
- Theme generated from the current `AppSettings` (theme mode + accent seed).
- The configured `GoRouter`.
- Auto-check for updates on startup when `autoCheckUpdate` is enabled.

## Core Layer

### Settings (`lib/core/settings/`)

- `settings_repository.dart` defines `AppSettings` (theme mode, accent seed, API key flag, check interval, notification toggles, banner dismissed, auto-check updates) and `SettingsRepository`, which serializes everything to `SharedPreferences`.
- `SettingsRepository.load()` is synchronous after the initial `SharedPreferences.getInstance()`.

### Theme (`lib/core/theme/`)

- `app_theme.dart` maps accent seeds to concrete `Color` values and builds a `ThemeData` from `ColorScheme.fromSeed` plus `AppExtraColors` for warn/amber/red level states.
- `theme_provider.dart` exposes `settingsProvider` as an `AsyncNotifier` and `settingsRepositoryProvider` as a sync provider overridden in `main()`.

### Update (`lib/core/update/`)

- `version_utils.dart` — version comparison and release asset matching.
- `release_info.dart` — release + asset models.
- `update_service.dart` — GitHub `releases/latest` check, asset selection, and download with progress.
- `update_controller.dart` / `update_state.dart` — Riverpod state machine (idle/checking/available/downloading/ready/installing/error).
- `installer.dart` — platform-specific install launchers:
  - Windows: run `setup.exe /VERYSILENT /SUPPRESSMSGBOXES /NORESTART` and exit.
  - Linux: `pkexec dpkg -i <deb>` with `xdg-open` fallback.
  - macOS: mount `.dmg` and copy `GoMeter.app` to `/Applications` via `osascript`.
  - Android: `FileProvider` + `ACTION_VIEW` intent via a Kotlin method channel.

### Router (`lib/core/router/`)

- `app_router.dart` creates a `GoRouter` with:
  - `/onboarding` for the first-run screen.
  - A `StatefulShellRoute.indexedStack` with 5 branches: `/usage`, `/notifications`, `/settings`, `/key`, `/about`.
  - A redirect that sends users without a saved key to `/onboarding` and authenticated users away from `/onboarding`.

### Shell (`lib/core/shell/`)

- `app_shell.dart` renders:
  - A floating 3-tab bottom pill navigation on screens narrower than 600 logical pixels (Usage, Notifications, Settings).
  - A `NavigationRail` on wider screens with all 5 destinations and a collapse/expand toggle.
- Key and About are stacked routes on mobile; on desktop they are rail destinations.

### Widgets (`lib/core/widgets/`)

Shared MD3 components used across screens:

- `brand_logo.dart`, `status_chip.dart`, `filter_chip.dart`, `color_dot.dart`, `filled_text_field.dart`, `limit_card.dart`, `update_banner.dart`, `update_progress_dialog.dart`.

## Feature Layer

- `lib/features/onboarding/onboarding_screen.dart` — first-run: theme, accent color, API key validation (`sk-` prefix + length), and start action.
- `lib/features/usage/usage_screen.dart` — limit cards, refresh action, animated status chip, live countdown, and update banner.
- `lib/features/usage/models/usage_limit.dart` — `UsageLimit` model.
- `lib/features/usage/providers/usage_provider.dart` — mock limit data matching the mockup.
- `lib/features/notifications/notifications_screen.dart` — notification preview and threshold switches.
- `lib/features/settings/settings_screen.dart` — check interval, theme, accent color, notification toggles, update settings, key/about navigation, and data reset.
- `lib/features/access_key/access_key_screen.dart` — API key input with show/hide and validation.
- `lib/features/about/about_screen.dart` — app info, dynamic update card, and links.

## Known Gaps

- The Usage screen still uses mock data; real OpenCode Go API integration has not started.
- Update release asset names must follow the convention `GoMeter-<version>-<platform>-<arch>.<ext>` for `update_service.dart` to pick the correct file.

## Roadmap

1. Replace mock `usageProvider` with real OpenCode Go API calls behind an interface.
2. Add focused provider/widget tests for settings, usage, and update flows.
3. Add background limit checking and local notifications.
