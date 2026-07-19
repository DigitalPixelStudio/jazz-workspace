#!/bin/bash
# workspace-health.sh — Full health, connectivity, and tool check
# Usage: ./workspace-health.sh

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
PASS="${GREEN}✅${NC}"
FAIL="${RED}❌${NC}"
WARN="${YELLOW}⚠️${NC}"

echo "Jazz🔥 Workspace Health Report"
echo "============================="
echo ""

# --- System ---
echo "System:"
echo "  Host: $(hostname)"
UPTIME=$(uptime -p 2>/dev/null | sed 's/up //') || UPTIME="N/A"
echo "  Uptime: $UPTIME"
echo "  Disk: $(df -h / | awk 'NR==2 {print $3 " used / " $2 " (" $5 ")"}')"
echo "  Memory: $(free -h | awk '/Mem:/ {print $3 " used / " $2}')"
LOAD=$(uptime 2>/dev/null | awk -F'load average:' '{print $2}' | xargs) || LOAD="N/A"
echo "  Load: $LOAD"
echo ""

# --- Core Tools ---
echo "Core Tools:"
for tool in git bash tar curl; do
  if command -v $tool &>/dev/null; then
    echo -e "  $PASS $tool"
  else
    echo -e "  $FAIL $tool"
  fi
done
echo ""

# --- Dev Tools (required vs optional) ---
echo "Dev Tools:"
for tool in node npm bun python3; do
  if command -v $tool &>/dev/null; then
    echo -e "  $PASS $tool"
  else
    echo -e "  $FAIL $tool"
  fi
done
# Optional tools (not critical for workflow)
for tool in docker rustc go; do
  if command -v $tool &>/dev/null; then
    echo -e "  $PASS $tool"
  else
    echo -e "  $WARN $tool (optional)"
  fi
done
# Docker compose check
if docker compose version &>/dev/null || docker-compose --version &>/dev/null; then
  echo -e "  $PASS docker compose"
else
  echo -e "  $WARN docker compose (optional)"
fi
echo ""

# --- IPv4 Config ---
echo "IPv4 Force:"
if grep -q "ipv4\|IP_VERSION=4\|ForceIPv4" /root/.curlrc /root/.bash_aliases /etc/apt/apt.conf.d/99force-ipv4 2>/dev/null; then
  echo -e "  $PASS IPv4 forced (curl, git, apt all prefer IPv4)"
else
  echo -e "  $WARN IPv4 not forced — HTTPS may be slow"
fi
echo ""

# --- Network ---
echo "Network Connectivity:"
timeout=10
pids=""
hosts="github.com registry.npmjs.org"
for host in $hosts; do
  (curl -s --max-time $timeout -o /dev/null -w "%{http_code}" "https://$host" &>/dev/null && echo -e "  $PASS $host" || echo -e "  $WARN $host (slow/unreachable from container)") &
  pids="$pids $!"
done
wait $pids 2>/dev/null
echo "  ℹ HTTPS now fast — IPv4 forced. SSH/22 works for git pushes."
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
  # Check remote and unpushed
  if git remote get-url origin &>/dev/null; then
    UPSTREAM="@{upstream}"
    UNPUSHED=$(git log $UPSTREAM..HEAD 2>/dev/null | grep -c '^commit') || UNPUSHED=0
    echo "  Unpushed commits: $UNPUSHED"
  else
    echo "  Unpushed commits: 0 (no remote)"
  fi
else
  echo -e "  $FAIL not a git repository"
fi
echo ""

# --- Backups ---
echo "Backups:"
BACKUP_COUNT=$(ls -1 "/root/Digital Pixel Studio"/jazz-workspace-*.tar.gz 2>/dev/null | wc -l)
if [ "$BACKUP_COUNT" -gt 0 ]; then
  LATEST=$(ls -1t "/root/Digital Pixel Studio"/jazz-workspace-*.tar.gz 2>/dev/null | head -1)
  echo -e "  $PASS $BACKUP_COUNT backup(s) available"
  echo "  Latest: $(basename "$LATEST") ($(du -h "$LATEST" | cut -f1))"
else
  echo -e "  $WARN no backups found"
fi
echo ""

echo "============================="
echo "Report complete."
