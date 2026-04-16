# Setup Zsh - Implementation

## 1. Install zsh

```bash
# Ubuntu/Debian
sudo apt install zsh

# CentOS/RHEL
sudo yum install zsh

# Fedora
sudo dnf install zsh
```

## 2. Install Oh My Zsh

```bash
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
```

## 3. Install zsh-syntax-highlighting

```bash
ZSH_CUSTOM="${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
```

## 4. Install zsh-autosuggestions

```bash
git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
```

## 5. Configure .zshrc

Backup existing config:
```bash
cp ~/.zshrc ~/.zshrc.backup
```

Create new `.zshrc`:
```bash
cat > ~/.zshrc << 'EOF'
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="af-magic"

plugins=(git zsh-syntax-highlighting zsh-autosuggestions)

setopt AUTO_CD

COMPLETION_WAITING_DOTS="true"

source $ZSH/oh-my-zsh.sh

export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
EOF
```

## 6. Set zsh as default shell

```bash
chsh -s $(which zsh)
```

If you can't use `chsh` (requires password), add to `.bashrc`:
```bash
echo "" >> ~/.bashrc
echo "# Auto-start zsh with oh-my-zsh" >> ~/.bashrc
echo 'if [ -z "$ZSH_VERSION" ] && [ -f /usr/bin/zsh ]; then' >> ~/.bashrc
echo '    exec /usr/bin/zsh' >> ~/.bashrc
echo 'fi' >> ~/.bashrc
```

## 7. Apply

```bash
exec zsh
```

Or start a new terminal session.
