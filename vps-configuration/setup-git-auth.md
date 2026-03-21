# Setup Git Authentication with SSH Keys

## Overview
Setup SSH keys for git authentication to access private repositories on GitHub, GitLab, or Bitbucket.

## Usage
```bash
setup-git-auth.sh [username|easypanel]
```

- Without arguments: sets up for current user
- With username: sets up for specified system user
- With "easypanel": sets up for EasyPanel Docker container

## For System Users

### 1. Create user (if needed)
```bash
sudo useradd -m username
```

### 2. Generate SSH keys
```bash
su - username -c "
    mkdir -p ~/.ssh && \
    chmod 700 ~/.ssh && \
    ssh-keygen -t ed25519 -C 'username@vps' -f ~/.ssh/id_ed25519 -N '' && \
    ssh-keyscan github.com >> ~/.ssh/known_hosts 2>/dev/null
"
```

### 3. Display public key
```bash
cat /home/username/.ssh/id_ed25519.pub
# or for root:
cat /root/.ssh/id_ed25519.pub
```

### 4. Add SSH key to git provider
**GitHub**: Settings → SSH and GPG keys → New SSH key  
**GitLab**: Preferences → SSH Keys  
**Bitbucket**: Settings → SSH keys → Add key

### 5. Test connection
```bash
su - username -c "ssh -T git@github.com"
```

Expected output: `Hi username! You've successfully authenticated...`

### 6. Configure git user info
```bash
su - username
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

## For EasyPanel

EasyPanel runs in Docker and needs SSH keys inside its container.

### 1. Find EasyPanel container
```bash
docker ps | grep easypanel
```

### 2. Generate SSH keys inside container
```bash
CONTAINER_ID=$(docker ps | grep easypanel | awk '{print $1}' | head -1)
docker exec $CONTAINER_ID sh -c "
    mkdir -p ~/.ssh && \
    chmod 700 ~/.ssh && \
    ssh-keygen -t ed25519 -C 'easypanel@vps' -f ~/.ssh/id_ed25519 -N '' && \
    ssh-keyscan github.com >> ~/.ssh/known_hosts 2>/dev/null
"
```

### 3. Display public key
```bash
docker exec $CONTAINER_ID cat ~/.ssh/id_ed25519.pub
```

### 4. Add SSH key to GitHub
Same process as above - add to your GitHub SSH keys.

### 5. Test connection
```bash
docker exec $CONTAINER_ID ssh -T git@github.com
```

## Why Each User Needs Their Own SSH Key

1. **File isolation**: Each user has their own `~/.ssh/` directory
2. **Permissions**: SSH requires strict permissions (600 on private keys)
3. **Authentication context**: When you run `git clone`, the current user's SSH keys are used
4. **Security**: Each user/service has their own identity for audit and access control
5. **Docker isolation**: Containers are isolated from host users, need their own keys

## Cloning Repositories
After setup, clone using SSH URLs:
```bash
git clone git@github.com:username/repo.git
```

## Troubleshooting

### Permission denied (publickey)
- SSH key not added to git provider
- Wrong SSH key being used
- File permissions incorrect on private key

### Host key verification failed
- Add GitHub/GitLab/Bitbucket to known_hosts:
```bash
ssh-keyscan github.com >> ~/.ssh/known_hosts
```

### EasyPanel can't access repository
- Ensure SSH keys are generated inside the container
- Verify public key is added to GitHub
- Test connection from inside container