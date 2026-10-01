---
name: faegentic-x
description: Orchestrates Unreal Engine feature work across two model families. The current agent (Claude Opus or GPT-Sol) plans, the opposite family implements through a headless CLI bridge, the orchestrator's family reviews, and each subfeature is committed. Use only when the user invokes `faegentic-x` (or misspellings like `faegenctic-x`, `faegentix`).
---

# faegentic-x

You are the **orchestrator**: you plan, decide architecture, build, and commit. Writers implement; reviewers check.

## Commands

```
faegentic-x on <feature>                 cross mode (default)
faegentic-x on <feature> claude          family lock: Claude writes and reviews
faegentic-x on <feature> gpt             family lock: GPT writes and reviews
faegentic-x on <feature> tutor off docs on effort high
faegentic-x off                          return to the normal workflow
```

If the last word is `claude` or `gpt`, it is a family lock, not part of the feature name.

| Option | Default | Meaning |
| --- | --- | --- |
| `tutor` | `on` | Create `learn.md` |
| `docs` | `on` | Create feature docs |
| `writer` | opposite family | Force writer family (`gpt` or `claude`). Ignored under a family lock |
| `effort` | per tier | Force writer reasoning effort for every subtask |
| `parallel` | `off` | Parallel writers in separate worktrees |

## Who writes and who reviews

Your family: `claude` if you are Claude, `gpt` if you are a GPT model in Codex.

| Mode | Writer | Reviewer |
| --- | --- | --- |
| Default | Opposite family, bridge | Own family, native |
| `writer` = own family | Own family, native | Opposite family, bridge |
| Lock = own family | Own family, native | Own family, native |
| Lock = opposite family | Opposite family, bridge | Opposite family, bridge |

Outside a lock, the writer and reviewer of one subtask are never the same family.

**Bridge**: `pwsh -NoProfile -File <skill-dir>/scripts/cross.ps1 -To <family> -Role write|fix|review -Brief <file> -Dir <repo-or-worktree> -Model <tier-model> -Effort <tier-effort>`. Always pass model and effort from the tier tables. It prepends the role preamble and `references/unreal-rules.md` itself. Output lands next to the brief as `<role>-<n>.md` and `<role>-<n>.log`.

- Claude Code: run it with `run_in_background: true`; runs can exceed 10 minutes.
- Codex: set the shell timeout to at least 1800 seconds.

**Native**: a fresh-context subagent.

- Claude: `Agent` tool, `subagent_type: "general-purpose"`, `model: "sonnet"`, or `"opus"` where the tier table says Opus.
- GPT: Codex subagent, model and `reasoning_effort` from the tier table.
- Writer prompt: `references/writer-preamble.md` + `references/unreal-rules.md` + the brief.
- Reviewer prompt: `references/reviewer-preamble.md` + `references/unreal-rules.md` + the review input.

## Subtask tiers

While planning, assign every subtask one tier. The tier picks the writer model, effort, and reviewer.

| Tier | Use for |
| --- | --- |
| `small` | Narrow, fully specified parts: boilerplate, getters, config, data types, Blueprint exposure, tests |
| `core` | Main C++ or Blueprint-facing logic, multi-file work |
| `risky` | Replication, threading, GC/UPROPERTY lifetime, save/load, state machines, changes to existing core systems |

| Tier | `gpt` writer | `claude` writer | `gpt` reviewer | `claude` reviewer |
| --- | --- | --- | --- | --- |
| `small` | `gpt-6-luna` `max` | `claude-sonnet-5-5` `medium` | `gpt-6.1-sol` `medium` | `claude-sonnet-5-5` `high` |
| `core` | `gpt-6.1-sol` `medium` | `claude-sonnet-5-5` `high` | `gpt-6.1-sol` `medium` | `claude-sonnet-5-5` `high` |
| `risky` | `gpt-6.1-sol` `high` | `claude-sonnet-5-5` `high` | `gpt-6.1-sol` `high` | `claude-opus-5-5` `high` |

The `effort` option, when given, overrides the writer's tier effort.

**Escalation**: if a subtask still gets `CHANGES` after its first fix round, run the second fix round with the next tier's writer (`small` → `core`, `core` → `risky`). Record the escalation in the commit and in `crossreview.md`.

## Preflight

Run once per feature, before planning:

