class_name GameOver
extends CanvasLayer

## Shown once Health.died fires (see #6): a semi-transparent panel over the
## whole screen with the run's final score, freezing behind it because Main
## pauses the tree at the same moment. This layer (and its input-delay
## timer) must keep running while paused, so process_mode is set to ALWAYS
## in the scene — Panda, the HUD and everything else stay on the default
## PAUSABLE mode and simply stop, which is what makes the freeze work.
##
## No reset method: restarting reloads the scene (#10), which builds a
## fresh Main, Health, Pace, Spawner and this screen hidden again.

@onready var _title_label: Label = $VBoxContainer/TitleLabel
@onready var _score_label: Label = $VBoxContainer/ScoreLabel
@onready var _prompt_label: Label = $VBoxContainer/PromptLabel
@onready var _input_delay_timer: Timer = $InputDelayTimer

var _accepting_input: bool = false


func _ready() -> void:
	visible = false
	_input_delay_timer.one_shot = true
	_input_delay_timer.timeout.connect(_on_input_delay_timeout)


## The screen's exact copy, kept as a static pure function so it's testable
## without a scene tree: the big "Game Over" line, the final score, and the
## restart prompt, in that order.
static func lines_for(score: int) -> Array[String]:
	return ["Game Over", "Score: %d" % score, "Tap to play again"]


## Shows the screen with `score`'s final tally. `jump` is ignored for the
## first `input_delay` seconds, so a tap already in progress when the last
## heart goes doesn't skip straight past the screen.
func show_game_over(score: int, input_delay: float) -> void:
	var lines: Array[String] = GameOver.lines_for(score)
	_title_label.text = lines[0]
	_score_label.text = lines[1]
	_prompt_label.text = lines[2]
	_accepting_input = false
	visible = true
	_input_delay_timer.start(input_delay)


func _on_input_delay_timeout() -> void:
	_accepting_input = true


func _unhandled_input(event: InputEvent) -> void:
	if not visible or not _accepting_input:
		return
	if event.is_action_pressed("jump"):
		get_viewport().set_input_as_handled()
		_restart()


func _restart() -> void:
	_accepting_input = false
	visible = false
	get_tree().paused = false
	get_tree().reload_current_scene()
