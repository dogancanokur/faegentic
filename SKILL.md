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
| `effort` | `max` | Writer reasoning effort |
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

**Bridge**: `pwsh -NoProfile -File <skill-dir>/scripts/cross.ps1 -To <family> -Role write|fix|review -Brief <file> -Dir <repo-or-worktree> -Effort <effort>`. It prepends the role preamble and `references/unreal-rules.md` itself. Output lands next to the brief as `<role>-<n>.md` and `<role>-<n>.log`.

- Claude Code: run it with `run_in_background: true`; runs can exceed 10 minutes.
- Codex: set the shell timeout to at least 1800 seconds.

**Native**: a fresh-context subagent.

- Claude: `Agent` tool, `subagent_type: "general-purpose"`, `model: "opus"`.
- GPT: Codex subagent, `model: "gpt-6.1-sol"`, `reasoning_effort: "max"`.
- Writer prompt: `references/writer-preamble.md` + `references/unreal-rules.md` + the brief.
- Reviewer prompt: `references/reviewer-preamble.md` + `references/unreal-rules.md` + the review input.

Models: `gpt` → `gpt-6.1-sol`, `claude` → `claude-opus-5-5`.

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
2. Present a short plan: goal, scope, dependencies, risks, subtasks. Continue without approval unless a central architectural decision is open; then ask the user.
3. Make all architectural decisions yourself before delegating.
4. **Brief.** Write `.faegentic/<feature>/<NN>-<subtask>/brief.md` from `references/brief-template.md`. Fill every section; file ownership lists exact paths.
5. **Write.** Run the writer (bridge or native, per the table).
6. **Ownership.** Run `git status --porcelain` in the writer's directory. Revert any file outside the ownership list and record it in the review input.
7. **Review.** Fill `references/review-template.md` with the brief, the writer report, and `git diff` of the subtask. Run the reviewer. Save its reply as `review-<n>.md`.
8. **Fix.** On `CHANGES`, copy the findings into `fix-<n>.md` and run the writer with `-Role fix` on the same directory, then review again. After 2 fix rounds, stop and show the user the open findings.
9. **Verify.** Build the affected module (UBT or editor build) and run existing automation tests that cover the change. Record what actually ran.
10. **Commit** the subfeature yourself:

    `feature. <main feature> - [<writer-model> <effort> / review <reviewer-model>] - [<subfeature> - <work completed>]`

    Example: `feature. door interaction - [gpt-6.1-sol max / review claude-opus-5-5] - [E open/close interaction - door interaction added]`

    Under a lock both models are the same: `[claude-opus-5-5 max / review claude-opus-5-5]`.

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
- `crossreview.md`: per subtask, writer model, reviewer model, fix rounds, findings that changed the code

Do not duplicate Git history. `.faegentic/` is scratch, not documentation. `docs off`: create no docs. `tutor off`: no `learn.md`.

## Rules

- Explicit user instructions override this workflow.
- Speed or demo pressure does not remove planning, cross review, or verification.
- Never switch the writer or reviewer model silently. If a model is unavailable, stop and ask.
- Do not present incomplete work as complete.
- At the end, report: completed work, commits, fix rounds per subtask, validation actually run, remaining Blueprint or Editor steps.
