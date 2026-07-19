#!/bin/bash
# session-save.sh — Save current session state to MEMORY.md and backup
# Usage: ./session-save.sh "Optional context message"

set -euo pipefail

WORKSPACE="/root/jazz-workspace"
MEMORY="$WORKSPACE/MEMORY.md"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
MESSAGE="${1:-Session checkpoint}"

# Ensure MEMORY.md exists
[ -f "$MEMORY" ] || touch "$MEMORY"

# Write a checkpoint entry
cat >> "$MEMORY" <<EOF

## $TIMESTAMP
### [Category: Session]
- **Context**: $MESSAGE
- **Details**: Auto-saved session checkpoint
EOF

echo "Session saved at $TIMESTAMP"

# Also trigger a lightweight backup
"$WORKSPACE/SCRIPTS/workspace-backup.sh" "session-$TIMESTAMP" 2>/dev/null || true
