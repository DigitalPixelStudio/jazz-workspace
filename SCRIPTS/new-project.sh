#!/bin/bash
# new-project.sh — Scaffold a new Jazz🔥 project
# Usage: ./new-project.sh <project-name> ["description"]

set -euo pipefail

WORKSPACE="/root/jazz-workspace"
TEMPLATE="$WORKSPACE/PROJECTS/.template"
NAME="${1:?Usage: new-project.sh <project-name> [description]}"
DESC="${2:-No description yet}"
DATE=$(date +%Y-%m-%d)
TARGET="$WORKSPACE/PROJECTS/$NAME"

if [ -d "$TARGET" ]; then
    echo "Project '$NAME' already exists at $TARGET"
    exit 1
fi

cp -r "$TEMPLATE" "$TARGET"

# Fill in template vars
for f in "$TARGET/README.md" "$TARGET/NOTES.md" "$TARGET/devcontainer.json"; do
    [ -f "$f" ] && sed -i "s/{{PROJECT_NAME}}/$NAME/g" "$f"
done
sed -i "s/{{PROJECT_DESCRIPTION}}/$DESC/g" "$TARGET/README.md"
sed -i "s/{{DATE}}/$DATE/g" "$TARGET/NOTES.md"

# Init git for the new project
cd "$TARGET" && git init && git add -A && git commit -q -m "Initial commit: $NAME" 2>/dev/null || true

echo "Created project: $NAME"
echo "  Location: $TARGET"
echo "  Description: $DESC"
echo "  Docker: docker compose up -d (optional)"
