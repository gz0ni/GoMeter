# GoMeter

Agent entry point for the GoMeter repository. Keep this file small; detailed context lives in `.agents/*.md` and repo-scoped skills live in `.agents/skills/*/SKILL.md`.

Communication with the user is in Russian. Code, commits, and documentation are in English.

## Start Here

Read these files before making changes:

- [.agents/project.md](.agents/project.md): project overview, platforms, versions, dependencies, design basis.
- [.agents/commands.md](.agents/commands.md): pub get, analyze, test, run, and build commands.
- [.agents/rules.md](.agents/rules.md): coding, testing, and workflow conventions.

Read these only when the task touches their area:

- [.agents/architecture.md](.agents/architecture.md): lib structure, state management, routing, shell, features, known gaps vs mockup.
- [.agents/agent-config.md](.agents/agent-config.md): surface placement rules, skill authoring rules, and configuration boundaries.
- [.agents/skills.md](.agents/skills.md): index of repo-scoped skills.
- [.agents/models.md](.agents/models.md): OpenCode Go model catalog and routing for this project.

## Model Routing

- Classify each task against the routing table in `.agents/models.md`.
- If the current session model does not fit the task class, propose the switch in one line, e.g. `Switch to /models -> opencode-go/glm-5.3 for this refactor.`
- Delegate codebase exploration to the `explore` subagent and code review to the `code-reviewer` subagent instead of doing them with the main model.
- Never burn top-tier models (glm-5.3, kimi-k3, qwen Max) on routine work.

## Highest Priority Rules

- NEVER run `flutter build` or `dart setup.dart` locally without an explicit user request. Builds and packaging go through GitHub Actions (triggered by `v*` tags, see `.github/workflows/build.yaml` and `.agents/commands.md`). Verification on the local machine is limited to `flutter analyze` + `flutter test`; request a tag push if a built artifact is needed.
- Verify with `flutter analyze` and `flutter test` before claiming work is complete.
- The design basis is `docs/gometer-mockup-md3/`. Match it for UI work; call the `material-3` skill for MD3 components, themes, and audits.
- UI text is in Russian; code identifiers, commits, and docs are in English.
- Do not add comments unless requested.
- Do not commit, push, or create PRs without explicit user request.
- Keep changes minimal and follow existing patterns.

## Repo Skills

Use repo skills from `.agents/skills/` when a task matches their descriptions. See [.agents/skills.md](.agents/skills.md).
