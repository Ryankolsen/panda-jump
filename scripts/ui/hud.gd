class_name Hud
extends CanvasLayer

## Draws hearts in the top-left corner, 8px from the edges. Full hearts are
## red, empty hearts are grey outlines, drawn with simple shapes (no font
## glyphs). Redrawn whenever Health emits `changed`, plus once at start so
## the initial hearts show without waiting for the first hit.

const MARGIN := 8.0
const HEART_SIZE := 16.0
const HEART_SPACING := 4.0
const FULL_COLOR := Color("E23B4A")
const EMPTY_COLOR := Color(0.6, 0.6, 0.6)

var _hearts: int
var _max_hearts: int

@onready var _hearts_control: Control = $Hearts
@onready var _score_label: Label = $ScoreLabel


func _ready() -> void:
	_hearts_control.draw.connect(_draw_hearts)


func setup(health: Health) -> void:
	_max_hearts = health.max_hearts
	_hearts = health.hearts
	health.changed.connect(_on_health_changed)
	_hearts_control.queue_redraw()
	set_score(0)


## Updates the top-right score label from the current score. Main calls
## this every frame with `pace.score`.
func set_score(score: int) -> void:
	_score_label.text = Hud.score_text(score)


## The exact text shown in the score label — a static, pure rule kept out
## of the drawing code so it's testable without a scene tree.
static func score_text(score: int) -> String:
	return "Score: %s" % NumberFormat.thousands(score)


## Returns, left to right, whether each of `max_hearts` heart slots is full
## (true) given `hearts` currently held. Never reports more full hearts than
## max_hearts even if `hearts` overshoots it.
static func heart_states(hearts: int, max_hearts: int) -> Array[bool]:
	var full := clampi(hearts, 0, max_hearts)
	var states: Array[bool] = []
	for i in range(max_hearts):
		states.append(i < full)
	return states


func _on_health_changed(hearts: int) -> void:
	_hearts = hearts
	_hearts_control.queue_redraw()


func _draw_hearts() -> void:
	var states := heart_states(_hearts, _max_hearts)
	var shape := _heart_shape(HEART_SIZE)
	for i in range(states.size()):
		var x := i * (HEART_SIZE + HEART_SPACING)
		var offset := Vector2(x, 0.0)
		var points := PackedVector2Array()
		for p in shape:
			points.append(p + offset)
		if states[i]:
			_hearts_control.draw_colored_polygon(points, FULL_COLOR)
		else:
			var outline := points.duplicate()
			outline.append(points[0])
			_hearts_control.draw_polyline(outline, EMPTY_COLOR, 2.0, true)


## A heart-shaped outline, `size` px on its longer side, with its top-left
## corner at (0, 0) — a simple shape (no font glyphs) reused for both the
## filled polygon (full hearts) and the closed outline (empty hearts).
static func _heart_shape(size: float) -> PackedVector2Array:
	var samples := 24
	var raw := PackedVector2Array()
	for i in range(samples):
		var t := 2.0 * PI * i / samples
		var x := 16.0 * pow(sin(t), 3.0)
		var y := -(13.0 * cos(t) - 5.0 * cos(2.0 * t) - 2.0 * cos(3.0 * t) - cos(4.0 * t))
		raw.append(Vector2(x, y))

	var min_v := raw[0]
	var max_v := raw[0]
	for p in raw:
		min_v.x = min(min_v.x, p.x)
		min_v.y = min(min_v.y, p.y)
		max_v.x = max(max_v.x, p.x)
		max_v.y = max(max_v.y, p.y)
	var span: float = max(max_v.x - min_v.x, max_v.y - min_v.y)
	var scale: float = size / span if span > 0.0 else 1.0

	var points := PackedVector2Array()
	for p in raw:
		points.append((p - min_v) * scale)
	return points
