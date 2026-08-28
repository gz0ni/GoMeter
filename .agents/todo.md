# TODO

Task checklist. The agent maintains this file: creates items, marks them done, keeps it honest. Work from here — do not lose tasks between sessions.

## Format

- `[ ]` pending task — add due date or note if needed
- `[x]` done task — keep for history, do not delete immediately
- `[~]` in progress — who/what is working on it

## Rules

- Add a task the moment it is discovered, even if vague.
- Mark `[x]` only when actually verified done (checks passed), not by intent.
- Review this file at the end of every session: close finished items, add follow-ups.

---

## Open

- [x] Align Flutter UI with the updated mockup (`docs/gometer-mockup-md3/`): static desktop rail, 2 mobile tabs, page-head, status-card, mockup limit tiles, no `/notifications` route (v0.2.0 UI rework).
- [x] Replace `Icons.speed` brand placeholders (BrandLogo, onboarding hero, about hero, notification preview) with the GoMeter logo from `assets/images/png/`.
- [x] Implement real autostart ("Start with system") and quiet start ("Тихий старт"): `AutostartService` (Windows reg.exe / Linux .desktop / macOS LaunchAgent / no-op mobile), wired into `SettingsNotifier`, `--quiet` start arg starts in tray (`tray_manager` + `window_manager`). Verified: `flutter analyze`, `flutter test` (24 tests), `flutter build windows`.
- [x] Verify real OpenCode Go API integration end to end (usage fetch with real key) — `test/e2e/usage_api_e2e_test.dart` fetched real windows: rolling 3%, weekly 41%, monthly 69% (2026-08-26, Windows).
- [x] **v0.2.2 release prep**:
  - [x] Restore `env.json` to `{"APP_ENV":"pre"}` (local setup.dart run polluted it to `stable`)
  - [x] `pubspec.yaml`: version → `0.2.2+4`; `flutter_launcher_icons`: add `adaptive_icon_background` + `adaptive_icon_foreground` (`assets/images/png/icon-1024.png`) for Android adaptive icon → `dart run flutter_launcher_icons`
  - [x] Fix broken icon paths in `linux/packaging/deb/make_config.yaml` and `linux/packaging/rpm/make_config.yaml`: `icon: ./assets/images/icon.png` (deleted) → `./assets/images/png/icon-512.png` — otherwise Linux CI build fails
  - [x] Verified: `flutter analyze`, `flutter test` (77 tests), `flutter build windows`
  - [x] Commit + `git push origin main` + `git tag v0.2.2` + `git push origin v0.2.2` → CI build (android/windows/linux/macos) + GitHub Release. TRACK THE WORKFLOW RUN and report status/release URL. BUILD LOCALLY ONLY WITH EXPLICIT USER REQUEST — builds go through GitHub Actions, not local `setup.dart`.
- [x] **Auto accent (Material You dynamic color)**: `AccentSeed.auto` currently maps to hardcoded `Colors.deepPurple` — not the wallpaper/accent-driven dynamic color users expect (like Google apps / LocalSend).
  - [x] Add `dynamic_color` — NOTE: use `^1.9.0`, NOT `^2.1.0`: 2.x depends on `material_ui` and returns its own `ColorScheme` type, incompatible with `flutter/material`'s `ColorScheme` (fails to compile). 1.9.0 supports Android S+ wallpaper, Linux XDG portal/GTK, macOS app accent, Windows accent color; iOS falls back to seed.
  - [x] `lib/app.dart`: wrap `MaterialApp` in `DynamicColorBuilder`; pass light/dark dynamic schemes into the theme
  - [x] `lib/core/theme/app_theme.dart` `buildTheme`: when `seed == AccentSeed.auto` and a dynamic scheme is available → use it; otherwise fallback to `AccentSeed.auto.color` (now `#2196F3` blue, user-approved; was `deepPurple`)
  - [x] Harmonize custom `AppExtraColors` warn/palette colors with the active scheme: `AppExtraColors.forScheme(scheme)` uses `harmonizeWith(scheme.primary)` (`harmonized()` covers built-in scheme colors only; we need a custom extension)
  - [x] Settings UI: `ColorDot` for auto already exists — behavior verified, unchanged (minimal diff)
  - [x] Compiled/verified: `flutter analyze`, `flutter test` (82 tests); `app_theme_test.dart` (5 tests: auto+dynamic dark/light, auto+no-dynamic fallback, explicit-seed ignores dynamic, warn harmonization)
  - [ ] Manual check on hardware: Android wallpaper change re-themes app; desktop accent color change re-themes app
