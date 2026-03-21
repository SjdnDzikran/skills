# Setup Zsh with Oh My Zsh

## Overview
Configure zsh with oh-my-zsh, syntax highlighting, auto-suggestions, and custom settings for an enhanced terminal experience.

## Prerequisites
- Zsh installed on your system
- Git installed
- Internet connection for cloning repositories

## Installation Steps

### 1. Check if zsh is installed
```bash
# Ubuntu/Debian
sudo apt install zsh

# CentOS/RHEL
sudo yum install zsh

# Fedora
sudo dnf install zsh
```

### 2. Install Oh My Zsh
```bash
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
```

### 3. Install zsh-syntax-highlighting
```bash
ZSH_CUSTOM="${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
```

### 4. Install zsh-autosuggestions
```bash
git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
```

### 5. Configure .zshrc
Backup existing config:
```bash
cp ~/.zshrc ~/.zshrc.backup
```

Create new `.zshrc`:
```bash
cat > ~/.zshrc << 'EOF'
# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="af-magic"

# Plugins
plugins=(git zsh-syntax-highlighting zsh-autosuggestions)

# Auto cd - type directory name to cd into it
setopt AUTO_CD

# Show completion dots while waiting
COMPLETION_WAITING_DOTS="true"

source $ZSH/oh-my-zsh.sh

# User configuration
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
EOF
```

### 6. Set zsh as default shell
```bash
chsh -s $(which zsh)
```

If you can't use chsh (requires password), add to `.bashrc`:
```bash
echo "" >> ~/.bashrc
echo "# Auto-start zsh with oh-my-zsh" >> ~/.bashrc
echo 'if [ -z "$ZSH_VERSION" ] && [ -f /usr/bin/zsh ]; then' >> ~/.bashrc
echo '    exec /usr/bin/zsh' >> ~/.bashrc
echo 'fi' >> ~/.bashrc
```

### 7. Apply changes
```bash
exec zsh
```

or start a new terminal session.

## Features Included
- Oh My Zsh framework
- af-magic theme
- Syntax highlighting
- Auto-suggestions
- Auto cd (type folder name to cd)
- Completion dots

## Verification
After setup, you should see:
- Colorful prompt with git status
- Command syntax highlighting
- Auto-suggestions as you type
- Auto cd into directories by typing their name