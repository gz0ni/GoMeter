# Bugs

Known bugs found in this project and how they were fixed, so they do not reappear. Logged at the end of every session. Status: `open` / `fixed` / `won't fix`.

## Format

```
### <Short bug title> (YYYY-MM-DD) — status

- Symptom
- Root cause
- Fix applied
- How to prevent recurrence
```

---

### UpdateService.pickAsset picked wrong platform in CI (2026-08-27) — fixed

- Symptom: `test/update_service_test.dart` failed on ubuntu runner: expected `gometer-windows-amd64-setup.exe`, got `gometer-linux-amd64.deb`. Locally (Windows) it passed.
- Root cause: `pickAsset` used host `Platform` (`currentPlatform`/`currentArch`), so the test asserted host-dependent output; in CI the host was Linux.
- Fix: `pickAsset(release, {String? platform, String? arch})` with host defaults and explicit test overrides; tests now cover windows/linux/macos explicitly (windows test still passes on any host).
- How to prevent recurrence: keep platform logic out of test assertions; parametrize the seam (platform/arch args) and test it with explicit values.

### e2e usage test failed on CI despite "skips without key" comment (2026-08-27) — fixed

- Symptom: `test/e2e/usage_api_e2e_test.dart` failed in CI at `expect(key, isNotNull)` — no key in env or auth.json on the runner.
- Root cause: the skip was documented in a comment but not implemented; the test body required a real key.
- Fix: resolve the key once in `async main()` before `test(...)` and pass `skip: key == null ? '...' : false`.
- How to prevent recurrence: every test that needs external credentials must declare `skip:` conditionally; CI has no auth.json and no GOMETER_API_KEY secret.

### Linux release build failed on missing ayatana-appindicator (2026-08-27) — fixed

- Symptom: `dart setup.dart linux` failed: CMake in `flutter/ephemeral/.plugin_symlinks/tray_manager/linux` — "tray_manager package requires ayatana-appindicator3-0.1 or appindicator3-0.1".
- Root cause: tray_manager added in v0.2.0 needs the native appindicator library; setup.dart's Linux dependency check did not install it, and deb/rpm packages did not list the runtime dep.
- Fix: added `libayatana-appindicator3-dev` to `_ensureLinuxDependencies` in setup.dart and `libayatana-appindicator3-0.1` to deb `dependencies`. CI Linux build green after the fix.
- How to prevent recurrence: when adding a plugin with native Linux deps, update setup.dart pkgGroups AND the packaging deps in one pass; check rpm `Requires` too (not yet done).

### Android release build failed on missing core library desugaring (2026-08-27) — fixed

- Symptom: CI Android job failed at `:app:checkReleaseAarMetadata` with "Dependency ':flutter_local_notifications' requires core library desugaring to be enabled for :app."
- Root cause: flutter_local_notifications (added in v0.2.0) needs desugaring; `build.gradle.kts` had no `isCoreLibraryDesugaringEnabled`.
- Fix: `compileOptions { isCoreLibraryDesugaringEnabled = true }` + `dependencies { coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4") }` in `android/app/build.gradle.kts`.
- How to prevent recurrence: when adding plugins that ship java.time etc., enable desugaring from the start; tests on desktop won't catch it — only the Android build does.

---

### Mobile shell body collapses to 0 height after onboarding (2026-08-25) — fixed

- Symptom: on Android the pill navigation rendered, but the screen body (and AppBar) was completely blank after entering the key and finishing onboarding. Reproduced in a widget test at 390dp (`card found: 0`) and on an emulator.
- Root cause: `Align` inside `_PillNavigationBar` (app_shell.dart) had no `heightFactor`; under bounded constraints from the Scaffold's `bottomNavigationBar` slot it expands to the full available height (~828dp), so the Scaffold body is laid out with 0 height. The usage screen (AppBar + cards) was simply not visible. Desktop was unaffected (no bottom pill).
- Fix: `Align(alignment: Alignment.bottomCenter, heightFactor: 1, ...)` so the pill shrink-wraps vertically.
- How to prevent recurrence: regression tests `regression: shell body renders content on mobile` and `onboarding flow: key entry lands on usage with content` in test/mobile_screens_test.dart assert actual cards render inside the shell.

---

<!-- New entries go here, newest first. -->