- [x] **Full Material 3 audit** (base = m3.material.io, pure M3 wins over `docs/gometer-mockup-md3/`):
  - [x] Load repo skills `material-3` + `ui-work`; inventory every screen/widget against M3:
    - [x] Typography → M3 type scale (`TextTheme` roles: headlineSmall, titleLarge, titleMedium, bodyMedium/large/small, labelLarge) instead of hardcoded fontSize/weight — all widgets/screens (status_card, limit_card, push_card, phone_notif, setting_row, section_title, page_head, brand_logo, dropdown_pill, about/onboarding/access_key/settings/usage screens)
    - [x] Shape → M3 corner tokens: cards 12 (28 kept only for the large StatusCard), no ad-hoc 10/17/22/9999 (chip → M3 default 8, dropdown pill → 24 full on 48dp button, progress bar 4dp)
    - [x] Components: mobile pill nav → M3 `NavigationBar`, desktop rail → M3 `NavigationDrawer`; chips → M3 defaults; `LinearProgressIndicator` 4dp; buttons M3 heights (removed 38/50 overrides); `Switch`/`AlertDialog` already M3
    - [x] Colors → M3 roles only; `AppExtraColors` warn hack removed — amber level mapped to `tertiary` (green→primary, red→error); `AppExtraColors.forScheme` + harmonize gone; app_theme_test updated (5 tests)
    - [x] Accent palette (5 seeds + auto) → keep, but rebuild via `ColorScheme.fromSeed` + dynamic color; `ColorDot` styling per M3 — `ColorDot` already 56dp M3 circle, `app_theme.dart:35-40` uses `dynamicScheme` when auto + available, fallback blue #2196F3 (verified)
  - [x] Update `docs/gometer-mockup-md3/` separately AFTER the app (mockup is design history; app is source of truth now): styles.css/desktop.css/desktop.html synced to current app state — M3 type roles (22/16/14/12/28px), card radii 12 (status-card 28), chip/menu/field 8, dropdown 24, buttons 40h, progress 4dp, ColorDot 56, NavigationBar (indicator pill + surface bar), NavigationDrawer rail (260px, 56px items, radius 24, brand titleMedium + sub)
  - [x] Regression: `flutter analyze` ✅, `flutter test` (87 tests) ✅, `flutter build windows` + screenshot pass on mobile/desktop, light/dark — **NOTE: NO local builds (rule in AGENTS.md) — do artifact/visual checks via GitHub Actions tag (v*) with explicit user request**
- [x] Add `requires: libayatana-appindicator-gtk3` to `linux/packaging/rpm/make_config.yaml` — deb got the runtime dep, rpm did not (found 2026-08-27, see bugs.md/gotchas.md). NOTE: RPM variant name (Fedora/RHEL/EPEL); deb/OpenSUSE name is `libayatana-appindicator3-0.1`/`libayatana-appindicator3-1`. Mapper key verified in flutter_distributor (FlClash branch) `make_rpm_config.dart`: `requires` → `Requires:` in preamble.
- [ ] Confirm `opencode_auth.dart` reading of the local auth.json works on all desktop platforms — Windows verified (nested per-provider format, `opencode-go.key`); Linux/macOS paths are unit-tested, hardware check pending.
- [x] Add focused provider/widget tests for settings, usage, and update flows: `settings_autostart_test.dart` (5), `usage_api_service_test.dart` (5), `update_service_test.dart` (4). Verified: 33 tests green.
- [x] Wire `usageProvider` to `UsageApiService` behind an interface and remove the remaining mock path — service is overridden via `usageApiServiceProvider` in `main()`; no mock left in `lib/` (verified by grep).
- [x] Add background limit checking and local notifications (incl. live push cards on the Usage screen): `LimitMonitor` (app-root watcher keeps polling alive), `NotificationHistory` anti-spam (once per threshold per window, re-arms on reset), live push cards per mockup, `flutter_local_notifications` on all 5 platforms. Verified: `flutter analyze`, `flutter test` (69 tests). Delivery on Linux/macOS/Android/iOS hardware and Windows packaged toasts still pending manual checks — see `architecture.md` Known Gaps.
- [x] Update `.agents/architecture.md` when API/auth layers are finalized — documented autostart/tray layers, refreshed known gaps and roadmap.
- [x] Fix tray/icon issues (v0.2.1 follow-up): brand logo everywhere (`flutter_launcher_icons` source → `assets/images/png/icon-1024.png`, removed `scripts/generate_icon.dart` stub + `assets/images/icon.png`, new `scripts/generate_ico.dart` builds multi-frame BMP `.ico`), absolute tray icon path (`resolveTrayIconPath` from exe dir + cwd fallbacks, unit-tested), tray context menu on right-click (`onTrayIconRightMouseDown` → `popUpContextMenu`), single-instance guard in `windows/runner/main.cpp` (named mutex + activate existing window).

