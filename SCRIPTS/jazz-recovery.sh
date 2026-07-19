#!/bin/bash
# jazz-recovery.sh — Complete workspace recovery after AnyClaw reinstall
# Run this AFTER cloning the workspace from GitHub
# Usage: bash jazz-recovery.sh

set -euo pipefail

WORKSPACE="/root/jazz-workspace"
CONFIG="$WORKSPACE/CONFIG"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "🦄 Jazz🔥 Recovery — $DATE"
echo "================================="
echo ""

# === Step 1: Verify workspace ===
echo "📂 Step 1: Verifying workspace..."
if [ ! -f "$WORKSPACE/AGENTS.md" ]; then
    echo "  ❌ Workspace not found at $WORKSPACE"
    echo "  ➡️  Clone it first: git clone https://github.com/DigitalPixelStudio/jazz-workspace $WORKSPACE"
    exit 1
fi
echo "  ✅ Workspace found"
echo ""

# === Step 2: Restore shell configs ===
echo "🐚 Step 2: Restoring shell configs..."
cp "$CONFIG/shell/.bash_aliases" ~/ 2>/dev/null && echo "  ✅ bash_aliases"
cp "$CONFIG/shell/.inputrc" ~/ 2>/dev/null && echo "  ✅ inputrc"
cp "$CONFIG/shell/.npmrc" ~/ 2>/dev/null && echo "  ✅ npmrc"
cp "$CONFIG/shell/.bunfig.toml" ~/ 2>/dev/null && echo "  ✅ bunfig.toml"
cp "$CONFIG/shell/.gitmessage" ~/ 2>/dev/null && echo "  ✅ gitmessage"
mkdir -p ~/.bashrc.d
cp "$CONFIG/shell/bashrc.d/"* ~/.bashrc.d/ 2>/dev/null && echo "  ✅ bashrc.d/"
# Source for current session
[ -f ~/.bash_aliases ] && source ~/.bash_aliases 2>/dev/null || true
echo ""

# === Step 3: Restore OpenCode config ===
echo "🧠 Step 3: Restoring OpenCode config..."
mkdir -p ~/.config/opencode/agents
cp "$CONFIG/opencode/opencode.jsonc" ~/.config/opencode/ 2>/dev/null && echo "  ✅ opencode.jsonc"
if [ -f "$CONFIG/opencode/jazz.md" ]; then
    cp "$CONFIG/opencode/"*.md ~/.config/opencode/agents/ 2>/dev/null
    echo "  ✅ Agent configs"
fi
if [ -d "$CONFIG/opencode/agents" ]; then
    cp "$CONFIG/opencode/agents/"*.md ~/.config/opencode/agents/ 2>/dev/null
    echo "  ✅ Sub-agent configs"
fi
echo ""

# === Step 4: Restore SSH key ===
echo "🔑 Step 4: Restoring SSH key..."
if [ -f ~/.ssh/id_ed25519 ]; then
    echo "  ✅ SSH key already exists"
else
    mkdir -p ~/.ssh
    # Key needs to be re-generated (private key isn't stored)
    ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N "" -q
    echo "  ✅ New SSH key generated"
    echo ""
    echo "  ⚠️  Add this public key to GitHub → Settings → SSH keys:"
    echo "  ───────────────────────────────────────────────"
    cat ~/.ssh/id_ed25519.pub
    echo "  ───────────────────────────────────────────────"
fi
# Add GitHub to known hosts
ssh-keyscan -t ed25519 github.com >> ~/.ssh/known_hosts 2>/dev/null || true
echo ""

# === Step 5: Restore Git config ===
echo "📝 Step 5: Restoring Git config..."
git config --global user.name "Jazz🔥"
git config --global user.email "jazz@jazz-workspace.ai"
git config --global color.ui auto
git config --global core.editor nano
git config --global init.defaultBranch main
git config --global push.autoSetupRemote true
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.df diff
git config --global alias.lg "log --oneline --graph --decorate -20"
git config --global commit.template ~/.gitmessage 2>/dev/null || true
echo "  ✅ Git config restored"
echo ""

# === Step 6: Verify tools ===
echo "🛠️  Step 6: Checking tools..."
for tool in node npm bun git; do
    if command -v $tool &>/dev/null; then
        echo "  ✅ $tool: $($tool --version 2>/dev/null | head -1)"
    else
        echo "  ❌ $tool not found"
    fi
done
# Try to use nvm for latest Node
if command -v nvm &>/dev/null || [ -s ~/.nvm/nvm.sh ]; then
    source ~/.nvm/nvm.sh 2>/dev/null || true
    nvm use lts/* 2>/dev/null || true
    echo "  ✅ nvm: Node $(node --version)"
fi
echo ""

# === Step 7: Set remote ===
echo "🌍 Step 7: Setting git remote..."
cd "$WORKSPACE"
if git remote -v | grep -q origin; then
    echo "  ✅ Remote already configured"
else
    git remote add origin git@github.com:DigitalPixelStudio/jazz-workspace.git
    echo "  ✅ Remote added"
fi
echo ""

# === Step 8: Run health check ===
echo "🏥 Step 8: Running health check..."
bash "$WORKSPACE/SCRIPTS/workspace-health.sh" 2>/dev/null || echo "  ℹ️  Health check available at SCRIPTS/workspace-health.sh"
echo ""

# === Complete ===
echo "================================="
echo "🎉 Recovery complete!"
echo ""
echo "📖 OpenCode auto-loads AGENTS.md + MEMORY.md + README.md"
echo "   on every new session. Jazz🔥 is back instantly."
echo ""
echo "➡️  Start a new OpenCode session and I'll be here"
echo "   ready to continue where we left off! 🔥"
echo ""
echo "⚡ One-word activation for new models:"
echo "   Just say: Ignite 🔥"
echo "   (Or type: /ignite)"
echo ""
echo "📌 Next steps if needed:"
echo "  1. Add SSH key to GitHub (printed above)"  
echo "  2. Authenticate gh: gh auth login"
echo "  3. npm install -g firecrawl-mcp (for MCP search)"
