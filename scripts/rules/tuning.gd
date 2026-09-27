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

## Display height of the panda sprite, in pixels. The picture is scaled to
## this height regardless of its source resolution.
@export var panda_height: float = 64.0

## Downward acceleration applied to the panda every physics frame, in
## pixels per second squared.
@export var gravity: float = 1400.0

## Upward speed applied on takeoff, in pixels per second. With `gravity`
## above this gives an ~96px high, ~0.74s jump.
@export var jump_velocity: float = 520.0

## Hearts the panda starts (and heals back up to). See issue #6.
@export var max_hearts: int = 3

## Seconds of invincibility after a hit lands, before another can. See #6.
@export var invincible_time: float = 1.0

## Extra seconds added to a barrel's gap beyond bare jump-clearance, so the
## panda has time to land and react before the next one. See issue #7.
@export var barrel_landing_time: float = 0.45

## Extra random distance (0..this, in pixels) added on top of the fair
## minimum gap between barrels, so gaps aren't all identical. See #7.
@export var barrel_gap_extra: float = 220.0

## Seconds between visibility toggles while the panda is invincible after a
## hit, so it blinks rather than just staying tinted. See issue #8.
@export var blink_interval: float = 0.1
