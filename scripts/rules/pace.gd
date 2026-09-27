class_name Pace
extends RefCounted

## Tracks how far the run has traveled. Time only moves through tick() —
## no _process, no scene dependencies — so this is trivially testable and
## drivable at any rate (or replayed deterministically) by whoever owns time.

var speed: float
var distance: float = 0.0
var _points_per_pixel: float

## Score, computed from distance rather than stored separately, so it can
## never drift out of step with how far the run has actually traveled.
var score: int:
	get:
		return int(floor(distance * _points_per_pixel))


func _init(tuning: Tuning) -> void:
	speed = tuning.start_speed
	_points_per_pixel = tuning.points_per_pixel


func tick(delta: float) -> void:
	distance += speed * delta
