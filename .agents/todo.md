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
- [ ] Confirm `opencode_auth.dart` reading of the local auth.json works on all desktop platforms — Windows verified (nested per-provider format, `opencode-go.key`); Linux/macOS paths are unit-tested, hardware check pending.
- [x] Add focused provider/widget tests for settings, usage, and update flows: `settings_autostart_test.dart` (5), `usage_api_service_test.dart` (5), `update_service_test.dart` (4). Verified: 33 tests green.
- [x] Wire `usageProvider` to `UsageApiService` behind an interface and remove the remaining mock path — service is overridden via `usageApiServiceProvider` in `main()`; no mock left in `lib/` (verified by grep).
- [x] Add background limit checking and local notifications (incl. live push cards on the Usage screen): `LimitMonitor` (app-root watcher keeps polling alive), `NotificationHistory` anti-spam (once per threshold per window, re-arms on reset), live push cards per mockup, `flutter_local_notifications` on all 5 platforms. Verified: `flutter analyze`, `flutter test` (69 tests). Delivery on Linux/macOS/Android/iOS hardware and Windows packaged toasts still pending manual checks — see `architecture.md` Known Gaps.
- [x] Update `.agents/architecture.md` when API/auth layers are finalized — documented autostart/tray layers, refreshed known gaps and roadmap.

## In Progress

- [~] None.

## Done

- [x] Initial release: UI, in-app updates, packaging, CI, OpenCode Go API (v0.1.0).
- [x] v0.1.1 fixes: rail bubble, auth paths, mobile UX, release table, exe installer.
- [x] Windows/Linux/macOS packaging and CI releases on `v*` tags.
- [x] v0.2.0 UI rework per updated mockup: static desktop rail with brand, 2 mobile tabs, page-head + status-card + limit tiles on Usage, page-head screens for key/about, mockup-style Settings rows/dropdowns/phone-notif, brand logo replaces `Icons.speed` placeholders. Verified: `flutter analyze`, `flutter test` (13 tests).
