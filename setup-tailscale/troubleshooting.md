# Tailscale Troubleshooting

## Can't access services via Tailscale

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

## SSH connection fails

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

## No SSH/Subnet badges in dashboard

1. Verify flags during authentication:
```bash
tailscale status --json | grep -A2 SSH
```

2. Re-authenticate with correct flags:
```bash
tailscale down
tailscale up --ssh --accept-routes=true
```

## Public SSH still accessible

Verify firewall rules:
```bash
firewall-cmd --list-rich-rules | grep "port.*22"
```

Should show a reject rule. If not:
```bash
firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" port protocol="tcp" port="22" reject'
firewall-cmd --reload
```

## Accessing Services

### From Public Internet
```bash
http://your-domain.com
https://your-domain.com
```

### From Tailscale VPN
```bash
ssh dzikran@<tailscale-ip>
http://<tailscale-ip>:3000    # EasyPanel
http://<tailscale-ip>:8090    # Beszel Hub
```

## Changing Configuration

```bash
tailscale down
tailscale up --ssh=false --accept-routes=true         # Disable SSH
tailscale up --advertise-routes=10.11.0.0/16          # Advertise subnet
```

## Resources

- [Tailscale documentation](https://tailscale.com/kb/)
- [Tailscale SSH](https://tailscale.com/kb/1193/tailscale-ssh/)
- [Subnet routers](https://tailscale.com/kb/1019/subnets/)
- [Tailscale ACLs](https://tailscale.com/kb/1018/acls/)
