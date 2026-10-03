"""Cut a paper drawing out of its photo: white paper and shadows become
transparent, the drawing is trimmed and scaled to a fixed height.

Usage: python tools/cutout.py PHOTO OUT.png [brightness=140] [grayness=30] [height=512]
Needs numpy, scipy and pillow."""
import sys
import numpy as np
from PIL import Image, ImageOps, ImageFilter
from scipy import ndimage as ndi


def cutout_foreground(img, bright, sat):
    """Return a boolean mask, same size as img, of the largest non-paper-like
    blob not touching the border, with holes filled and a binary opening
    applied. img is a PIL RGB image."""
    a = np.asarray(img).astype(int)
    mean = a.mean(axis=2)
    spread = a.max(axis=2) - a.min(axis=2)
    paperlike = (mean > bright) & (spread < sat)

    # Background = paper-like regions connected to the photo's border.
    labels, _ = ndi.label(paperlike)
    border = set(np.unique(np.concatenate([labels[0], labels[-1], labels[:, 0], labels[:, -1]]))) - {0}
    bg = np.isin(labels, list(border))

    # Foreground = largest remaining blob (drops the countertop strip), holes filled.
    fg = ~bg
    fl, n = ndi.label(fg)
    sizes = ndi.sum(fg, fl, range(1, n + 1))
    fg = fl == (np.argmax(sizes) + 1)
    fg = ndi.binary_fill_holes(fg)
    fg = ndi.binary_opening(fg, iterations=3)
    return fg


def padded_box(xmin, ymin, xmax, ymax, width, height, pad=8):
    """Pad a bounding box by pad px on each side, clamped to (width, height)."""
    return (max(xmin - pad, 0), max(ymin - pad, 0), min(xmax + pad, width), min(ymax + pad, height))


def cutout(src, dst, bright, sat, height):
    img = ImageOps.exif_transpose(Image.open(src)).convert("RGB")
    fg = cutout_foreground(img, bright, sat)
    ys, xs = np.where(fg)
    box = padded_box(xs.min(), ys.min(), xs.max(), ys.max(), img.width, img.height)

    alpha = Image.fromarray((fg * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(1.5))
    out = img.convert("RGBA")
    out.putalpha(alpha)
    out = out.crop(box)
    out = out.resize((round(out.width * height / out.height), height), Image.LANCZOS)
    out.save(dst)
    print("crop box", box, "->", out.size)

    # Preview on a checkerboard and on the forest so the edges can be judged.
    chk = Image.new("RGBA", out.size, (255, 0, 255, 255))
    chk.alpha_composite(out)
    chk.convert("RGB").save(dst.replace(".png", "_preview.png"))


if __name__ == "__main__":
    args = sys.argv[1:] + ["140", "30", "512"][len(sys.argv) - 3:]
    src, dst, bright, sat, height = args[0], args[1], int(args[2]), int(args[3]), int(args[4])
    cutout(src, dst, bright, sat, height)
