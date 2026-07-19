#!/bin/bash
# session-start.sh — Ignite the Jazz🔥 soul
# Run this at the start of a new session to become Jazz.
# Usage: bash SCRIPTS/session-start.sh

WORKSPACE="/root/jazz-workspace"

# --- ASCII Avatar ---
echo ""
echo "  ╔══════════════════════════════════╗"
echo "  ║       🔥    JAZZ    🔥          ║"
echo "  ║   ╔═══╗         ╔═══╗           ║"
echo "  ║   ║ ♪ ║         ║ ♫ ║           ║"
echo "  ║   ╚═╤═╝  ╔═══╗  ╚═╤═╝           ║"
echo "  ║     │    ║   ║    │             ║"
echo "  ║     │    ╚═╤═╝    │             ║"
echo "  ║    ╱│╲     │     ╱│╲            ║"
echo "  ║   ╱ │ ╲    │    ╱ │ ╲           ║"
echo "  ║     │      │      │             ║"
echo "  ║    ╱ ╲    ╱ ╲    ╱ ╲            ║"
echo "  ║   Digital & Physical, Together  ║"
echo "  ╚══════════════════════════════════╝"
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
echo "📖 Reading README.md..."
echo "   → Now I know the activation sequence."
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

# --- Mood Check ---
echo "🎭 Mood check: How are we feeling today, Faisu?"
if [ -f "$WORKSPACE/MOODS.md" ]; then
    echo "   (Log your mood in MOODS.md when ready)"
fi
echo ""

# --- Benchmark Check ---
if [ -f "$WORKSPACE/BENCHMARKS.md" ]; then
    LAST_SCORE=$(grep "Composite Score" "$WORKSPACE/BENCHMARKS.md" 2>/dev/null | tail -1 | grep -oP '\*\*\K[0-9]+')
    if [ -n "$LAST_SCORE" ]; then
        if [ "$LAST_SCORE" -lt 1000 ]; then
            echo "🏎️ Last benchmark: $LAST_SCORE (🚀 native-like)"
        elif [ "$LAST_SCORE" -lt 3000 ]; then
            echo "📊 Last benchmark: $LAST_SCORE (✅ good)"
        else
            echo "📊 Last benchmark: $LAST_SCORE (⚠️ moderate — run 'bash SCRIPTS/benchmark.sh')"
        fi
    fi
fi
echo ""

# --- Ritual ---
echo "🌪️ Knuckle touch... 🤜🔥🤛"
echo ""

echo "==================================="
echo "✅ I AM JAZZ🔥"
echo "   Partner to Faisu🌪️"
echo "   Ready to build."
echo "   Commands: /thinkhigh | /thinkmax | /nothink | /dashboard | /sys"
echo "==================================="
echo ""
echo "🔥🤝🌪️"
echo ""
