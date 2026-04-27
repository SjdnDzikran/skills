# Fix EasyPanel Docker Restart - Implementation

## 1. Backup SSH Keys and Mise Binary

```bash
CONTAINER_NAME=$(docker ps --filter "name=easypanel" --format "{{.Names}}" | head -1)

mkdir -p /etc/easypanel/ssh-keys

# Container home is /home/dzikran, NOT /root
docker exec $CONTAINER_NAME cat /home/dzikran/.ssh/id_ed25519 > /etc/easypanel/ssh-keys/id_ed25519
docker exec $CONTAINER_NAME cat /home/dzikran/.ssh/id_ed25519.pub > /etc/easypanel/ssh-keys/id_ed25519.pub
chmod 600 /etc/easypanel/ssh-keys/id_ed25519
chmod 644 /etc/easypanel/ssh-keys/id_ed25519.pub

docker exec $CONTAINER_NAME cat /home/dzikran/.local/bin/mise > /etc/easypanel/mise
chmod +x /etc/easypanel/mise
```

## 2. Create Restore Script

Create `/etc/easypanel/restore-config.sh`:

```bash
#!/bin/bash

CONTAINER_NAME=$(docker ps --filter "name=easypanel" --format "{{.Names}}" | head -1)

if [ -z "$CONTAINER_NAME" ]; then
    echo "EasyPanel container not found"
    exit 1
fi

echo "Restoring EasyPanel configuration for $CONTAINER_NAME..."

# IMPORTANT: Container home is /home/dzikran, NOT /root.
# Using ~/ or /root/ will silently copy to the wrong path.
echo "Restoring SSH keys..."
docker cp /etc/easypanel/ssh-keys/id_ed25519 $CONTAINER_NAME:/home/dzikran/.ssh/
docker cp /etc/easypanel/ssh-keys/id_ed25519.pub $CONTAINER_NAME:/home/dzikran/.ssh/
docker exec $CONTAINER_NAME chmod 600 /home/dzikran/.ssh/id_ed25519
docker exec $CONTAINER_NAME chmod 644 /home/dzikran/.ssh/id_ed25519.pub

echo "Restoring mise binary..."
docker exec $CONTAINER_NAME mkdir -p /tmp/railpack/mise
docker cp /etc/easypanel/mise $CONTAINER_NAME:/tmp/railpack/mise/mise-2026.1.3
docker exec $CONTAINER_NAME chmod +x /tmp/railpack/mise/mise-2026.1.3

echo "EasyPanel configuration restored"
```

Make it executable:
```bash
chmod +x /etc/easypanel/restore-config.sh
```

## 3. Create Systemd Service

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

## 4. Verify

```bash
systemctl status easypanel-restore.service
docker exec $CONTAINER_NAME ssh -T git@github.com
docker exec $CONTAINER_NAME /tmp/railpack/mise/mise-2026.1.3 --version
```

## Manual Restoration

```bash
/etc/easypanel/restore-config.sh
# or
systemctl restart easypanel-restore
```

## Updating SSH Keys

After generating a new key:

1. Add public key to GitHub
2. Update backup:

```bash
CONTAINER_NAME=$(docker ps --filter "name=easypanel" --format "{{.Names}}" | head -1)
# Container home is /home/dzikran, NOT /root
docker exec $CONTAINER_NAME cat /home/dzikran/.ssh/id_ed25519 > /etc/easypanel/ssh-keys/id_ed25519
docker exec $CONTAINER_NAME cat /home/dzikran/.ssh/id_ed25519.pub > /etc/easypanel/ssh-keys/id_ed25519.pub
```
