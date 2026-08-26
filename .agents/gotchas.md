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

### OpenCode auth.json is nested per-provider, key is not a top-level field (2026-08-26)

- What happened: `importOpencodeAuth()` returned null on a machine where `~/.local/share/opencode/auth.json` existed and contained a valid API key.
- Root cause: real `auth.json` is `{"opencode-go": {"type": ..., "key": "sk-..."}, ...}` — the key lives under a provider entry, not as top-level `token`/`access_token` as the old parser assumed.
- How to avoid: `parseAuthToken()` prefers `opencode-go` → `zen` → `opencode` → any provider's `key` (legacy flat fields still supported). Any change to auth discovery must keep `test/opencode_auth_test.dart` green.

<!-- New entries go here, newest first. -->
