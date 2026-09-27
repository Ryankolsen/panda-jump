class_name ForestBackground
extends Node2D

## Repeats assets/backgrounds/bamboo_forest.png horizontally so the screen
## stays covered at any viewport width (keep_height can widen it past 480).
## The source image's left and right edges don't match, so every odd copy
## is flipped horizontally; a mirrored pair joins seamlessly and the whole
## pattern repeats every 2 copies. Scroll math lives in static functions so
## it is testable without a scene tree.

const TEXTURE_PATH := "res://assets/backgrounds/bamboo_forest.png"
const SOURCE_HEIGHT := 336.0
const VIEWPORT_HEIGHT := 270.0

var _texture: Texture2D = load(TEXTURE_PATH)
var _tile_scale: float = VIEWPORT_HEIGHT / SOURCE_HEIGHT
var _tile_width: float = 0.0
var _sprites: Array[Sprite2D] = []


func _ready() -> void:
	_tile_width = _texture.get_width() * _tile_scale
	_update_sprite_count()


## Wraps distance into [0, 2 * tile_width) — one mirrored pair — since the
## pattern beyond that repeats identically.
static func scroll_offset(distance: float, tile_width: float) -> float:
	return fposmod(distance, 2.0 * tile_width)


## Odd copy indices are the ones flipped horizontally.
static func is_mirrored(copy_index: int) -> bool:
	return copy_index % 2 == 1


## Called every frame by Main with the run's total distance so far.
func set_distance(distance: float) -> void:
	_update_sprite_count()
	position.x = -ForestBackground.scroll_offset(distance, _tile_width)


func _update_sprite_count() -> void:
	if _tile_width <= 0.0:
		return
	var viewport_width := get_viewport_rect().size.x
	# +3: one extra tile to cover the shift as the offset wraps, one more so
	# a wide (keep_height) viewport is still fully covered, and rounding up.
	var needed := int(ceil(viewport_width / _tile_width)) + 3
	while _sprites.size() < needed:
		var index := _sprites.size()
		var sprite := Sprite2D.new()
		sprite.texture = _texture
		sprite.centered = false
		sprite.scale = Vector2(_tile_scale, _tile_scale)
		sprite.flip_h = ForestBackground.is_mirrored(index)
		sprite.position = Vector2(index * _tile_width, 0.0)
		add_child(sprite)
		_sprites.append(sprite)
	while _sprites.size() > needed:
		var sprite: Sprite2D = _sprites.pop_back()
		sprite.queue_free()
