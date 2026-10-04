"""Cut a font down to just the emoji the Game Over picker offers, so the
game can bundle a tiny colour emoji font instead of relying on system
font fallback (which differs between Android versions and desktop, and
shows nothing at all in headless runs).

The source is the CBDT bitmap build of Noto Color Emoji
(NotoColorEmoji.ttf from the googlefonts/noto-emoji repo). Every glyph
outside EMOJI is dropped, so the output is a few kilobytes rather than
the source's ~10MB. The source font is not committed; only the subset
and its OFL licence (assets/fonts/OFL.txt) are.

Usage:
    python tools/subset_emoji.py SOURCE_FONT OUT_FONT

e.g.
    python tools/subset_emoji.py NotoColorEmoji.ttf assets/fonts/emoji_subset.ttf

Needs fonttools (pip install fonttools)."""
import sys
from fontTools import subset

# Must match Leaderboard's picker set, in picker order. Each is a single
# code point with no U+FE0F variation selector. A GUT test catches drift.
EMOJI = [
    0x1F43C,  # 🐼 panda
    0x1F38B,  # 🎋 tanabata tree
    0x1F43B,  # 🐻 bear
    0x1F98A,  # 🦊 fox
    0x1F438,  # 🐸 frog
    0x1F430,  # 🐰 rabbit
    0x1F431,  # 🐱 cat
    0x2B50,   # ⭐ star
]


def subset_font(src_path, dst_path):
    options = subset.Options()
    # CBDT/CBLC hold the colour bitmaps; make sure they're never dropped,
    # or the glyphs come out blank in Godot.
    options.drop_tables = [t for t in options.drop_tables if t not in ("CBDT", "CBLC")]
    options.notdef_outline = True
    font = subset.load_font(src_path, options)
    subsetter = subset.Subsetter(options)
    subsetter.populate(unicodes=EMOJI)
    subsetter.subset(font)

    missing = [cp for cp in EMOJI if cp not in font.getBestCmap()]
    if missing:
        sys.exit("missing from source font: " + ", ".join("U+%04X" % cp for cp in missing))

    subset.save_font(font, dst_path, options)
    print(src_path, "->", dst_path, len(EMOJI), "emoji")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    subset_font(sys.argv[1], sys.argv[2])
