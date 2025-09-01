import re
import os
import json
from PIL import Image

# --------------- CONFIG ---------------
# Folder containing your theme files
folder_path = "/home/harri/.config/themes/test"
# Output image file for color swatches
output_image = "theme_palette.png"
# Swatch size
swatch_size = 50
# --------------------------------------

colors = []
seen = set()

# Scan files
for root, _, files in os.walk(folder_path):
    for file_name in files:
        with open(os.path.join(root, file_name), "r") as f:
            try:
                content = f.read()
            except:
                continue
            hex_colors = re.findall(r'#[0-9A-Fa-f]{6,8}', content)
            rgba_colors = re.findall(r'rgba\([0-9.,]+\)', content)
            for c in hex_colors + rgba_colors:
                if c not in seen:
                    seen.add(c)
                    colors.append(c)


# Save to JSON
output_json = "theme_colors.json"
with open(output_json, "w") as f:
    json.dump(colors, f, indent=4)

print(f"Found {len(colors)} unique colors. Saved to {output_json}")


# ---------------- CREATE SWATCH IMAGE ----------------
if colors:
    cols = 8
    rows = (len(colors) + cols - 1) // cols

    img = Image.new("RGBA", (cols * swatch_size, rows * swatch_size), (255, 255, 255, 0))

    for idx, color in enumerate(colors):
        col = idx % cols
        row = idx // cols
        # Convert rgba string to tuple if needed
        if color.startswith("rgba"):
            nums = [float(n) for n in color[5:-1].split(",")]
            if len(nums) == 4:
                r, g, b, a = nums
                a = int(a * 255) if a <= 1 else int(a)
                rgba = (int(r), int(g), int(b), a)
        else:  # hex
            hex_color = color.lstrip("#")
            if len(hex_color) == 6:
                r, g, b = int(hex_color[0:2], 16), int(hex_color[2:4], 16), int(hex_color[4:6], 16)
                rgba = (r, g, b, 255)
            elif len(hex_color) == 8:
                r, g, b, a = int(hex_color[0:2], 16), int(hex_color[2:4], 16), int(hex_color[4:6], 16), int(hex_color[6:8], 16)
                rgba = (r, g, b, a)
        # Draw swatch
        for x in range(col * swatch_size, (col + 1) * swatch_size):
            for y in range(row * swatch_size, (row + 1) * swatch_size):
                img.putpixel((x, y), rgba)

    img.save(output_image)
    print(f"Swatch image saved as {output_image}")

