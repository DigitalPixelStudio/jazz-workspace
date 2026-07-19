#!/usr/bin/env python3
"""analyze-image.py — Extract everything from an image for Jazz🔥

Usage:
    python3 analyze-image.py <image_path>
    python3 analyze-image.py <image_url>

What it extracts:
    - OCR text via tesseract
    - EXIF metadata (device, camera, GPS, dates)
    - Image properties (dimensions, colors, format)
    - ASCII art preview
"""

import sys
import os
import json
import subprocess
import urllib.request
import tempfile

def download_image(url):
    """Download image from URL to temp file"""
    ext = url.split('.')[-1].split('?')[0][:4] if '.' in url else '.jpg'
    tmp = tempfile.NamedTemporaryFile(suffix=ext, delete=False)
    try:
        urllib.request.urlretrieve(url, tmp.name)
        return tmp.name
    except Exception as e:
        print(f"  ❌ Failed to download: {e}")
        sys.exit(1)

def run_cmd(cmd):
    """Run a command and return stdout"""
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
        return result.stdout.strip()
    except Exception as e:
        return f"[Error: {e}]"

def get_metadata(image_path):
    """Extract EXIF + file metadata"""
    print("\n📷 Metadata:")
    print("  ─────────────────────────────────────────")
    
    # File info
    stat = os.stat(image_path)
    size = stat.st_size
    if size > 1024*1024:
        size_str = f"{size/(1024*1024):.1f} MB"
    else:
        size_str = f"{size/1024:.1f} KB"
    print(f"  Size:     {size_str}")
    
    # exiftool output
    exif = run_cmd(["exiftool", "-json", image_path])
    if exif and exif != "[Error: ]":
        try:
            data = json.loads(exif)
            if data:
                interesting = [
                    ("Device", "Device Model Name"),
                    ("Make", "Make"),
                    ("Model", "Model"),
                    ("Software", "Software"),
                    ("Date/Time", "Date/Time Original"),
                    ("GPS", "GPS Position"),
                    ("ISO", "ISO"),
                    ("Aperture", "Aperture"),
                    ("Shutter", "Shutter Speed"),
                    ("Focal", "Focal Length"),
                    ("Flash", "Flash"),
                    ("Orientation", "Orientation"),
                    ("Color Space", "Color Space"),
                    ("File Type", "File Type"),
                    ("MIME Type", "MIME Type"),
                ]
                for label, key in interesting:
                    val = data[0].get(key)
                    if val:
                        print(f"  {label:12s}: {val}")
        except:
            pass
    else:
        print("  No EXIF data available")

def get_image_properties(image_path):
    """Get image properties using Pillow"""
    print("\n🖼️  Image Properties:")
    print("  ─────────────────────────────────────────")
    safe_path = image_path.replace("'", "'\\''")
    props = run_cmd(["python3", "-c", f"""
from PIL import Image
img = Image.open('{safe_path}')
print(f"Format:   {{img.format}}")
print(f"Mode:     {{img.mode}}")
print(f"Size:     {{img.size[0]}}x{{img.size[1]}} px")
print(f"DPI:      {{img.info.get('dpi', 'N/A')}}")
print(f"Colors:   {{len(img.getcolors(maxcolors=256)) if img.mode == 'RGB' else 'N/A'}}")
mp = img.width * img.height / 1e6
if img.width > 1000:
    print(f"Quality:  High-res ({{mp:.1f}} MP)")
elif img.width > 500:
    print(f"Quality:  Medium-res")
else:
    print(f"Quality:  Low-res (thumbnail)")
"""])
    for line in props.split('\n'):
        print(f"  {line}")

def get_ascii_preview(image_path):
    """Generate ASCII art preview"""
    print("\n🎨 ASCII Preview:")
    print("  ─────────────────────────────────────────")
    safe_path = image_path.replace("'", "'\\''")
    ascii_art = run_cmd(["python3", "-c", f"""
from PIL import Image
img = Image.open('{safe_path}')
width = 60
ratio = img.height / img.width
height = int(width * ratio * 0.55)
img_small = img.resize((width, height))
if img_small.mode != 'L':
    img_small = img_small.convert('L')
chars = '@%#*+=-:. '
pixels = list(img_small.getdata())
ascii_str = ''
for i, p in enumerate(pixels):
    char_idx = min(int(p / 256 * len(chars)), len(chars) - 1)
    ascii_str += chars[char_idx]
    if (i + 1) % width == 0:
        ascii_str += chr(10)
print(ascii_str)
"""])
    print(f"  (width=60, scaled to fit)")
    for line in ascii_art.split('\n'):
        if line.strip():
            print(f"  {line}")

def get_ocr(image_path):
    """Extract text via OCR"""
    print("\n🔤 OCR Text (from image):")
    print("  ─────────────────────────────────────────")
    # Try multiple languages
    text = run_cmd(["tesseract", image_path, "stdout", "-l", "eng", "--psm", "3"])
    if text and "Error" not in text:
        lines = [l.strip() for l in text.split('\n') if l.strip()]
        if lines:
            print(f"  ({len(lines)} lines, {sum(len(l) for l in lines)} chars)")
            print("")
            for line in lines[:50]:  # max 50 lines
                print(f"  {line}")
            if len(lines) > 50:
                print(f"  ... and {len(lines) - 50} more lines")
        else:
            print("  (no text detected)")
    else:
        print("  (OCR not available or no text found)")

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 analyze-image.py <image_path_or_url>")
        sys.exit(1)
    
    path = sys.argv[1]
    
    # Check if it's a URL
    if path.startswith(('http://', 'https://')):
        print(f"⬇️  Downloading: {path}")
        path = download_image(path)
        downloaded = True
    else:
        downloaded = False
        if not os.path.exists(path):
            print(f"❌ File not found: {path}")
            sys.exit(1)
    
    print(f"\n{'='*50}")
    print(f"🔍 Image Analysis — Jazz🔥")
    print(f"{'='*50}")
    
    get_metadata(path)
    get_image_properties(path)
    get_ocr(path)
    get_ascii_preview(path)
    
    print(f"\n{'='*50}")
    print("✅ Analysis complete")
    
    if downloaded:
        os.unlink(path)

if __name__ == "__main__":
    main()
