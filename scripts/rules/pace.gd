class_name Pace
extends RefCounted

## Tracks how far the run has traveled. Time only moves through tick() —
## no _process, no scene dependencies — so this is trivially testable and
## drivable at any rate (or replayed deterministically) by whoever owns time.

var speed: float
var distance: float = 0.0


func _init(tuning: Tuning) -> void:
	speed = tuning.start_speed


func tick(delta: float) -> void:
	distance += speed * delta
