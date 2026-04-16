# Tailscale Installation

## 1. Install Tailscale Binaries

Extract from Docker container (easiest method):

```bash
docker run --name ts-extract tailscale/tailscale:latest sleep infinity &

docker cp ts-extract:/usr/local/bin/tailscale /usr/local/bin/tailscale
docker cp ts-extract:/usr/local/bin/tailscaled /usr/local/bin/tailscaled

chmod +x /usr/local/bin/tailscale /usr/local/bin/tailscaled

docker stop ts-extract && docker rm ts-extract
```

## 2. Create Systemd Service

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

mkdir -p /var/run/tailscale /var/lib/tailscale
systemctl daemon-reload
systemctl enable tailscaled
systemctl start tailscaled
```

## 3. Authenticate Tailscale

### Option A: Interactive (First-time setup)

```bash
tailscale up --ssh --accept-routes=true
```

Visit the URL that appears to authenticate.

### Option B: Auth key (Automated)

1. Get an auth key from https://login.tailscale.com/admin/settings/keys
2. Run:

```bash
tailscale up --ssh --accept-routes=true --auth-key=YOUR_KEY
```

## 4. Verify Setup

```bash
tailscale status
tailscale status --self
tailscale ip -4
ip addr show tailscale0
systemctl status tailscaled
```

## Updating Tailscale

```bash
systemctl stop tailscaled

docker run --name ts-extract tailscale/tailscale:latest sleep infinity &
sleep 2
docker cp ts-extract:/usr/local/bin/tailscale /usr/local/bin/tailscale
docker cp ts-extract:/usr/local/bin/tailscaled /usr/local/bin/tailscaled
chmod +x /usr/local/bin/tailscale /usr/local/bin/tailscaled
docker stop ts-extract && docker rm ts-extract

systemctl start tailscaled
```

## Managing Tailscale

```bash
tailscale status                    # Show all peers
tailscale status --self              # Show this machine
tailscale ip -4                      # Get IPv4 address
systemctl status tailscaled          # Check service
systemctl restart tailscaled         # Restart service
journalctl -u tailscaled -f          # View logs
```
