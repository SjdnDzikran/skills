---
name: ship-it
description: Use when the user wants to create, update, or merge a GitHub pull request — triggers include "ship it", "create a PR", "make a PR", "merge my PR", "merge this branch", or after completing feature work that should ship.
---

# Ship It

## Overview

End-to-end PR workflow: verify there is something to ship, generate a conventional-commit title and structured description, create or update the PR, merge with squash, and clean up. You generate all PR content yourself from the actual diff — technically specific, never generic.

**Announce at start:** "I'm using the ship-it skill to create and manage this PR."

## When to Use

- User says "ship it", "create a PR", "make a PR", "merge my PR", "merge this branch"
- Feature work is complete and should be shipped

## The Process

Use the `gh` CLI; exact commands are your choice except where a strategy is specified.

### 1. Verify there is something to ship

Source = current branch, target = repo default branch. Two hard gates before anything else:

- **Non-empty diff** against the target. If none, stop and tell the user.
- **No duplicate PR.** Check for an existing open PR on the same branches. If one exists, ask whether to update it, merge it, or skip.

### 2. Gather context

Read the full diff and the commit log between the branches. All PR content comes from these — no guessing.

### 3. Link issues automatically

List open GitHub issues and link the ones semantically related to the diff (code areas touched, bug fixed). Do not ask the user to pick. If none relate, link none.

### 4. Generate title and description

**Title:** Conventional Commits — `type(scope): subject`, where type is one of `feat`, `fix`, `refactor`, `chore`, `style`, `ci`, `docs`. Subject in imperative mood, short. Scope optional.

**Description:** Start with 2-3 summary bullets. Then group changes under only the relevant headings:

- `### New Feature`
- `### Refactoring & Architectural Changes`
- `### Bug Fixes`
- `### Performance Improvements`
- `### Maintenance & Chores`

Each bullet: **Bold title:** detailed explanation naming actual files, functions, and patterns from the diff. Reference issues in a nested bullet as `Fixes #N` or `Closes #N`.

**Hard rule:** each issue number appears exactly once in the entire description — merge related changes into one bullet. No introductory sentences.

Show the generated title and description to the user, then proceed.

### 5. Create or update the PR

Create the PR targeting the right branches, assign the current user, and apply labels carried over from the linked issues. If updating an existing PR, edit its title/body/assignee/labels instead of creating a new one. Show the user the PR URL.

### 6. Merge and clean up

Merge with squash. Use auto-merge if the repo supports it (`gh pr merge --squash --auto`); if unsupported, retry without `--auto`.

After running the merge command, check the PR state:

- **MERGED:** sync the target branch locally (`git pull --ff-only`) and delete the feature branch, local and remote.
- **OPEN** (auto-merge queued on pending checks): stop. Tell the user the PR is queued and they can ask for cleanup once checks pass.

Only delete branches after confirming the merge. If a step fails, hand the user the exact commands to finish manually.

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Creating a PR with no diff | Verify the diff first — hard gate |
| Duplicate PRs | Check for existing open PRs first |
| Repeating issue numbers | Each issue appears exactly once |
| Asking user to pick issues | Auto-link by semantic match |
| Generic descriptions | Name actual files, functions, patterns |
| Deleting branches before confirmed merge | Verify `MERGED` state first |

## Red Flags

Never create a PR with no diff. Never delete branches before confirming merge success. Never ask about merge strategy or cleanup — squash and cleanup are automatic.
