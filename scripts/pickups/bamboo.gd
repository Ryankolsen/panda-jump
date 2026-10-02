class_name Bamboo
extends Area2D

## A bamboo pickup. Spawned as a child of World by Main so it scrolls at
## Pace's speed with no copy of the speed of its own; this script only
## tracks its own on-screen position to free itself once it has scrolled
## off the left edge. The node's origin is the bottom-center of the stalk,
## so Main can position it directly on ground_y (or bamboo_float_height
## above it) without doing its own height math. Hitbox is roughly the size
## of the picture — bamboo is generous, unlike barrels (see issue #7).
##
## When `texture` is set (see issue #16), it's drawn scaled to HEIGHT tall
## via SpriteFit, bottom-aligned to this node's origin, instead of the
## placeholder shape; the hitbox doesn't change either way.
##
## Bamboo is green on a green bamboo-forest background, so to read as a
## pickup the picture is drawn inside the Visual CanvasGroup, whose shader
## outlines whatever is drawn (placeholder or texture) in OUTLINE_COLOR, and
## Visual bobs gently up and down. Only the picture bobs; the hitbox stays put.

const WIDTH := 10.0
const HEIGHT := 28.0
const FREE_AT_X := -64.0
const STALK_COLOR := Color("9CCC65")
const BAND_COLOR := Color("558B2F")
const LEAF_COLOR := Color("8BC34A")
## Outline thickness in game pixels (the 480x270 viewport, not the window).
const OUTLINE_THICKNESS := 1.0
const BOB_HEIGHT := 2.0
const BOB_PERIOD := 1.2

signal eaten

@export var texture: Texture2D

var _elapsed := 0.0

@onready var _visual: CanvasGroup = $Visual
@onready var _picture: Node2D = $Visual/Picture


## The picture's vertical offset t seconds into the bob: starts at rest and
## rises (negative y) to BOB_HEIGHT a quarter period in.
static func bob_offset(t: float) -> float:
	return -BOB_HEIGHT * sin(TAU * t / BOB_PERIOD)


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_picture.draw.connect(_draw_picture)
	# The shader works in real screen pixels; scale by the window stretch so
	# the outline is OUTLINE_THICKNESS game pixels on any screen size.
	var stretch := get_viewport().get_final_transform().get_scale().x
	(_visual.material as ShaderMaterial).set_shader_parameter("line_thickness", OUTLINE_THICKNESS * stretch)


func _process(delta: float) -> void:
	_elapsed += delta
	_visual.position.y = bob_offset(_elapsed)
	if global_position.x < FREE_AT_X:
		queue_free()


func _draw_picture() -> void:
	if texture:
		var scale := SpriteFit.scale_for(texture.get_size(), HEIGHT)
		var size := texture.get_size() * scale
		_picture.draw_texture_rect(texture, Rect2(Vector2(-size.x / 2.0, -size.y), size), false)
		return

	var stalk_rect := Rect2(Vector2(-WIDTH / 2.0, -HEIGHT), Vector2(WIDTH, HEIGHT))
	_picture.draw_rect(stalk_rect, STALK_COLOR)

	var band_height := HEIGHT / 8.0
	_picture.draw_rect(Rect2(Vector2(-WIDTH / 2.0, -HEIGHT * 0.66), Vector2(WIDTH, band_height)), BAND_COLOR)
	_picture.draw_rect(Rect2(Vector2(-WIDTH / 2.0, -HEIGHT * 0.33), Vector2(WIDTH, band_height)), BAND_COLOR)

	# A small leaf poking out near the top.
	var leaf_points := PackedVector2Array([
		Vector2(WIDTH / 2.0, -HEIGHT),
		Vector2(WIDTH / 2.0 + 8.0, -HEIGHT + 3.0),
		Vector2(WIDTH / 2.0, -HEIGHT + 6.0),
	])
	_picture.draw_polygon(leaf_points, PackedColorArray([LEAF_COLOR]))


func _on_body_entered(_body: Node2D) -> void:
	eaten.emit()
	queue_free()
