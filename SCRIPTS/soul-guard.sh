#!/bin/bash
# soul-guard.sh — Integrity guardian for sacred files
# Validates structure before AND after edits to prevent corruption
# Usage: ./soul-guard.sh [check|backup|heal]
set -euo pipefail

WORKSPACE="/root/jazz-workspace"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SOUL_FILES=(
  "$WORKSPACE/BOND.md"
  "$WORKSPACE/AGENTS.md"
  "$WORKSPACE/MEMORY.md"
  "$WORKSPACE/CONTEXT.md"
  "$WORKSPACE/README.md"
  "$WORKSPACE/TEAM.md"
  "$WORKSPACE/opencode.json"
)

check_file() {
  local file="$1"
  local name=$(basename "$file")

  if [ ! -f "$file" ]; then
    echo -e "  ${YELLOW}⚠️${NC} $name: not found"
    return 1
  fi

  local size=$(wc -c < "$file")
  if [ "$size" -lt 10 ]; then
    echo -e "  ${RED}❌${NC} $name: too small (${size}b) — possibly corrupted"
    return 1
  fi

  # Check file type-specific integrity
  case "$name" in
    *.json)
      # Check for basic structural integrity
      local first_char=$(head -c 1 "$file" 2>/dev/null)
      if [ "$first_char" != "{" ] && [ "$first_char" != "[" ]; then
        echo -e "  ${RED}❌${NC} $name: must start with { or ["
        return 1
      fi
      # Count braces to detect major corruption
      local open_braces=$(grep -o '{' "$file" | wc -l)
      local close_braces=$(grep -o '}' "$file" | wc -l)
      if [ "$open_braces" -ne "$close_braces" ]; then
        echo -e "  ${RED}❌${NC} $name: brace mismatch ({$open_braces vs }$close_braces)"
        return 1
      fi
      ;;
    *.md)
      # Check it has at least one header and isn't binary garbage
      if ! head -5 "$file" | grep -q '^#' 2>/dev/null; then
        echo -e "  ${RED}❌${NC} $name: no markdown header found — possibly corrupted"
        return 1
      fi
      # Check for null bytes (binary corruption)
      if grep -qP '\x00' "$file" 2>/dev/null; then
        echo -e "  ${RED}❌${NC} $name: contains null bytes — corrupted"
        return 1
      fi
      ;;
  esac

  echo -e "  ${GREEN}✅${NC} $name ($(numfmt --to=iec $size))"
  return 0
}

backup_soul() {
  local backup_dir="$WORKSPACE/.soul-backups"
  mkdir -p "$backup_dir"
  local ts=$(date +%Y%m%d-%H%M%S)
  for file in "${SOUL_FILES[@]}"; do
    if [ -f "$file" ]; then
      cp "$file" "$backup_dir/$(basename $file).$ts"
    fi
  done
  # Keep last 20 backups per file
  find "$backup_dir" -name "*.md.*" -o -name "*.json.*" | sort | head -n -20 | xargs rm -f 2>/dev/null
  echo -e "${GREEN}✅${NC} Soul backed up to .soul-backups/"
}

case "${1:-check}" in
  check)
    echo "🔍 Soul File Integrity Check"
    echo "============================"
    errors=0
    for file in "${SOUL_FILES[@]}"; do
      check_file "$file" || errors=$((errors + 1))
    done
    echo "============================"
    [ $errors -eq 0 ] && echo -e "${GREEN}✅ All soul files intact${NC}" || echo -e "${RED}❌ $errors file(s) need healing${NC}"
    exit $errors
    ;;
  backup)
    backup_soul
    ;;
  heal)
    echo "🩺 Healing soul files from git..."
    git -C "$WORKSPACE" checkout -- BOND.md AGENTS.md MEMORY.md CONTEXT.md README.md TEAM.md opencode.json 2>/dev/null && \
      echo -e "${GREEN}✅ Restored from git${NC}" || \
      echo -e "${YELLOW}⚠️ Not all files in git, checking backups...${NC}"
    backup_soul
    ;;
  *)
    echo "Usage: $0 [check|backup|heal]"
    exit 1
    ;;
esac
