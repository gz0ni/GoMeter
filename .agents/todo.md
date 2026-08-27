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
- [ ] **v0.2.2 release prep**:
  - [x] Restore `env.json` to `{"APP_ENV":"pre"}` (local setup.dart run polluted it to `stable`)
  - [x] `pubspec.yaml`: version → `0.2.2+4`; `flutter_launcher_icons`: add `adaptive_icon_background` + `adaptive_icon_foreground` (`assets/images/png/icon-1024.png`) for Android adaptive icon → `dart run flutter_launcher_icons`
  - [x] Fix broken icon paths in `linux/packaging/deb/make_config.yaml` and `linux/packaging/rpm/make_config.yaml`: `icon: ./assets/images/icon.png` (deleted) → `./assets/images/png/icon-512.png` — otherwise Linux CI build fails
  - [x] Verified: `flutter analyze`, `flutter test` (77 tests), `flutter build windows`
  - [ ] Commit + `git push origin main` + `git tag v0.2.2` + `git push origin v0.2.2` → CI build (android/windows/linux/macos) + GitHub Release. TRACK THE WORKFLOW RUN and report status/release URL. BUILD LOCALLY ONLY WITH EXPLICIT USER REQUEST — builds go through GitHub Actions, not local `setup.dart`.
- [ ] **Auto accent (Material You dynamic color)**: `AccentSeed.auto` currently maps to hardcoded `Colors.deepPurple` — not the wallpaper/accent-driven dynamic color users expect (like Google apps / LocalSend).
  - [ ] Add `dynamic_color: ^2.1.0` (material.io, verified — supports Android S+ wallpaper, Linux XDG portal/GTK, macOS app accent, Windows accent color; iOS falls back to seed)
  - [ ] `lib/app.dart`: wrap `MaterialApp` in `DynamicColorBuilder`; pass light/dark dynamic schemes into the theme
  - [ ] `lib/core/theme/app_theme.dart` `buildTheme`: when `seed == AccentSeed.auto` and a dynamic scheme is available → use it; keep current fallback otherwise
  - [ ] Harmonize custom `AppExtraColors` warn/palette colors with the dynamic scheme (`harmonized()` / `harmonizeWith`) and/or normalize into the M3 color roles
  - [ ] Settings UI: `ColorDot` for auto already exists — verify label/behavior; maybe show the resolved accent color dot
  - [ ] Compiled/verified: `flutter analyze`, `flutter test`, manual check on Android (wallpaper change re-themes app)
- [ ] **Full Material 3 audit** (base = m3.material.io, pure M3 wins over `docs/gometer-mockup-md3/`):
  - [ ] Load repo skills `material-3` + `ui-work`; inventory every screen/widget against M3:
    - Typography → M3 type scale (`TextTheme` roles: headlineSmall, titleLarge, bodyMedium, labelLarge...) instead of hardcoded fontSize/weight
    - Shape → M3 corner tokens: cards 12 (and 28 only for large/extra-large), no ad-hoc 28/22/10
    - Components: replace pill bottom nav with M3 `NavigationBar` (mobile), desktop rail → M3 `NavigationRail` or `NavigationDrawer`; cards → M3 `Card` variants; text fields → M3 `TextField`/filled; chips/progress/dialogs per spec (LinearProgressIndicator 4dp, AlertDialog 28)
    - Colors → M3 roles only (primary/secondary/tertiary/error + container/fixed variants, surface tones); remove `AppExtraColors` warn hack by mapping amber level to M3 roles (e.g. tertiary/warning is not a token — decide error vs tertiary) 
    - Accent palette (5 seeds + auto) → keep, but rebuild via `ColorScheme.fromSeed` + dynamic color; `ColorDot` styling per M3
  - [ ] Update `docs/gometer-mockup-md3/` separately AFTER the app (mockup is design history; app is source of truth now)
  - [ ] Regression: `flutter analyze`, `flutter test`, `flutter build windows` + screenshot pass on mobile/desktop, light/dark
- [ ] Add `Requires: libayatana-appindicator3-0.1` to `linux/packaging/rpm/make_config.yaml` — deb got the runtime dep, rpm did not (found 2026-08-27, see bugs.md/gotchas.md).
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
