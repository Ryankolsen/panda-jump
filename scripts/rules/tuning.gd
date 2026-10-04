class_name Tuning
extends Resource

## The one place gameplay numbers live. Each field is an @export with a
## default set here, so Tuning.new() carries real values in tests without
## needing a saved .tres.

## Starting forward speed of the run, in pixels per second.
@export var start_speed: float = 140.0

## How fast forward speed ramps up, in px/s of speed gained per second
## elapsed. See issue #13.
@export var speed_ramp: float = 4.0

## The speed the ramp never exceeds, in pixels per second. At speed_ramp's
## default this is reached 40s in. See issue #13.
@export var max_speed: float = 300.0

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

## Score points earned per pixel traveled. 0.1 is 1 point per 10px, about
## 14 points a second at the starting speed. See issue #9.
@export var points_per_pixel: float = 0.1

## Chance that a given barrel gap gets a bamboo mixed into it. See #11.
@export var bamboo_chance: float = 0.4

## Given a gap has bamboo, the chance it floats at jump height rather than
## sitting on the ground. See issue #11.
@export var bamboo_float_chance: float = 0.5

## Seconds of travel a ground bamboo must clear from each neighbouring
## barrel, so grabbing it never forces the panda into one. See issue #11.
@export var bamboo_clearance_time: float = 0.5

## Seconds after the Game Over screen appears during which `jump` is
## ignored, so a tap already in progress when the last heart goes doesn't
## immediately restart the run. See issue #10.
@export var game_over_input_delay: float = 0.5

## Height, in pixels, above ground_y that a floating bamboo's bottom sits.
## Kept at least 12px below jump_apex() so it stays reachable by a normal
## jump. See issue #12.
@export var bamboo_float_height: float = 70.0


## Seconds each running pose (RUN_1/RUN_2) is shown before alternating to
## the other one. See issue #15.
@export var run_frame_time: float = 0.15

## Highest-scores remembered by Leaderboard. See issue #24.
@export var leaderboard_size: int = 5


## The highest point above its start a jump reaches: jump_velocity squared
## over twice gravity. Follows this tuning's own values, not a constant, so
## edits to jump_velocity or gravity keep bamboo placement honest.
func jump_apex() -> float:
	return jump_velocity * jump_velocity / (2.0 * gravity)
