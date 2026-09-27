class_name Barrel
extends Area2D

## A rolling barrel hazard (see issue #8 for losing hearts on contact).
## Spawned as a child of World by Main so it scrolls at Pace's speed with no
## copy of the speed of its own; this script only tracks its own on-screen
## movement to spin the picture and to free itself once it has scrolled off
## the left edge. The node's origin is the circle's own center (so rotation
## spins it in place); Main positions that center one picture-radius above
## ground_y so the barrel visually rests on the path.
##
## When `texture` is set (see issue #16), it's drawn scaled to PICTURE_HEIGHT
## tall via SpriteFit instead of the placeholder shape; the hitbox and
## rolling behaviour don't change either way.

const PICTURE_RADIUS := 14.0
const PICTURE_HEIGHT := 28.0
const HITBOX_RADIUS := 11.0
const BAND_HALF_HEIGHT := 3.0
const FREE_AT_X := -64.0
const BODY_COLOR := Color("8B5A2B")
const BAND_COLOR := Color("5C3A1B")

signal hit_panda(body: Node2D)

@export var texture: Texture2D

var _last_global_x: float


func _ready() -> void:
	_last_global_x = global_position.x
	body_entered.connect(_on_body_entered)


func _process(_delta: float) -> void:
	var dx := global_position.x - _last_global_x
	_last_global_x = global_position.x
	# Rolling: angle turned equals distance traveled divided by radius.
	rotation += dx / HITBOX_RADIUS
	if global_position.x < FREE_AT_X:
		queue_free()


func _draw() -> void:
	if texture:
		var scale := SpriteFit.scale_for(texture.get_size(), PICTURE_HEIGHT)
		var size := texture.get_size() * scale
		draw_texture_rect(texture, Rect2(-size / 2.0, size), false)
		return
	draw_circle(Vector2.ZERO, PICTURE_RADIUS, BODY_COLOR)
	draw_rect(Rect2(Vector2(-PICTURE_RADIUS, -BAND_HALF_HEIGHT), Vector2(PICTURE_RADIUS * 2.0, BAND_HALF_HEIGHT * 2.0)), BAND_COLOR)


func _on_body_entered(body: Node2D) -> void:
	hit_panda.emit(body)
