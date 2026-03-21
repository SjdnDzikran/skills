# Fix EasyPanel Docker Restart Persistence

## Problem
When Docker restarts, the EasyPanel container loses:
- SSH keys for Git access
- `mise` binary (tool manager needed by Railpack)

This causes deployment failures with errors like:
- "Git key not found"
- "failed to run mise command"

## Solution
Set up persistent backups and automatic restoration of SSH keys and mise binary.

## Implementation

### 1. Backup SSH Keys and Mise Binary

```bash
# Get EasyPanel container name
CONTAINER_NAME=$(docker ps --filter "name=easypanel" --format "{{.Names}}" | head -1)

# Create backup directory
mkdir -p /etc/easypanel/ssh-keys

# Backup SSH keys
docker exec $CONTAINER_NAME cat ~/.ssh/id_ed25519 > /etc/easypanel/ssh-keys/id_ed25519
docker exec $CONTAINER_NAME cat ~/.ssh/id_ed25519.pub > /etc/easypanel/ssh-keys/id_ed25519.pub
chmod 600 /etc/easypanel/ssh-keys/id_ed25519
chmod 644 /etc/easypanel/ssh-keys/id_ed25519.pub

# Backup mise binary
docker exec $CONTAINER_NAME cat /root/.local/bin/mise > /etc/easypanel/mise
chmod +x /etc/easypanel/mise
```

### 2. Create Restore Script

Create `/etc/easypanel/restore-config.sh`:

```bash
#!/bin/bash

# Restore EasyPanel SSH keys and mise binary after container restart

CONTAINER_NAME=$(docker ps --filter "name=easypanel" --format "{{.Names}}" | head -1)

if [ -z "$CONTAINER_NAME" ]; then
    echo "EasyPanel container not found"
    exit 1
fi

echo "Restoring EasyPanel configuration for $CONTAINER_NAME..."

# Restore SSH keys
echo "Restoring SSH keys..."
docker exec $CONTAINER_NAME mkdir -p ~/.ssh
docker cp /etc/easypanel/ssh-keys/id_ed25519 $CONTAINER_NAME:/root/.ssh/
docker cp /etc/easypanel/ssh-keys/id_ed25519.pub $CONTAINER_NAME:/root/.ssh/
docker exec $CONTAINER_NAME chmod 600 ~/.ssh/id_ed25519
docker exec $CONTAINER_NAME chmod 644 ~/.ssh/id_ed25519.pub

# Restore mise binary
echo "Restoring mise binary..."
docker exec $CONTAINER_NAME mkdir -p /tmp/railpack/mise
docker cp /etc/easypanel/mise $CONTAINER_NAME:/tmp/railpack/mise/mise-2026.1.3
docker exec $CONTAINER_NAME chmod +x /tmp/railpack/mise/mise-2026.1.3

echo "✓ EasyPanel configuration restored"
```

Make it executable:
```bash
chmod +x /etc/easypanel/restore-config.sh
```

### 3. Create Systemd Service

Create `/etc/systemd/system/easypanel-restore.service`:

```ini
[Unit]
Description=Restore EasyPanel SSH keys and mise binary
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
ExecStart=/etc/easypanel/restore-config.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

Enable and start:
```bash
systemctl daemon-reload
systemctl enable easypanel-restore.service
systemctl start easypanel-restore.service
```

### 4. Test Restoration

After Docker restart, verify:

```bash
# Check service status
systemctl status easypanel-restore.service

# Test SSH connection
docker exec $CONTAINER_NAME ssh -T git@github.com

# Test mise
docker exec $CONTAINER_NAME /tmp/railpack/mise/mise-2026.1.3 --version
```

## Manual Restoration

If needed, manually run the restore script:

```bash
/etc/easypanel/restore-config.sh
```

Or restart the service:

```bash
systemctl restart easypanel-restore
```

## Updating SSH Keys

When you need to update the SSH key (e.g., after generating a new one):

1. Add new public key to GitHub
2. Update the backup:
```bash
CONTAINER_NAME=$(docker ps --filter "name=easypanel" --format "{{.Names}}" | head -1)
docker exec $CONTAINER_NAME cat ~/.ssh/id_ed25519 > /etc/easypanel/ssh-keys/id_ed25519
docker exec $CONTAINER_NAME cat ~/.ssh/id_ed25519.pub > /etc/easypanel/ssh-keys/id_ed25519.pub
```

## Why This Happens

EasyPanel runs in Docker with temporary filesystem (`/tmp`) that gets cleared on:
- Docker restart
- Container restart
- System reboot

The `mise` binary is downloaded to `/tmp/railpack/mise/` and SSH keys are stored in the container's `/root/.ssh/`, both of which are ephemeral unless backed up and restored.