class_name PauseMenu
extends CanvasLayer

## A pause button at the top centre, plus the "Paused" overlay it opens.
## The `pause` action (Escape or P) toggles too, and while paused a `jump`
## tap anywhere resumes. Like GameOver, this layer's process_mode is ALWAYS
## in the scene so it still hears input while the tree is paused.
##
## The button's focus_mode is NONE so Space (also `jump`) can never press
## it, and the overlay ignores the mouse so a resume tap reaches
## _unhandled_input instead of being swallowed by the GUI.

var _state := PauseState.new()

@onready var _button: Button = $PauseButton
@onready var _overlay: Control = $Overlay


func _ready() -> void:
	_overlay.visible = false
	_button.pressed.connect(_toggle)


## Called when the run ends: hides the button and stops pausing, leaving
## the tree's pause to Game Over.
func lock() -> void:
	_state.lock()
	_button.visible = false
	_overlay.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if _state.is_locked():
		return
	if event.is_action_pressed("pause") or (_state.paused and event.is_action_pressed("jump")):
		get_viewport().set_input_as_handled()
		_toggle()


func _toggle() -> void:
	if _state.is_locked():
		return
	_state.toggle()
	get_tree().paused = _state.paused
	_overlay.visible = _state.paused
