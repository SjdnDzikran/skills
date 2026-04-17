---
name: ship-it
description: Use when the user wants to create, update, or merge a GitHub pull request with an AI-generated title and description based on code diffs and linked issues.
---

# Ship It

## Overview

End-to-end PR workflow: analyze diffs, link GitHub issues, generate a conventional-commit PR title and structured description, create or update the PR with labels and assignee, and optionally merge with branch cleanup. The agent itself generates all PR content — no external AI API calls.

**Announce at start:** "I'm using the ship-it skill to create and manage this PR."

## When to Use

- User says "create a PR", "make a PR", "ship it", "ship-it"
- User says "merge my PR" or "merge this branch"
- User asks to update an existing PR with new description
- After completing feature work and wanting to ship it

## The Process

### Step 1: Detect Branches and Existing PRs

```
current_branch = git rev-parse --abbrev-ref HEAD
default_branch = git remote show origin | awk '/HEAD branch/ {print $NF}'
```

Ask user to confirm source and target branches (default to current and default).

Check for existing open PRs:
```bash
gh pr list --state open --head "$from_branch" --base "$to_branch" --json number,url -L 1
```

If an existing PR is found, ask the user:
1. **Update** the existing PR (re-generate title/description)
2. **Merge** the existing PR (skip to Step 6)
3. **Skip** (create a new PR or cancel)

### Step 2: Fetch the Diff

```bash
git fetch origin "$to_branch" --quiet
git diff "origin/$to_branch...$from_branch"
```

If no diff, tell the user there's nothing to PR and stop.

Also read commit messages between the branches for additional context:
```bash
git log "origin/$to_branch..$from_branch" --oneline
```

### Step 3: Fetch and Select Related Issues

```bash
gh issue list --state open --limit 50 --json number,title,labels
```

Present the list to the user and ask which issues are related to this PR. Collect:
- Issue numbers and titles (for PR description)
- Labels from selected issues (to apply to PR)

### Step 4: Generate PR Title and Description

Analyze the diff, commit messages, and linked issues to produce:

#### Title Format

Follow Conventional Commits: `type(scope): subject`

| Type | When to use |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `refactor` | Code restructuring without behavior change |
| `chore` | Maintenance, dependencies, config |
| `style` | Formatting, whitespace |
| `ci` | CI/CD changes |
| `docs` | Documentation only |

`scope` is optional (e.g., `api`, `ui`, `auth`). `subject` is imperative mood, short.

#### Description Format

Start with a brief summary (2-3 bullet points). Then group changes under these H3 headings — only include sections with relevant changes:

- `### New Feature`
- `### Refactoring & Architectural Changes`
- `### Bug Fixes`
- `### Performance Improvements`
- `### Maintenance & Chores`

Under each heading:
- Primary bullet: **Bold title:** detailed explanation of the change and its impact.
- Nested bullet for issue reference: `Fixes #N` or `Closes #N`

**Rules:**
- Each issue number appears **once** only in the entire description. Merge related changes into one bullet.
- No introductory sentences — start directly with the summary or first heading.
- Be technically specific: mention files, functions, patterns changed.

### Step 5: Create or Update the PR

```bash
gh api user --jq '.login'  # get assignee
```

Build the PR command:
```bash
gh pr create \
  --base "$to_branch" \
  --head "$from_branch" \
  --title "$pr_title" \
  --body "$pr_body" \
  --assignee "$assignee" \
  --label "label1" --label "label2"  # from linked issues
```

If updating an existing PR:
```bash
gh pr edit "$pr_number" --title "$pr_title" --body "$pr_body" --assignee "$assignee" --label "label1"
```

Show the user the PR URL when done.

### Step 6: Merge and Cleanup

After creating/updating the PR, immediately merge using squash:

```bash
gh pr merge "$pr_number" --squash --auto
```

Use `--auto` so if checks are pending, it queues auto-merge. If `--auto` is not supported (repo settings), retry without it.

#### Post-Merge Cleanup

After successful merge, immediately clean up:

1. Sync base branch:
```bash
git switch "$to_branch"
git pull --ff-only
```

2. Delete branches:
```bash
git branch -D "$from_branch"
git push origin --delete "$from_branch"
```

If branch deletion fails, tell the user to handle it manually with the exact commands.

Skip sync and deletion if merge was queued via auto-merge (checks still pending).

## Quick Reference

```
Step 1: Detect branches + check existing PRs
Step 2: Fetch diff + commit log
Step 3: Select related GitHub issues
Step 4: Agent generates conventional-commit PR title + structured description
Step 5: Create or update PR (with assignee + labels from issues)
Step 6: Auto merge (squash) + branch cleanup
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Skipping diff check | Always verify there's a diff before proceeding |
| Not checking existing PRs | Check first to avoid duplicate PRs |
| Repeating issue numbers | Each issue appears exactly once in description |
| Generic PR descriptions | Use actual file names, function names, patterns from the diff |
| Force-deleting unmerged branches | Only delete after confirmed merge |
| Merging without --auto fallback | Always try --auto first, fallback to direct merge |

## Red Flags

**Never:**
- Create a PR with no diff
- Delete branches before confirming merge success
- Ask for merge strategy or cleanup confirmation (always auto)

**Always:**
- Verify diff exists before creating PR
- Show the generated title/description to user before creating
- Apply labels from linked issues
- Auto-merge with squash after PR creation
- Auto-cleanup branches after confirmed merge
