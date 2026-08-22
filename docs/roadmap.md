# GoMeter Roadmap

## Phase 1 — UI matching mockup (`docs/gometer-mockup-md3/`)

### 1.1 Theme + shared MD3 widgets
- Add warn/amber color tokens to `lib/core/theme/app_theme.dart` (green/amber/red levels from mockup).
- Create `lib/core/widgets/`:
  - `status_chip.dart` — ok/warn/danger chip with dot.
  - `status_pill.dart` — level pill used inside limit cards.
  - `filter_chip.dart` — custom-styled selectable chip.
  - `color_dot.dart` — 48px accent selector with ring.
  - `filled_text_field.dart` — filled input with bottom accent line.
  - `limit_card.dart` — usage limit card with level colors.
  - `update_banner.dart` — dismissible update banner.
  - `brand_logo.dart` — 40px brand icon + name + subtitle.

### 1.2 Adaptive shell
- Mobile: floating pill bottom navigation with 3 tabs (Использование, Уведомления, Настройки).
- Desktop: NavigationRail with 5 items + collapse/expand toggle, toolbar with brand + summary chip, wide card grid layout.
- Key and About: stacked routes with back button on mobile; rail items on desktop.

### 1.3 Usage screen
- Dynamic status chip based on worst card level.
- Live countdown timer ("Сброс через X дн HH:MM"), tick every second.
- Refresh animation + mock drift.
- Update banner wired to Phase 2 updater.

### 1.4 Remaining screens
- Onboarding, Access Key, Settings, Notifications, About aligned to mockup: tonal buttons, text links, platform chips, notification preview with timestamp.

## Phase 2 — In-app updates

### Deps
- `dio`, `package_info_plus`, `path_provider`, `url_launcher`.

### Code
- `lib/core/update/version_utils.dart` — `compareVersions` (from B.O.L.T).
- `lib/core/update/release_info.dart` — release model + body parser.
- `lib/core/update/update_service.dart` — GitHub API `releases/latest`, asset selection, download with progress.
- `lib/core/update/update_controller.dart` — Riverpod state (idle/available/downloading/ready/error).
- `lib/core/update/installer.dart` — platform installers:
  - Windows: `setup.exe /VERYSILENT /SUPPRESSMSGBOXES /NORESTART`.
  - macOS: mount dmg, copy `.app` to `/Applications` via `osascript`.
  - Linux: `pkexec dpkg -i <deb>` with `xdg-open` fallback.
  - Android: `ACTION_VIEW` + `FileProvider`.

### UI
- Update banner on Usage.
- Update card in About.
- Download progress dialog.
- Auto-check setting + "do not remind".

## Phase 3 — Packaging

### 3.1 `setup.dart` (adapted from B.O.L.T)
- Targets: Windows (`exe` + `zip`), Linux (`deb` + `rpm` + `tar.gz`), macOS (`dmg`), Android (split ABI: `arm64-v8a`, `armeabi-v7a`, `x86_64`, `x86`).
- `env.json` with `APP_ENV`.
- Dependency checks: `appdmg`, `rpm`/`patchelf`, activate `chen08209/flutter_distributor` fork.

### 3.2 Packaging configs
- `windows/packaging/exe/{make_config.yaml,inno_setup.iss}`
- `linux/packaging/{deb,rpm}/make_config.yaml`
- `macos/packaging/dmg/make_config.yaml`
- `distribute_options.yaml`

### 3.3 Placeholder icon
- Generate 1024 PNG + ICO + platform icon sets from mockup "speed" logo.
- Use `flutter_launcher_icons` for Android/iOS.

### 3.4 Android signing
- Generate keystore with `keytool`.
- Update `build.gradle.kts` release signing config.
- CI secrets (KEYSTORE_BASE64, KEY_ALIAS, STORE_PASSWORD, KEY_PASSWORD).

## Phase 4 — CI

- `.github/workflows/build.yaml`:
  - Test job: `flutter analyze --no-fatal-infos` + `flutter test`.
  - Build matrix: android, windows amd64, linux amd64/arm64, macos intel/arm64.
  - Release job: SHA256SUMS + `softprops/action-gh-release`.
- Skip Telegram, Homebrew, F-Droid.

## Phase 5 — Docs

- Update `.agents/commands.md`, `.agents/architecture.md`, `.agents/project.md` with new commands and architecture.

## Verification

- `flutter analyze` + `flutter test`.
- Local `dart setup.dart linux` (deb + tar.gz) and `dart setup.dart android --arch arm64`.
- CI validated by pushing a tag on user request.
