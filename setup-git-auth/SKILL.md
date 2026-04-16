---
name: setup-git-auth
description: Use when setting up SSH key authentication for git on a VPS, including for system users and EasyPanel Docker containers, or when troubleshooting "Permission denied (publickey)" errors
---

# Setup Git Authentication with SSH Keys

## Overview

Set up SSH keys for git authentication to access private repositories on GitHub, GitLab, or Bitbucket. Supports both system users and EasyPanel Docker containers.

## When to Use

- Setting up a new VPS user that needs git access
- Configuring git inside an EasyPanel Docker container
- Troubleshooting "Permission denied (publickey)" errors
- Setting up a new VPS

## Quick Reference

| Scenario | Key Generation | Key Location |
|----------|---------------|--------------|
| System user | `ssh-keygen` as the user | `/home/user/.ssh/` |
| Root | `ssh-keygen` as root | `/root/.ssh/` |
| EasyPanel | `docker exec` into container | Container's `/root/.ssh/` |

## Implementation

See [implementation.md](implementation.md) for full step-by-step instructions.

## Why Each User Needs Their Own SSH Key

1. **File isolation**: Each user has their own `~/.ssh/` directory
2. **Permissions**: SSH requires strict permissions (600 on private keys)
3. **Authentication context**: `git clone` uses the current user's SSH keys
4. **Security**: Each user/service has its own identity for audit and access control
5. **Docker isolation**: Containers are isolated from host users, need their own keys

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| "Permission denied (publickey)" | Verify key is added to git provider and permissions are 600 |
| "Host key verification failed" | Run `ssh-keyscan github.com >> ~/.ssh/known_hosts` |
| EasyPanel can't access repo | Keys must be generated inside the container, not copied from host |
| Using wrong key | Each user/service needs its own key pair |
