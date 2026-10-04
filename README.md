# Panda Jump

A side-scrolling jump game starring a pink panda, built in Godot 4.7.

## Opening the project

Open `project.godot` in Godot 4.7 (Mobile rendering method). The viewport is
480x270 with `canvas_items` stretch, `keep_height` aspect, and `fractional`
scale, so the game fills wider screens without stretching the art.

Tap anywhere, press Space, or click to trigger the `jump` input action.

## Running the tests headless

Tests use [GUT](https://github.com/bitwes/Gut) 9.6, vendored under
`addons/gut/`. From the project root:

```sh
"$GODOT" --headless --path . --import
"$GODOT" --headless --path . -s addons/gut/gut_cmdln.gd -gconfig=res://gut_config.json -gexit
```

where `$GODOT` points at your Godot 4.7 binary. The first command refreshes
the `class_name` cache so headless runs resolve custom classes like `Tuning`
and `Pace`; the second runs the suite in `tests/unit`.

A pre-commit hook (`.githooks/pre-commit`) runs this automatically and blocks
a commit if any test fails or if no tests ran at all. Enable it once per
clone with:

```sh
git config core.hooksPath .githooks
```

## Adding a drawing

Barrel, bamboo, and each panda pose can show one of the artist's drawings
instead of the placeholder shape.

1. Photograph the drawing on plain white paper in good light (the panda
   facing right, when she draws side views).
2. Cut it out with `tools/cutout.py`, which needs numpy, scipy and pillow:

   ```sh
   python tools/cutout.py photo.jpg assets/panda/pink/run_1.png
   ```

   If the cutout comes out wrong (background left in, or the drawing
   clipped), pass the optional brightness, grayness and height arguments,
   e.g. `python tools/cutout.py photo.jpg assets/panda/pink/run_1.png 140 30 512`.

   When cutting out a **set** of poses for the same panda (e.g. all five
   `run_1`/`run_2`/`jump_takeoff`/`jump_air`/`hurt` pictures), use
   `tools/cutout_set.py` instead of running `cutout.py` on each photo
   separately. The game scales every pose picture to the panda's display
   height, so if each pose were trimmed to its own tightest crop the panda's
   apparent body size would shift pose to pose. `cutout_set.py` cuts out
   each photo the same way `cutout.py` does, then crops every photo to one
   shared box — the union of all their individual foreground boxes — so the
   panda's body renders at a consistent size across poses:

   ```sh
   python tools/cutout_set.py assets/panda/pink \
       run_1_photo.jpg:run_1.png run_2_photo.jpg:run_2.png
   ```

   All the input photos must be the same pixel size; `cutout_set.py` exits
   with an error otherwise, since a shared crop box only makes sense on a
   shared canvas.

3. Keep the original photo in `art/originals/`.
4. Set the texture on the right pose in `resources/panda/pink_skin.tres`, or
   on the barrel or bamboo scene:
   - Barrel: `assets/barrel/barrel.png`
   - Bamboo: `assets/bamboo/bamboo.png`
   - Panda poses (in `resources/panda/pink_skin.tres`): `assets/panda/pink/run_1.png`,
     `run_2.png`, `jump_takeoff.png`, `jump_air.png`, `hurt.png`

## Changing the emoji

The Game Over card's emoji picker draws its emoji with
`assets/fonts/emoji_subset.ttf`, a tiny font holding only the picker's
emoji, cut from Noto Color Emoji. Godot's default font has no emoji, and
system fallback looks different on every device, so the game bundles its own.

1. Download `NotoColorEmoji.ttf` (the CBDT bitmap build, about 10MB) from
   `2D/fonts/` in the [googlefonts/noto-emoji](https://github.com/googlefonts/noto-emoji)
   repo. Don't commit it; only the subset and `assets/fonts/OFL.txt` are.
2. Edit the `EMOJI` list at the top of `tools/subset_emoji.py`. It must match
   `Leaderboard`'s picker set, in the same order, one code point each with no
   U+FE0F variation selector. A GUT test fails if the two drift apart.
3. Cut the subset with `tools/subset_emoji.py`, which needs fonttools:

   ```sh
   pip install fonttools
   python tools/subset_emoji.py NotoColorEmoji.ttf assets/fonts/emoji_subset.ttf
   ```

4. Open the project in the Godot editor so it reimports the font, and commit
   `emoji_subset.ttf` together with its `.import` file.
