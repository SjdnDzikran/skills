---
name: setup-zsh
description: Use when setting up zsh with oh-my-zsh on a VPS, including syntax highlighting, auto-suggestions, and custom shell configuration
---

# Setup Zsh with Oh My Zsh

## Overview

Configure zsh with oh-my-zsh, syntax highlighting, auto-suggestions, and custom settings for an enhanced terminal experience on a VPS.

## When to Use

- Setting up a new VPS
- Wanting a better terminal experience with syntax highlighting and auto-suggestions
- Switching from bash to zsh

## Quick Reference

| Component | Source | Feature |
|-----------|--------|---------|
| Oh My Zsh | ohmyzsh/ohmyzsh | Framework and themes |
| zsh-syntax-highlighting | zsh-users | Real-time syntax highlighting |
| zsh-autosuggestions | zsh-users | Gray auto-suggestions from history |
| af-magic theme | Built-in | Colorful prompt with git status |

## Implementation

See [implementation.md](implementation.md) for full step-by-step instructions.

## Prerequisites

- Zsh installed (`apt install zsh` / `yum install zsh` / `dnf install zsh`)
- Git installed
- Internet connection

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Can't use `chsh` (requires password) | Add auto-start to `.bashrc` instead (see implementation) |
| Plugins not loading | Verify plugin directories exist in `~/.oh-my-zsh/custom/plugins/` |
| Lost `.zshrc` config | Always backup first: `cp ~/.zshrc ~/.zshrc.backup` |
