class_name Panda
extends CharacterBody2D

## The player's panda: fixed on screen at x = 96, standing on the ground
## until the `jump` action sends it airborne. Gravity and jump height come
## from the exported Tuning so tuning.tres controls feel without touching
## this script. The picture comes from `skin`, kept separate (see
## PandaSkin) so a different-looking panda can reuse this same behaviour.

const FIXED_X := 96.0
const HURT_MODULATE := Color(1, 0.6, 0.6)
const NORMAL_MODULATE := Color(1, 1, 1)

@export var tuning: Tuning
@export var skin: PandaSkin

var health: Health
var run_time: float = 0.0

# Set by a `jump` press that no GUI control (the pause button) took first,
# and cleared every physics frame — so it behaves like just-pressed.
var _jump_requested: bool = false

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	position.x = FIXED_X
	if tuning:
		position.y = tuning.ground_y
	_update_look()


func _physics_process(delta: float) -> void:
	if not tuning:
		return
	velocity.y += tuning.gravity * delta
	if is_on_floor() and _jump_requested:
		velocity.y = -tuning.jump_velocity
	_jump_requested = false
	move_and_slide()
	if is_on_floor():
		run_time += delta
	else:
		run_time = 0.0
	_update_look()


## Jumps come through here rather than polling Input, so a tap on the pause
## button (handled by the GUI first) doesn't also make the panda jump.
## A screen tap reaches "jump" only as a left mouse click, via the project's
## input_devices/pointing/emulate_mouse_from_touch (left at Godot's default,
## on); turning that off would leave touch screens unable to jump.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		_jump_requested = true


## Whether the sprite should be visible right now, given `time_left` seconds
## remaining in the invincible period and a blink `interval`: always visible
## once the period has ended, otherwise toggling on and off every interval.
static func blink_visible(time_left: float, interval: float) -> bool:
	if time_left <= 0.0:
		return true
	return int(time_left / interval) % 2 == 0


## Picks the pose for the current physics state via PosePicker, shows its
## texture at panda_height tall, and applies the hurt tint/blink from #8 on
## top (still driven by Health's invincible period, independent of pose).
func _update_look() -> void:
	if not sprite:
		return

	var hurt := health != null and health.is_invincible()

	if skin and tuning:
		var pose := PosePicker.pick(is_on_floor(), velocity.y, hurt, run_time, tuning.run_frame_time)
		sprite.texture = skin.texture_for(pose)
		_scale_sprite_to_panda_height()

	if hurt:
		sprite.visible = Panda.blink_visible(health.invincible_time_left(), tuning.blink_interval)
		sprite.modulate = HURT_MODULATE
	else:
		sprite.visible = true
		sprite.modulate = NORMAL_MODULATE


## Scales the sprite to Tuning.panda_height via SpriteFit and keeps it
## bottom-aligned to this node's origin (the panda's feet, at ground level)
## regardless of the source picture's resolution.
func _scale_sprite_to_panda_height() -> void:
	var texture := sprite.texture
	if not texture or texture.get_height() <= 0:
		return
	sprite.scale = SpriteFit.scale_for(texture.get_size(), tuning.panda_height)
	sprite.position.y = -tuning.panda_height / 2.0
