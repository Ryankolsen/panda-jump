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
