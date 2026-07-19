#!/usr/bin/env python3
"""
analyze-image.py — Image analyzer for Jazz🔥
Extracts text (OCR), metadata, colors, layout, ASCII preview.

Usage:
  python3 analyze-image.py <image-path>         # local file
  python3 analyze-image.py <url>                # download + analyze
  python3 analyze-image.py -                    # read base64 from stdin
"""

import sys
import os
import json
import subprocess
import tempfile
import urllib.request
import base64
from io import BytesIO

try:
    from PIL import Image
except ImportError:
    print("❌ Pillow not installed. Run: pip3 install Pillow")
    sys.exit(1)


def extract_text(path):
    """OCR via tesseract"""
    try:
        result = subprocess.run(
            ["tesseract", path, "stdout", "--psm", "6"],
            capture_output=True, text=True, timeout=30
        )
        text = result.stdout.strip()
        if text:
            return text
        # Try different PSM modes
        result = subprocess.run(
            ["tesseract", path, "stdout", "--psm", "3"],
            capture_output=True, text=True, timeout=30
        )
        return result.stdout.strip()
    except Exception as e:
        return f"[OCR error: {e}]"


def extract_metadata(path):
    """EXIF/metadata via exiftool"""
    try:
        result = subprocess.run(
            ["exiftool", "-json", path],
            capture_output=True, text=True, timeout=10
        )
        if result.stdout:
            data = json.loads(result.stdout)
            if data:
                return data[0]
    except Exception as e:
        return {"error": str(e)}
    return {}


def get_image_info(path):
    """Basic image info via Pillow"""
    img = Image.open(path)
    info = {
        "format": img.format,
        "mode": img.mode,
        "width": img.width,
        "height": img.height,
        "aspect_ratio": round(img.width / img.height, 4) if img.height else 0,
        "megapixels": round(img.width * img.height / 1_000_000, 2),
    }
    
    # File size
    if os.path.exists(path):
        info["file_size_bytes"] = os.path.getsize(path)
        info["file_size_kb"] = round(info["file_size_bytes"] / 1024, 1)
    
    # Color analysis (sample for speed)
    try:
        if img.mode in ("RGB", "RGBA"):
            small = img.copy()
            small.thumbnail((100, 100))
            pixels = list(small.getdata() if hasattr(small, 'getdata') else small.get_flattened_data())
            # Average color
            r, g, b = 0, 0, 0
            count = len(pixels)
            for px in pixels:
                r += px[0]
                g += px[1]
                b += px[2]
            info["avg_color"] = f"rgb({r//count}, {g//count}, {b//count})"
            
            # Color palette (quantized)
            if count > 10:
                pal = small.quantize(colors=8)
                info["palette_colors"] = pal.getpalette()[:24]  # 8 colors × 3
    except Exception:
        pass
    
    return info


def ascii_art(path, width=80):
    """Generate ASCII art preview"""
    try:
        img = Image.open(path)
        aspect = img.width / img.height
        height = int(width / aspect * 0.5)  # terminal char aspect
        small = img.resize((width, height))
        small = small.convert("L")  # grayscale
        
        chars = " .:-=+*#%@"
        pixels = list(small.getdata() if hasattr(small, 'getdata') else small.get_flattened_data())
        art_lines = []
        for y in range(height):
            line = ""
            for x in range(width):
                idx = pixels[y * width + x] * len(chars) // 256
                line += chars[min(idx, len(chars) - 1)]
            art_lines.append(line)
        return "\n".join(art_lines)
    except Exception as e:
        return f"[ASCII error: {e}]"


def get_image(path_or_url):
    """Get image path from various inputs"""
    if path_or_url == "-":
        # Read base64 from stdin
        data = sys.stdin.read().strip()
        if "," in data:
            data = data.split(",", 1)[1]  # strip data:image/png;base64,
        try:
            img_data = base64.b64decode(data)
        except Exception:
            img_data = base64.b64decode(data + "==")
        tmp = tempfile.NamedTemporaryFile(delete=False, suffix=".png")
        tmp.write(img_data)
        tmp.close()
        return tmp.name
    
    # URL?
    if path_or_url.startswith(("http://", "https://")):
        print(f"  ↓ Downloading {path_or_url[:60]}...")
        tmp = tempfile.NamedTemporaryFile(delete=False, suffix=".png")
        urllib.request.urlretrieve(path_or_url, tmp.name)
        return tmp.name
    
    # Local file
    if os.path.exists(path_or_url):
        return path_or_url
    
    return path_or_url  # raw string


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)
    
    if sys.argv[1] in ("--help", "-h"):
        print(__doc__)
        sys.exit(0)
    
    source = sys.argv[1]
    path = get_image(source)
    
    print("\n" + "=" * 60)
    print("  🔍 IMAGE ANALYSIS by Jazz🔥")
    print("=" * 60)
    
    # 1. Basic info
    print("\n📐 Basic Info:")
    info = get_image_info(path)
    for k, v in info.items():
        print(f"  • {k}: {v}")
    
    # 2. Metadata
    print("\n🏷️  Metadata:")
    meta = extract_metadata(path)
    if meta:
        interesting = [
            "DeviceModelName", "Model", "Make", "Software",
            "CreateDate", "DateTimeOriginal", "GPSLatitude", "GPSLongitude",
            "ImageWidth", "ImageHeight", "XResolution", "Software",
            "Artist", "Copyright", "UserComment", "Description"
        ]
        for key in interesting:
            if key in meta and meta[key]:
                print(f"  • {key}: {meta[key]}")
        if "error" in meta:
            print(f"  • {meta['error']}")
    else:
        print("  • No metadata found")
    
    # 3. OCR text
    print("\n📝 Text Found (OCR):")
    text = extract_text(path)
    if text:
        for line in text.split("\n"):
            print(f"  {line}")
    else:
        print("  • No text detected in image")
    
    # 4. ASCII preview
    print("\n🎨 ASCII Preview:")
    art = ascii_art(path)
    print(art)
    
    # Cleanup temp files
    if source in ("-",) or source.startswith(("http://", "https://")):
        os.unlink(path)
    
    print("\n" + "=" * 60)


if __name__ == "__main__":
    main()
