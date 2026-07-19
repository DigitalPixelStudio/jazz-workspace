#!/bin/bash
# session-restore.sh — Restore workspace state from a backup
# Usage: ./session-restore.sh [backup-file]
#   Without args, lists available backups

WORKSPACE="/root/jazz-workspace"
BACKUP_DIR="/root/workspace-backups"

if [ $# -eq 0 ]; then
    echo "Available backups:"
    echo "------------------"
    if ls -1t "$BACKUP_DIR"/jazz-workspace-*.tar.gz &>/dev/null; then
        ls -1t "$BACKUP_DIR"/jazz-workspace-*.tar.gz | while read -r b; do
            SIZE=$(du -h "$b" | cut -f1)
            echo "  $(basename "$b")  ($SIZE)"
        done
    else
        echo "  (no backups found)"
    fi
    echo ""
    echo "Usage: $0 <backup-file>"
    exit 0
fi

BACKUP_FILE="$1"
if [ ! -f "$BACKUP_FILE" ]; then
    # Check if it's just a filename in the backup dir
    if [ -f "$BACKUP_DIR/$BACKUP_FILE" ]; then
        BACKUP_FILE="$BACKUP_DIR/$BACKUP_FILE"
    else
        echo "Backup not found: $1"
        exit 1
    fi
fi

echo "Restoring from: $BACKUP_FILE"
echo "  Size: $(du -h "$BACKUP_FILE" | cut -f1)"
echo ""
echo "This will overwrite current workspace files."
echo "Current workspace will be backed up first."
echo ""

# Backup current state first
CURRENT_BACKUP="$BACKUP_DIR/pre-restore-$(date +%Y%m%d-%H%M%S).tar.gz"
tar -czf "$CURRENT_BACKUP" -C "$(dirname "$WORKSPACE")" "$(basename "$WORKSPACE")" 2>/dev/null
echo "Current state saved to: $(basename "$CURRENT_BACKUP")"

# Extract backup
tar -xzf "$BACKUP_FILE" -C "$(dirname "$WORKSPACE")"
echo "Restore complete."
