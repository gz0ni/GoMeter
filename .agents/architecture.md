# Architecture

## Entry Point

`lib/main.dart` initializes `SharedPreferences`, creates a `SettingsRepository`, builds the `AppRouter`, creates a `Dio` client and `UpdateService` from `PackageInfo`, initializes the `FlutterLocalNotificationsService`, and runs the app under a `ProviderScope` that overrides `settingsRepositoryProvider`, `updateServiceProvider`, `usageApiServiceProvider`, `notificationsServiceProvider`, and `notificationHistoryProvider`. If launched with `--quiet` (autostart with quiet start), it hides the window and attaches the tray icon via `TrayController`.

`lib/app.dart` is the root widget. It watches `settingsProvider` and builds `MaterialApp.router` with:

- Russian locale (`Locale('ru', 'RU')`).
- Theme generated from the current `AppSettings` (theme mode + accent seed).
- The configured `GoRouter`.
- Auto-check for updates on startup when `autoCheckUpdate` is enabled.

## Core Layer

### Settings (`lib/core/settings/`)

- `settings_repository.dart` defines `AppSettings` (theme mode, accent seed, API key, check interval, notification toggles, banner dismissed, auto-check updates, autostart, quiet start) and `SettingsRepository`, which serializes everything to `SharedPreferences`.
- `SettingsRepository.load()` is synchronous after the initial `SharedPreferences.getInstance()`.

### Theme (`lib/core/theme/`)

- `app_theme.dart` maps accent seeds to concrete `Color` values and builds a `ThemeData` from `ColorScheme.fromSeed` plus `AppExtraColors` for warn/amber/red level states.
- `app_extra_colors.dart` — `AppExtraColors` used by the theme for warn/amber/red states.
- `theme_provider.dart` exposes `settingsProvider` as an `AsyncNotifier` and `settingsRepositoryProvider` as a sync provider overridden in `main()`.

### Auth (`lib/core/utils/`)

- `opencode_auth.dart` — locates the OpenCode CLI auth file (`auth.json`) across Linux/macOS/Windows config paths and reads the saved API key.

### Autostart (`lib/core/autostart/`)

- `autostart_service.dart` — platform services + `autostartServiceProvider`:
  - Windows: `reg.exe` key `HKCU\Software\Microsoft\Windows\CurrentVersion\Run`, value `GoMeter`, command `"<exe>" [--quiet]`.
  - Linux: `~/.config/autostart/gometer.desktop` (X-GNOME-Autostart entry).
  - macOS: `~/Library/LaunchAgents/dev.gometer.gometer.plist` (RunAtLoad).
  - Android/iOS: `NoopAutostartService`.
- Pure builders (`windowsRunCommand`, `linuxDesktopEntry`, `macosLaunchAgentPlist`) are unit-tested.

### Notifications (`lib/core/notifications/`)

- `notification_service.dart` — `NotificationService` abstraction + `notificationsServiceProvider` (overridden in `main()`).
- `flutter_local_notifications_service.dart` — implementation over `flutter_local_notifications`: Android small icon via `@mipmap/ic_launcher`, Windows `dev.gometer.gometer` AppUserModelId, Linux DBus, macOS/iOS permission requests. Best-effort: init failures (e.g. Linux without a notification daemon) are swallowed.
- `notification_history.dart` — `NotificationHistory` persisted in `SharedPreferences`: anti-spam marks (`notified-<window>-<threshold>-<resetAtMillis>`, once per threshold per window, re-arms after the window resets) and the dismissed live-push set.

### Tray (`lib/core/tray/`)

- `tray_controller.dart` — singleton that hides the window, sets the tray icon and provides a menu: «Открыть GoMeter» (show/restore/focus) and «Выход». Icon path is resolved by `resolveTrayIconPath` against the exe dir (`data/flutter_assets`), with cwd fallbacks for dev runs (Windows `.ico`, others `icon-64.png`). Right-click pops the context menu via `onTrayIconRightMouseDown` → `popUpContextMenu`. Used only for `--quiet` start (tray_manager + window_manager).

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

### Layout (`lib/core/layout/`)

- `breakpoints.dart` — `isDesktopLayout()` (width >= 600), `DesktopNarrow` wrapper (max 640 centered column for desktop side pages).

### Router (`lib/core/router/`)

- `app_router.dart` creates a `GoRouter` with:
  - `/onboarding` for the first-run screen.
  - A `ShellRoute` with 4 branches: `/usage`, `/settings`, `/key`, `/about`. `/notifications` was removed with the mockup rework.
  - A redirect that sends users without a saved key to `/onboarding` and authenticated users away from `/onboarding`.

### Shell (`lib/core/shell/`)

