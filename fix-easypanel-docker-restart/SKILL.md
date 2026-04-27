---
name: fix-easypanel-docker-restart
description: Use when EasyPanel Docker container loses SSH keys or mise binary after restart, causing deployment failures like "Git key not found" or "failed to run mise command"
---

# Fix EasyPanel Docker Restart Persistence

## Overview

EasyPanel runs in Docker with an ephemeral filesystem. On restart, SSH keys (needed for git access) and the `mise` binary (needed by Railpack) are lost. This skill sets up persistent backups and automatic restoration via a systemd service.

## When to Use

- Deployment fails with "Git key not found"
- Deployment fails with "failed to run mise command"
- After Docker restart, EasyPanel can't pull from private repos
- Setting up a new VPS with EasyPanel

## Quick Reference

| Step | What | Where |
|------|------|-------|
| 1. Backup | SSH keys + mise binary | `/etc/easypanel/` |
| 2. Restore script | Automates restoration | `/etc/easypanel/restore-config.sh` |
| 3. Systemd service | Runs restore on Docker start | `/etc/systemd/system/easypanel-restore.service` |
| 4. Verify | SSH + mise work after restart | Manual test |

## Implementation

See [implementation.md](implementation.md) for full step-by-step instructions.

## Why This Happens

EasyPanel's Docker container uses `/tmp` (ephemeral). On restart:
- `/home/dzikran/.ssh/` is wiped (SSH keys lost)
- `/tmp/railpack/mise/` is wiped (mise binary lost)

The systemd service restores both from `/etc/easypanel/` backups after Docker starts.

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Forgetting `chmod +x` on restore script | Service will fail to execute |
| Wrong mise version path | Match the version Railpack expects (check logs) |
| Not updating backup after rotating SSH keys | Re-run backup step after key rotation |
| Service runs before Docker is ready | `After=docker.service` and `Requires=docker.service` handle this |
| Using `~` or `/root/` for SSH paths in container | EasyPanel container home is `/home/dzikran`, not `/root`. Always use explicit `/home/dzikran/.ssh/` paths — `docker cp` to `/root/.ssh/` silently copies to wrong location |
