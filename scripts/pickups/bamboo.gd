class_name Bamboo
extends Area2D

## A bamboo pickup. Placeholder art only — see issue #16 for swappable
## drawing. Spawned as a child of World by Main so it scrolls at Pace's
## speed with no copy of the speed of its own; this script only tracks its
## own on-screen position to free itself once it has scrolled off the left
## edge. The node's origin is the bottom-center of the stalk, so Main can
## position it directly on ground_y (or bamboo_float_height above it)
## without doing its own height math. Hitbox is roughly the size of the
## picture — bamboo is generous, unlike barrels (see issue #7).

const WIDTH := 10.0
const HEIGHT := 28.0
const FREE_AT_X := -64.0
const STALK_COLOR := Color("4CAF50")
const BAND_COLOR := Color("2E7D32")
const LEAF_COLOR := Color("4CAF50")

signal eaten


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _process(_delta: float) -> void:
	if global_position.x < FREE_AT_X:
		queue_free()


func _draw() -> void:
	var stalk_rect := Rect2(Vector2(-WIDTH / 2.0, -HEIGHT), Vector2(WIDTH, HEIGHT))
	draw_rect(stalk_rect, STALK_COLOR)

	var band_height := HEIGHT / 8.0
	draw_rect(Rect2(Vector2(-WIDTH / 2.0, -HEIGHT * 0.66), Vector2(WIDTH, band_height)), BAND_COLOR)
	draw_rect(Rect2(Vector2(-WIDTH / 2.0, -HEIGHT * 0.33), Vector2(WIDTH, band_height)), BAND_COLOR)

	# A small leaf poking out near the top.
	var leaf_points := PackedVector2Array([
		Vector2(WIDTH / 2.0, -HEIGHT),
		Vector2(WIDTH / 2.0 + 8.0, -HEIGHT + 3.0),
		Vector2(WIDTH / 2.0, -HEIGHT + 6.0),
	])
	draw_polygon(leaf_points, PackedColorArray([LEAF_COLOR]))


func _on_body_entered(_body: Node2D) -> void:
	eaten.emit()
	queue_free()
