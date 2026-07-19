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
sed -i "s/{{PROJECT_NAME}}/$NAME/g" "$TARGET/README.md" "$TARGET/NOTES.md"
sed -i "s/{{PROJECT_DESCRIPTION}}/$DESC/g" "$TARGET/README.md"
sed -i "s/{{DATE}}/$DATE/g" "$TARGET/NOTES.md"

echo "Created project: $NAME"
echo "  Location: $TARGET"
echo "  Description: $DESC"
