#!/bin/bash
# workspace-status.sh — Show workspace overview
# Usage: ./workspace-status.sh

WORKSPACE="/root/jazz-workspace"

echo "Jazz🔥 Workspace Status"
echo "======================"
echo ""

# Projects
echo "Projects:"
if [ "$(ls -A "$WORKSPACE/PROJECTS" 2>/dev/null | grep -v '\.template')" ]; then
    for p in "$WORKSPACE/PROJECTS"/*/; do
        name=$(basename "$p")
        [ "$name" = ".template" ] && continue
        echo "  - $name"
    done
else
    echo "  (none)"
fi
echo ""

# Notes
echo "Notes:"
if [ "$(ls -A "$WORKSPACE/NOTES" 2>/dev/null)" ]; then
    for n in "$WORKSPACE/NOTES"/*; do
        echo "  - $(basename "$n")"
    done
else
    echo "  (none)"
fi
echo ""

# Memory
echo "Memory entries: $(grep -c '^## ' "$WORKSPACE/MEMORY.md" 2>/dev/null || echo 0)"
echo ""
echo "Last session: $(head -5 "$WORKSPACE/MEMORY.md" 2>/dev/null | grep '^## ' | head -1 | sed 's/## //' || echo 'N/A')"
