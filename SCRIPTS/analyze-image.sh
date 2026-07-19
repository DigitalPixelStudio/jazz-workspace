#!/bin/bash
# analyze-image.sh — Easy wrapper for analyze-image.py
# Usage:
#   analyze-image.sh screenshot.png        # local file
#   analyze-image.sh https://imgur.com/x   # URL
#   analyze-image.sh                       # paste base64
#   analyze-image.sh --help

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PYTHON_SCRIPT="$SCRIPT_DIR/analyze-image.py"

if [ ! -f "$PYTHON_SCRIPT" ]; then
    echo "❌ analyze-image.py not found at $PYTHON_SCRIPT"
    exit 1
fi

case "$1" in
    ""|"-")
        echo "📸 Paste base64 image data (CTRL+D when done):"
        python3 "$PYTHON_SCRIPT" -
        ;;
    --help|-h)
        echo "Analyze an image with OCR + metadata + ASCII preview"
        echo ""
        echo "  analyze-image.sh image.png    # local file"
        echo "  analyze-image.sh https://...  # URL"
        echo "  analyze-image.sh              # paste base64"
        echo "  analyze-image.sh --help       # this help"
        ;;
    *)
        python3 "$PYTHON_SCRIPT" "$1"
        ;;
esac
