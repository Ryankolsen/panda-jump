class_name Panda
extends CharacterBody2D

## The player's panda: fixed on screen at x = 96, standing on the ground
## until the `jump` action sends it airborne. Gravity and jump height come
## from the exported Tuning so tuning.tres controls feel without touching
## this script. The picture comes from `skin`, kept separate (see
## PandaSkin) so a different-looking panda can reuse this same behaviour.

const FIXED_X := 96.0

@export var tuning: Tuning
@export var skin: PandaSkin

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	position.x = FIXED_X
	if tuning:
		position.y = tuning.ground_y
	if skin and sprite:
		sprite.texture = skin.texture_for(PandaSkin.Pose.STANDING)
		_scale_sprite_to_panda_height()


func _physics_process(delta: float) -> void:
	if not tuning:
		return
	velocity.y += tuning.gravity * delta
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = -tuning.jump_velocity
	move_and_slide()


## Scales the sprite to Tuning.panda_height and keeps it bottom-aligned to
## this node's origin (the panda's feet, at ground level) regardless of the
## source picture's resolution.
func _scale_sprite_to_panda_height() -> void:
	var texture := sprite.texture
	if not texture or texture.get_height() <= 0:
		return
	var s := tuning.panda_height / texture.get_height()
	sprite.scale = Vector2(s, s)
	sprite.position.y = -tuning.panda_height / 2.0
