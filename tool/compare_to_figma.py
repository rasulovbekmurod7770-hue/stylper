#!/usr/bin/env python3
"""Compare golden screenshots with the Figma renders in design/figma/screens.

Usage: python3 tool/compare_to_figma.py [OUT_DIR]

For each pair in PAIRS, writes OUT_DIR/<name>_compare.png containing
Figma | Flutter | diff heatmap, and prints the share of differing pixels.
The mockup-only status bar (top 44px), home indicator (bottom 34px) and the
40px device corners are masked out. Requires Pillow.
"""
import os
import sys

from PIL import Image, ImageChops, ImageDraw

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FIGMA = os.path.join(ROOT, 'design', 'figma', 'screens')
GOLDEN = os.path.join(ROOT, 'test', 'goldens', 'screens')

PAIRS = {
    'welcome': '01_welcome.png',
    'sign_in': '02_login.png',
    'sign_up': '03_sign_up.png',
    'profile_setup': '04_profile_setup.png',
    'style_quiz': '05_intro_dress_like_you.png',
    'forgot_password': '06_forgot_password.png',
}


def mask(size):
    w, h = size
    m = Image.new('L', size, 255)
    d = ImageDraw.Draw(m)
    d.rectangle([0, 0, w, 44], fill=0)
    d.rectangle([0, h - 34, w, h], fill=0)
    outer = Image.new('L', size, 0)
    ImageDraw.Draw(outer).rounded_rectangle([0, 0, w - 1, h - 1], 40, fill=255)
    return ImageChops.multiply(m, outer)


def compare(name, figma_file, out_dir):
    golden_path = os.path.join(GOLDEN, f'{name}.png')
    if not os.path.exists(golden_path):
        return
    figma = Image.open(os.path.join(FIGMA, figma_file)).convert('RGB')
    golden = Image.open(golden_path).convert('RGB').resize(figma.size)
    m = mask(figma.size)
    diff = ImageChops.difference(figma, golden).convert('L')
    diff = ImageChops.multiply(diff, m)
    changed = sum(1 for p in diff.getdata() if p > 40)
    total = sum(1 for p in m.getdata() if p)
    heat = Image.merge('RGB', (diff.point(lambda p: min(255, p * 3)),) + (Image.new('L', figma.size, 0),) * 2)
    w, h = figma.size
    sheet = Image.new('RGB', (w * 3 + 20, h), 'white')
    sheet.paste(figma, (0, 0))
    sheet.paste(golden, (w + 10, 0))
    sheet.paste(heat, (2 * w + 20, 0))
    sheet.save(os.path.join(out_dir, f'{name}_compare.png'))
    print(f'{name:16} {100 * changed / total:5.2f}% pixels differ (>40/255)')


def main():
    out_dir = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, 'build', 'figma_compare')
    os.makedirs(out_dir, exist_ok=True)
    for name, figma_file in PAIRS.items():
        compare(name, figma_file, out_dir)
    print(f'Sheets written to {out_dir}')


if __name__ == '__main__':
    main()
