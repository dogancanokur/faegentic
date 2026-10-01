---
name: faegentic-x
description: Use when the user invokes `faegentic-x` for an Unreal Engine feature and wants it planned by the current agent (Claude Opus or GPT-Sol), implemented by the opposite model family through a headless CLI bridge, reviewed by the orchestrator's own family, committed by subfeature, and prepared for review.
---

# faegentic-x

Cross-model Unreal Engine feature workflow. The agent that loads this skill is the **orchestrator**. Every subtask is written by one model family and reviewed by the other.

Usage:

`faegentic-x on <feature>` → cross mode (default)
`faegentic-x on <feature> claude` → full Claude: Claude writes and reviews
`faegentic-x on <feature> gpt` → full GPT: GPT writes and reviews
`faegentic-x off`
`faegentic-x on <feature> tutor off docs on effort high`

Also accept common misspellings of the trigger (`faegenctic-x`, `faegentix`).

## Family lock

If the last word of the request is `claude` or `gpt`, it is a family lock, not part of the feature name. Under a lock:

- Writer and reviewer are both the locked family. The cross rule below does not apply.
- If the locked family is your own family, use native subagents for both roles; do not call `cross.ps1` and skip the cross CLI preflight check. Give the native writer `references/writer-preamble.md` + the brief, and the native reviewer `references/reviewer-preamble.md` + the review input.
- If the locked family is the opposite family, use `cross.ps1 -Role write|fix|review` for both roles.
- Commit format uses the same model twice: `[claude-opus-5-5 max / review claude-opus-5-5]`.
- Ignore the `writer` option.

Options and defaults:

| Option | Default | Meaning |
| --- | --- | --- |
| `tutor` | `on` | Create `learn.md` |
| `docs` | `on` | Create feature docs |
| `writer` | opposite family | Force writer family: `gpt` or `claude` |
| `effort` | `max` | Writer reasoning effort |
| `parallel` | `off` | Allow parallel writers in separate worktrees |

## Roles

Identify your own family first. If you are Claude, your family is `claude`. If you are a GPT model running in Codex, your family is `gpt`.

| Role | Who | How |
| --- | --- | --- |
| Orchestrator | You | Plans, writes briefs, decides architecture, integrates, builds, commits |
| Writer | Opposite family | `scripts/cross.ps1 -To <family> -Role write` |
| Reviewer | Your family | Native subagent with fresh context |

Models:

| Family | Writer model | Reviewer model |
| --- | --- | --- |
| `gpt` | `gpt-6.1-sol` | `gpt-6.1-sol` |
| `claude` | `claude-opus-5-5` | `claude-opus-5-5` |

Reviewer invocation:

- Claude orchestrator: `Agent` tool, `subagent_type: "general-purpose"`, `model: "opus"`.
- GPT orchestrator: Codex subagent, `model: "gpt-6.1-sol"`, `reasoning_effort: "max"`.

Outside a family lock, the writer and reviewer of one subtask must never be the same family. If the `writer` option forces your own family, the reviewer becomes the opposite family through `cross.ps1 -Role review`.

## Preflight

Run once per feature, before planning:

1. Confirm the cross CLI responds: `codex --version` or `claude --version`.
2. Confirm the working tree is clean or that the user accepts the existing changes.
3. Add `.faegentic/` to `.git/info/exclude` if missing. Do not edit the project's `.gitignore` for this.

If the cross CLI is missing, not logged in, or out of quota, stop and tell the user. Do not silently fall back to your own family.

## Workflow

1. Inspect `AGENTS.md` / `CLAUDE.md`, Git state, Unreal project structure, and relevant code.

2. Present a short plan: feature goal, scope, dependencies, risks, subtasks. Proceed without further approval unless a central architectural decision is open.

3. Make central architectural decisions yourself before delegating. Writers implement; they do not decide architecture. If you cannot decide with confidence, ask the user.

4. For each subtask, write a brief to `.faegentic/<feature>/<NN>-<subtask>/brief.md` using `references/brief-template.md`. The brief must include:
   - goal
   - implementation steps
   - file ownership (exact paths the writer may touch)
   - interfaces it must match (signatures, delegates, UPROPERTY names)
   - acceptance criteria
   - commit scope

