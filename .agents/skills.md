# Agent Skills

Repo-scoped skills live under `.agents/skills/*/SKILL.md` and are discoverable by skill `name` and `description`; the full instructions load only when a task matches.

## Available Repo Skills

- `material-3`: Google's Material Design 3 system — tokens, components, adaptive layouts, theming, dynamic color, accessibility. Supports Jetpack Compose (primary), Flutter, and limited web. Use when implementing or auditing MD3 surfaces, components, themes, or layouts. Argument: `[component|theme|layout|scaffold|audit] [description or URL]`.
- `ui-work`: Flutter UI work inside this repository. Use when changing screens, widgets, navigation surfaces, or mockup-driven styling.
- `provider-tests`: Riverpod provider and notifier tests. Use when writing or updating tests for `SettingsNotifier`, feature providers, or future state-management code.

Global skills such as `ui-ux-pro-max` and `agent-browser` are not duplicated here; use them from the agent's global skill catalog when needed.

## Authoring Notes

- Add new repeatable workflows as `.agents/skills/<skill-name>/SKILL.md`.
- Keep skill descriptions trigger-focused and start them with `Use when...`.
- Keep long reference material in `.agents/*.md`; skills should link to it instead of duplicating it.
- Do not add tool/agent-specific configuration (e.g. `.codex/`) — this repo does not use it.
