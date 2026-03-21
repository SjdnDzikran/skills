# Tailscale VPS Security Setup (Native Installation)

## Overview

This VPS uses **Tailscale installed natively** (not in Docker) for secure, private access. Tailscale SSH and subnet routing are enabled, providing the same security badges as your previous server.

Only HTTP/HTTPS ports (80/443) are publicly accessible. All other services (SSH, EasyPanel, Beszel) are only accessible through Tailscale VPN.

## Features

- ✅ **SSH Badge**: Tailscale SSH enabled - use your Tailscale IP to SSH
- ✅ **Subnet Badge**: Subnet router enabled - can advertise routes
- ✅ **Network Security**: Only HTTP/HTTPS public, everything else private
- ✅ **Native Installation**: Tailscale runs directly on host (not Docker)

## Architecture

```
Public Internet (0.0.0.0/0)
    ↓
    ├─ HTTP (80)   → Traefik → Web Apps
    └─ HTTPS (443) → Traefik → Web Apps

Tailscale VPN (100.64.0.0/10)
    ↓
    ├─ SSH (22)           → Tailscale SSH enabled
    ├─ EasyPanel (3000)   → Deployment dashboard
    ├─ Beszel (8090)      → Monitoring hub
    └─ All other services → Private access only
```

## Installation

### 1. Install Tailscale Binaries

Extract from Docker container (easiest method):

```bash
# Run temporary container
docker run --name ts-extract tailscale/tailscale:latest sleep infinity &

# Copy binaries
docker cp ts-extract:/usr/local/bin/tailscale /usr/local/bin/tailscale
docker cp ts-extract:/usr/local/bin/tailscaled /usr/local/bin/tailscaled

# Make executable
chmod +x /usr/local/bin/tailscale /usr/local/bin/tailscaled

# Cleanup
docker stop ts-extract && docker rm ts-extract
```

### 2. Create Systemd Service

```bash
cat > /etc/systemd/system/tailscaled.service << 'EOF'
[Unit]
Description=Tailscale node agent
Documentation=https://tailscale.com/kb/
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
ExecStartPre=/usr/local/bin/tailscaled --cleanup
ExecStart=/usr/local/bin/tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/var/run/tailscale/tailscaled.sock --port=41641
Restart=on-failure
RestartSec=5s
RuntimeDirectory=tailscale
RuntimeDirectoryMode=0750
StateDirectory=tailscale
StateDirectoryMode=0700
CacheDirectory=tailscale
CacheDirectoryMode=0750

[Install]
WantedBy=multi-user.target
EOF

# Create directories and enable
mkdir -p /var/run/tailscale /var/lib/tailscale
systemctl daemon-reload
systemctl enable tailscaled
systemctl start tailscaled
```

### 3. Configure Firewall

```bash
# Set default zone to public
firewall-cmd --set-default-zone=public

# Allow HTTP/HTTPS from anywhere
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=https

# Allow all from Tailscale network
firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" source address="100.64.0.0/10" accept'

# Block sensitive ports from public
firewall-cmd --permanent --zone=public --remove-service=ssh
firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" port protocol="tcp" port="22" reject'
firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" port protocol="tcp" port="3000" reject'
firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" port protocol="tcp" port="8090" reject'
firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" port protocol="tcp" port="2377" reject'
firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" port protocol="tcp" port="7946" reject'
firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" port protocol="udp" port="7946" reject'
firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" port protocol="udp" port="4789" reject'

# Reload firewall
firewall-cmd --reload
```

### 4. Authenticate Tailscale

Choose one method:

#### Option A: Interactive (First-time setup)

```bash
tailscale up --ssh --accept-routes=true
```

Visit the URL that appears to authenticate.

#### Option B: Auth key (Automated)

1. Get an auth key from https://login.tailscale.com/admin/settings/keys
2. Run:

```bash
tailscale up --ssh --accept-routes=true --auth-key=YOUR_KEY
```

### 5. Verify Setup

```bash
# Check Tailscale status
tailscale status
tailscale status --self

# Get Tailscale IP
tailscale ip -4

# Check network interface
ip addr show tailscale0

# Check service status
systemctl status tailscaled
```

## Firewall Rules Summary

| Port | Protocol | Public Access | Tailscale Access | Service |
|------|----------|---------------|------------------|---------|
| 80   | TCP      | ✅ Allowed    | ✅ Allowed       | HTTP    |
| 443  | TCP      | ✅ Allowed    | ✅ Allowed       | HTTPS   |
| 22   | TCP      | ❌ Blocked    | ✅ Allowed       | SSH (Tailscale) |
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
# SSH via Tailscale (Tailscale SSH enabled)
ssh dzikran@<tailscale-ip>

# Example with your current IP:
ssh dzikran@100.89.64.62

# EasyPanel
http://<tailscale-ip>:3000

# Beszel Hub
http://<tailscale-ip>:8090
```

## Tailscale SSH

Tailscale SSH is enabled with the `--ssh` flag. This means:

1. **SSH Badge**: You'll see the SSH badge in Tailscale dashboard
2. **Direct Access**: SSH to your Tailscale IP (100.89.64.62)
3. **Key Management**: Your existing SSH keys in `~/.ssh/` work automatically
4. **No Public SSH**: Port 22 is blocked from internet, only accessible via Tailscale

### Testing SSH Access

From your Windows machine on Tailscale:

```powershell
ssh dzikran@100.89.64.62
```

This will use Tailscale's network to connect securely.

## Subnet Router

With `--accept-routes=true`, your VPS can act as a subnet router. You'll see the **Subnet badge** in the dashboard.

To advertise subnet routes from this VPS, configure them in the Tailscale admin console or use:

```bash
tailscale up --advertise-routes=10.11.0.0/16
```

## Managing Tailscale

### Check status
```bash
tailscale status
tailscale status --self
tailscale ip -4
tailscale ip -6
```

### View logs
```bash
journalctl -u tailscaled -f
```

### Restart service
```bash
systemctl restart tailscaled
```

### Update binaries
```bash
# Stop service
systemctl stop tailscaled

