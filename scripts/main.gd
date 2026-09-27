class_name Main
extends Node2D

## Root of the game. Owns the run's Pace (built from an exported Tuning
## resource) and drives it every physics frame, then hands the resulting
## distance to World (so later barrels/bamboo scroll for free) and to the
## background. Ground is a StaticBody2D whose top surface sits at
## Tuning.ground_y so the panda's feet rest on the painted path; Panda is
## fixed on screen and handles its own gravity and jump.

@export var tuning: Tuning

var pace: Pace

@onready var world: Node2D = $World
@onready var background: ForestBackground = $Background
@onready var ground_shape: CollisionShape2D = $Ground/CollisionShape2D


func _ready() -> void:
	pace = Pace.new(tuning)
	# Ground's shape is a fixed-size rectangle; center it so its top edge
	# lands on Tuning.ground_y, whatever that value is set to.
	var half_height: float = ground_shape.shape.size.y / 2.0
	ground_shape.position.y = tuning.ground_y + half_height


func _physics_process(delta: float) -> void:
	pace.tick(delta)
	world.position.x = -pace.distance
	background.set_distance(pace.distance)
