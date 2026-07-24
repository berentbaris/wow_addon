"""
Crop all image files (.tga, .jpg, .jpeg, .png) in this folder to 509x720, preserving as much
of the original image as possible (scale-to-cover, then center-crop).

Output goes to test_portraits folder (as .tga files, same names).

Usage:
    python crop_portraits.py
"""
import os, sys
from PIL import Image

TARGET_W, TARGET_H = 509, 720
TARGET_RATIO = TARGET_W / TARGET_H  # ~0.707

SRC_DIR = os.path.dirname(os.path.abspath(__file__))
DST_DIR = r"C:\Users\beren\Objet\wow_addon\test_portraits"

os.makedirs(DST_DIR, exist_ok=True)

EXTS = (".tga", ".jpg", ".jpeg", ".png")
files = sorted(f for f in os.listdir(SRC_DIR) if f.lower().endswith(EXTS))
print(f"Found {len(files)} image files in {SRC_DIR}")

for fname in files:
    src_path = os.path.join(SRC_DIR, fname)
    try:
        img = Image.open(src_path).convert("RGBA")
    except Exception as e:
        print(f"  SKIP {fname}: {e}")
        continue

    w, h = img.size
    src_ratio = w / h

    if src_ratio > TARGET_RATIO:
        # Image is wider than target — scale by height, crop width
        scale = TARGET_H / h
        new_w = round(w * scale)
        new_h = TARGET_H
        img = img.resize((new_w, new_h), Image.LANCZOS)
        left = (new_w - TARGET_W) // 2
        img = img.crop((left, 0, left + TARGET_W, TARGET_H))
    else:
        # Image is taller than target — scale by width, crop height
        scale = TARGET_W / w
        new_w = TARGET_W
        new_h = round(h * scale)
        img = img.resize((new_w, new_h), Image.LANCZOS)
        top = (new_h - TARGET_H) // 2
        img = img.crop((0, top, TARGET_W, top + TARGET_H))

    # Save as JPEG-renamed-to-TGA (matching the existing convention)
    base = os.path.splitext(fname)[0]
    dst_path = os.path.join(DST_DIR, base + ".tga")
    img.convert("RGB").save(dst_path, format="JPEG", quality=92)
    print(f"  OK: {fname} ({w}x{h} -> {TARGET_W}x{TARGET_H})")

print(f"\nDone — {len(files)} files written to {DST_DIR}")
