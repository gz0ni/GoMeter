# Gotchas

Traps and pitfalls the agent has stepped on in this project. Log a gotcha immediately whenever something does not build, run, or pass — right after the incident, while context is fresh, do not wait for session end. Check this file before repeating similar work. One entry per trap.

## Format

```
### <Short trap title> (YYYY-MM-DD)

- What happened / what was wrong
- Root cause
- How to avoid next time
```

---

### Kotlin daemon "Could not close incremental caches" on Windows (2026-08-25)

- What happened: `flutter build apk --debug` failed with `Storage for [..].tab is already registered` / `Could not close incremental caches` even after killing daemons and deleting `build/`.
- Root cause: flaky Kotlin incremental-cache handling in the Kotlin daemon on Windows when several Kotlin modules compile in one build.
- Workaround: added `kotlin.compiler.execution.strategy=in-process` + `kotlin.incremental=false` to android/gradle.properties. Rebuilds are reliable; no cache conflict.

### Flutter tests render text with the Ahem font (2026-08-25)

- What happened: widget tests fail with "RenderFlex overflowed" in rows that fit fine on a real device (BrandLogo in the AppBar, metric row in LimitCard, import button).
- Root cause: in tests every glyph is a 1em square (Ahem), so Cyrillic strings are ~2x wider than in Roboto.
- How to avoid: make such rows overflow-tolerant (Flexible/Expanded + ellipsis), not just in tests — this also covers big system font scales on devices.

### adb screencap via PowerShell redirect (2026-08-25)

- What happened: `adb exec-out screencap -p > file.png` through PowerShell produced a corrupt PNG.
- Root cause: PowerShell `>` re-encodes binary output.
- How to avoid: capture via `cmd /c "adb exec-out screencap -p > out.png"` or a file-stream redirect.

---

### Release tag silently points to a stale commit (2026-08-27)

- What happened: after pushing the fix commit to `main`, `git push origin v0.2.0` did not produce a CI run on the fix — the run executed the OLD code and failed the same tests again (`head_sha=8d66979` while `main=54c4a8b`).
- Root cause: the local tag `v0.2.0` still pointed at the previous SHA; the push did not move it, so GitHub received the same (stale) tag object.
- How to avoid: before any release re-build, move the tag to HEAD locally: `git tag -d v0.2.0 && git tag v0.2.0` (without -f!), delete the remote tag, then push. Verify after push: `git ls-remote origin refs/tags/v0.2.0` must equal the new main SHA.

### GitHub Actions startup_failure / run stuck in queued (2026-08-26)

- What happened: the first v0.2.0 run died instantly with `startup_failure` ("unexpected error", not a workflow-file problem); the re-created run stayed `queued` for 17+ hours with zero jobs.
- Root cause: GitHub Actions incident (Major Outage, githubstatus.com) — workflow file itself was identical to the last green run (verified via blob SHA).
- How to avoid: check https://www.githubstatus.com first; `startup_failure` runs cannot be rerun — fix is delete+recreate the tag, which starts a fresh run; stash a stale queued run and wait until the incident resolves.

### Platform-dependent tests fail on CI runners (2026-08-27)

- What happened: `UpdateService.pickAsset` test "prefers dedicated setup asset on windows" passed locally on Windows but failed on the ubuntu CI runner (`Expected gometer-windows-amd64-setup.exe, Actual gometer-linux-amd64.deb`).
- Root cause: `pickAsset` derived the platform from `Platform.isWindows` (`version_utils.dart`), so the assertion depended on the host OS, not the test intent.
- How to avoid: parametrize platform-dependent logic (`pickAsset(release, {String? platform, String? arch})` — host defaults, explicit overrides) and write tests with an explicit platform. Never assert host-dependent output in tests.

### e2e tests against real API must skip on CI (2026-08-27)

- What happened: `test/e2e/usage_api_e2e_test.dart` promised "Skips when no key is available" but the skip was never wired; on CI it failed at `expect(key, isNotNull)`.
- Root cause: key exists only locally (env `GOMETER_API_KEY` or `~/.local/share/opencode/auth.json`); the test was green on the author's machine and red in CI.
- How to avoid: resolve the key before `test()` in `main()` and pass `skip: key == null ? 'reason' : false`; never assert on the key inside the body.

### Linux build needs libayatana-appindicator3 (2026-08-27)

- What happened: `dart setup.dart linux` failed in CI with CMake error from `tray_manager`: "requires ayatana-appindicator3-0.1 or appindicator3-0.1".
- Root cause: the new `tray_manager` dependency (v0.2.0) has a native Linux requirement (`libayatana-appindicator3-dev` at build time, `libayatana-appindicator3-0.1` at runtime).
- How to avoid: `get_dependencies` are already handled in `setup.dart` `_ensureLinuxDependencies` (pkgGroups has `libayatana-appindicator3-dev`) and `linux/packaging/deb/make_config.yaml` lists the runtime dep. NOTE: `linux/packaging/rpm/make_config.yaml` has NO Requires — add `libayatana-appindicator3-0.1` there the next time RPM is touched.

### Android build needs core library desugaring (2026-08-27)

- What happened: CI Android build failed at `:app:checkReleaseAarMetadata` — "Dependency ':flutter_local_notifications' requires core library desugaring to be enabled for :app."
- Root cause: `flutter_local_notifications` (v0.2.0 feature) requires Java 8+ APIs beyond Android's default; the AGP flag was not enabled.
- How to avoid: `android/app/build.gradle.kts` has `isCoreLibraryDesugaringEnabled = true` + `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")` — re-verify the desugar_jdk_libs version when bumping the plugin.

### OpenCode auth.json is nested per-provider, key is not a top-level field (2026-08-26)

- What happened: `importOpencodeAuth()` returned null on a machine where `~/.local/share/opencode/auth.json` existed and contained a valid API key.
- Root cause: real `auth.json` is `{"opencode-go": {"type": ..., "key": "sk-..."}, ...}` — the key lives under a provider entry, not as top-level `token`/`access_token` as the old parser assumed.
- How to avoid: `parseAuthToken()` prefers `opencode-go` → `zen` → `opencode` → any provider's `key` (legacy flat fields still supported). Any change to auth discovery must keep `test/opencode_auth_test.dart` green.

<!-- New entries go here, newest first. -->
