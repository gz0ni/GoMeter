# Model Catalog and Routing

Model selection guide for the OpenCode Go subscription (provider `opencode-go`). Active as of Aug 2026.
Limits: $12/5h, $30/week, $60/month. Request counts are approximate and task-dependent.

The agent cannot switch the main session model itself; it proposes a switch (user picks via `/models`).
Automatic model routing happens for subagents (`explore` on `deepseek-v4-flash`, `code-reviewer` on `glm-5.3`) via the global `~/.config/opencode/opencode.jsonc`.

## Top tier (complex tasks, expensive against limits)

| Model | Approx. req/5h | Use when |
|---|---|---|
| `glm-5.3` / `glm-5.2` | 220-880 | Deep code edits, refactoring, planning. Best open-weight coder. |
| `kimi-k3` | 110 | Complex agentic work, long autonomous multi-step runs. |
| `qwen3.8-max` / `qwen3.7-max` | 160-340 | Heavy tasks, very long context. |
| `grok-4.5` | 120 | Coding and general tasks. |
| `gpt-5.6-luna` | 2050 | Cheap GPT-class reasoning. |

## Optimum price/quality (recommended workhorses)

| Model | Approx. req/5h | Use when |
|---|---|---|
| `kimi-k2.7-code` | 1350 | **Default coding model.** Dedicated coder, best balance for Dart/Flutter. |
| `deepseek-v4-pro` | 1050 | General text coding alternative to k2.7-code. |
| `mimo-v2.5-pro` | 3250 | Unified coding + vision (Sonnet-class). UI debugging from screenshots. |
| `qwen3.7-plus` | 4300 | Vision for UI debugging, stable. |
| `minimax-m3` | 3200 | Vision (photos/videos/screenshots). |

## Budget (routine, bulk operations)

| Model | Approx. req/5h | Use when |
|---|---|---|
| `deepseek-v4-flash` | 7600 | Simple edits, tests, reading files, autonomous subagents, titles/summaries. |
| `mimo-v2.5` | 30000 | Cheapest, omnimodal (photo/audio/video). Reading docs and images. |
| `minimax-m2.7` | 3400 | Budget routine. |
| `glm-5.1` / `kimi-k2.6` | 880-1150 | Previous generation, cheap tasks. |

## Routing for GoMeter

Project profile: Flutter (Dart) UI only; no native platform code yet.

| Task class | Model to propose |
|---|---|
| Main Flutter coding | `opencode-go/kimi-k2.7-code` (session default) |
| Complex refactoring, architecture, planning | `opencode-go/glm-5.3` |
| Long autonomous multi-step agentic work | `opencode-go/kimi-k3` or `opencode-go/qwen3.8-max` |
| UI debugging from screenshots / vision | `opencode-go/mimo-v2.5-pro` or `opencode-go/qwen3.7-plus` |
| Code review | `opencode-go/glm-5.3` (via `code-reviewer` subagent) |
| Codebase exploration / research | `opencode-go/deepseek-v4-flash` (via `explore` subagent) |
| Tests, simple edits, reading files, generation | `opencode-go/deepseek-v4-flash` |
| Reading docs / images cheaply | `opencode-go/mimo-v2.5` |

## Workflow

1. Classify the incoming task against the routing table.
2. If the current session model does not fit the task class, propose the switch in one line, e.g. `Switch to /models -> opencode-go/glm-5.3 for this refactor.`
3. Delegate work that maps to a configured subagent automatically (`explore`, `code-reviewer`) instead of doing it with the main model.
4. Never burn top-tier models (glm-5.3, kimi-k3, qwen Max) on routine work; keep them for complex tasks.