5. **Write.** Run the writer:

   ```
   pwsh -NoProfile -File <skill-dir>/scripts/cross.ps1 -To <opposite> -Role write -Brief <brief.md> -Dir <repo-or-worktree> -Effort <effort>
   ```

   - Claude Code: run it with `run_in_background: true`; writer runs can exceed 10 minutes.
   - Codex: give the shell call a timeout of at least 1800 seconds.
   - Output lands next to the brief: `write-1.md` (writer report) and `write-1.log`.

6. **Check ownership.** Run `git status --porcelain` in the writer's directory. If any file outside the brief's ownership list changed, revert those files and record it in the review input.

7. **Review.** Start the reviewer with `references/review-template.md`, filled with: the brief, `git diff` of the subtask, and the writer report. The reviewer returns `PASS` or `CHANGES` with numbered findings (file, line, cause, fix). Save it as `review-<n>.md`.

8. **Fix loop.** On `CHANGES`, write the findings into `fix-<n>.md` and run `cross.ps1 -Role fix -Brief <fix-n.md>` against the same directory, then review again. Maximum 2 fix rounds. After that, stop and show the user the open findings.

9. **Verify.** You build and test, not the writer. Compile the affected module (UBT or editor build) and run existing automation tests that cover the change. Record what actually ran.

10. **Commit** each completed subfeature yourself:

    `feature. <main feature> - [<writer-model> <effort> / review <reviewer-model>] - [<subfeature> - <work completed>]`

    Example:

    `feature. door interaction - [gpt-6.1-sol max / review claude-opus-5-5] - [E open/close interaction - door interaction added]`

11. After all subtasks, review the full feature diff yourself and report validation actually performed. Do not present incomplete work as complete.

## Parallel writers

Default is sequential. With `parallel on`:

- Only run subtasks with disjoint file ownership and no interface dependency.
- Give each writer its own worktree: `git worktree add .faegentic/wt/<NN> -b fx/<feature>/<NN>`.
- Integrate by applying each worktree diff into the main checkout, review per subtask, then remove the worktree.
- Never let two writers touch the same file.

## Implementation rules (passed to writers through the brief)

Follow Unreal Engine coding standards and the existing project architecture.

Avoid unnecessary abstractions, refactors, or speculative APIs.

C++ owns reusable systems, state integrity, validation, low-level logic, and replication rules when applicable.

Blueprint owns gameplay orchestration, sequencing, system connections, animation, sound, VFX, and designer-driven behavior.

C++ exposes a minimal Blueprint-ready API. Expose only:

- gameplay actions
- read-only queries
- meaningful events/delegates
- designer-tunable properties

Do not expose internal implementation details to Blueprint.

If the project has test infrastructure and the feature can be tested automatically, add tests. Otherwise, do not create test infrastructure; list the Unreal Editor or PIE validation steps instead.

Add comments only when intent or Unreal-specific behavior is not clear from the code.

## Tutor

If `tutor on`, create `learn.md` in the feature docs folder with the three most important C++ or Unreal concepts from this feature. Only concepts directly used in the feature. If `tutor off`, create no tutorial output.

## Documentation

If `docs on`, use the project's `Docs` directory (create it if missing). Per feature: `Docs/<feature>-<date-time>/` with only useful files:

- `README.md` → summary and architectural flow
- `api.md` → important C++ and Blueprint API
- `learn.md` → only when `tutor on`
- `decisions.md` → architectural decisions, when applicable
- `crossreview.md` → per subtask: writer model, reviewer model, number of fix rounds, findings that changed the code

Do not document every subtask or temporary detail. Do not duplicate Git history. `.faegentic/` run files are scratch and are not documentation.

If `docs off`, do not create or update feature docs.

## General Rules

After `faegentic-x off`, return to the normal agent workflow.

Explicit user instructions take priority over this workflow.

Demo pressure or a request for speed does not remove planning, cross review, or verification.

Never switch writer or reviewer model silently. If a model is unavailable, stop and ask.

When the feature is complete, summarize: completed work, commits, fix rounds per subtask, validation performed, remaining Blueprint or Unreal Editor steps.
