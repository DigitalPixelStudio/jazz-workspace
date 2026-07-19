#!/bin/bash
# validate-config.sh — Check opencode config files for known schema issues
# Run before OpenCode starts to catch errors early
# Returns 0 if all configs valid, 1 if issues found

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

check_config() {
    local file="$1"
    local label="$2"

    if [ ! -f "$file" ]; then
        echo -e "  ${YELLOW}⚠️${NC} $label: not found (skipped)"
        return
    fi

    echo -e "  Checking $label..."

    # Check 1: formatter schema (v1.16.2+)
    # Old: "formatter": {"enabled": true, "command": [...]}
    # New: "formatter": {"prettier": {"command": [...]}}
    if grep -q '"enabled": true' "$file" 2>/dev/null && grep -q '"formatter"' "$file" 2>/dev/null; then
        # Verify it's actually the formatter field, not MCP
        local formatter_section
        formatter_section=$(grep -A5 '"formatter"' "$file" 2>/dev/null)
        if echo "$formatter_section" | grep -q '"enabled": true' 2>/dev/null; then
            echo -e "    ${RED}❌ FORMATTER SCHEMA${NC}: Has old format (enabled: true)"
            echo -e "    ${YELLOW}Fix:${NC} Change to {\"prettier\": {\"command\": [...]}}"
            ERRORS=$((ERRORS + 1))
        fi
    fi

    # Check 2: deprecated MCP servers
    if grep -q '@modelcontextprotocol/server-github' "$file" 2>/dev/null; then
        if grep -q '"enabled": true' "$file" 2>/dev/null; then
            echo -e "    ${YELLOW}⚠️ DEPRECATED MCP${NC}: @modelcontextprotocol/server-github is deprecated"
            echo -e "    ${YELLOW}Fix:${NC} Set \"enabled\": false or remove"
            WARNINGS=$((WARNINGS + 1))
        fi
    fi

    # Check 3: MCP timeout too low (< 20s)
    local timeouts
    timeouts=$(grep -o '"timeout": [0-9]*' "$file" 2>/dev/null | grep -o '[0-9]*' || true)
    for t in $timeouts; do
        if [ "$t" -lt 20000 ] 2>/dev/null; then
            echo -e "    ${YELLOW}⚠️ LOW TIMEOUT${NC}: ${t}ms — MCP servers may need 20-30s to start"
            WARNINGS=$((WARNINGS + 1))
            break
        fi
    done

    # Check 4: Basic structure (file not empty, has opening brace)
    if [ ! -s "$file" ]; then
        echo -e "    ${RED}❌ EMPTY FILE${NC}: $file is empty"
        ERRORS=$((ERRORS + 1))
    elif ! head -1 "$file" | grep -q '{' 2>/dev/null; then
        echo -e "    ${YELLOW}⚠️ FORMAT${NC}: $file doesn't start with {"
        WARNINGS=$((WARNINGS + 1))
    fi

    # Check 5: required fields
    if ! grep -q '"\$schema"' "$file" 2>/dev/null; then
        echo -e "    ${YELLOW}⚠️ MISSING \$schema${NC}: Config may not validate against schema"
        WARNINGS=$((WARNINGS + 1))
    fi

    echo -e "    ${GREEN}✅ $label passed${NC}"
}

echo "🔍 OpenCode Config Validator"
echo "============================"
echo ""

# Global config
check_config ~/.config/opencode/opencode.jsonc "Global config (~/.config/opencode/)"

# Project config
check_config ~/jazz-workspace/opencode.json "Project config (~/jazz-workspace/)"

# CONFIG backups
check_config ~/jazz-workspace/CONFIG/opencode/opencode.json "CONFIG backup (opencode.json)"
check_config ~/jazz-workspace/CONFIG/opencode/opencode.jsonc "CONFIG backup (opencode.jsonc)"

echo ""
echo "============================"
if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}❌ $ERRORS error(s), $WARNINGS warning(s)${NC}"
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}⚠️ 0 errors, $WARNINGS warning(s)${NC}"
    exit 0
else
    echo -e "${GREEN}✅ All configs valid!${NC}"
    exit 0
fi