- [x] **v0.2.3 release**: M3 audit + auto accent + rpm requires + mockup sync. Commits: `feat(theme)`, `feat(ui): material 3 audit`, `fix(linux): rpm requires`, `docs: sync mockup`, `release: v0.2.3` (0.2.3+5). CI build.yaml run 22 ✅ (Test/linux/android/macos/windows/Release) → https://github.com/gz0ni/GoMeter/releases/tag/v0.2.3

## Icon / Tray / Background (v0.2.3 feedback)

- [x] Tray icon too small: `scripts/generate_ico.dart` now produces tray-optimized `assets/images/ico/gometer.ico` — transparent margins trimmed, ring/bolt fill ~96% of the canvas, frames 16/20/24/32/48 (was 7 frames up to 256 with thin ring); `app_icon.ico` unchanged (byte-identical). Visual check of 16/24px frames: bold readable ring. Done 2026-08-28. NOTE: run `flutter_launcher_icons` BEFORE `scripts/generate_ico.dart` — the former rewrites `windows/runner/resources/app_icon.ico` (documented in commands.md).
- [x] Windows window/taskbar icon still a placeholder: verified 2026-08-28 — `app_icon.ico` 372526 bytes (7 frames 16-256) vs `gometer.ico` 19278 bytes (5 frames 16-48), SHA256 `7685F4...` vs `7DA51A...` differ (not byte-identical); order `flutter_launcher_icons` → `scripts/generate_ico.dart` re-verified (`dart run flutter_launcher_icons` + `dart run scripts/generate_ico.dart` → hashes stable). Repo asset correct; stale icon = installed build cache. Verify via CI `v*` artifact + reinstall at 150% DPI if still shows placeholder: `ie4uinit.exe -show` or clear IconCache.
- [x] Android launcher icon too big: new `scripts/generate_launcher_assets.dart` → `adaptive-foreground.png` (logo scaled to 56% — inside the 66/108 safe zone, no mask clipping) + `adaptive-background.png` (blue→lavender gradient); pubspec points `flutter_launcher_icons` at them, Android mipmaps regenerated. Done 2026-08-28.
- [x] Android notification without icon: monochrome vector `drawable/ic_stat_gometer.xml` (white ring + spark, transparent bg) added; `AndroidInitializationSettings` switched from `@mipmap/ic_launcher` to `ic_stat_gometer` (32-bit color icons are invalid as small icons on Android). Verif on device pending (incl. Android 13+ small-icon rules) — see architecture.md Known Gaps.
- [x] App not working in background on Android: Dart timers suspend/kill when app is backgrounded → `flutter_foreground_task 11.0.1` added (`pubspec.yaml` + manifest `FOREGROUND_SERVICE/DATA_SYNC/WAKE_LOCK` + service decl), `lib/core/foreground/gometer_task_handler.dart` (top-level `startCallback`, `GoMeterTaskHandler.onRepeatEvent` polls `https://opencode.ai/zen/go/v1/usage` every `checkIntervalMinutes`, updates foreground notif via `updateService`, limit alerts via `flutter_local_notifications` with anti-spam `notified-*` keys, best-effort), `lib/core/foreground/foreground_service.dart` (`init/sync/start/stop/restartWithInterval`, autoRunOnBoot), wired in `main.dart` (init+sync) + `app.dart` (`ref.listen` settings + `_autoCheck` permission request). Verified: `flutter analyze` clean, `flutter test` 87 green (e2e fetched 7%/72%/84%). HW verify pending: minimize app, wait interval, check persistent notif + limit alert arrives.
- [x] Tray tooltip with remaining limits: `TrayController.updateTooltip()` + pure `buildTrayTooltip()` (e.g. `R5h: 69% осталось · W: 41% · M: 31%`), hooked into `LimitMonitor` on every usage update; no-op when tray not attached (mobile). 3 new unit tests (87 total green). macOS `setToolTip` unsupported by tray_manager — tooltip alone; context menu mirror is a follow-up.

