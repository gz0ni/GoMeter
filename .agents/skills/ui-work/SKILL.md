---
name: ui-work
description: Use when changing GoMeter Flutter UI, widgets, screens, navigation surfaces, Material 3 styling, or user-facing interactions.
---

# UI Work

## When To Use

Use this for user-facing Flutter UI changes in `lib/`, including widgets, screens, navigation surfaces, settings rows, dialogs, and interaction behavior.

## Workflow

1. Open `docs/gometer-mockup-md3/` and identify the screen/component being changed. The mockup is the design basis.
2. Load the `material-3` skill (`name: material-3`) for MD3 tokens, components, adaptive layouts, and audits.
3. Locate existing nearby widgets and reuse their patterns before adding new abstractions.
4. Keep `child:` last in widget constructors; prefer `const` and `final`.
5. Keep UI text in Russian; code identifiers in English.
6. Add focused widget tests when behavior changes (rendering states, taps, scrolling, empty/error states).
7. Verify:

   ```bash
   flutter analyze
   flutter test
   ```

## Pitfalls

- Do not introduce a new visual system for one screen.
- Do not ignore `docs/gometer-mockup-md3/` styling details (pills, chips, color dots, switches, progress colors) when the task is to match the mockup.
- Avoid broad layout rewrites unless the requested change requires them.
