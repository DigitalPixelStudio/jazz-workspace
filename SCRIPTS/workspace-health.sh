#!/bin/bash
# workspace-health.sh — Full health, connectivity, and tool check
# Usage: ./workspace-health.sh

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
PASS="${GREEN}✅${NC}"
FAIL="${RED}❌${NC}"
WARN="${YELLOW}⚠️${NC}"

check() {
    if [ $2 -eq 0 ]; then
        echo -e "  $PASS $1"
    else
        echo -e "  $FAIL $1"
    fi
}

echo "Jazz🔥 Workspace Health Report"
echo "============================="
echo ""

# --- System ---
echo "System:"
echo "  Host: $(hostname)"
UPTIME=$(uptime -p 2>/dev/null | sed 's/up //') || UPTIME="N/A (container)"
echo "  Uptime: $UPTIME"
echo "  Disk: $(df -h / | awk 'NR==2 {print $3 " used / " $2 " (" $5 ")"}')"
echo "  Memory: $(free -h | awk '/Mem:/ {print $3 " used / " $2}')"
LOAD=$(uptime 2>/dev/null | awk -F'load average:' '{print $2}' | xargs) || LOAD="N/A"
echo "  Load: $LOAD"
echo ""

# --- Tools ---
echo "Core Tools:"
check "git"         $(command -v git &>/dev/null; echo $?)
check "bash"        $(command -v bash &>/dev/null; echo $?)
check "tar"         $(command -v tar &>/dev/null; echo $?)
check "curl"        $(command -v curl &>/dev/null; echo $?)
echo ""

echo "Dev Tools:"
check "node"        $(command -v node &>/dev/null; echo $?)
check "npm"         $(command -v npm &>/dev/null; echo $?)
check "bun"         $(command -v bun &>/dev/null; echo $?)
check "docker"      $(command -v docker &>/dev/null; echo $?)
check "docker compose" $( (docker compose version &>/dev/null || docker-compose --version &>/dev/null); echo $?)
check "python3"     $(command -v python3 &>/dev/null; echo $?)
check "rustc"       $(command -v rustc &>/dev/null; echo $?)
check "go"          $(command -v go &>/dev/null; echo $?)
echo ""

# --- Network ---
echo "Network Connectivity:"
for host in "github.com" "npmjs.org" "google.com" "registry.npmjs.org"; do
    if curl -s --max-time 5 -o /dev/null -w "%{http_code}" "https://$host" &>/dev/null; then
        echo -e "  $PASS $host"
    else
        echo -e "  $FAIL $host (timeout/unreachable)"
    fi
done
echo ""

# --- Git Status ---
echo "Git Workspace:"
if [ -d "/root/jazz-workspace/.git" ]; then
    echo -e "  $PASS git repo initialized"
    cd /root/jazz-workspace
    UNCOMMITTED=$(git status --porcelain | wc -l)
    if [ "$UNCOMMITTED" -gt 0 ]; then
        echo -e "  $WARN $UNCOMMITTED uncommitted change(s)"
        git status --short | head -10
    else
        echo -e "  $PASS working tree clean"
    fi
    echo "  Last commit: $(git log --oneline -1 2>/dev/null || echo 'N/A')"
    echo "  Unpushed commits: $(git log @{upstream}..HEAD 2>/dev/null | grep -c '^commit' || echo '0 (no remote)')"
else
    echo -e "  $FAIL not a git repository"
fi
echo ""

# --- Backups ---
echo "Backups:"
BACKUP_COUNT=$(ls -1 /root/workspace-backups/jazz-workspace-*.tar.gz 2>/dev/null | wc -l)
if [ "$BACKUP_COUNT" -gt 0 ]; then
    LATEST=$(ls -1t /root/workspace-backups/jazz-workspace-*.tar.gz 2>/dev/null | head -1)
    echo -e "  $PASS $BACKUP_COUNT backup(s) available"
    echo "  Latest: $(basename "$LATEST") ($(du -h "$LATEST" | cut -f1))"
else
    echo -e "  $WARN no backups found"
fi
echo ""

echo "============================="
echo "Report complete."