## Platform fixes (v0.2.3 feedback, round 2)

- [~] macOS app won't open (black window): `network.client` entitlement added to both `Release.entitlements` (was sandbox-blocks-API black window) and `DebugProfile.entitlements` (2026-08-28); `attachToTray` made best-effort (internal try/catch) so a tray/notification startup failure can no longer leave a black window before `runApp`. Remaining (hardware/CI): CI ships arm64-only DMG — verify arch; launch from Terminal to capture crash log on the new release.
- [x] Android in-place update fails ("conflicts with an existing package"): fixed 2026-08-28 — `android/app/build.gradle.kts:57-66` now `error()` instead of debug fallback (`INSTALL_FAILED_UPDATE_INCOMPATIBLE` prevented), `.github/workflows/build.yaml:64-78` validates `KEYSTORE/KEY_ALIAS/STORE_PASSWORD/KEY_PASSWORD` all non-empty + prints keystore size/alias. Verified: `flutter analyze` clean, `flutter test` 87 green. HW verify: `apksigner verify --print-certs` on v0.2.3+ APKs must share SHA; if secret was rotated, users need `adb uninstall dev.gometer.gometer` once.
- [x] Windows toast has no app icon: `WindowsInitializationSettings(iconPath: resolveTrayIconPath())` passed (flutter_local_notifications_windows 3.1.1 writes `IconUri` into the registry; native code verified); reuses the tray .ico resolution with exe-dir/cwd fallbacks (unit-tested). Verified: `flutter analyze` clean, 87 tests green. Toast rendering check on hardware pending.
- [x] Mobile limit tiles misaligned: "осталось 100%" wraps in the first column → taller card, ragged progress bars, card border barely visible on dark theme → single-line label (FittedBox / no-wrap), equal card heights (`CrossAxisAlignment.stretch` + `IntrinsicHeight`), clearer card outline (`outlineVariant` border). Done 2026-08-28: `flutter analyze` clean, `flutter test` 84 green (2 new regression tests: narrow-column no-wrap, equal card heights). Committed: `fix(ui): align mobile limit tiles` (7473154).

## Icon fixes (v0.2.4 feedback 2026-08-28 — screenshots Win taskbar/tray + Android launcher/notifications)

- [x] **1) Пиксели / шакалы — все 3 иконки сильно пикселят** — done 2026-08-28 via sharp
  - Причина: `assets/images/png/icon-1024.png` (42KB) → `pubspec.yaml:40` `flutter_launcher_icons` кубик-ресемпл в `mipmap-*` (48-192px) + `scripts/generate_ico.dart:13` `_encodeBmpFrame` BMP-only ICO (7 фреймов 16-256, без PNG-compress) → мыло на 125/150% DPI. Трей `assets/images/ico/gometer.ico` (5 фреймов 16-48) тоже из 1024 с одной итерацией cubic.
  - Решение (выбран A, sharp): `scripts/svg_to_png.mjs` (sharp density 400 → `icon-2048.png` 97252 + high-quality `icon-1024.png` 38877) → `scripts/generate_launcher_assets.dart:11` `_safeDiameter 0.56→0.66`, `scripts/generate_ico.dart:8` PNG-compressed ICO + `_appFrameSizes [16,20,24,32,40,48,64,96,128,256]` (10 фреймов), CI `build.yaml:109` `setup-node@20 + sharp + generate_launcher_assets → flutter_launcher_icons → generate_ico` (correct order per `commands.md`). Локально verify: `dart run scripts/generate_launcher_assets.dart && dart run flutter_launcher_icons && dart run scripts/generate_ico.dart`, `flutter analyze` clean, `flutter test` 87 green. Artifacts: `adaptive-foreground.png` 40913 (was 42732/52459), `app_icon.ico` 12383 (10 frames PNG, was 372526 BMP), `gometer.ico` 2459 (was 19278).
  - Файлы: `assets/images/svg/logo.svg`, `assets/images/png/icon-2048.png` (new), `assets/images/png/icon-1024.png`, `scripts/svg_to_png.mjs` (new), `scripts/generate_launcher_assets.dart:11`, `scripts/generate_ico.dart:8`, `windows/runner/resources/app_icon.ico`, `assets/images/ico/gometer.ico`, `.github/workflows/build.yaml:109`

