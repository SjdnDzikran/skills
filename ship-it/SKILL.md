---
name: ship-it
description: Use when the user wants to create, update, or merge a GitHub pull request — triggers include "ship it", "create a PR", "make a PR", "merge my PR", "merge this branch", or after completing feature work that should ship.
---

# Ship It

All PR content comes from the actual work — technically specific, never generic.

**Announce at start:** "I'm using the ship-it skill to create and manage this PR."

Source = current branch, target = repo default branch.

## 1. Draft

The conversation is the primary source. When the work happened in this thread, write the title and description from what you already know; read the diff only to fill gaps, confirming file and issue names against `git diff <target>...HEAD`.

One-line check while drafting — surface a result only when it trips:

- No open PR on this branch yet: `gh pr list --head <branch>` returns none. One exists → adopt it: update it in place per step 3 instead of creating a duplicate.

**Link issues:** list open GitHub issues and link the ones the work fixed or touched — pick the semantic matches yourself.

## 2. Title and description

Language and audience come from the project type — derive it, zero questions:

| Project | Description language | Audience |
|---|---|---|
| Flutter or mobile app (`pubspec.yaml` present, or `react-native` in package.json) | Bahasa Indonesia | user-facing |
| Everything else | English | developer-facing |

An explicit user instruction in the conversation overrides the table.

**Title:** Conventional Commits, always English — `type(scope): subject`, type one of `feat`, `fix`, `refactor`, `chore`, `style`, `ci`, `docs`; subject imperative and short; scope optional.

**Description:** the relevant headings only, in order — `### Added`, `### Changed`, `### Fixed` — each entry one sentence naming actual files, functions, and patterns from the work, ending with its issue numbers in parentheses, e.g. `(#123, #456)`. Each issue number appears exactly once in the entire description; merge related changes into one entry. Headings and entries only — intro sentences, summary bullets, and attributions live elsewhere.

**user-facing** entries explain what changed in the app's behavior and why it matters to end users; engineering artifacts (files, functions, CI internals) belong in developer-facing entries.

Show the draft in one message and proceed in the same turn; a reply steers a correction instead of a gate. The message names the intent: with merge intent, "Creating and squash-merging now unless you object"; without it, "Creating the PR now" — the run stops at the URL from step 3.

## 3. Create

`gh pr create` against the target branch; assign the current user. **Labels:** apply the linked issues' labels; when none relate to the work, derive one from the change type (`fix` → `bug`, `feat` → `enhancement`, `docs` → `documentation`) and create it first with `gh label create "<name>"`. An existing open PR gets edited in place — title, body, assignee, labels. Report the PR URL.

## 4. Merge and clean up

**Merge gate:** merging requires explicit merge intent from the user — "ship it", "merge my PR", "merge this branch", or a direct confirmation. A PR created on the agent's own initiative, or from a plain "create a PR" request, stops at the URL from step 3: the PR sits open and ready. With merge intent:

A draft PR gets marked ready first (`gh pr ready`). Squash-merge: `gh pr merge --squash --auto`; unsupported → retry without `--auto`.

- **MERGED:** `git pull --ff-only` the target branch, then delete the feature branch locally and remotely.
- **OPEN** (auto-merge queued on checks): report the queue; the user returns for cleanup after checks pass.

Branches get deleted only with the merge confirmed. Any failure → hand over the exact commands to finish manually.
