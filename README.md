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

3. Keep the original photo in `art/originals/`.
4. Set the texture on the right pose in `resources/panda/pink_skin.tres`, or
   on the barrel or bamboo scene:
   - Barrel: `assets/barrel/barrel.png`
   - Bamboo: `assets/bamboo/bamboo.png`
   - Panda poses (in `resources/panda/pink_skin.tres`): `assets/panda/pink/standing.png`,
     `run_1.png`, `run_2.png`, `jump_takeoff.png`, `jump_air.png`, `hurt.png`
