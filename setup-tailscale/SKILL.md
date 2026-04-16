---
name: setup-tailscale
description: Use when setting up Tailscale on a VPS for secure private networking, configuring firewall rules to only expose HTTP/HTTPS publicly, enabling Tailscale SSH, or troubleshooting Tailscale connectivity issues
---

# Setup Tailscale on VPS

## Overview

Install Tailscale natively (not in Docker) on a VPS for secure, private access. Only HTTP/HTTPS ports (80/443) are publicly accessible. All other services (SSH, EasyPanel, Beszel) are only accessible through Tailscale VPN.

## When to Use

- Setting up a new VPS with Tailscale
- Configuring firewall rules to block public SSH and only allow Tailscale access
- Enabling Tailscale SSH or subnet routing
- Troubleshooting Tailscale connectivity issues
- Updating Tailscale binaries

## Architecture

```
Public Internet (0.0.0.0/0)
    |--- HTTP (80)   --> Traefik --> Web Apps
    +--- HTTPS (443) --> Traefik --> Web Apps

Tailscale VPN (100.64.0.0/10)
    |--- SSH (22)           --> Tailscale SSH enabled
    +--- EasyPanel (3000)   --> Deployment dashboard
    +--- Beszel (8090)      --> Monitoring hub
    +--- All other services --> Private access only
```

## Quick Reference

| Port | Protocol | Public | Tailscale | Service |
|------|----------|--------|-----------|---------|
| 80   | TCP      | Allowed | Allowed | HTTP |
| 443  | TCP      | Allowed | Allowed | HTTPS |
| 22   | TCP      | Blocked | Allowed | SSH (Tailscale) |
| 3000 | TCP      | Blocked | Allowed | EasyPanel |
| 8090 | TCP      | Blocked | Allowed | Beszel |

## Implementation

See [installation.md](installation.md) for full setup instructions.
See [firewall.md](firewall.md) for firewall rules reference.
See [troubleshooting.md](troubleshooting.md) for common issues.

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Running Tailscale in Docker | Native installation gives proper kernel WireGuard, SSH, and subnet badges |
| Public SSH still accessible | Verify firewall reject rule on port 22 |
| No SSH/Subnet badges in dashboard | Re-authenticate with `--ssh --accept-routes=true` |
| Can't access services via Tailscale | Check `tailscale status`, `ip addr show tailscale0`, and firewall rules |
