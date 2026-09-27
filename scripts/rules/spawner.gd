class_name Spawner
extends RefCounted

## Decides what to spawn next and how far past the previous spawn it lands.
## Gaps are always at least as wide as a normal jump needs to clear them, so
## a barrel can always be jumped regardless of the random extra added on
## top. Takes its own RandomNumberGenerator so callers control the seed and
## get a reproducible sequence for tests and replays.

enum Kind { BARREL }

var _tuning: Tuning
var _rng: RandomNumberGenerator


func _init(tuning: Tuning, rng: RandomNumberGenerator) -> void:
	_tuning = tuning
	_rng = rng


## The smallest gap, in pixels, that a jump at `speed` can always clear: the
## distance covered during the jump's full airtime, plus a landing buffer.
func min_barrel_gap(speed: float) -> float:
	var air_time := 2.0 * _tuning.jump_velocity / _tuning.gravity
	return speed * (air_time + _tuning.barrel_landing_time)


## Returns the next thing to spawn as { "kind": Kind, "offset": float },
## where offset is the distance after the previous spawn.
func next(speed: float) -> Dictionary:
	var offset := min_barrel_gap(speed) + _rng.randf_range(0.0, _tuning.barrel_gap_extra)
	return { "kind": Kind.BARREL, "offset": offset }
