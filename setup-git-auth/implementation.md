# Setup Git Auth - Implementation

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
```

### 4. Add SSH key to git provider
- **GitHub**: Settings -> SSH and GPG keys -> New SSH key
- **GitLab**: Preferences -> SSH Keys
- **Bitbucket**: Settings -> SSH keys -> Add key

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

## For EasyPanel Docker Container

### 1. Find EasyPanel container
```bash
CONTAINER_ID=$(docker ps | grep easypanel | awk '{print $1}' | head -1)
```

### 2. Generate SSH keys inside container
```bash
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
```bash
ssh-keyscan github.com >> ~/.ssh/known_hosts
```

### EasyPanel can't access repository
- Ensure SSH keys are generated inside the container
- Verify public key is added to GitHub
- Test connection from inside container
