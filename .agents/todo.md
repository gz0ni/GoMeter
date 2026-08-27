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
- [~] **Full Material 3 audit** (base = m3.material.io, pure M3 wins over `docs/gometer-mockup-md3/`):
  - [x] Load repo skills `material-3` + `ui-work`; inventory every screen/widget against M3:
    - [x] Typography → M3 type scale (`TextTheme` roles: headlineSmall, titleLarge, titleMedium, bodyMedium/large/small, labelLarge) instead of hardcoded fontSize/weight — all widgets/screens (status_card, limit_card, push_card, phone_notif, setting_row, section_title, page_head, brand_logo, dropdown_pill, about/onboarding/access_key/settings/usage screens)
    - [x] Shape → M3 corner tokens: cards 12 (28 kept only for the large StatusCard), no ad-hoc 10/17/22/9999 (chip → M3 default 8, dropdown pill → 24 full on 48dp button, progress bar 4dp)
    - [x] Components: mobile pill nav → M3 `NavigationBar`, desktop rail → M3 `NavigationDrawer`; chips → M3 defaults; `LinearProgressIndicator` 4dp; buttons M3 heights (removed 38/50 overrides); `Switch`/`AlertDialog` already M3
    - [x] Colors → M3 roles only; `AppExtraColors` warn hack removed — amber level mapped to `tertiary` (green→primary, red→error); `AppExtraColors.forScheme` + harmonize gone; app_theme_test updated (5 tests)
    - [ ] Accent palette (5 seeds + auto) → keep, but rebuild via `ColorScheme.fromSeed` + dynamic color; `ColorDot` styling per M3 — needs visual pass (see regression below)
  - [x] Update `docs/gometer-mockup-md3/` separately AFTER the app (mockup is design history; app is source of truth now): styles.css/desktop.css/desktop.html synced to current app state — M3 type roles (22/16/14/12/28px), card radii 12 (status-card 28), chip/menu/field 8, dropdown 24, buttons 40h, progress 4dp, ColorDot 56, NavigationBar (indicator pill + surface bar), NavigationDrawer rail (260px, 56px items, radius 24, brand titleMedium + sub)
  - [~] Regression: `flutter analyze` ✅, `flutter test` (82 tests) ✅, `flutter build windows` + screenshot pass on mobile/desktop, light/dark — **NOTE: NO local builds (rule in AGENTS.md) — do artifact/visual checks via GitHub Actions tag (v*) with explicit user request**
- [x] Add `requires: libayatana-appindicator-gtk3` to `linux/packaging/rpm/make_config.yaml` — deb got the runtime dep, rpm did not (found 2026-08-27, see bugs.md/gotchas.md). NOTE: RPM variant name (Fedora/RHEL/EPEL); deb/OpenSUSE name is `libayatana-appindicator3-0.1`/`libayatana-appindicator3-1`. Mapper key verified in flutter_distributor (FlClash branch) `make_rpm_config.dart`: `requires` → `Requires:` in preamble.
- [ ] Confirm `opencode_auth.dart` reading of the local auth.json works on all desktop platforms — Windows verified (nested per-provider format, `opencode-go.key`); Linux/macOS paths are unit-tested, hardware check pending.
- [x] Add focused provider/widget tests for settings, usage, and update flows: `settings_autostart_test.dart` (5), `usage_api_service_test.dart` (5), `update_service_test.dart` (4). Verified: 33 tests green.
- [x] Wire `usageProvider` to `UsageApiService` behind an interface and remove the remaining mock path — service is overridden via `usageApiServiceProvider` in `main()`; no mock left in `lib/` (verified by grep).
- [x] Add background limit checking and local notifications (incl. live push cards on the Usage screen): `LimitMonitor` (app-root watcher keeps polling alive), `NotificationHistory` anti-spam (once per threshold per window, re-arms on reset), live push cards per mockup, `flutter_local_notifications` on all 5 platforms. Verified: `flutter analyze`, `flutter test` (69 tests). Delivery on Linux/macOS/Android/iOS hardware and Windows packaged toasts still pending manual checks — see `architecture.md` Known Gaps.
- [x] Update `.agents/architecture.md` when API/auth layers are finalized — documented autostart/tray layers, refreshed known gaps and roadmap.
- [x] Fix tray/icon issues (v0.2.1 follow-up): brand logo everywhere (`flutter_launcher_icons` source → `assets/images/png/icon-1024.png`, removed `scripts/generate_icon.dart` stub + `assets/images/icon.png`, new `scripts/generate_ico.dart` builds multi-frame BMP `.ico`), absolute tray icon path (`resolveTrayIconPath` from exe dir + cwd fallbacks, unit-tested), tray context menu on right-click (`onTrayIconRightMouseDown` → `popUpContextMenu`), single-instance guard in `windows/runner/main.cpp` (named mutex + activate existing window).

## In Progress

- [~] None.

## Done

- [x] Initial release: UI, in-app updates, packaging, CI, OpenCode Go API (v0.1.0).
- [x] v0.1.1 fixes: rail bubble, auth paths, mobile UX, release table, exe installer.
- [x] Windows/Linux/macOS packaging and CI releases on `v*` tags.
- [x] v0.2.0 UI rework per updated mockup: static desktop rail with brand, 2 mobile tabs, page-head + status-card + limit tiles on Usage, page-head screens for key/about, mockup-style Settings rows/dropdowns/phone-notif, brand logo replaces `Icons.speed` placeholders. Verified: `flutter analyze`, `flutter test` (13 tests).
