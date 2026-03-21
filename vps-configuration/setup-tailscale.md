# Tailscale VPS Security Setup

## Overview

This VPS is configured to use Tailscale for secure, private access. Only HTTP/HTTPS ports (80/443) are publicly accessible for web services. All other services (SSH, EasyPanel, Beszel) are only accessible through Tailscale VPN.

## Architecture

```
Public Internet (0.0.0.0/0)
    ↓
    ├─ HTTP (80)   → Traefik → Web Apps
    └─ HTTPS (443) → Traefik → Web Apps

Tailscale VPN (100.64.0.0/10)
    ↓
    ├─ SSH (22)           → Secure shell access
    ├─ EasyPanel (3000)   → Deployment dashboard
    ├─ Beszel (8090)      → Monitoring hub
    └─ All other services → Private access only
```

## Installation

### 1. Install firewalld

```bash
dnf install -y firewalld
systemctl enable --now firewalld
```

### 2. Configure firewall

```bash
# Set default zone to public
firewall-cmd --set-default-zone=public

# Allow HTTP/HTTPS from anywhere
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=https

# Allow Tailscale network (100.64.0.0/10)
firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" source address="100.64.0.0/10" accept'

# Block sensitive ports from public
firewall-cmd --permanent --zone=public --remove-service=ssh
firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" port protocol="tcp" port="22" reject'
firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" port protocol="tcp" port="3000" reject'
firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" port protocol="tcp" port="8090" reject'

# Reload firewall
firewall-cmd --reload
```

### 3. Install Tailscale via Docker

```bash
docker run -d \
  --name tailscale \
  --restart=always \
  --network=host \
  --cap-add=NET_ADMIN \
  --cap-add=NET_RAW \
  -v /var/lib:/var/lib \
  -v /dev/net/tun:/dev/net/tun \
  tailscale/tailscale:latest
```

### 4. Authenticate Tailscale

Choose one method:

#### Option A: Interactive (First-time setup)

```bash
docker exec tailscale tailscale up --ssh --accept-dns=false
```

Visit the URL that appears to authenticate.

#### Option B: Auth key (Automated)

1. Get an auth key from https://login.tailscale.com/admin/settings/keys
2. Run:

```bash
docker exec tailscale tailscale up --ssh --accept-dns=false --auth-key=YOUR_KEY
```

### 5. Verify setup

```bash
# Check Tailscale status
docker exec tailscale tailscale status

# Check firewall rules
firewall-cmd --list-all

# Test Tailscale SSH (from another device on Tailscale)
ssh dzikran@<vps-tailscale-ip>
```

## Firewall Rules Summary

| Port | Protocol | Public Access | Tailscale Access | Service |
|------|----------|---------------|------------------|---------|
| 80   | TCP      | ✅ Allowed    | ✅ Allowed       | HTTP    |
| 443  | TCP      | ✅ Allowed    | ✅ Allowed       | HTTPS   |
| 22   | TCP      | ❌ Blocked    | ✅ Allowed       | SSH     |
| 3000 | TCP      | ❌ Blocked    | ✅ Allowed       | EasyPanel |
| 8090 | TCP      | ❌ Blocked    | ✅ Allowed       | Beszel |
| 2377 | TCP      | ❌ Blocked    | ✅ Allowed       | Docker Swarm |
| 7946 | TCP/UDP  | ❌ Blocked    | ✅ Allowed       | Docker Overlay |
| 4789 | UDP      | ❌ Blocked    | ✅ Allowed       | Docker VXLAN |

## Accessing Services

### From Public Internet
```bash
# Web apps (via Traefik)
http://your-domain.com
https://your-domain.com
```

### From Tailscale VPN
```bash
# SSH
ssh dzikran@<tailscale-ip>

# EasyPanel
http://<tailscale-ip>:3000

# Beszel Hub
http://<tailscale-ip>:8090
```

## Tailscale SSH

Tailscale SSH is enabled, providing secure access without public SSH port:

1. Install Tailscale on your local machine: https://tailscale.com/download
2. Log in to Tailscale
3. Connect directly:

```bash
ssh dzikran@<vps-tailscale-ip>
```

Your existing SSH keys in `~/.ssh/` will work automatically.

## Managing Tailscale

### Check status
```bash
docker exec tailscale tailscale status
docker exec tailscale tailscale status --self
```

### View logs
```bash
docker logs tailscale
```

### Restart
```bash
docker restart tailscale
```

### Update
```bash
docker stop tailscale
docker rm tailscale
docker pull tailscale/tailscale:latest
# Re-run the docker run command from step 3
```

### Get Tailscale IP
```bash
docker exec tailscale tailscale ip -4
```

## Troubleshooting

### Can't access services via Tailscale

1. Check Tailscale is running:
   ```bash
   docker exec tailscale tailscale status
   ```

2. Check firewall rules:
   ```bash
   firewall-cmd --list-all
   ```

3. Verify Tailscale network:
   ```bash
   docker exec tailscale tailscale ping <another-device>
   ```

### Tailscale container exits after Docker restart

Check if the systemd service is enabled:
```bash
systemctl status tailscale-docker-fix
```

If not, recreate it (see setup script step 6).

### Public SSH still accessible

Verify firewall rules are correct:
```bash
firewall-cmd --permanent --zone=public --list-all | grep -E "port.*22"
```

Should show a reject rule. If not, re-run the firewall configuration.

## Security Best Practices

1. **Use Tailscale SSH**: Never expose port 22 publicly
2. **Keep Tailscale updated**: Run `docker pull tailscale/tailscale:latest` regularly
3. **Use auth keys**: For automated deployments, use Tailscale auth keys with expiration
4. **Monitor access**: Check Tailscale admin console for connected devices
5. **Enable ACLs**: Use Tailscale ACLs to restrict which devices can access this VPS

## Resources

- [Tailscale documentation](https://tailscale.com/kb/)
- [Tailscale SSH](https://tailscale.com/kb/1193/tailscale-ssh/)
- [Tailscale ACLs](https://tailscale.com/kb/1018/acls/)
- [Firewalld documentation](https://firewalld.org/documentation/)

## System Information

- **OS**: OpenCloudOS 9.4
- **Tailscale version**: 1.94.2 (Docker container)
- **Firewall**: firewalld with nftables backend
- **Tailscale network**: 100.64.0.0/10 (CGNAT range)
