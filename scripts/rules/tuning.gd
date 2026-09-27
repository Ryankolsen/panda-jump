class_name Tuning
extends Resource

## The one place gameplay numbers live. Each field is an @export with a
## default set here, so Tuning.new() carries real values in tests without
## needing a saved .tres.

## Starting forward speed of the run, in pixels per second.
@export var start_speed: float = 140.0

## Y coordinate of the painted dirt path in the 480x270 viewport, in pixels.
## Checked against a headless screenshot of the background — see issue #4.
@export var ground_y: float = 233.0