- `app_shell.dart` renders:
  - A bottom navigation bar with 2 tabs (Лимиты, Настройки) on screens narrower than 600 logical pixels. The bar is hidden on `/key` and `/about` (stack screens with a back button).
  - A static 240px rail on wider screens: brand block (logo + GoMeter) on top, then Лимиты / Настройки / О приложении, no collapse toggle.
- The Usage grid no longer depends on any rail expansion state; `rail_state.dart` was removed. Content columns are centered and capped at 640px via `DesktopNarrow`, matching the mockup.

### Widgets (`lib/core/widgets/`)

Shared MD3 components used across screens:

- `app_icon.dart`, `brand_logo.dart`, `page_head.dart`, `section_title.dart`, `setting_row.dart` (SettingRow/SwitchRow/SettingsSection), `phone_notif.dart`, `status_card.dart`, `dropdown_pill.dart`, `filter_chip.dart`, `color_dot.dart`, `filled_text_field.dart`, `limit_card.dart`, `update_progress_dialog.dart`.
- The GoMeter logo (`assets/images/png/*`) replaces the old `Icons.speed` placeholders in BrandLogo, onboarding hero, about hero, and the notification preview.

## Feature Layer

- `lib/features/onboarding/onboarding_screen.dart` — first-run: hero with logo, API key validation (`sk-` prefix + length), start action. Theme/accent selection was removed from onboarding (mockup rework); it lives in Settings.
- `lib/features/usage/usage_screen.dart` — page head «Лимиты» with refresh/key actions, live push cards (per mockup `PUSH_THRESHOLDS` = 80/95), limit card grid, «Статус» section with StatusCard, last-updated line.
- `lib/features/usage/models/usage_limit.dart` — `UsageLimit` model.
- `lib/features/usage/models/push_card.dart` — live push card model (threshold, window, message, reset seconds).
- `lib/features/usage/logic/threshold_logic.dart` — pure helpers: `crossedThreshold` (first observation or upward crossing), `buildPushCards` (worst window per enabled threshold, dismissed-aware), notification texts, reset keys.
- `lib/features/usage/providers/usage_provider.dart` — limit data for the Usage screen (polling + live countdown).
- `lib/features/usage/providers/limit_monitor.dart` — `LimitMonitor` watched at the app root; keeps `usageProvider` alive while the app runs (background limit checks even when the Usage screen is not visible), sends OS notifications once per threshold per window.
- `lib/features/usage/providers/push_cards_provider.dart` — `PushCardsController` recomputes live push cards from usage data + settings; `dismiss(id)` persists the dismissal.
- `lib/features/usage/services/usage_api_service.dart` — `UsageApiService` calls the real OpenCode Go usage endpoint (`https://opencode.ai/zen/go/v1/usage`) with a bearer key and parses windows (rolling/weekly/monthly); `usageApiServiceProvider` is overridden in `main()`.
- `lib/features/usage/utils/duration_format.dart` — formats live countdown durations.
- `lib/features/settings/settings_screen.dart` — mockup-style rows: appearance (theme/accent), update settings (check/auto/interval), notifications (preview + thresholds), autostart («Старт вместе с системой» + «Тихий старт», wired through `SettingsNotifier`), access, data reset.
- `lib/features/access_key/access_key_screen.dart` — API key input with show/hide and validation.
- `lib/features/about/about_screen.dart` — app info, dynamic update card, and links.

## Known Gaps

- `UsageApiService` and `opencode_auth.dart` are verified end to end on Windows (`test/e2e/usage_api_e2e_test.dart`, real windows fetched). `parseAuthToken()` supports the nested per-provider `auth.json` format (`opencode-go.key` preferred, legacy flat fields as fallback).
- `opencode_auth.dart` discovery on Linux/macOS is unit-tested for path candidates but not manually verified on those OSes.
- Quiet start tray behaviour is compiled and unit-covered (`resolveTrayIconPath` resolved from the exe dir with cwd fallbacks), but running the actual tray across platforms is not yet manually verified. On Windows the tray icon path must be absolute (relative paths break when the CWD is `System32`, e.g. Start-menu/autostart launches).
- Update release asset names must follow the convention `GoMeter-<version>-<platform>-<arch>.<ext>` for `update_service.dart` to pick the correct file.
- Local notifications are implemented via `flutter_local_notifications` (Windows/Linux/macOS/Android/iOS), but only verified on Windows so far; Linux DBus delivery and packaged-proof toasts on Windows (AUMID requires a Start Menu shortcut) still need manual checks.
- Background checks run while the app process is alive (desktop tray/quiet start keeps it alive). Guaranteed background delivery on iOS/Android needs BGTask/WorkManager and is out of scope.

## Roadmap

1. Confirm `opencode_auth.dart` key discovery on Linux/macOS (Windows done).
2. ~~Add background limit checking and local notifications~~ (done: `LimitMonitor`, `NotificationHistory`, live push cards; verify delivery on Linux/macOS/Android/iOS hardware).
