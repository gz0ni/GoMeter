# Rules

## Code Style

`analysis_options.yaml` includes `package:flutter_lints/flutter.yaml` with default rules. No custom lints are active yet.

Conventions used in the current codebase:

- Prefer `const` constructors and `final` locals.
- Use trailing commas in multi-line argument lists.
- Keep `child:` as the last named parameter when applicable.
- Do not add comments unless explicitly requested.
- No `print()` calls in committed code.

## Languages

- User-facing UI text: Russian.
- Dart identifiers, file names, commit messages, and documentation: English.

## Design

- The design basis is `docs/gometer-mockup-md3/`. Refer to it for every UI change.
- Use Material Design 3 components. Load the `material-3` skill when implementing or auditing MD3 surfaces, components, themes, or layouts.
- Do not invent new visual systems for one screen; reuse existing patterns in `lib/`.

## State and Persistence

- App settings and the API key flag are persisted through `SettingsRepository` (`lib/core/settings/settings_repository.dart`) using `SharedPreferences`.
- Do not introduce additional persistence mechanisms without a clear reason.
- Use Riverpod providers in `lib/core/theme/theme_provider.dart` for reactive settings state.

## Testing

- Maintain the smoke test in `test/widget_test.dart`.
- Add focused tests when behavior changes:
  - Repository tests: save/load round-trips.
  - Notifier tests: `SettingsNotifier` state transitions.
  - Widget tests: rendering states, taps, navigation.
- Mock `SharedPreferences` in tests with `SharedPreferences.setMockInitialValues({})`.

## Generated and External Files

- Do not edit the HTML mockups in `docs/`. They are the design basis, not generated output.
- `build/`, `.dart_tool/`, `.idea/`, `*.iml`, and `.codegraph/` are ignored.

## Git

- Do not commit, push, create PRs, or run destructive git operations without explicit user request.
- Before any commit (if requested), check `git status`, `git diff`, and `git log --oneline -10`; stage only intended files.
