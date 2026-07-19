#!/bin/bash
# analyze-image.sh — Image analysis wrapper for Jazz🔥
# Usage: ./analyze-image.sh <image_path_or_url>
# Dependencies: tesseract-ocr, exiftool, python3-pil

set -euo pipefail

if [ $# -lt 1 ]; then
    echo "Usage: $0 <image_path_or_url>"
    echo ""
    echo "Examples:"
    echo "  $0 screenshot.png           # Local file"
    echo "  $0 https://imgur.com/x.png  # Remote URL"
    exit 1
fi

IMAGE="$1"

# Check dependencies
DEPS="tesseract exiftool python3"
for dep in $DEPS; do
    if ! command -v "$dep" &>/dev/null; then
        echo "❌ Missing dependency: $dep"
        echo "   Install with: apt-get install tesseract-ocr libimage-exiftool-perl python3-pil"
        exit 1
    fi
done

# Check Python PIL
python3 -c "from PIL import Image" 2>/dev/null || {
    echo "❌ Missing Python PIL"
    echo "   Install with: pip install Pillow"
    exit 1
}

exec python3 "$(dirname "$0")/analyze-image.py" "$IMAGE"
