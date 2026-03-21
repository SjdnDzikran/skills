#!/bin/bash

# Skill: Setup Zsh with Oh My Zsh
# Description: Configure zsh with oh-my-zsh, syntax highlighting, auto-suggestions, and custom settings
# Usage: Source this file or run it directly to set up zsh on a new VPS

set -e

echo "🚀 Setting up Zsh with Oh My Zsh..."

# Check if zsh is installed
if ! command -v zsh &> /dev/null; then
    echo "❌ Zsh is not installed. Please install it first:"
    echo "   Ubuntu/Debian: sudo apt install zsh"
    echo "   CentOS/RHEL: sudo yum install zsh"
    echo "   Fedora: sudo dnf install zsh"
    exit 1
fi

echo "✓ Zsh is installed"

# Install oh-my-zsh unattended
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "📦 Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo "✓ Oh My Zsh installed"
else
    echo "✓ Oh My Zsh already installed"
fi

# Install zsh-syntax-highlighting
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo "📦 Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    echo "✓ zsh-syntax-highlighting installed"
else
    echo "✓ zsh-syntax-highlighting already installed"
fi

# Install zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "📦 Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    echo "✓ zsh-autosuggestions installed"
else
    echo "✓ zsh-autosuggestions already installed"
fi

# Backup existing .zshrc
if [ -f "$HOME/.zshrc" ] && [ ! -f "$HOME/.zshrc.backup" ]; then
    echo "💾 Backing up .zshrc to .zshrc.backup"
    cp "$HOME/.zshrc" "$HOME/.zshrc.backup"
fi

# Create new .zshrc with custom configuration
echo "📝 Configuring .zshrc..."
cat > "$HOME/.zshrc" << 'EOF'
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

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

echo "✓ .zshrc configured"

# Set zsh as default shell if possible
if [ -n "$SHELL" ] && [ "$(basename "$SHELL")" != "zsh" ]; then
    echo "🔄 Setting zsh as default shell..."
    if command -v chsh &> /dev/null; then
        # Try to change shell non-interactively
        if chsh -s "$(which zsh)" 2>/dev/null; then
            echo "✓ Default shell changed to zsh"
        else
            echo "⚠️  Could not change default shell (requires password)"
            echo "💡 Adding zsh auto-start to .bashrc instead..."
            
            # Add to .bashrc for auto-start
            if ! grep -q "exec.*zsh" "$HOME/.bashrc" 2>/dev/null; then
                echo "" >> "$HOME/.bashrc"
                echo "# Auto-start zsh with oh-my-zsh" >> "$HOME/.bashrc"
                echo 'if [ -z "$ZSH_VERSION" ] && [ -f /usr/bin/zsh ]; then' >> "$HOME/.bashrc"
                echo '    exec /usr/bin/zsh' >> "$HOME/.bashrc"
                echo 'fi' >> "$HOME/.bashrc"
                echo "✓ Added zsh auto-start to .bashrc"
            fi
        fi
    fi
fi

echo ""
echo "✅ Zsh setup complete!"
echo ""
echo "📝 Next steps:"
echo "   1. Run 'exec zsh' or start a new terminal session"
echo "   2. You'll now have:"
echo "      • Oh My Zsh framework"
echo "      • af-magic theme"
echo "      • Syntax highlighting"
echo "      • Auto-suggestions"
echo "      • Auto cd (type folder name to cd)"
echo "      • Completion dots"
echo ""
