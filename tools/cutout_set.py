"""Cut out several photos of the same canvas size with one shared crop box,
so every output picture shows its drawing at the same scale and the same
output size as the others — e.g. a set of a character's poses that must
line up when swapped at runtime.

Each input is cut out the same way tools/cutout.py does a single photo:
paper-like pixels touching the border become background, only the largest
remaining blob is kept, holes are filled, a binary opening is applied, and
the alpha edge is blurred. Unlike cutout.py, the crop box used for every
image is the union of all their individual foreground boxes (padded 8px,
clamped to the canvas) — not each image's own box — so a pose trimmed
tighter than its neighbours doesn't end up a different size.

Usage:
    python tools/cutout_set.py OUT_DIR IN1.png:out1.png IN2.png:out2.png ... \
        [--brightness 140] [--grayness 30] [--height 512]

All inputs must share the same pixel width and height; this is a hard
error otherwise, since a shared crop box only makes sense on a shared
canvas.

Needs numpy, scipy and pillow."""
import sys
import numpy as np
from PIL import Image, ImageOps, ImageFilter

from cutout import cutout_foreground, padded_box


def parse_args(argv):
    brightness, grayness, height = 140, 30, 512
    pairs = []
    i = 0
    while i < len(argv):
        arg = argv[i]
        if arg == "--brightness":
            brightness = int(argv[i + 1])
            i += 2
        elif arg == "--grayness":
            grayness = int(argv[i + 1])
            i += 2
        elif arg == "--height":
            height = int(argv[i + 1])
            i += 2
        else:
            pairs.append(arg)
            i += 1
    out_dir = pairs[0]
    specs = []
    for pair in pairs[1:]:
        src, dst = pair.split(":", 1)
        specs.append((src, dst))
    return out_dir, specs, brightness, grayness, height


def cutout_set(out_dir, specs, bright, sat, height):
    images = [ImageOps.exif_transpose(Image.open(src)).convert("RGB") for src, _ in specs]

    sizes = {img.size for img in images}
    if len(sizes) > 1:
        raise ValueError(
            "inputs must all be the same size, got %s for %s"
            % (sorted(sizes), [src for src, _ in specs])
        )
    width, canvas_height = next(iter(sizes))

    fgs = [cutout_foreground(img, bright, sat) for img in images]

    xmin = min(np.where(fg)[1].min() for fg in fgs)
    ymin = min(np.where(fg)[0].min() for fg in fgs)
    xmax = max(np.where(fg)[1].max() for fg in fgs)
    ymax = max(np.where(fg)[0].max() for fg in fgs)
    box = padded_box(xmin, ymin, xmax, ymax, width, canvas_height)

    for img, fg, (src, dst) in zip(images, fgs, specs):
        alpha = Image.fromarray((fg * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(1.5))
        out = img.convert("RGBA")
        out.putalpha(alpha)
        out = out.crop(box)
        out = out.resize((round(out.width * height / out.height), height), Image.LANCZOS)
        dst_path = "%s/%s" % (out_dir, dst)
        out.save(dst_path)
        print(src, "-> crop box", box, "->", dst_path, out.size)


if __name__ == "__main__":
    out_dir, specs, brightness, grayness, height = parse_args(sys.argv[1:])
    cutout_set(out_dir, specs, brightness, grayness, height)
