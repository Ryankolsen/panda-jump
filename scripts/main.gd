class_name Main
extends Node2D

## Root of the game. Owns the run's Pace (built from an exported Tuning
## resource) and drives it every physics frame, then hands the resulting
## distance to World (so later barrels/bamboo scroll for free) and to the
## background.

@export var tuning: Tuning

var pace: Pace

@onready var world: Node2D = $World
@onready var background: ForestBackground = $Background


func _ready() -> void:
	pace = Pace.new(tuning)


func _physics_process(delta: float) -> void:
	pace.tick(delta)
	world.position.x = -pace.distance
	background.set_distance(pace.distance)
