# Agent Configuration Model

Use the smallest durable surface that matches the job.

## Surfaces

- `AGENTS.md`: auto-loaded repository entry point. Keep it small and reserve it for always-on rules, routing, and high-priority expectations.
- `.agents/*.md`: human- and agent-readable reference docs linked from `AGENTS.md`. Use these for detailed project context, commands, architecture, and conventions.
- `.agents/skills/*/SKILL.md`: repo-scoped skills discoverable by `name` and `description`; full instructions load only when a task matches.
- Global user-level skills live outside the repo (for example `~/.config/opencode/skills/`) and are loaded automatically by the agent; repo copies should not duplicate them unless a portable copy is intentional.
- `opencode.json` (repo root): opencode MCP configuration (e.g. `codegraph`). No permission rules are defined in this repo.

There is no `.codex/` directory in this repository. Do not add Codex-specific config, rules, or hooks; enforcement lives in `analysis_options.yaml`, tests, and CI.

## Placement Rules

- Put stable team conventions in `AGENTS.md` only when every task must see them without opening another file.
- Put detailed explanations in `.agents/*.md` and link them from `AGENTS.md`.
- Put reusable task workflows in `.agents/skills/<skill-name>/SKILL.md`.
- Put mechanical enforcement in linters, tests, or CI; do not rely on prose when tooling can enforce the rule.
- Keep user-specific preferences out of the repository. They belong in user-level configuration or user-level skills.

## Skill Authoring Rules

- Use lowercase hyphenated names.
- Start descriptions with `Use when...`.
- Describe trigger conditions in the description, not the workflow.
- Keep `SKILL.md` lean; link to `.agents/*.md` for large reference material.
- Add scripts only when deterministic behavior is needed repeatedly.