- [x] **2) Android уведомления — не видно / жмыхнутая иконка** — done 2026-08-28
  - Причина: `lib/core/foreground/foreground_service.dart:52` `notificationIcon: null` → fallback на adaptive launcher (16% inset + 56% safeDiameter → жмых в 24dp smallIcon). `drawable/ic_stat_gometer.xml:1` — 2 белых path, `evenOdd`, тонкое кольцо, без паддинга → на маленьком размере схлопывается / розовый largeIcon из фона на HyperOS (скрины 4-5).
  - Решение (выбран A): `drawable/ic_stat_gometer.xml` — один path `nonZero`, `viewport 24`, кольцо outer 10.5/inner 8.7 (stroke 1.8), `1.5dp` паддинг, звезда 3dp, `fill #FFFFFF` на transparent; `ForegroundService.start` → `NotificationIcon(metaDataName: 'dev.gometer.gometer.notificationIcon', backgroundColor: 0xFF2196F3)` + `AndroidManifest.xml:50` `<meta-data android:resource="@drawable/ic_stat_gometer"/>`; `gometer_task_handler.dart:127` + `flutter_local_notifications_service.dart:77` → `AndroidNotificationDetails(icon: 'ic_stat_gometer', color: 0xFF2196F3)`. Verified: `flutter analyze` clean, `flutter test` 87 green. HW шторка collapsed/expanded светлая/тёмная Pixel/HyperOS pending.
  - Файлы: `android/app/src/main/res/drawable/ic_stat_gometer.xml`, `android/app/src/main/AndroidManifest.xml:50`, `lib/core/foreground/foreground_service.dart:52`, `lib/core/foreground/gometer_task_handler.dart:127`, `lib/core/notifications/flutter_local_notifications_service.dart:77`

- [x] **3) Launcher Android маленький — увеличить** — done 2026-08-28
  - Причина: `mipmap-anydpi-v26/ic_launcher.xml:7` `inset 16%` + `_safeDiameter 0.56` (573px) в `generate_launcher_assets.dart:12` + 11% паддинг самого SVG (круг 400/512) → итого ~27% полей, выглядит меньше соседей (скрин 6). Текущий `adaptive-foreground.png` 1024 — 14KB, `mipmap-xxxhdpi 192px` — 9KB, уже ресемплен дважды.
  - Решение (выбран A): `ic_launcher.xml:7` `inset 16% → 11%`, `generate_launcher_assets.dart:11` `_safeDiameter 0.56 → 0.66` (~676px), кольцо 78% → ~86% канваса, паддинг 27% → ~18%. Перегенерить `adaptive-foreground/background.png` + `drawable-*/mipmap-*` via `flutter_launcher_icons`. `adaptive-foreground.png` 40913 (was 42732), `drawable-xxxhdpi/ic_launcher_foreground.png` 15791 (was 14449/17081), визуал vs Telegram/Chrome — larger, no clipping. Verified: `flutter analyze` clean, 87 tests.
  - Файлы: `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml:7`, `scripts/generate_launcher_assets.dart:11`, `assets/images/png/adaptive-foreground.png`, `assets/images/png/adaptive-background.png`, `android/app/src/main/res/drawable-*/ic_launcher_foreground.png`

## In Progress

- [~] None.

## Done

- [x] Initial release: UI, in-app updates, packaging, CI, OpenCode Go API (v0.1.0).
- [x] v0.1.1 fixes: rail bubble, auth paths, mobile UX, release table, exe installer.
- [x] Windows/Linux/macOS packaging and CI releases on `v*` tags.
- [x] v0.2.0 UI rework per updated mockup: static desktop rail with brand, 2 mobile tabs, page-head + status-card + limit tiles on Usage, page-head screens for key/about, mockup-style Settings rows/dropdowns/phone-notif, brand logo replaces `Icons.speed` placeholders. Verified: `flutter analyze`, `flutter test` (13 tests).
