class_name Spawner
extends RefCounted

## Decides what to spawn next and how far past the previous spawn it lands.
## Barrel gaps are always at least as wide as a normal jump needs to clear
## them, so a barrel can always be jumped regardless of the random extra
## added on top. Each gap may also get a bamboo mixed in — grounded (which
## must clear both neighbouring barrels by a jump's worth of distance so it
## never traps the panda) or floating at jump height (safe anywhere, since
## grabbing it happens mid-jump over a barrel). Takes its own
## RandomNumberGenerator so callers control the seed and get a reproducible
## sequence for tests and replays.

enum Kind { BARREL, BAMBOO_GROUND, BAMBOO_FLOAT }

var _tuning: Tuning
var _rng: RandomNumberGenerator

## Items already planned for the current barrel gap but not yet returned by
## next() — at most a bamboo followed by the barrel that ends the gap.
var _pending: Array[Dictionary] = []


func _init(tuning: Tuning, rng: RandomNumberGenerator) -> void:
	_tuning = tuning
	_rng = rng


## The smallest gap, in pixels, that a jump at `speed` can always clear: the
## distance covered during the jump's full airtime, plus a landing buffer.
func min_barrel_gap(speed: float) -> float:
	var air_time := 2.0 * _tuning.jump_velocity / _tuning.gravity
	return speed * (air_time + _tuning.barrel_landing_time)


## Returns the next thing to spawn as { "kind": Kind, "offset": float },
## where offset is the distance after the previous spawn (of any kind).
func next(speed: float) -> Dictionary:
	if _pending.is_empty():
		_pending = _plan_gap(speed)
	return _pending.pop_front()


## Plans one barrel gap: a fair total distance to the next barrel, with an
## optional bamboo (ground or floating) inserted somewhere inside it. Split
## into offsets from whatever precedes each item in the plan.
func _plan_gap(speed: float) -> Array[Dictionary]:
	var gap := min_barrel_gap(speed) + _rng.randf_range(0.0, _tuning.barrel_gap_extra)
	var items: Array[Dictionary] = []

	if _rng.randf() < _tuning.bamboo_chance:
		var clearance := speed * _tuning.bamboo_clearance_time
		var is_float := _rng.randf() < _tuning.bamboo_float_chance
		# Ground bamboo needs room to clear both barrels; if the gap can't
		# fit that, fall back to floating rather than trapping the panda.
		if not is_float and gap < clearance * 2.0:
			is_float = true

		var bamboo_position: float
		if is_float:
			bamboo_position = _rng.randf_range(0.0, gap)
		else:
			bamboo_position = _rng.randf_range(clearance, gap - clearance)

		var kind := Kind.BAMBOO_FLOAT if is_float else Kind.BAMBOO_GROUND
		items.append({ "kind": kind, "offset": bamboo_position })
		items.append({ "kind": Kind.BARREL, "offset": gap - bamboo_position })
	else:
		items.append({ "kind": Kind.BARREL, "offset": gap })

	return items
