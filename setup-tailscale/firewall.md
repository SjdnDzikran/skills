# Tailscale Firewall Rules

## Configure Firewall

```bash
firewall-cmd --set-default-zone=public

firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=https

firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" source address="100.64.0.0/10" accept'

firewall-cmd --permanent --zone=public --remove-service=ssh
firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" port protocol="tcp" port="22" reject'
firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" port protocol="tcp" port="3000" reject'
firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" port protocol="tcp" port="8090" reject'
firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" port protocol="tcp" port="2377" reject'
firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" port protocol="tcp" port="7946" reject'
firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" port protocol="udp" port="7946" reject'
firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" port protocol="udp" port="4789" reject'

firewall-cmd --reload
```

## Full Rules Summary

| Port | Protocol | Public Access | Tailscale Access | Service |
|------|----------|---------------|------------------|---------|
| 80   | TCP      | Allowed | Allowed | HTTP |
| 443  | TCP      | Allowed | Allowed | HTTPS |
| 22   | TCP      | Blocked | Allowed | SSH (Tailscale) |
| 3000 | TCP      | Blocked | Allowed | EasyPanel |
| 8090 | TCP      | Blocked | Allowed | Beszel |
| 2377 | TCP      | Blocked | Allowed | Docker Swarm |
| 7946 | TCP/UDP  | Blocked | Allowed | Docker Overlay |
| 4789 | UDP      | Blocked | Allowed | Docker VXLAN |

## Verify Rules

```bash
firewall-cmd --list-all
firewall-cmd --list-rich-rules | grep "port.*22"
```
