---
name: faegentic
description: Use when the user invokes `faegentic` for a new Unreal Engine feature and wants it planned, implemented through Luna subagents, committed by subfeature, and prepared for review.
---

# faegentic

This skill manages the Unreal Engine feature development workflow.

Usage:

`faegentic on`  
`faegentic off`  
`faegentic on tutor off docs on`

Defaults:

- `tutor on`
- `docs on`

When `faegentic on` is used, both are considered enabled by default.

## Workflow

1. Inspect `AGENTS.md`, the Git state, the Unreal project structure, and the relevant existing code.

2. Present a short plan covering the feature goal, scope, dependencies, risks, and subtasks. If the architectural requirements do not exceed Luna's scope, proceed with implementation without waiting for additional approval.

3. Break the work into small subtasks with clear acceptance criteria.

For each subtask, use:

`model: "gpt-6-luna"`  
`reasoning_effort: "max"`

The main agent prepares a subplan before starting each subagent.

The subplan must include:

- goal
- implementation steps
- file ownership
- dependencies
- acceptance criteria
- commit scope

Only run independent tasks in parallel. Do not allow subagents to modify the same files concurrently.

4. A subtask may exceed Luna's scope if it cannot be defined as a small, independent task, requires a central architectural decision, or requires coordinated interface changes across multiple interconnected Unreal systems.

In that case, stop implementation, explain the reason, and ask the user to choose a larger model or reasoning level.

If Luna is unavailable, do not silently switch to another model.

5. Review and integrate subagent results in the main checkout.

Commit each completed subfeature separately.

Commit format:

`feature. <main feature> - [<model> <reasoning>] - [<subfeature> - <work completed>]`

Example:

`feature. door interaction - [luna max] - [E open/close interaction - door interaction added]`

The main agent creates the commits.

6. After all work is complete, review the final diff and report the validation that was actually performed.

Do not present incomplete work as complete.

## Implementation

Follow Unreal Engine coding standards and the existing project architecture.

Avoid unnecessary abstractions, refactors, or speculative APIs intended only for possible future use.

C++ owns reusable systems, state integrity, validation, low-level logic, and replication rules when applicable.

Blueprint owns gameplay orchestration, sequencing, system connections, animation, sound, VFX, and designer-driven behavior.

C++ should expose a minimal Blueprint-ready API.

Expose only:

- gameplay actions
- read-only queries
- meaningful events/delegates
- designer-tunable properties

Do not expose internal implementation details to Blueprint.

If the project already has test infrastructure and the feature can be meaningfully tested automatically, add appropriate tests.

If automated testing is not appropriate, do not create unnecessary test infrastructure. Instead, specify the required Unreal Editor or PIE validation steps.

Add code comments only when the intent or Unreal-specific behavior is not clear from the code itself.

## Tutor

If `tutor on`, create a `learn.md` file inside the feature documentation folder.

Document the three most important C++ or Unreal concepts that can be learned from the feature.

Only include concepts directly related to the feature.

If `tutor off`, do not create tutorial output or `learn.md`.

## Documentation

If `docs on`, use the project's `Docs` directory. Create it if it does not exist.

For each feature, create:

`Docs/<feature>-<date-time>/`

Add only the documentation that is useful for that feature.

Preferred structure:

- `README.md` → feature summary and architectural flow
- `api.md` → important C++ and Blueprint API
- `learn.md` → only when `tutor on`
- `decisions.md` → important architectural decisions, when applicable

Do not document every small subtask or temporary implementation detail.

Do not duplicate Git history in the documentation.

If `docs off`, do not create or update feature documentation.

## General Rules

After `faegentic off`, return to the normal agent workflow.

Explicit user instructions take priority over this default workflow.

Demo pressure or a request for speed alone does not remove the planning or review steps.

When the feature is complete, briefly summarize the completed work, commits, validation performed, and any remaining Blueprint or Unreal Editor steps for the user.