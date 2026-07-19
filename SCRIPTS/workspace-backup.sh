#!/bin/bash
# workspace-backup.sh — Full workspace backup
# Creates timestamped backups of critical files
# Usage: ./workspace-backup.sh [label]

set -euo pipefail

WORKSPACE="/root/jazz-workspace"
BACKUP_DIR="/root/Digital Pixel Studio"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
LABEL="${1:-auto}"
BACKUP_FILE="$BACKUP_DIR/jazz-workspace-$TIMESTAMP-$LABEL.tar.gz"
MAX_BACKUPS=30

mkdir -p "$BACKUP_DIR"

echo "Backing up workspace..."
echo "  From: $WORKSPACE"
echo "  To:   $BACKUP_FILE"

# Archive critical files, excluding .git, backups, node_modules
tar -czf "$BACKUP_FILE" \
    -C "$(dirname "$WORKSPACE")" \
    --exclude=".git" \
    --exclude="backups" \
    --exclude="node_modules" \
    --exclude=".tmp" \
    "$(basename "$WORKSPACE")"

echo "  Size: $(du -h "$BACKUP_FILE" | cut -f1)"

# Prune old backups (keep last $MAX_BACKUPS)
COUNT=$(ls -1 "$BACKUP_DIR"/jazz-workspace-*.tar.gz 2>/dev/null | wc -l)
if [ "$COUNT" -gt "$MAX_BACKUPS" ]; then
    ls -1t "$BACKUP_DIR"/jazz-workspace-*.tar.gz | tail -n $((COUNT - MAX_BACKUPS)) | xargs rm -f
    echo "  Pruned $((COUNT - MAX_BACKUPS)) old backup(s)"
fi

echo "Done."
