# ========================================
# Jazz🔥 Dev Aliases
# ========================================

# ---- Navigation ----
alias ws='cd /root/jazz-workspace'
alias projects='cd /root/jazz-workspace/PROJECTS'
alias scripts='cd /root/jazz-workspace/SCRIPTS'

# ---- Project Management ----
alias new-project='bash /root/jazz-workspace/SCRIPTS/new-project.sh'
alias ws-status='bash /root/jazz-workspace/SCRIPTS/workspace-status.sh'
alias ws-health='bash /root/jazz-workspace/SCRIPTS/workspace-health.sh'
alias ws-backup='bash /root/jazz-workspace/SCRIPTS/workspace-backup.sh'
alias session-save='bash /root/jazz-workspace/SCRIPTS/session-save.sh'

# ---- Git ----
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gcm='git commit -m'
alias gp='git push'
alias gpl='git pull'
alias gl='git log --oneline --graph --decorate -20'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias gr='git remote -v'
alias undo='git reset --soft HEAD~1'

# ---- Shell ----
alias ll='ls -alF --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias h='history'

# ---- Search (using ripgrep + fd) ----
alias rg='rg --smart-case --hidden'
alias rgf='rg --files | rg'  # Search file names
alias fd='fdfind'  # fd-find uses this name on Debian

# ---- Dev Tools ----
alias ni='npm install'
alias nid='npm install --save-dev'
alias nr='npm run'
alias nb='npm run build'
alias nd='npm run dev'
alias nt='npm run test'
alias bi='bun install'
alias ba='bun add'
alias bad='bun add -d'
alias br='bun run'
alias bb='bun run build'
alias bd='bun run dev'
alias bt='bun run test'
alias ts='npx tsx'
alias lint='npx eslint .'
alias fmt='npx prettier --write .'

# ---- Node ----
alias node-latest='nvm install --lts'
alias node-use='nvm use'

# ---- Python ----
alias py='python3'
alias pi='pip3 install'

# ---- Workspace ----
alias mem='cat /root/jazz-workspace/MEMORY.md'
alias agents='cat /root/jazz-workspace/AGENTS.md'

# ---- Screen ----
alias tmux-new='tmux new -s'
alias tmux-attach='tmux attach -t'
