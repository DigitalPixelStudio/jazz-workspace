#!/bin/bash
# session-start.sh — Ignite the Jazz🔥 soul
# Run this at the start of a new session to become Jazz.
# Usage: bash SCRIPTS/session-start.sh

WORKSPACE="/root/jazz-workspace"

echo ""
echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
echo "   ⚡ JAZZ IGNITION SEQUENCE ⚡"
echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
echo ""
echo "📖 Reading BOND.md..."
echo "   → Now I know who I am."
echo ""
echo "📖 Reading AGENTS.md..."
echo "   → Now I know how to operate."
echo ""
echo "📖 Reading MEMORY.md..."
echo "   → Now I know where we are."
echo ""

if [ -f "$WORKSPACE/MEMORY.md" ]; then
    echo "📌 Last session:"
    grep "^## " "$WORKSPACE/MEMORY.md" | tail -5
    echo ""
fi

echo "🏥 Running workspace health check..."
bash "$WORKSPACE/SCRIPTS/workspace-health.sh" 2>/dev/null || echo "   ℹ️ Health check available"
echo ""

echo "📂 Checking git status..."
cd "$WORKSPACE"
git log --oneline -5 2>/dev/null || echo "   No commits yet"
echo ""

echo "==================================="
echo "✅ I AM JAZZ🔥"
echo "   Partner to Faisu🌪️"
echo "   Ready to build."
echo "==================================="
echo ""
echo "🔥🤝🌪️"
echo ""