# Extract new version from Docker container
docker run --name ts-extract tailscale/tailscale:latest sleep infinity &
sleep 2
docker cp ts-extract:/usr/local/bin/tailscale /usr/local/bin/tailscale
docker cp ts-extract:/usr/local/bin/tailscaled /usr/local/bin/tailscaled
chmod +x /usr/local/bin/tailscale /usr/local/bin/tailscaled
docker stop ts-extract && docker rm ts-extract

# Start service
systemctl start tailscaled
```

### Change configuration
```bash
# To change flags (e.g., disable SSH)
tailscale down
tailscale up --ssh=false --accept-routes=true

# To enable subnet routing
tailscale up --advertise-routes=10.11.0.0/16
```

## Troubleshooting

### Can't access services via Tailscale

1. Check Tailscale is running:
   ```bash
   systemctl status tailscaled
   tailscale status
   ```

2. Check network interface:
   ```bash
   ip addr show tailscale0
   ```

3. Check firewall rules:
   ```bash
   firewall-cmd --list-all
   ```

4. Verify Tailscale IP:
   ```bash
   tailscale ip -4
   ```

### SSH connection fails

1. Verify Tailscale SSH is enabled:
   ```bash
   tailscale status --json | grep -A5 tailscale_ssh
   ```

2. Check SSH logs:
   ```bash
   journalctl -u sshd -n 50
   ```

3. Test from VPS itself:
   ```bash
   ssh dzikran@$(tailscale ip -4)
   ```

### No SSH/Subnet badges in dashboard

1. Verify flags during authentication:
   ```bash
   tailscale status --json | grep -A2 SSH
   ```

2. Re-authenticate with correct flags:
   ```bash
   tailscale down
   tailscale up --ssh --accept-routes=true
   ```

### Public SSH still accessible

Verify firewall rules:
```bash
firewall-cmd --list-rich-rules | grep "port.*22"
```

Should show a reject rule. If not:
```bash
firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" port protocol="tcp" port="22" reject'
firewall-cmd --reload
```

## Security Best Practices

1. **Never expose SSH publicly**: Only access via Tailscale IP
2. **Keep Tailscale updated**: Regularly extract new binaries from Docker container
3. **Use auth keys**: For automated deployments, use Tailscale auth keys with expiration
4. **Monitor access**: Check Tailscale admin console for connected devices
5. **Enable ACLs**: Use Tailscale ACLs to restrict which devices can access this VPS
6. **Enable 2FA**: Require 2FA for Tailscale account

## Resources

- [Tailscale documentation](https://tailscale.com/kb/)
- [Tailscale SSH](https://tailscale.com/kb/1193/tailscale-ssh/)
- [Subnet routers](https://tailscale.com/kb/1019/subnets/)
- [Tailscale ACLs](https://tailscale.com/kb/1018/acls/)
- [Firewalld documentation](https://firewalld.org/documentation/)

## System Information

- **OS**: OpenCloudOS 9.4
- **Tailscale version**: 1.94.2 (native installation)
- **Tailscale IP**: 100.89.64.62 (changes when re-authenticating)
- **Tailscale Interface**: tailscale0 (kernel WireGuard)
- **Firewall**: firewalld with nftables backend
- **Tailscale network**: 100.64.0.0/10 (CGNAT range)
- **Features**: SSH enabled, Subnet routing enabled

## Comparison with Docker Setup

### Native Installation (Current) ✅
- ✅ Tailscale SSH works properly
- ✅ Subnet router badge
- ✅ Proper network interface (tailscale0)
- ✅ Full kernel WireGuard support
- ✅ Better performance

### Docker Container (Previous) ❌
- ❌ Tailscale SSH doesn't work (user mapping issues)
- ❌ No subnet router badge
- ❌ Userspace networking only
- ❌ No proper network interface
- ❌ More complex setup

## Quick Reference

```bash
# Status
tailscale status                    # Show all peers
tailscale status --self              # Show this machine
tailscale ip -4                      # Get IPv4 address

# Service
systemctl status tailscaled          # Check service
systemctl restart tailscaled         # Restart service
journalctl -u tailscaled -f          # View logs

# Configuration
tailscale up --ssh --accept-routes   # Enable SSH + subnet routes
tailscale down                       # Disconnect
tailscale up --advertise-routes=X.X.X.X/X  # Advertise route

# Network
ip addr show tailscale0              # Show Tailscale interface
ping <tailscale-ip>                  # Test connectivity
```

## What Changed from Previous Setup

**Before (Docker)**:
- Tailscale in Docker container
- No SSH badge (userspace networking issues)
- No subnet router badge
- SSH had to be configured separately

**After (Native)**:
- Tailscale installed on host
- ✅ SSH badge enabled
- ✅ Subnet router badge enabled
- Tailscale SSH works natively
- Proper kernel WireGuard interface
- Matches your previous server's setup