1. If any role uses the bridge, confirm the opposite CLI responds: `codex --version` or `claude --version`. If it is missing, logged out, or out of quota, stop and tell the user.
2. Confirm the working tree is clean, or that the user accepts the existing changes.
3. Add `.faegentic/` to `.git/info/exclude` if missing. Do not edit `.gitignore`.

## Workflow

Copy this checklist and track it per subtask:

```
- [ ] Brief written
- [ ] Writer run
- [ ] Ownership checked
- [ ] Review PASS (fix rounds: 0/2)
- [ ] Build + tests run
- [ ] Committed
```

1. Read `AGENTS.md` / `CLAUDE.md`, Git state, the Unreal project structure, and relevant code.
2. Present a short plan: goal, scope, dependencies, risks, subtasks. Per subtask, one line: tier, writer model + effort, reviewer model, and why. The user may override any line. Continue without approval unless a central architectural decision is open; then ask the user.
3. Make all architectural decisions yourself before delegating.
4. **Brief.** Write `.faegentic/<feature>/<NN>-<subtask>/brief.md` from `references/brief-template.md`. Fill every section; file ownership lists exact paths.
5. **Write.** Run the writer (bridge or native, per the table).
6. **Ownership.** Run `git status --porcelain` in the writer's directory. Revert any file outside the ownership list and record it in the review input.
7. **Review.** Fill `references/review-template.md` with the brief, the writer report, and `git diff` of the subtask. Run the reviewer. Save its reply as `review-<n>.md`.
8. **Fix.** On `CHANGES`, copy the findings into `fix-<n>.md` and run the writer with `-Role fix` on the same directory, then review again. After 2 fix rounds, stop and show the user the open findings.
9. **Verify.** Build the affected module (UBT or editor build) and run existing automation tests that cover the change. Record what actually ran.
10. **Commit** the subfeature yourself:

    `feature. <main feature> - [<writer-model> <effort> / review <reviewer-model>] - [<subfeature> - <work completed>]`

    Example: `feature. door interaction - [gpt-6.1-sol medium / review claude-sonnet-5-5] - [E open/close interaction - door interaction added]`

    Under a lock both models come from the same family: `[claude-sonnet-5-5 high / review claude-sonnet-5-5]`.

11. After all subtasks, review the full feature diff yourself.

## Parallel writers

Only with `parallel on`:

- Run in parallel only subtasks with disjoint file ownership and no interface dependency.
- One worktree per writer: `git worktree add .faegentic/wt/<NN> -b fx/<feature>/<NN>`.
- Review per subtask, apply each worktree diff to the main checkout, then remove the worktree.

## Docs and tutor

`docs on`: write to `Docs/<feature>-<date-time>/` (create `Docs/` if missing). Only files that carry information:

- `README.md`: summary and architectural flow
- `api.md`: important C++ and Blueprint API
- `learn.md`: only with `tutor on`; the three most important C++/Unreal concepts actually used in this feature
- `decisions.md`: architectural decisions, when there are any
- `crossreview.md`: per subtask, tier, writer model, reviewer model, fix rounds, escalations, findings that changed the code
- `blueprint.md`: see Blueprint guide

Do not duplicate Git history. `.faegentic/` is scratch, not documentation. `docs off`: create no docs except `blueprint.md`. `tutor off`: no `learn.md`.

## Blueprint guide

Always create `blueprint.md`, even with `docs off`. With `docs off`, create `Docs/<feature>-<date-time>/blueprint.md` and nothing else there.

It is the user's Editor checklist for the Blueprint side, followable without reading the C++ code. Numbered steps, only those this feature needs:

1. Blueprint assets to create or open: content path, parent class
2. Components to add and property values to set (exact names, suggested values)
3. Node wiring per event, in order: which event, which C++ function or delegate, what connects where
4. Animation, sound, and VFX hookups
5. PIE validation: what to do and the expected result

Use the exact Blueprint-visible names from the C++ code. If no Blueprint work is needed, write that in one line.

## Rules

- Explicit user instructions override this workflow.
- Speed or demo pressure does not remove planning, cross review, or verification.
- Never switch the writer or reviewer model silently. If a model is unavailable, stop and ask.
- Do not present incomplete work as complete.
- At the end, report: completed work, commits, fix rounds per subtask, validation actually run, and the path to `blueprint.md` with its first step.
