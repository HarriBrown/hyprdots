from PIL import Image

# ---------- CONFIG ----------
base_image = "theme_palette.png"
modified_image = "modified.png"
output_file = "replacements.txt"
# -----------------------------

base = Image.open(base_image).convert("RGBA")
mod = Image.open(modified_image).convert("RGBA")

if base.size != mod.size:
    raise ValueError("Base and modified images must have the same dimensions")

def rgb_to_hex(rgb):
    return "#{:02x}{:02x}{:02x}".format(*rgb[:3])

# Build replacement set
replacements = set()

for x in range(base.width):
    for y in range(base.height):
        old_pixel = base.getpixel((x, y))
        new_pixel = mod.getpixel((x, y))
        if old_pixel != new_pixel:
            old_hex = rgb_to_hex(old_pixel)
            new_hex = rgb_to_hex(new_pixel)
            replacements.add((old_hex, new_hex))

if not replacements:
    print("No differences found!")
else:
    with open(output_file, "w") as f:
        for old, new in sorted(replacements):
            f.write(f"{old} {new}\n")
    print(f"Replacement file created: {output_file}")

