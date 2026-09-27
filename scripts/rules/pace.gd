class_name Pace
extends RefCounted

## Tracks how far the run has traveled. Time only moves through tick() —
## no _process, no scene dependencies — so this is trivially testable and
## drivable at any rate (or replayed deterministically) by whoever owns time.
##
## Speed ramps up with elapsed time toward Tuning.max_speed (see issue #13)
## rather than staying fixed at start_speed, so this is the one place a
## speed value lives — nothing else should keep its own copy.

var speed: float
var distance: float = 0.0
var _elapsed: float = 0.0
var _tuning: Tuning

## Score, computed from distance rather than stored separately, so it can
## never drift out of step with how far the run has actually traveled.
var score: int:
	get:
		return int(floor(distance * _tuning.points_per_pixel))


func _init(tuning: Tuning) -> void:
	_tuning = tuning
	speed = _speed_at(0.0)


func tick(delta: float) -> void:
	_elapsed += delta
	speed = _speed_at(_elapsed)
	distance += speed * delta


## Speed at `elapsed` seconds into the run: ramps up from start_speed at
## speed_ramp px/s per second, capped at max_speed. The clamp always wins,
## even if max_speed is set below start_speed.
func _speed_at(elapsed: float) -> float:
	return min(_tuning.start_speed + _tuning.speed_ramp * elapsed, _tuning.max_speed)
