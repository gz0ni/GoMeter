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

### Mobile shell body collapses to 0 height after onboarding (2026-08-25) — fixed

- Symptom: on Android the pill navigation rendered, but the screen body (and AppBar) was completely blank after entering the key and finishing onboarding. Reproduced in a widget test at 390dp (`card found: 0`) and on an emulator.
- Root cause: `Align` inside `_PillNavigationBar` (app_shell.dart) had no `heightFactor`; under bounded constraints from the Scaffold's `bottomNavigationBar` slot it expands to the full available height (~828dp), so the Scaffold body is laid out with 0 height. The usage screen (AppBar + cards) was simply not visible. Desktop was unaffected (no bottom pill).
- Fix: `Align(alignment: Alignment.bottomCenter, heightFactor: 1, ...)` so the pill shrink-wraps vertically.
- How to prevent recurrence: regression tests `regression: shell body renders content on mobile` and `onboarding flow: key entry lands on usage with content` in test/mobile_screens_test.dart assert actual cards render inside the shell.

---

<!-- New entries go here, newest first. -->
