"""Generate the ForceTrace launcher, web and Windows icons.

Usage:
    python tool/make_icons.py   # requires Pillow
"""
import math
import os
from PIL import Image, ImageDraw, ImageFilter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SIZE = 1024
SS = 2
S = SIZE * SS


def lerp(a, b, t):
    return int(a + (b - a) * t)


def make_icon(padding_ratio=0.0, maskable=False):
    img = Image.new("RGB", (S, S), (7, 11, 15))
    px = img.load()
    for y in range(S):
        t = y / (S - 1)
        r = lerp(10, 5, t)
        g = lerp(20, 9, t)
        b = lerp(27, 13, t)
        for x in range(S):
            px[x, y] = (r, g, b)

    # Soft green glow behind the mark.
    glow = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    cx = cy = S // 2
    gd.ellipse(
        [cx - S * 0.42, cy - S * 0.42, cx + S * 0.42, cy + S * 0.42],
        fill=(74, 222, 128, 36),
    )
    glow = glow.filter(ImageFilter.GaussianBlur(S * 0.08))
    img = Image.alpha_composite(img.convert("RGBA"), glow)

    draw = ImageDraw.Draw(img)
    pad = S * (0.115 + padding_ratio)
    box = [pad, pad, S - pad, S - pad]
    radius = (box[2] - box[0]) * 0.24

    # Neon rounded frame (a few strokes for a glow).
    for width, alpha in [(S * 0.030, 45), (S * 0.018, 120), (S * 0.010, 255)]:
        layer = Image.new("RGBA", (S, S), (0, 0, 0, 0))
        ld = ImageDraw.Draw(layer)
        ld.rounded_rectangle(
            box,
            radius=radius,
            outline=(74, 222, 128, alpha),
            width=int(width),
        )
        if alpha < 255:
            layer = layer.filter(ImageFilter.GaussianBlur(S * 0.008))
        img = Image.alpha_composite(img, layer)
        draw = ImageDraw.Draw(img)

    # Barbell shaft.
    bar_y = S * 0.52
    shaft = [S * 0.28, bar_y - S * 0.012, S * 0.72, bar_y + S * 0.012]
    draw.rounded_rectangle(shaft, radius=S * 0.012, fill=(244, 247, 250, 255))

    # Plates: neon green rounded bars.
    plate_w = S * 0.040
    plate_h = S * 0.20
    plate_radius = plate_w * 0.42
    for x in [S * 0.315, S * 0.385, S * 0.575, S * 0.645]:
        draw.rounded_rectangle(
            [x - plate_w / 2, bar_y - plate_h / 2, x + plate_w / 2, bar_y + plate_h / 2],
            radius=plate_radius,
            fill=(74, 222, 128, 255),
        )

    # Orange heartbeat across the bar.
    points = [
        (S * 0.24, bar_y),
        (S * 0.42, bar_y),
        (S * 0.46, bar_y - S * 0.075),
        (S * 0.50, bar_y + S * 0.095),
        (S * 0.55, bar_y - S * 0.045),
        (S * 0.59, bar_y),
        (S * 0.76, bar_y),
    ]
    draw.line(points, fill=(251, 146, 60, 255), width=int(S * 0.018), joint="curve")
    for point in [points[4], points[5]]:
        draw.ellipse(
            [point[0] - S * 0.012, point[1] - S * 0.012, point[0] + S * 0.012, point[1] + S * 0.012],
            fill=(251, 146, 60, 255),
        )

    # Crop away the transparent edge, then resize.
    return img.convert("RGB").resize((SIZE, SIZE), Image.LANCZOS)


icon = make_icon()
maskable = make_icon(padding_ratio=0.045, maskable=True)


def save(img, path, size):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    img.resize((size, size), Image.LANCZOS).save(path, "PNG", optimize=True)
    print("wrote", path, size)


save(icon, os.path.join(ROOT, r"web\favicon.png"), 64)
save(icon, os.path.join(ROOT, r"web\icons\Icon-192.png"), 192)
save(icon, os.path.join(ROOT, r"web\icons\Icon-512.png"), 512)
save(maskable, os.path.join(ROOT, r"web\icons\Icon-maskable-192.png"), 192)
save(maskable, os.path.join(ROOT, r"web\icons\Icon-maskable-512.png"), 512)

android_sizes = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}
for folder, size in android_sizes.items():
    save(
        icon,
        os.path.join(ROOT, "android", "app", "src", "main", "res", folder, "ic_launcher.png"),
        size,
    )

ios_files = {
    "Icon-App-20x20@1x.png": 20,
    "Icon-App-20x20@2x.png": 40,
    "Icon-App-20x20@3x.png": 60,
    "Icon-App-29x29@1x.png": 29,
    "Icon-App-29x29@2x.png": 58,
    "Icon-App-29x29@3x.png": 87,
    "Icon-App-40x40@1x.png": 40,
    "Icon-App-40x40@2x.png": 80,
    "Icon-App-40x40@3x.png": 120,
    "Icon-App-60x60@2x.png": 120,
    "Icon-App-60x60@3x.png": 180,
    "Icon-App-76x76@1x.png": 76,
    "Icon-App-76x76@2x.png": 152,
    "Icon-App-83.5x83.5@2x.png": 167,
    "Icon-App-1024x1024@1x.png": 1024,
}
for name, size in ios_files.items():
    save(
        icon,
        os.path.join(ROOT, "ios", "Runner", "Assets.xcassets", "AppIcon.appiconset", name),
        size,
    )

# Windows .ico
ico_path = os.path.join(ROOT, r"windows\runner\resources\app_icon.ico")
icon.save(
    ico_path,
    format="ICO",
    sizes=[(16, 16), (24, 24), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)],
)
print("wrote", ico_path)
