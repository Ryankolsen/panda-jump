class_name Health
extends RefCounted

## Hearts, hits, the invincible period after a hit, healing, and dying.
## Pure logic — not connected to the game yet. Time only moves through
## tick(), matching Pace's shape from #3, so this is trivially testable
## and drivable at any rate by whoever owns time.
##
## No reset method: restarting a run reloads the scene (#10), which builds
## a new Health.

signal changed(hearts: int)
signal died

var hearts: int
var max_hearts: int

var _invincible_time: float
var _invincible_left: float = 0.0
var _dead: bool = false


func _init(tuning: Tuning) -> void:
	max_hearts = tuning.max_hearts
	hearts = max_hearts
	_invincible_time = tuning.invincible_time


## Registers a hit. Does nothing and returns false if already dead or
## currently invincible. Otherwise removes one heart, starts the
## invincible period, emits changed, and — if hearts reach 0 — emits died
## exactly once. Hearts never go below 0.
func hit() -> bool:
	if _dead or is_invincible():
		return false

	hearts -= 1
	_invincible_left = _invincible_time
	changed.emit(hearts)

	if hearts <= 0:
		hearts = 0
		_dead = true
		died.emit()

	return true


## Adds one heart, capped at max_hearts. Emits changed only if the count
## actually changed. Does nothing when dead.
func heal() -> void:
	if _dead:
		return
	if hearts >= max_hearts:
		return

	hearts += 1
	changed.emit(hearts)


## Counts down the invincible period. Time only moves through tick.
func tick(delta: float) -> void:
	_invincible_left = max(0.0, _invincible_left - delta)


func is_invincible() -> bool:
	return _invincible_left > 0.0


func invincible_time_left() -> float:
	return _invincible_left


func is_dead() -> bool:
	return _dead
